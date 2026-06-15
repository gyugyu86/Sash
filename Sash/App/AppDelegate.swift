import AppKit

/// 起動時の初期化を担う。グローバルショートカット登録と初回の権限案内を行う。
/// （将来: スナップ監視の開始・初回オンボーディングもここから起動する）
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // グローバルショートカットを登録
        Shortcuts.registerAll()

        // monitor memory: ディスプレイ変化の監視と配置学習を開始（既定 OFF。Preferences で有効化）。
        MonitorMemory.shared.start()

        // アクセシビリティ未許可なら初回オンボーディング（ウェルカム画面）を表示。
        // 標準ダイアログは出さず、案内はこのウインドウ 1 つに集約する。
        WelcomeWindowController.shared.showIfNeeded()
    }
}
