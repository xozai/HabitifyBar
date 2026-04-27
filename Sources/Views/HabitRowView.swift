import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 10) {
                    // Color dot
                    Circle()
                        .fill(habit.hexColor)
                        .frame(width: 10, height: 10)

                    // Name
                    Text(habit.name)
                        .font(.system(size: 13))
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    Spacer()

                    // Streak badge
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

                    // Status icon
                    Image(systemName: habit.status.icon)
                        .font(.system(size: 15))
                        .foregroundStyle(habit.status.color)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                HabitChainView(habit: habit)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
