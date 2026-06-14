import AppKit
import ApplicationServices

/// 最前面ウインドウを Accessibility API 経由で移動・リサイズする AX エンジン。
///
/// AX 操作はこの型に閉じ込め、UI 層から AXUIElement を直接触らない（CLAUDE.md 規約）。
/// 座標変換は `ScreenGeometry`、権限は `PermissionsManager`、配置前フレームの記録は
/// `PlacementHistory`、ディスプレイ選択は `DisplayMover` に委譲する。
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
        let id = windowID(of: window)

        // 履歴ベース／ディスプレイ移動は幾何配置とは別経路で処理する
        switch action {
        case .restore:
            guard let id, let target = PlacementHistory.shared.restoreFrame(for: id) else {
                NSSound.beep()
                return
            }
            setFrame(target, for: window)
            return
        case .moveToPreviousDisplay:
            moveToDisplay(window: window, currentQuartz: currentQuartz, direction: .previous)
            return
        case .moveToNextDisplay:
            moveToDisplay(window: window, currentQuartz: currentQuartz, direction: .next)
            return
        default:
            break
        }

        // 幾何配置: 現在のディスプレイの visibleFrame を基準に目標矩形を求める
        let primaryH = ScreenGeometry.primaryHeight()
        let currentCocoa = ScreenGeometry.flipY(currentQuartz, primaryHeight: primaryH)
        let screen = ScreenGeometry.screen(containingCocoa: currentCocoa) ?? NSScreen.main
        guard let visible = screen?.visibleFrame,
              let targetCocoa = action.targetFrame(visibleFrame: visible,
                                                   gap: CGFloat(Preferences.shared.gap)) else { return }
        let targetQuartz = ScreenGeometry.flipY(targetCocoa, primaryHeight: primaryH)

        // 配置前フレームを記録 → 適用 → 実際に適用されたフレームを記録（Restore 用）
        if let id { PlacementHistory.shared.recordBeforePlacement(currentFrame: currentQuartz, for: id) }
        setFrame(targetQuartz, for: window)
        if let id {
            let applied = frame(of: window) ?? targetQuartz
            PlacementHistory.shared.recordApplied(frame: applied, for: id)
        }
    }

    /// 最前面ウインドウを隣のディスプレイへ、比率を保って移動する。
    private func moveToDisplay(window: AXUIElement, currentQuartz: CGRect, direction: DisplayMover.Direction) {
        let primaryH = ScreenGeometry.primaryHeight()
        let currentCocoa = ScreenGeometry.flipY(currentQuartz, primaryHeight: primaryH)
        guard let currentScreen = ScreenGeometry.screen(containingCocoa: currentCocoa) else {
            NSSound.beep()
            return
        }
        let allVisible = NSScreen.screens.map { $0.visibleFrame }
        guard let targetVisible = DisplayMover.adjacentVisibleFrame(current: currentScreen.visibleFrame,
                                                                    all: allVisible, direction) else {
            NSSound.beep()   // ディスプレイが 1 枚 等で移動先が無い
            return
        }
        let targetCocoa = ScreenGeometry.proportionalFrame(currentCocoa,
                                                           from: currentScreen.visibleFrame, to: targetVisible)
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

    /// ウインドウの安定識別子（CGWindowID）。非公開 API `_AXUIElementGetWindow` で取得する。
    /// 公開ヘッダに無いが ApplicationServices に存在し、Rectangle / yabai も用いる事実上の標準。
    /// 直接配布(非MAS)アプリなので使用上の問題はない（宣言は Sash-Bridging-Header.h）。
    private func windowID(of window: AXUIElement) -> CGWindowID? {
        var id: CGWindowID = 0
        return _AXUIElementGetWindow(window, &id) == .success ? id : nil
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
