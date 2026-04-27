import SwiftUI

struct SettingsView: View {
    @Environment(HabitViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                Text("Filter Habits")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(FilterMode.allCases) { mode in
                    Button {
                        vm.filterMode = mode
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: vm.filterMode == mode ? "largecircle.fill.circle" : "circle")
                                .foregroundStyle(vm.filterMode == mode ? Color.accentColor : .secondary)
                                .font(.system(size: 16))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.displayName)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.primary)
                                Text(mode.description)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            let loginMgr = LaunchAtLoginManager.shared
            Toggle(isOn: Binding(
                get: { loginMgr.isEnabled },
                set: { _ in loginMgr.toggle() }
            )) {
                Text("Launch at Login")
                    .font(.system(size: 13))
            }
            .toggleStyle(.checkbox)

            Spacer()
        }
        .padding(20)
        .frame(width: 300, height: 240)
    }
}
