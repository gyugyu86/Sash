import AppKit

/// ディスプレイ構成ごとにウインドウ配置を覚えて復元する（monitor memory）。
///
/// Spike 段階では **メモリ保持・手動 Save/Restore** のみ（永続化と自動トリガーは製品化フェーズ）。
/// 目的は最大の不安＝「照合と frame 定着が実機で効くか」を最小構成で確かめること。
/// 構成シグネチャは `DisplayConfiguration`、照合は `LayoutMatcher`、AX は `WindowManager` に委譲。
final class MonitorMemory {
    static let shared = MonitorMemory()
    private init() {}

    /// 構成シグネチャ → そのときのウインドウ配置。
    private var store: [String: [WindowSnapshot]] = [:]

    /// 現在のディスプレイ構成のシグネチャ（NSScreen から値を抽出して純関数へ渡す）。
    private func currentSignature() -> String {
        let displays: [(id: UInt32, frame: CGRect)] = NSScreen.screens.map { screen in
            let number = (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0
            return (id: number, frame: screen.frame)
        }
        return DisplayConfiguration.signature(from: displays)
    }

    /// 現在の配置を、今のディスプレイ構成に紐づけて記録する。
    func saveCurrentLayout() {
        let snapshot = WindowManager.shared.snapshotCurrentWindows()
        guard !snapshot.isEmpty else { NSSound.beep(); return }
        store[currentSignature()] = snapshot
    }

    /// 今のディスプレイ構成に対して記録があれば復元する。
    func restoreCurrentLayout() {
        guard let saved = store[currentSignature()], !saved.isEmpty else { NSSound.beep(); return }
        WindowManager.shared.applyLayout(saved)
    }
}
