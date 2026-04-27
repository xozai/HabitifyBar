import SwiftUI

struct SetupView: View {
    @Environment(HabitViewModel.self) private var vm
    @State private var apiKey = ""
    @State private var isValidating = false
    @State private var validationError: String?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.green)

            Text("Connect Habitify")
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                Text("To find your API key:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Habitify → Settings → API → API Key")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SecureField("Paste your API key", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .onSubmit { connect() }

            if let error = validationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button(action: connect) {
                if isValidating {
                    ProgressView().controlSize(.small)
                } else {
                    Text("Connect")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(apiKey.isEmpty || isValidating)
        }
        .padding(16)
    }

    private func connect() {
        guard !apiKey.isEmpty else { return }
        isValidating = true
        validationError = nil
        vm.saveAPIKey(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
        // Give refresh a moment; errors surface via vm.errorMessage
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isValidating = false
            if let err = vm.errorMessage {
                validationError = err
                vm.clearAPIKey()
            }
        }
    }
}
