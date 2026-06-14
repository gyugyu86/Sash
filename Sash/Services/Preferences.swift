import SwiftUI

/// アプリ全体の設定値。UserDefaults を `@AppStorage` で包む。
///
/// マジックナンバーを散らさず、設定はすべてここを経由する（CLAUDE.md 規約）。
/// 各値は後続フェーズで配線する: gap=Phase 2 / cycle=Phase 4 / hud=Phase 5 / dragSnap=Phase 6。
final class Preferences: ObservableObject {
    static let shared = Preferences()
    private init() {}

    @AppStorage("gap")             var gap: Double = 0          // ウインドウと画面端の余白(px)
    @AppStorage("dragSnapEnabled") var dragSnapEnabled = true   // ドラッグスナップの ON/OFF
    @AppStorage("cycleEnabled")    var cycleEnabled = true      // 連続サイクル(1/2→2/3→1/3)の ON/OFF
    @AppStorage("hudEnabled")      var hudEnabled = false       // アクション HUD の ON/OFF
}
