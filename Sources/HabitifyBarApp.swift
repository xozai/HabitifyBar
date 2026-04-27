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
            MenuBarLabelView(completed: viewModel.completedCount, total: viewModel.totalCount)
                .environment(viewModel)
        }
        .menuBarExtraStyle(.window)

        Window("Settings", id: "settings") {
            SettingsView()
                .environment(viewModel)
        }
        .defaultSize(width: 300, height: 240)
        .windowResizability(.contentSize)
    }
}

struct MenuBarLabelView: View {
    let completed: Int
    let total: Int
    @Environment(\.openWindow) private var openWindow
    @Environment(HabitViewModel.self) private var vm

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
            if total > 0 {
                Text("\(completed)/\(total)")
                    .font(.system(size: 11, weight: .medium))
            }
        }
        .contextMenu {
            Button("Settings…") {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "settings")
            }
            Divider()
            Button("Log Out") { vm.clearAPIKey() }
            Button("Quit HabitifyBar") { NSApp.terminate(nil) }
        }
    }
}
