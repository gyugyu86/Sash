import XCTest
@testable import Sash

/// ディスプレイの並び替えと隣接選択（端で循環）のテスト。
final class DisplayMoverTests: XCTestCase {

    private let s0 = CGRect(x: 0,   y: 0, width: 100, height: 100)
    private let s1 = CGRect(x: 100, y: 0, width: 100, height: 100)
    private let s2 = CGRect(x: 200, y: 0, width: 100, height: 100)

    func testNextMovesRightAndWraps() {
        let all = [s2, s0, s1]   // 順不同でも左→右に整列される
        XCTAssertEqual(DisplayMover.adjacentVisibleFrame(current: s0, all: all, .next), s1)
        XCTAssertEqual(DisplayMover.adjacentVisibleFrame(current: s1, all: all, .next), s2)
        XCTAssertEqual(DisplayMover.adjacentVisibleFrame(current: s2, all: all, .next), s0) // 循環
    }

    func testPreviousMovesLeftAndWraps() {
        let all = [s0, s1, s2]
        XCTAssertEqual(DisplayMover.adjacentVisibleFrame(current: s0, all: all, .previous), s2) // 循環
        XCTAssertEqual(DisplayMover.adjacentVisibleFrame(current: s2, all: all, .previous), s1)
    }

    func testSingleDisplayReturnsNil() {
        XCTAssertNil(DisplayMover.adjacentVisibleFrame(current: s0, all: [s0], .next))
    }

    func testVisibleFrameAtDisplayIndexOrdersLeftToRight() {
        let all = [s2, s0, s1]   // 順不同でも左→右に整列される
        XCTAssertEqual(DisplayMover.visibleFrame(atDisplayIndex: 0, among: all), s0)
        XCTAssertEqual(DisplayMover.visibleFrame(atDisplayIndex: 1, among: all), s1)
        XCTAssertEqual(DisplayMover.visibleFrame(atDisplayIndex: 2, among: all), s2)
    }

    func testVisibleFrameAtDisplayIndexOutOfRangeReturnsNil() {
        XCTAssertNil(DisplayMover.visibleFrame(atDisplayIndex: 3, among: [s0, s1, s2]))
        XCTAssertNil(DisplayMover.visibleFrame(atDisplayIndex: -1, among: [s0]))
    }
}
