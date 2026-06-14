import ApplicationServices

/// アクセシビリティ（AX）権限の確認と要求を一手に引き受ける。
///
/// Sash は他アプリのウインドウを AX で操作するため、サンドボックス無効＋AX 許可が必須。
/// 許可状態の可視化（設定画面の緑✓/橙⚠）とオンボーディングはこの型を起点にする。
final class PermissionsManager {
    static let shared = PermissionsManager()
    private init() {}

    /// このプロセスがアクセシビリティの操作を許可されているか。
    var isTrusted: Bool { AXIsProcessTrusted() }

    /// 未許可ならシステムのアクセシビリティ許可ダイアログを表示する。
    /// （`kAXTrustedCheckOptionPrompt` を true にすると初回プロンプトが出る）
    func requestAccess() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }
}
