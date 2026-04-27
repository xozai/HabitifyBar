import SwiftUI

@Observable
class HabitViewModel {
    var habits: [Habit] = []
    var filter: HabitTimeOfDay = .allDay
    var isLoading = false
    var errorMessage: String?
    var hasAPIKey: Bool { KeychainStore.load() != nil }

    var filteredHabits: [Habit] {
        guard filter != .allDay else { return habits }
        return habits.filter { $0.timeOfDayIds.contains(filter.rawValue) }
    }

    var completedCount: Int { habits.filter { $0.status == .completed }.count }
    var totalCount: Int { habits.count }

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
        // Optimistic update
        if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[idx].status = status
        }
        Task {
            do {
                try await HabitifyAPI.shared.setStatus(status, habitId: habit.id)
            } catch {
                // Revert on failure
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
        Task { await refresh() }
    }

    func clearAPIKey() {
        KeychainStore.delete()
        habits = []
    }
}
