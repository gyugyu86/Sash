import CoreGraphics

/// 保存したレイアウトと現在のウインドウ群を対応付ける純ロジック（monitor memory の核）。
///
/// 同定の難所をここに閉じ込めてユニットテストする。方針:
///  1. 同じ bundleIdentifier の中で title が完全一致するものを優先的に対応付ける。
///  2. 余った保存ウインドウは、同じアプリの余った現在ウインドウへ出現順でフォールバック対応。
///  3. 保存側に居て現在側に居ないアプリ（未起動など）はスキップ。
enum LayoutMatcher {
    /// 復元計画。`current` の index と、そこへ適用すべき保存フレームの組を返す。純関数。
    static func plan(saved: [WindowSnapshot], current: [WindowSnapshot]) -> [(currentIndex: Int, frame: CGRect)] {
        // 現在ウインドウの index を bundleID ごとに出現順で保持
        var currentByBundle: [String: [Int]] = [:]
        for (i, w) in current.enumerated() {
            currentByBundle[w.bundleIdentifier, default: []].append(i)
        }
        // 保存ウインドウを bundleID ごとに出現順で保持
        var savedByBundle: [String: [WindowSnapshot]] = [:]
        for w in saved {
            savedByBundle[w.bundleIdentifier, default: []].append(w)
        }

        var result: [(currentIndex: Int, frame: CGRect)] = []
        for (bundle, savedWindows) in savedByBundle {
            guard var candidates = currentByBundle[bundle], !candidates.isEmpty else { continue }
            var remaining = savedWindows

            // 1) title 完全一致を先に消化
            var i = 0
            while i < remaining.count {
                let s = remaining[i]
                if let pos = candidates.firstIndex(where: { current[$0].title == s.title }) {
                    result.append((candidates[pos], s.frame))
                    candidates.remove(at: pos)
                    remaining.remove(at: i)
                } else {
                    i += 1
                }
            }
            // 2) 余りは出現順でフォールバック対応
            for s in remaining {
                guard let idx = candidates.first else { break }
                result.append((idx, s.frame))
                candidates.removeFirst()
            }
        }
        return result
    }
}
