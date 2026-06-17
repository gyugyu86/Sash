import XCTest
@testable import Sash

/// 更新確認のバージョン比較（`.` 区切りの数値比較）のテスト。
final class UpdateCheckerTests: XCTestCase {

    func testNewerVersions() {
        XCTAssertTrue(UpdateChecker.isNewer("1.1", than: "1.0"))
        XCTAssertTrue(UpdateChecker.isNewer("1.0.1", than: "1.0"))
        XCTAssertTrue(UpdateChecker.isNewer("2.0", than: "1.9"))
        XCTAssertTrue(UpdateChecker.isNewer("1.10", than: "1.9"))   // 数値比較（10 > 9）
    }

    func testSameOrOlderVersions() {
        XCTAssertFalse(UpdateChecker.isNewer("1.0", than: "1.0"))
        XCTAssertFalse(UpdateChecker.isNewer("1.0", than: "1.1"))
        XCTAssertFalse(UpdateChecker.isNewer("1.0", than: "1.0.1"))
        XCTAssertFalse(UpdateChecker.isNewer("1.9", than: "1.10"))
    }
}
