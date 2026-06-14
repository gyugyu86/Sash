import SwiftUI

/// メニューバーアイコンをクリックしたときのドロップダウン内容。
struct MenuContent: View {
    var body: some View {
        ForEach(WindowAction.allCases) { action in
            Button {
                WindowManager.shared.apply(action)
            } label: {
                Label(action.localizedTitle, systemImage: action.symbol)
            }
        }

        Divider()

        SettingsLink {
            Label("Settings…", systemImage: "gearshape")
        }
        .keyboardShortcut(",", modifiers: .command)

        Button("Quit Sash") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
