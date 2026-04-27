import SwiftUI

struct TimeFilterBar: View {
    @Binding var selection: HabitTimeOfDay

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HabitTimeOfDay.allCases) { tod in
                Button {
                    selection = tod
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: tod.icon)
                            .font(.system(size: 11))
                        Text(tod.displayName)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        selection == tod
                            ? tod == .allDay ? Color.accentColor : tod.accentColor
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: 6)
                    )
                    .foregroundStyle(selection == tod ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
