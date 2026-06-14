import AppKit

/// 座標系変換と画面特定を一手に引き受ける純粋ロジック層。
///
/// AX/Quartz は左上原点・Y は下方向、Cocoa(NSScreen) は左下原点・Y は上方向。
/// この変換ミスは最頻出バグなので、ここに集約してユニットテストする（`Tests/ScreenGeometryTests.swift`）。
/// 副作用のない計算は `static` の純関数にしておき、画面状態に依存する処理だけ NSScreen を触る。
enum ScreenGeometry {

    /// 座標系の基準となる主ディスプレイ（原点が (0,0) の画面）の高さ。
    /// Quartz⇄Cocoa の Y 反転はこの高さを基準に行う。
    static func primaryHeight() -> CGFloat {
        NSScreen.screens.first(where: { $0.frame.origin == .zero })?.frame.height
            ?? NSScreen.main?.frame.height
            ?? 0
    }

    /// Cocoa(左下原点) ⇄ Quartz(左上原点) の Y 反転。
    /// 同じ式で双方向に変換できる対称変換（2 回かければ元に戻る）。純関数。
    static func flipY(_ rect: CGRect, primaryHeight: CGFloat) -> CGRect {
        CGRect(x: rect.origin.x,
               y: primaryHeight - rect.origin.y - rect.height,
               width: rect.width,
               height: rect.height)
    }

    /// Cocoa 座標の矩形の中心を含む画面を返す。どの画面にも属さなければ nil。
    static func screen(containingCocoa rect: CGRect) -> NSScreen? {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return NSScreen.screens.first(where: { $0.frame.contains(center) })
    }

    /// 矩形を四辺から `gap` だけ内側に縮める（タイル時のギャップ/余白）。純関数。
    /// `gap` が大きすぎて潰れる場合でも、幅・高さが負にならないよう 0 で下限を取る。
    static func inset(_ rect: CGRect, by gap: CGFloat) -> CGRect {
        guard gap > 0 else { return rect }
        let inset = rect.insetBy(dx: gap, dy: gap)
        return CGRect(x: inset.minX,
                      y: inset.minY,
                      width: max(0, inset.width),
                      height: max(0, inset.height))
    }
}
