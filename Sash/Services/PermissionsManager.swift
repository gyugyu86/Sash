import ApplicationServices
import AppKit

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

    /// 標準ダイアログを出さずに Sash を「アクセシビリティ」許可リストへ登録する。
    /// 未許可のまま AX を一度呼ぶと、システムがアプリをリスト（オフ状態）へ追加するため、
    /// オンボーディングで設定ペインを開いたときユーザーが Sash をすぐ見つけてオンにできる。
    /// `requestAccess()`（標準プロンプト）と違い、ウインドウが増えない。
    func registerInAccessibilityList() {
        guard !isTrusted else { return }
        let systemWide = AXUIElementCreateSystemWide()
        var value: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &value)
    }

    /// システム設定の「プライバシーとセキュリティ → アクセシビリティ」ペインを開く。
    /// ユーザーが Sash をリストでオンにできるよう、オンボーディングや設定画面から呼ぶ。
    func openAccessibilitySettings() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
