import AppKit

/// ディスプレイ構成ごとにウインドウ配置を覚えて、構成が戻ったとき自動復元する（monitor memory）。
///
/// 構成シグネチャは `DisplayConfiguration`、照合は `LayoutMatcher`、AX は `WindowManager` に委譲。
/// 既定は OFF（`Preferences.monitorMemoryEnabled`）。OFF の間は監視も学習も何もしない。
/// 永続化先: `~/Library/Application Support/Sash/monitor-memory.json`。
/// メニューの手動 Save/Restore はオーバーライドとして常に使える。
final class MonitorMemory {
    static let shared = MonitorMemory()

    /// 構成シグネチャ → そのときのウインドウ配置。
    private var store: [String: [WindowSnapshot]] = [:]
    private let fileURL: URL

    private var settleWork: DispatchWorkItem?
    private var saveWork: DispatchWorkItem?
    private var learnTimer: Timer?
    private var isSettling = false   // 構成変化の処理中は学習を止める

    private init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Sash", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("monitor-memory.json")
        load()
    }

    /// 起動時に AppDelegate から呼ぶ。ディスプレイ変化の監視と学習タイマーを開始する。
    func start() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
        learnTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.learnIfStable()
        }
    }

    // MARK: - 自動

    @objc private func screensChanged() {
        // 抜き差し中は通知が連続するので、落ち着くまで待ってから処理する。
        isSettling = true
        settleWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.handleSettled() }
        settleWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
    }

    private func handleSettled() {
        isSettling = false
        guard Preferences.shared.monitorMemoryEnabled,
              let saved = store[currentSignature()], !saved.isEmpty else { return }
        // 再接続後も OS がウインドウを動かし続けるため、数回当て直して定着させる。
        for delay in [0.0, 0.6, 1.2] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                WindowManager.shared.applyLayout(saved)
            }
        }
    }

    /// 構成が安定している間、現在配置を学習（その構成の「最後に使っていた配置」として更新）。
    private func learnIfStable() {
        guard Preferences.shared.monitorMemoryEnabled, !isSettling else { return }
        let snaps = WindowManager.shared.snapshotCurrentWindows()
        guard !snaps.isEmpty else { return }
        store[currentSignature()] = snaps
        saveDebounced()
    }

    // MARK: - 手動オーバーライド（メニュー）

    func saveCurrentLayout() {
        let snaps = WindowManager.shared.snapshotCurrentWindows()
        guard !snaps.isEmpty else { NSSound.beep(); return }
        store[currentSignature()] = snaps
        save()
    }

    func restoreCurrentLayout() {
        guard let saved = store[currentSignature()], !saved.isEmpty else { NSSound.beep(); return }
        WindowManager.shared.applyLayout(saved)
    }

    func forgetAll() {
        store.removeAll()
        save()
    }

    // MARK: - 構成シグネチャ

    private func currentSignature() -> String {
        let displays: [(id: UInt32, frame: CGRect)] = NSScreen.screens.map { screen in
            let number = (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0
            return (id: number, frame: screen.frame)
        }
        return DisplayConfiguration.signature(from: displays)
    }

    // MARK: - 永続化

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([String: [WindowSnapshot]].self, from: data) else { return }
        store = decoded
    }

    private func saveDebounced() {
        saveWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.save() }
        saveWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: work)
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(store) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
