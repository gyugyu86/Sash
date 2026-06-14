import ServiceManagement

/// ログイン時起動（macOS 13+ の SMAppService）。
enum LoginItem {
    static var isEnabled: Bool { SMAppService.mainApp.status == .enabled }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            if SMAppService.mainApp.status != .enabled {
                try SMAppService.mainApp.register()
            }
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
