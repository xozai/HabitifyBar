import SwiftUI

@main
struct HabitifyBarApp: App {
    @State private var viewModel = HabitViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarRootView()
                .environment(viewModel)
                .frame(width: 340)
        } label: {
            MenuBarLabel(completed: viewModel.completedCount, total: viewModel.totalCount)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    let completed: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
            if total > 0 {
                Text("\(completed)/\(total)")
                    .font(.system(size: 11, weight: .medium))
            }
        }
    }
}
