import XCTest
@testable import Sash

/// Restore の「元の位置に戻す」挙動を支える復元先更新判定のテスト。
final class PlacementHistoryTests: XCTestCase {

    func testUpdatesWhenNoHistory() {
        // 履歴が無い（初回配置）なら現フレームを復元先にする
        XCTAssertTrue(PlacementHistory.shouldUpdateRestoreFrame(
            currentFrame: CGRect(x: 0, y: 0, width: 100, height: 100),
            lastAppliedFrame: nil))
    }

    func testKeepsRestoreFrameMidSequence() {
        // 現フレームが直近適用フレームとほぼ一致 → 連続配置の途中 → 復元先は維持
        let applied = CGRect(x: 10, y: 20, width: 800, height: 600)
        let current = CGRect(x: 11, y: 19, width: 799, height: 601) // 各成分 1px 差
        XCTAssertFalse(PlacementHistory.shouldUpdateRestoreFrame(
            currentFrame: current, lastAppliedFrame: applied))
    }

    func testUpdatesWhenUserMovedWindow() {
        // ユーザーが動かした（直近適用フレームから離れている）→ 復元先を更新
        let applied = CGRect(x: 10, y: 20, width: 800, height: 600)
        let current = CGRect(x: 300, y: 400, width: 500, height: 500)
        XCTAssertTrue(PlacementHistory.shouldUpdateRestoreFrame(
            currentFrame: current, lastAppliedFrame: applied))
    }

    func testToleranceBoundary() {
        let applied = CGRect(x: 0, y: 0, width: 100, height: 100)
        // ちょうど tolerance(2) 以内 → 維持
        XCTAssertFalse(PlacementHistory.shouldUpdateRestoreFrame(
            currentFrame: CGRect(x: 2, y: 0, width: 100, height: 100),
            lastAppliedFrame: applied, tolerance: 2))
        // tolerance 超え → 更新
        XCTAssertTrue(PlacementHistory.shouldUpdateRestoreFrame(
            currentFrame: CGRect(x: 3, y: 0, width: 100, height: 100),
            lastAppliedFrame: applied, tolerance: 2))
    }
}
