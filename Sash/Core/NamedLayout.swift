import CoreGraphics
import Foundation

/// 1つのウインドウのスナップショット（名前付きレイアウトの構成要素）。
///
/// アプリ再起動で変わる不安定な `CGWindowID` ではなく、`bundleIdentifier` ＋ `title` で
/// あとから現在のウインドウへ照合する（復元は Slice 2 で `LayoutMatcher` が担当）。
/// `frame` は Quartz 座標（AX ネイティブ：左上原点・Y 下方向）で `WindowManager` と揃える。
struct WindowSnapshot: Codable, Identifiable, Hashable {
    var id = UUID()
    var bundleIdentifier: String
    var appName: String
    var title: String
    var frame: CGRect
}

/// 名前付きレイアウト＝複数ウインドウ配置のスナップショット集合。JSON で永続化する。
struct NamedLayout: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var createdAt: Date
    var windows: [WindowSnapshot]
}
