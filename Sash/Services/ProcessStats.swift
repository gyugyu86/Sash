import Foundation
import Darwin

/// 自プロセス（Sash）のメモリ・CPU 使用量を公開 Mach API で取得する。
///
/// Activity Monitor を見なくても Sash 単体の状態を確認できるようにするための補助。
/// すべて自プロセス内の軽量な `task_info` / `thread_info` 呼び出しで、権限不要・サンドボックス非依存。
enum ProcessStats {
    /// メモリ使用量（MB, phys_footprint ＝ Activity Monitor の「メモリ」相当）。失敗時 nil。
    static func memoryFootprintMB() -> Double? {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return nil }
        return Double(info.phys_footprint) / (1024 * 1024)
    }

    /// CPU 使用率（%）。アイドルでない全スレッドの `cpu_usage` を合算。失敗時 nil。
    static func cpuUsagePercent() -> Double? {
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t(0)
        guard task_threads(mach_task_self_, &threadList, &threadCount) == KERN_SUCCESS,
              let threadList else { return nil }
        defer {
            vm_deallocate(mach_task_self_,
                          vm_address_t(UInt(bitPattern: UnsafeRawPointer(threadList))),
                          vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.stride))
        }

        var total: Double = 0
        let infoCount = mach_msg_type_number_t(MemoryLayout<thread_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
        for i in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var count = infoCount
            let kr = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    thread_info(threadList[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
                }
            }
            if kr == KERN_SUCCESS, (info.flags & TH_FLAGS_IDLE) == 0 {
                total += Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
            }
        }
        return total
    }
}
