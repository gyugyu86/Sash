import SwiftUI

/// メニューバーアイコンをクリックしたときのドロップダウン内容。
struct MenuContent: View {
    var body: some View {
        // グループ（配置 / Restore / ディスプレイ移動）ごとに区切り線で区切って並べる。
        ForEach(Array(WindowAction.Group.allCases.enumerated()), id: \.offset) { index, group in
            if index > 0 { Divider() }
            ForEach(WindowAction.allCases.filter { $0.group == group }) { action in
                Button {
                    WindowManager.shared.apply(action)
                } label: {
                    Label(action.localizedTitle, systemImage: action.symbol)
                }
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
