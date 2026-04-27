import Foundation

enum APIError: LocalizedError {
    case missingAPIKey
    case badResponse(Int)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "No API key configured."
        case .badResponse(let code): return "Server returned \(code)."
        case .decodingFailed(let e): return "Could not parse response: \(e.localizedDescription)"
        }
    }
}

actor HabitifyAPI {
    static let shared = HabitifyAPI()
    private let baseURL = URL(string: "https://api.habitify.me/v2")!

    private var apiKey: String {
        get throws {
            guard let key = KeychainStore.load(), !key.isEmpty else { throw APIError.missingAPIKey }
            return key
        }
    }

    private func request(_ path: String, method: String = "GET", query: [String: String] = [:], body: [String: Any]? = nil) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        var req = URLRequest(url: components.url!)
        req.httpMethod = method
        req.setValue(try apiKey, forHTTPHeaderField: "X-API-Key")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body {
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return req
    }

    func fetchHabits(for date: Date = .now) async throws -> [Habit] {
        let req = try request("habits/journal", query: ["date": isoDate(date)])
        let (data, resp) = try await URLSession.shared.data(for: req)
        try validate(resp)
        do {
            let decoded = try JSONDecoder().decode(HabitsResponse.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    func setStatus(_ status: HabitStatus, for habit: Habit, date: Date = .now) async throws {
        switch status {
        case .completed:
            // For manual/rep-based habits, log the target value to instantly complete.
            // Fall back to the boolean complete endpoint for habits without a target.
            if let progress = habit.progress, progress.target > 0, let unit = progress.unit {
                let req = try request("habits/\(habit.id)/logs", method: "POST", body: [
                    "value": progress.target,
                    "unitSymbol": unit,
                    "targetDate": isoDate(date)
                ])
                let (_, resp) = try await URLSession.shared.data(for: req)
                try validate(resp)
            } else {
                let req = try request("habits/\(habit.id)/logs/complete", method: "POST",
                                      body: ["targetDate": isoDate(date)])
                let (_, resp) = try await URLSession.shared.data(for: req)
                try validate(resp)
            }
        case .failed:
            let req = try request("habits/\(habit.id)/logs/failed", method: "POST",
                                  body: ["targetDate": isoDate(date)])
            let (_, resp) = try await URLSession.shared.data(for: req)
            try validate(resp)
        case .skipped:
            let req = try request("habits/\(habit.id)/logs/skipped", method: "POST",
                                  body: ["targetDate": isoDate(date)])
            let (_, resp) = try await URLSession.shared.data(for: req)
            try validate(resp)
        case .inprogress:
            return
        }
    }

    func removeStatus(habitId: String, date: Date = .now) async throws {
        let req = try request("habits/\(habitId)/logs/undo", method: "POST",
                              body: ["targetDate": isoDate(date)])
        let (_, resp) = try await URLSession.shared.data(for: req)
        try validate(resp)
    }

    func fetchChain(habitId: String, days: Int = 7) async throws -> [(Date, HabitStatus)] {
        let today = Calendar.current.startOfDay(for: .now)
        return try await withThrowingTaskGroup(of: (Date, HabitStatus)?.self) { group in
            for offset in 0..<days {
                let date = Calendar.current.date(byAdding: .day, value: -offset, to: today)!
                group.addTask {
                    let habits = try await self.fetchHabits(for: date)
                    let status = habits.first(where: { $0.id == habitId })?.status ?? .inprogress
                    return (date, status)
                }
            }
            var results: [(Date, HabitStatus)] = []
            for try await result in group {
                if let r = result { results.append(r) }
            }
            return results.sorted { $0.0 > $1.0 }
        }
    }

    private func isoDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f.string(from: Calendar.current.startOfDay(for: date))
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.badResponse(http.statusCode)
        }
    }
}
