import SwiftUI

@main
struct SashApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    // アプリ内の言語切替。変更時に App body を再評価させ、locale 環境を更新する。
    @StateObject private var languageManager = LanguageManager.shared
    // メニューバーアイコンの表示/非表示（非表示でもショートカットは有効。設定は再起動で開ける）。
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true

    var body: some Scene {
        // メニューバー常駐（macOS 13+ ネイティブの MenuBarExtra）。Dock アイコンは LSUIElement で抑止。
        MenuBarExtra("Sash", systemImage: "rectangle.split.2x1.fill", isInserted: $showMenuBarIcon) {
            MenuContent()
                .environment(\.locale, languageManager.locale)
                .environmentObject(languageManager)
        }
        .menuBarExtraStyle(.menu)

        // ⌘, で開く設定ウインドウ
        Settings {
            SettingsView()
                .environment(\.locale, languageManager.locale)
                .environmentObject(languageManager)
        }
    }
}
