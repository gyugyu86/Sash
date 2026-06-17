import SwiftUI

/// 設定ウインドウのコンテナ（TabView）。各タブは個別の View に分離している。
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
            ShortcutsSettingsView()
                .tabItem { Label("Shortcuts", systemImage: "keyboard") }
            AboutView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        // 正方形に近い大きめの固定サイズ。General タブ（6セクション）をスクロール無しで全表示する。
        // Shortcuts は項目が多いのでスクロールが残る／About は余白が増えるが許容。
        .frame(width: 700, height: 700)
    }
}
