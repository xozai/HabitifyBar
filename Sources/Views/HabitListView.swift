import SwiftUI

struct HabitListView: View {
    @Environment(HabitViewModel.self) private var vm
    @State private var expandedId: String?

    var body: some View {
        @Bindable var vm = vm
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Today")
                        .font(.headline)
                    Text("\(vm.completedCount) of \(vm.totalCount) complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if vm.isLoading {
                    ProgressView().controlSize(.small)
                } else {
                    Button {
                        Task { await vm.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }
                let loginMgr = LaunchAtLoginManager.shared
                Menu {
                    Toggle(isOn: Binding(
                        get: { loginMgr.isEnabled },
                        set: { _ in loginMgr.toggle() }
                    )) {
                        Label("Launch at Login", systemImage: "power")
                    }
                    Divider()
                    Button("Disconnect", role: .destructive) {
                        vm.clearAPIKey()
                    }
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 13))
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .help("Settings")
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 8)

            TimeFilterBar(selection: $vm.filter)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)

            if let error = vm.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
            }
            if let loginErr = LaunchAtLoginManager.shared.lastError {
                Text(loginErr)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
            }

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    if vm.filteredHabits.isEmpty && !vm.isLoading {
                        Text("No habits for this time of day")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 24)
                    }
                    ForEach(vm.filteredHabits) { habit in
                        HabitRowView(habit: habit, isExpanded: expandedId == habit.id) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                expandedId = expandedId == habit.id ? nil : habit.id
                            }
                        }
                        Divider().padding(.leading, 12)
                    }
                }
            }
            .frame(maxHeight: 420)
        }
        .task { await vm.refresh() }
    }
}
