import SwiftUI

@Observable
class HabitViewModel {
    var habits: [Habit] = []
    var filter: HabitTimeOfDay = .allDay
    var isLoading = false
    var errorMessage: String?
    var isAuthenticated: Bool = KeychainStore.load() != nil

    var filterMode: FilterMode = FilterMode(rawValue: UserDefaults.standard.string(forKey: "filterMode") ?? "") ?? .allHabits {
        didSet { UserDefaults.standard.set(filterMode.rawValue, forKey: "filterMode") }
    }

    var filteredHabits: [Habit] {
        switch filterMode {
        case .allHabits:
            return habits
        case .currentTimeOfDay:
            let tof = autoTimeOfDay
            return habits.filter { $0.timeOfDayIds.contains(tof.rawValue) }
        case .byTimeOfDay:
            guard filter != .allDay else { return habits }
            return habits.filter { $0.timeOfDayIds.contains(filter.rawValue) }
        }
    }

    var completedCount: Int { habits.filter { $0.status == .completed }.count }
    var totalCount: Int { habits.count }

    private var autoTimeOfDay: HabitTimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return .morning
        case 12..<17: return .afternoon
        default:      return .evening
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        do {
            habits = try await HabitifyAPI.shared.fetchHabits()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func mark(_ habit: Habit, as status: HabitStatus) {
        if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[idx].status = status
        }
        Task {
            do {
                try await HabitifyAPI.shared.setStatus(status, for: habit)
            } catch {
                await MainActor.run {
                    if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
                        habits[idx].status = habit.status
                    }
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func undo(_ habit: Habit) {
        if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[idx].status = .inprogress
        }
        Task {
            do {
                try await HabitifyAPI.shared.removeStatus(habitId: habit.id)
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchChain(for habit: Habit) async -> [(Date, HabitStatus)] {
        (try? await HabitifyAPI.shared.fetchChain(habitId: habit.id)) ?? []
    }

    func saveAPIKey(_ key: String) {
        KeychainStore.save(key)
        isAuthenticated = true
        Task { await refresh() }
    }

    func clearAPIKey() {
        KeychainStore.delete()
        isAuthenticated = false
        habits = []
        errorMessage = nil
    }
}
