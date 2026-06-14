import AppKit

/// 起動時の初期化を担う。グローバルショートカット登録と初回の権限案内を行う。
/// （将来: スナップ監視の開始・初回オンボーディングもここから起動する）
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // グローバルショートカットを登録
        Shortcuts.registerAll()

        // アクセシビリティ権限が無ければ初回に案内
        if !PermissionsManager.shared.isTrusted {
            PermissionsManager.shared.requestAccess()
        }
    }
}
