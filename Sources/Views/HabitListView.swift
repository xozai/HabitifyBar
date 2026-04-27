import SwiftUI

struct HabitListView: View {
    @Environment(HabitViewModel.self) private var vm
    @Environment(\.openWindow) private var openWindow

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
                Menu {
                    Button("Settings…") {
                        NSApp.activate(ignoringOtherApps: true)
                        openWindow(id: "settings")
                    }
                    Divider()
                    Button("Log Out") { vm.clearAPIKey() }
                    Button("Quit HabitifyBar") { NSApp.terminate(nil) }
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

            if vm.filterMode == .byTimeOfDay {
                TimeFilterBar(selection: $vm.filter)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }

            if let error = vm.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
            }

            Divider()

            let rowHeight: CGFloat = 38
            let habitCount = vm.filteredHabits.count

            if habitCount == 0 && !vm.isLoading {
                Text("No habits to show")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
            } else if habitCount <= 5 {
                VStack(spacing: 0) {
                    ForEach(vm.filteredHabits) { habit in
                        HabitRowView(habit: habit)
                        Divider().padding(.leading, 12)
                    }
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.filteredHabits) { habit in
                            HabitRowView(habit: habit)
                            Divider().padding(.leading, 12)
                        }
                    }
                }
                .frame(height: rowHeight * 5)
            }
        }
        .task { await vm.refresh() }
    }
}
