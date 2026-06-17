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
    }

    /// アプリを再度開いた（Finder/Spotlight 等）ときに設定ウインドウを表示する。
    /// メニューバーアイコンを非表示にしているとき、設定へ戻る経路になる。
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        return true
    }
}
