import Foundation

/// 名前付きレイアウトの一覧を JSON で永続化するストア。
///
/// 保存先: `~/Library/Application Support/Sash/layouts.json`（リスト構造なので UserDefaults より適）。
/// AX 操作は持たず、スナップショット取得は `WindowManager` に委譲する（AX は WindowManager に集約）。
final class LayoutStore: ObservableObject {
    static let shared = LayoutStore()

    @Published private(set) var layouts: [NamedLayout] = []

    private let fileURL: URL

    private init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Sash", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("layouts.json")
        load()
    }

    /// ディスクから読み込む（起動時・必要時）。
    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([NamedLayout].self, from: data) else { return }
        layouts = decoded
    }

    /// 現在開いている全ウインドウの配置を名前付きで保存する。
    /// 取得できるウインドウが無ければ何もせず false を返す。
    @discardableResult
    func saveCurrentWindows(named name: String) -> Bool {
        let windows = WindowManager.shared.snapshotCurrentWindows()
        guard !windows.isEmpty else { return false }
        layouts.append(NamedLayout(name: name, createdAt: Date(), windows: windows))
        save()
        return true
    }

    func delete(_ layout: NamedLayout) {
        layouts.removeAll { $0.id == layout.id }
        save()
    }

    func rename(_ layout: NamedLayout, to newName: String) {
        guard let idx = layouts.firstIndex(where: { $0.id == layout.id }) else { return }
        layouts[idx].name = newName
        save()
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(layouts) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
