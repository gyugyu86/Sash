import XCTest
@testable import Sash

/// 座標計算（最頻出バグ箇所）の純関数ユニットテスト。
/// 配置ロジックを変更したら必ずここにケースを追加する（CLAUDE.md 検証の作法）。
final class ScreenGeometryTests: XCTestCase {

    // MARK: - flipY（Cocoa ⇄ Quartz の Y 反転）

    func testFlipYConvertsCocoaToQuartz() {
        let primaryHeight: CGFloat = 1000
        let cocoa = CGRect(x: 100, y: 200, width: 300, height: 400)
        // Quartz の y = primaryHeight - cocoa.y - height = 1000 - 200 - 400 = 400
        let quartz = ScreenGeometry.flipY(cocoa, primaryHeight: primaryHeight)
        XCTAssertEqual(quartz, CGRect(x: 100, y: 400, width: 300, height: 400))
    }

    func testFlipYIsSymmetric() {
        // 同じ式を 2 回かければ元に戻る（対称変換）
        let primaryHeight: CGFloat = 1440
        let cocoa = CGRect(x: 12, y: 34, width: 560, height: 780)
        let quartz = ScreenGeometry.flipY(cocoa, primaryHeight: primaryHeight)
        let back = ScreenGeometry.flipY(quartz, primaryHeight: primaryHeight)
        XCTAssertEqual(back, cocoa)
    }

    func testFlipYTopAlignedWindowMapsToQuartzOrigin() {
        // 画面上半分（Cocoa では上端に張り付く）→ Quartz では y = 0
        let primaryHeight: CGFloat = 900
        let topHalfCocoa = CGRect(x: 0, y: 450, width: 1440, height: 450)
        let quartz = ScreenGeometry.flipY(topHalfCocoa, primaryHeight: primaryHeight)
        XCTAssertEqual(quartz, CGRect(x: 0, y: 0, width: 1440, height: 450))
    }

    // MARK: - inset（ギャップ/余白の適用）

    func testInsetReducesAllFourEdges() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let result = ScreenGeometry.inset(rect, by: 10)
        XCTAssertEqual(result, CGRect(x: 10, y: 10, width: 80, height: 80))
    }

    func testInsetWithZeroGapIsIdentity() {
        let rect = CGRect(x: 5, y: 7, width: 50, height: 60)
        XCTAssertEqual(ScreenGeometry.inset(rect, by: 0), rect)
    }

    func testInsetNeverProducesNegativeSize() {
        // gap が矩形の半幅より大きくても幅・高さは負にならない
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let result = ScreenGeometry.inset(rect, by: 20)
        XCTAssertGreaterThanOrEqual(result.width, 0)
        XCTAssertGreaterThanOrEqual(result.height, 0)
    }
}
