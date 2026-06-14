import XCTest
@testable import Sash

/// 連続サイクル（同じ方向キー連打で 1/2 → 2/3 → 1/3）の判定ロジックのテスト。
final class CycleSequencerTests: XCTestCase {
    private let now = Date()

    func testStartsAtHalfWithNoHistory() {
        XCTAssertEqual(CycleSequencer.cycledAction(for: .leftHalf, last: nil, now: now), .leftHalf)
        XCTAssertEqual(CycleSequencer.cycledAction(for: .rightHalf, last: nil, now: now), .rightHalf)
    }

    func testLeftCycleAdvancesAndWraps() {
        XCTAssertEqual(CycleSequencer.cycledAction(for: .leftHalf, last: (.leftHalf, now), now: now), .leftTwoThirds)
        XCTAssertEqual(CycleSequencer.cycledAction(for: .leftHalf, last: (.leftTwoThirds, now), now: now), .leftThird)
        XCTAssertEqual(CycleSequencer.cycledAction(for: .leftHalf, last: (.leftThird, now), now: now), .leftHalf) // 循環
    }

    func testRightCycleAdvances() {
        XCTAssertEqual(CycleSequencer.cycledAction(for: .rightHalf, last: (.rightHalf, now), now: now), .rightTwoThirds)
        XCTAssertEqual(CycleSequencer.cycledAction(for: .rightHalf, last: (.rightTwoThirds, now), now: now), .rightThird)
    }

    func testRestartsAfterTimeout() {
        let stale = now.addingTimeInterval(-5)   // timeout(1.5s) 超え
        XCTAssertEqual(CycleSequencer.cycledAction(for: .leftHalf, last: (.leftHalf, stale), now: now), .leftHalf)
    }

    func testDifferentGroupRestarts() {
        // 直前が右サイクルなら、左半分キーは左の最初から
        XCTAssertEqual(CycleSequencer.cycledAction(for: .leftHalf, last: (.rightHalf, now), now: now), .leftHalf)
    }

    func testNonCycleActionPassesThrough() {
        XCTAssertEqual(CycleSequencer.cycledAction(for: .maximize, last: (.maximize, now), now: now), .maximize)
        XCTAssertEqual(CycleSequencer.cycledAction(for: .topHalf, last: (.topHalf, now), now: now), .topHalf)
    }
}
