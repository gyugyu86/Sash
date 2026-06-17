import AppKit

/// 起動時の初期化を担う。グローバルショートカット登録と初回の権限案内を行う。
/// （将来: スナップ監視の開始・初回オンボーディングもここから起動する）
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // グローバルショートカットを登録
        Shortcuts.registerAll()

        // アクセシビリティ未許可なら初回オンボーディング（ウェルカム画面）を表示。
        // 標準ダイアログは出さず、案内はこのウインドウ 1 つに集約する。
        WelcomeWindowController.shared.showIfNeeded()

        // 自動アップデート確認（既定OFF・オプトイン。ONのときだけ1日1回まで）
        maybeAutoCheckForUpdates()
    }

    /// 自動確認が有効で、前回から1日以上経っていれば GitHub の最新版を確認する。
    /// 更新があればアラートで知らせ、「ダウンロード」でリリースページを開く。
    private func maybeAutoCheckForUpdates() {
        guard Preferences.shared.autoCheckUpdates else { return }
        let now = Date().timeIntervalSince1970
        guard now - Preferences.shared.lastUpdateCheck > 24 * 60 * 60 else { return }
        Preferences.shared.lastUpdateCheck = now
        Task {
            guard case let .available(version, url) = await UpdateChecker.shared.check() else { return }
            await MainActor.run { self.presentUpdateAlert(version: version, url: url) }
        }
    }

    @MainActor
    private func presentUpdateAlert(version: String, url: URL) {
        let b = LanguageManager.shared.bundle
        let alert = NSAlert()
        alert.messageText = String(localized: "A new version is available: \(version)", bundle: b)
        alert.addButton(withTitle: String(localized: "Download", bundle: b))
        alert.addButton(withTitle: String(localized: "Later", bundle: b))
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(url)
        }
    }
}
