import CoreGraphics

/// ウインドウを次/前のディスプレイへ移すための、ディスプレイ選択の純ロジック。
///
/// AX 操作や実際のフレーム適用は `WindowManager` が行う（AX は WindowManager に閉じ込める規約）。
/// ここはディスプレイの並び替えと隣接選択だけを担い、テスト可能にしておく。
enum DisplayMover {
    enum Direction {
        case next, previous
    }

    /// 全ディスプレイの visibleFrame を「左→上」の順に整列し、current の隣（端で循環）を返す。
    /// ディスプレイが 2 枚未満、または current が見つからなければ nil。純関数。
    static func adjacentVisibleFrame(current: CGRect, all: [CGRect], _ direction: Direction) -> CGRect? {
        guard all.count >= 2 else { return nil }
        let sorted = all.sorted { ($0.minX, $0.minY) < ($1.minX, $1.minY) }
        guard let index = sorted.firstIndex(where: { $0 == current }) else { return nil }
        let offset = direction == .next ? 1 : -1
        let target = (index + offset + sorted.count) % sorted.count
        return sorted[target]
    }
}
