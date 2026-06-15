import SwiftUI

/// 一般設定: ログイン時起動 / アクセシビリティ権限 / ギャップ（余白）/ 連続サイクル。
struct GeneralSettingsView: View {
    @State private var launchAtLogin = LoginItem.isEnabled
    @State private var hasPermission = PermissionsManager.shared.isTrusted
    @AppStorage("gap") private var gap: Double = 0              // Preferences.gap と同じ UserDefaults キー
    @AppStorage("cycleEnabled") private var cycleEnabled = true // Preferences.cycleEnabled と同じキー
    @AppStorage("monitorMemoryEnabled") private var monitorMemoryEnabled = false // Preferences と同じキー
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        Form {
            Section {
                Toggle("Launch Sash at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        try? LoginItem.setEnabled(newValue)
                    }
            }

            Section {
                Picker("Language", selection: $languageManager.language) {
                    ForEach(AppLanguage.allCases) { lang in
                        lang.labelText.tag(lang)
                    }
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

            Section("Gaps") {
                HStack {
                    Slider(value: $gap, in: 0...40, step: 2)
                    Text(verbatim: "\(Int(gap)) px")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .frame(width: 44, alignment: .trailing)
                }
                Text("Space between windows and screen edges when placing.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Cycle") {
                Toggle("Cycle width when pressing the same key", isOn: $cycleEnabled)
                Text("Pressing the same left/right key again steps the width: 1/2 → 2/3 → 1/3.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Per-Display Layouts") {
                Toggle("Remember layout per display setup", isOn: $monitorMemoryEnabled)
                Text("When you connect or disconnect a display, Sash restores the layout you last used with that display setup.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("Forget Saved Layouts") {
                    MonitorMemory.shared.forgetAll()
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
