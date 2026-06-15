import XCTest
@testable import Sash

/// 保存レイアウトと現在ウインドウの対応付け（title 一致優先＋順序フォールバック）のテスト。
final class LayoutMatcherTests: XCTestCase {

    private func snap(_ bundle: String, _ title: String, _ x: CGFloat) -> WindowSnapshot {
        WindowSnapshot(bundleIdentifier: bundle, title: title, frame: CGRect(x: x, y: 0, width: 100, height: 100))
    }

    func testMatchesByBundleAndTitle() {
        let saved = [snap("com.a", "Doc1", 10), snap("com.b", "Mail", 20)]
        let current = [snap("com.b", "Mail", 0), snap("com.a", "Doc1", 0)]
        let plan = LayoutMatcher.plan(saved: saved, current: current)

        // current[1] は com.a/Doc1 → x:10、current[0] は com.b/Mail → x:20
        XCTAssertEqual(plan.count, 2)
        XCTAssertEqual(frame(in: plan, forCurrentIndex: 1)?.minX, 10)
        XCTAssertEqual(frame(in: plan, forCurrentIndex: 0)?.minX, 20)
    }

    func testFallsBackToOrderWithinSameApp() {
        // 同じアプリの 2 窓。title が変わっていても出現順で対応付ける。
        let saved = [snap("com.a", "Old A", 10), snap("com.a", "Old B", 30)]
        let current = [snap("com.a", "New A", 0), snap("com.a", "New B", 0)]
        let plan = LayoutMatcher.plan(saved: saved, current: current)

        XCTAssertEqual(plan.count, 2)
        XCTAssertEqual(frame(in: plan, forCurrentIndex: 0)?.minX, 10)
        XCTAssertEqual(frame(in: plan, forCurrentIndex: 1)?.minX, 30)
    }

    func testSkipsAppNotCurrentlyOpen() {
        let saved = [snap("com.a", "Doc", 10), snap("com.missing", "X", 99)]
        let current = [snap("com.a", "Doc", 0)]
        let plan = LayoutMatcher.plan(saved: saved, current: current)

        XCTAssertEqual(plan.count, 1)
        XCTAssertEqual(plan.first?.currentIndex, 0)
        XCTAssertEqual(plan.first?.frame.minX, 10)
    }

    func testExtraCurrentWindowsAreLeftAlone() {
        // 現在の方が窓が多い場合、余った現在窓には何もしない（保存分だけ適用）。
        let saved = [snap("com.a", "Doc", 10)]
        let current = [snap("com.a", "Doc", 0), snap("com.a", "Other", 0)]
        let plan = LayoutMatcher.plan(saved: saved, current: current)

        XCTAssertEqual(plan.count, 1)
        XCTAssertEqual(plan.first?.currentIndex, 0)
    }

    private func frame(in plan: [(currentIndex: Int, frame: CGRect)], forCurrentIndex i: Int) -> CGRect? {
        plan.first { $0.currentIndex == i }?.frame
    }
}
