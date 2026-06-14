import SwiftUI

/// 一般設定: ログイン時起動トグルと、アクセシビリティ権限の状態表示。
struct GeneralSettingsView: View {
    @State private var launchAtLogin = LoginItem.isEnabled
    @State private var hasPermission = PermissionsManager.shared.isTrusted

    var body: some View {
        Form {
            Section {
                Toggle("Launch Sash at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        try? LoginItem.setEnabled(newValue)
                    }
            }

            Section("Accessibility Permission") {
                HStack(spacing: 8) {
                    Image(systemName: hasPermission
                          ? "checkmark.circle.fill"
                          : "exclamationmark.triangle.fill")
                        .foregroundStyle(hasPermission ? .green : .orange)
                    Text(hasPermission
                         ? "Granted"
                         : "Not granted — Sash needs permission to move windows")
                    Spacer()
                    if !hasPermission {
                        Button("Grant…") {
                            PermissionsManager.shared.requestAccess()
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        // 設定に戻ってきたタイミング（権限を付与して切り替えた後など）で状態を更新
        .onReceive(NotificationCenter.default.publisher(
            for: NSApplication.didBecomeActiveNotification)) { _ in
            hasPermission = PermissionsManager.shared.isTrusted
        }
    }
}
