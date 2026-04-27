import SwiftUI

enum HabitTimeOfDay: String, CaseIterable, Identifiable {
    case allDay = ""
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .allDay: return "All"
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        }
    }

    var icon: String {
        switch self {
        case .allDay: return "list.bullet"
        case .morning: return "cloud.sun.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .allDay: return .primary
        case .morning: return Color(hex: "#2AA8D0") ?? .blue
        case .afternoon: return Color(hex: "#E0861D") ?? .orange
        case .evening: return Color(hex: "#992AC0") ?? .purple
        }
    }
}
