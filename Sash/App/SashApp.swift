import SwiftUI

@main
struct SashApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // メニューバー常駐（macOS 13+ ネイティブの MenuBarExtra）。Dock アイコンは LSUIElement で抑止。
        MenuBarExtra("Sash", systemImage: "rectangle.split.2x1.fill") {
            MenuContent()
        }
        .menuBarExtraStyle(.menu)

        // ⌘, で開く設定ウインドウ
        Settings {
            SettingsView()
        }
    }
}
