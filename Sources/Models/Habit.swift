import Foundation
import SwiftUI

enum HabitStatus: String, Codable {
    case inprogress
    case completed
    case failed
    case skipped

    var icon: String {
        switch self {
        case .inprogress: return "circle"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .skipped: return "arrow.right.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .inprogress: return .secondary
        case .completed: return .green
        case .failed: return .red
        case .skipped: return .secondary
        }
    }
}

struct Streak: Codable {
    let length: Int
    let unit: String?
}

struct HabitProgress: Codable {
    let current: Double
    let target: Double
    let unit: String?
    let periodicity: String?
}

struct Habit: Codable, Identifiable {
    let id: String
    let name: String
    var status: HabitStatus
    let color: String
    let timeOfDayIds: [String]
    let type: String
    let currentStreak: Streak
    let progress: HabitProgress?

    var primaryTimeOfDay: HabitTimeOfDay {
        guard let first = timeOfDayIds.first else { return .allDay }
        return HabitTimeOfDay(rawValue: first) ?? .allDay
    }

    var hexColor: Color {
        Color(hex: color) ?? .accentColor
    }
}

struct HabitsResponse: Codable {
    let data: [Habit]
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
