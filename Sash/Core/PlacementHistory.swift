import CoreGraphics
import Foundation

/// ウインドウごとに「配置前のフレーム」と「直前アクション+時刻」を保持する。
///
/// キーは CGWindowID（`WindowManager` が `_AXUIElementGetWindow` で取得）。
/// 復元方針は「元の位置に戻す」: 連続配置の途中では復元先を上書きせず、ユーザーが自分で
/// ウインドウを動かした（＝現フレームが直近に Sash が設定したフレームと違う）ときだけ更新する。
/// 直前アクション+時刻は連続サイクル（CycleSequencer）の判定に使う。
/// 判定は純関数 `shouldUpdateRestoreFrame` に切り出してユニットテストする。
/// フレームはすべて Quartz 座標（AX ネイティブ）で保持する。
final class PlacementHistory {
    static let shared = PlacementHistory()
    private init() {}

    private struct Entry {
        var restoreFrame: CGRect          // 復元先（配置前フレーム）
        var lastAppliedFrame: CGRect?     // 直近に Sash が適用したフレーム（連続配置の判定用）
        var lastAction: WindowAction?     // 直近に適用したアクション（サイクル判定用）
        var lastActionTime: Date?         // 同上の時刻
    }
    private var entries: [CGWindowID: Entry] = [:]

    /// 復元先を更新すべきか。履歴が無い／ユーザーが動かした（現フレームが直近適用フレームから
    /// tolerance を超えて離れている）ときだけ true。連続配置の途中では false。純関数。
    static func shouldUpdateRestoreFrame(currentFrame: CGRect,
                                         lastAppliedFrame: CGRect?,
                                         tolerance: CGFloat = 2) -> Bool {
        guard let last = lastAppliedFrame else { return true }
        return !currentFrame.isApproximatelyEqual(to: last, tolerance: tolerance)
    }

    /// 配置を適用する直前に呼ぶ。必要なら復元先（配置前フレーム）を更新する。
    /// 直前アクション+時刻は維持する。
    func recordBeforePlacement(currentFrame: CGRect, for id: CGWindowID) {
        let existing = entries[id]
        guard Self.shouldUpdateRestoreFrame(currentFrame: currentFrame,
                                            lastAppliedFrame: existing?.lastAppliedFrame) else { return }
        entries[id] = Entry(restoreFrame: currentFrame,
                            lastAppliedFrame: existing?.lastAppliedFrame,
                            lastAction: existing?.lastAction,
                            lastActionTime: existing?.lastActionTime)
    }

    /// 配置を適用した直後に呼ぶ。実際に適用されたフレーム・アクション・時刻を記録する。
    func recordApplied(frame: CGRect, action: WindowAction, for id: CGWindowID) {
        entries[id]?.lastAppliedFrame = frame
        entries[id]?.lastAction = action
        entries[id]?.lastActionTime = Date()
    }

    /// Restore の復元先（Quartz 座標）。履歴が無ければ nil。
    func restoreFrame(for id: CGWindowID) -> CGRect? {
        entries[id]?.restoreFrame
    }

    /// 直前に適用したアクションと時刻（連続サイクルの判定に使う）。
    func lastAction(for id: CGWindowID) -> (action: WindowAction, time: Date)? {
        guard let e = entries[id], let action = e.lastAction, let time = e.lastActionTime else { return nil }
        return (action, time)
    }
}

private extension CGRect {
    /// 各成分の差が tolerance 以内なら「ほぼ同じ矩形」とみなす。
    func isApproximatelyEqual(to other: CGRect, tolerance: CGFloat) -> Bool {
        abs(minX - other.minX) <= tolerance &&
        abs(minY - other.minY) <= tolerance &&
        abs(width - other.width) <= tolerance &&
        abs(height - other.height) <= tolerance
    }
}
