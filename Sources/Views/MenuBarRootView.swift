import SwiftUI

struct MenuBarRootView: View {
    @Environment(HabitViewModel.self) private var vm

    var body: some View {
        if vm.hasAPIKey {
            HabitListView()
        } else {
            SetupView()
        }
    }
}
