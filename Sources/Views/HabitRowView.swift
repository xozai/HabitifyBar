import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @State private var showingPopover = false
    @Environment(HabitViewModel.self) private var vm

    var body: some View {
        Button {
            showingPopover = true
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(habit.hexColor)
                    .frame(width: 10, height: 10)

                Text(habit.name)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Spacer()

                if habit.currentStreak.length > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                        Text("\(habit.currentStreak.length)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.orange)
                    }
                }

                Image(systemName: habit.status.icon)
                    .font(.system(size: 15))
                    .foregroundStyle(habit.status.color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showingPopover, arrowEdge: .trailing) {
            HabitActionPopover(habit: habit)
                .environment(vm)
        }
    }
}

struct HabitActionPopover: View {
    let habit: Habit
    @Environment(HabitViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 10) {
            Text(habit.name)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)

            if habit.status == .inprogress {
                HStack(spacing: 12) {
                    HabitActionButton(label: "Done", icon: "checkmark.circle.fill", color: .green) {
                        vm.mark(habit, as: .completed)
                        dismiss()
                    }
                    HabitActionButton(label: "Fail", icon: "xmark.circle.fill", color: .red) {
                        vm.mark(habit, as: .failed)
                        dismiss()
                    }
                    HabitActionButton(label: "Skip", icon: "arrow.right.circle.fill", color: .secondary) {
                        vm.mark(habit, as: .skipped)
                        dismiss()
                    }
                }
            } else {
                Button("Undo") {
                    vm.undo(habit)
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(14)
    }
}

struct HabitActionButton: View {
    let label: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 52)
        }
        .buttonStyle(.plain)
    }
}
