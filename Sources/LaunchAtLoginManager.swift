import Foundation
import ServiceManagement

@Observable
final class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()
    var lastError: String?

    var isEnabled: Bool { SMAppService.mainApp.status == .enabled }

    func toggle() {
        lastError = nil
        do {
            if isEnabled { try SMAppService.mainApp.unregister() }
            else          { try SMAppService.mainApp.register()   }
        } catch {
            lastError = error.localizedDescription
        }
    }
}
