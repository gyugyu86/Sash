import AppKit
import ApplicationServices

/// 最前面ウインドウを Accessibility API 経由で移動・リサイズする AX エンジン。
///
/// AX 操作はこの型に閉じ込め、UI 層から AXUIElement を直接触らない（CLAUDE.md 規約）。
/// 座標変換は `ScreenGeometry`、権限は `PermissionsManager` に委譲する。
final class WindowManager {
    static let shared = WindowManager()
    private init() {}

    // MARK: - アクション適用

    func apply(_ action: WindowAction) {
        guard PermissionsManager.shared.isTrusted else {
            PermissionsManager.shared.requestAccess()
            return
        }
        guard let window = focusedWindow(),
              let currentQuartz = frame(of: window) else {
            NSSound.beep()
            return
        }

        let primaryH = ScreenGeometry.primaryHeight()
        // 現在位置を Cocoa 座標へ → ウインドウのある画面を特定
        let currentCocoa = ScreenGeometry.flipY(currentQuartz, primaryHeight: primaryH)
        let screen = ScreenGeometry.screen(containingCocoa: currentCocoa) ?? NSScreen.main
        guard let visible = screen?.visibleFrame else { return }

        // 目標矩形（Cocoa）→ Quartz に戻して適用
        let targetCocoa = action.targetFrame(visibleFrame: visible, currentSize: currentCocoa.size)
        let targetQuartz = ScreenGeometry.flipY(targetCocoa, primaryHeight: primaryH)
        setFrame(targetQuartz, for: window)
    }

    // MARK: - AX ヘルパー

    private func focusedWindow() -> AXUIElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            appElement, kAXFocusedWindowAttribute as CFString, &windowRef
        )
        guard result == .success, let windowRef else { return nil }
        // CFTypeRef の実体は AXUIElement
        return (windowRef as! AXUIElement)
    }

    /// ウインドウの現在矩形（Quartz 座標：左上原点・Y は下方向）
    private func frame(of window: AXUIElement) -> CGRect? {
        var posRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posRef) == .success,
              AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef) == .success
        else { return nil }

        var point = CGPoint.zero
        var size = CGSize.zero
        AXValueGetValue(posRef as! AXValue, .cgPoint, &point)
        AXValueGetValue(sizeRef as! AXValue, .cgSize, &size)
        return CGRect(origin: point, size: size)
    }

    /// 最小サイズ制約を持つアプリのために position → size → position の順で適用する。
    private func setFrame(_ rect: CGRect, for window: AXUIElement) {
        var origin = rect.origin
        var size = rect.size
        guard let posValue = AXValueCreate(.cgPoint, &origin),
              let sizeValue = AXValueCreate(.cgSize, &size) else { return }

        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, posValue)
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, posValue)
    }
}
