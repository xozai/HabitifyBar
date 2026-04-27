import Foundation

enum FilterMode: String, CaseIterable, Identifiable {
    case allHabits
    case currentTimeOfDay
    case byTimeOfDay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .allHabits:        return "All Habits"
        case .currentTimeOfDay: return "Current Time of Day"
        case .byTimeOfDay:      return "By Time of Day"
        }
    }

    var description: String {
        switch self {
        case .allHabits:        return "Show every habit regardless of time"
        case .currentTimeOfDay: return "Auto-select based on time of day"
        case .byTimeOfDay:      return "Choose Morning, Afternoon, or Evening"
        }
    }
}
