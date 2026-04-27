import SwiftUI

struct HabitChainView: View {
    @Environment(HabitViewModel.self) private var vm
    let habit: Habit

    @State private var chain: [(Date, HabitStatus)] = []
    @State private var isLoadingChain = false

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()

    private var currentStatus: HabitStatus {
        vm.habits.first(where: { $0.id == habit.id })?.status ?? habit.status
    }

    var body: some View {
        VStack(spacing: 10) {
            // 7-day chain dots
            if isLoadingChain {
                ProgressView().controlSize(.small).padding(.vertical, 8)
            } else {
                HStack(spacing: 6) {
                    ForEach(Array(chain.enumerated()), id: \.offset) { idx, entry in
                        let (date, status) = entry
                        let isToday = Calendar.current.isDateInToday(date)
                        VStack(spacing: 3) {
                            ZStack {
                                Circle()
                                    .stroke(isToday ? Color.primary : Color.clear, lineWidth: 1.5)
                                    .frame(width: 26, height: 26)
                                Circle()
                                    .fill(chainColor(status))
                                    .frame(width: isToday ? 20 : 22, height: isToday ? 20 : 22)
                                if status != .inprogress {
                                    Image(systemName: chainIcon(status))
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            Text(dayFormatter.string(from: date))
                                .font(.system(size: 9))
                                .foregroundStyle(isToday ? .primary : .secondary)
                            Text(dateFormatter.string(from: date))
                                .font(.system(size: 9))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            Divider()

            // Action buttons for today
            HStack(spacing: 8) {
                ActionButton(label: "Done", icon: "checkmark", color: .green,
                             isActive: currentStatus == .completed) {
                    if currentStatus == .completed {
                        vm.undo(habit)
                    } else {
                        vm.mark(habit, as: .completed)
                    }
                }
                ActionButton(label: "Fail", icon: "xmark", color: .red,
                             isActive: currentStatus == .failed) {
                    if currentStatus == .failed {
                        vm.undo(habit)
                    } else {
                        vm.mark(habit, as: .failed)
                    }
                }
                ActionButton(label: "Skip", icon: "arrow.right", color: .secondary,
                             isActive: currentStatus == .skipped) {
                    if currentStatus == .skipped {
                        vm.undo(habit)
                    } else {
                        vm.mark(habit, as: .skipped)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .background(.quinary, in: RoundedRectangle(cornerRadius: 0))
        .task { await loadChain() }
    }

    private func loadChain() async {
        isLoadingChain = true
        chain = await vm.fetchChain(for: habit)
        isLoadingChain = false
    }

    private func chainColor(_ status: HabitStatus) -> Color {
        switch status {
        case .completed: return .green
        case .failed: return .red
        case .skipped: return Color.gray.opacity(0.4)
        case .inprogress: return Color.gray.opacity(0.15)
        }
    }

    private func chainIcon(_ status: HabitStatus) -> String {
        switch status {
        case .completed: return "checkmark"
        case .failed: return "xmark"
        case .skipped: return "arrow.right"
        case .inprogress: return ""
        }
    }
}

struct ActionButton: View {
    let label: String
    let icon: String
    let color: Color
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: isActive ? "arrow.uturn.backward" : icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(isActive ? "Undo" : label)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(isActive ? color.opacity(0.15) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isActive ? color : Color.secondary.opacity(0.4), lineWidth: 1)
            )
            .foregroundStyle(isActive ? color : .primary)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
