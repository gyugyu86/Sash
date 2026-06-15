import SwiftUI

/// 設定ウインドウのコンテナ（TabView）。各タブは個別の View に分離している。
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
            ShortcutsSettingsView()
                .tabItem { Label("Shortcuts", systemImage: "keyboard") }
            LayoutsSettingsView()
                .tabItem { Label("Layouts", systemImage: "square.grid.2x2") }
            AboutView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 480, height: 540)
    }
}
