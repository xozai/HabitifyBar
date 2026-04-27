import SwiftUI

struct MenuBarRootView: View {
    @Environment(HabitViewModel.self) private var vm

    var body: some View {
        if vm.isAuthenticated {
            HabitListView()
        } else {
            SetupView()
        }
    }
}
