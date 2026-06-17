import SwiftUI

/// 一般設定: ログイン時起動 / アクセシビリティ権限 / ギャップ（余白）/ 連続サイクル。
struct GeneralSettingsView: View {
    @State private var launchAtLogin = LoginItem.isEnabled
    @State private var hasPermission = PermissionsManager.shared.isTrusted
    @AppStorage("gap") private var gap: Double = 0              // Preferences.gap と同じ UserDefaults キー
    @AppStorage("cycleEnabled") private var cycleEnabled = true // Preferences.cycleEnabled と同じキー
    @AppStorage("autoCheckUpdates") private var autoCheckUpdates = false // Preferences と同じキー
    @State private var updateState: UpdateState = .idle
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

            Section("Updates") {
                Toggle("Automatically check for updates", isOn: $autoCheckUpdates)
                Text("When on, Sash contacts GitHub to fetch only the latest version number — no personal data is sent. Off by default.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("Check for Updates…") { checkForUpdates() }
                updateStatus
            }
        }
        .formStyle(.grouped)
        // 設定に戻ってきたタイミング（権限を付与して切り替えた後など）で状態を更新
        .onReceive(NotificationCenter.default.publisher(
            for: NSApplication.didBecomeActiveNotification)) { _ in
            hasPermission = PermissionsManager.shared.isTrusted
        }
    }

    /// 手動「Check for Updates」の結果表示。
    @ViewBuilder private var updateStatus: some View {
        switch updateState {
        case .idle:
            EmptyView()
        case .checking:
            Text("Checking…").foregroundStyle(.secondary)
        case .upToDate:
            Label("You're up to date.", systemImage: "checkmark.circle").foregroundStyle(.secondary)
        case .available(let version, let url):
            HStack {
                Text("A new version is available: \(version)")
                Spacer()
                Button("Download") { NSWorkspace.shared.open(url) }
            }
        case .failed:
            Text("Couldn't check for updates.").foregroundStyle(.secondary)
        }
    }

    private func checkForUpdates() {
        updateState = .checking
        Task {
            let result = await UpdateChecker.shared.check()
            await MainActor.run { updateState = result }
        }
    }
}
