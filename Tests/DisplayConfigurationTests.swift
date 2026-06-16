import XCTest
@testable import Sash

/// ディスプレイ構成シグネチャの安定性テスト（順不同で同一・構成が変われば別物）。
final class DisplayConfigurationTests: XCTestCase {

    private let d1: (id: UInt32, frame: CGRect) = (1, CGRect(x: 0, y: 0, width: 1440, height: 900))
    private let d2: (id: UInt32, frame: CGRect) = (2, CGRect(x: 1440, y: 0, width: 1920, height: 1080))

    func testSameSetIsOrderIndependent() {
        let a = DisplayConfiguration.signature(from: [d1, d2])
        let b = DisplayConfiguration.signature(from: [d2, d1])
        XCTAssertEqual(a, b)
    }

    func testDifferentDisplaySetsDiffer() {
        let single = DisplayConfiguration.signature(from: [d1])
        let dual = DisplayConfiguration.signature(from: [d1, d2])
        XCTAssertNotEqual(single, dual)
    }

    func testResolutionChangeChangesSignature() {
        let original = DisplayConfiguration.signature(from: [d1])
        let scaled = DisplayConfiguration.signature(from: [(id: 1, frame: CGRect(x: 0, y: 0, width: 1280, height: 800))])
        XCTAssertNotEqual(original, scaled)
    }
}
