import XCTest
@testable import Sash

/// 自プロセスの使用量取得が妥当な値を返すことの最小限の健全性テスト。
final class ProcessStatsTests: XCTestCase {

    func testMemoryFootprintIsPositive() {
        let mb = ProcessStats.memoryFootprintMB()
        XCTAssertNotNil(mb)
        XCTAssertGreaterThan(mb ?? 0, 0)   // 実行中プロセスのメモリは必ず正
    }

    func testCPUUsageIsNonNegative() {
        let cpu = ProcessStats.cpuUsagePercent()
        XCTAssertNotNil(cpu)
        XCTAssertGreaterThanOrEqual(cpu ?? -1, 0)
    }
}
