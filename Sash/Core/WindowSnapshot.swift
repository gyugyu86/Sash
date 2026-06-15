import CoreGraphics

/// 1 ウインドウの最小スナップショット（monitor memory 用）。
/// 不安定な CGWindowID ではなく bundleIdentifier ＋ title で後から照合する。
/// frame は Quartz 座標（AX ネイティブ：左上原点・Y 下方向）。
struct WindowSnapshot: Codable, Equatable {
    let bundleIdentifier: String
    let title: String
    let frame: CGRect
}
