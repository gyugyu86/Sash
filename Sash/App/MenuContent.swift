import SwiftUI

/// メニューバーアイコンをクリックしたときのドロップダウン内容。
struct MenuContent: View {
    var body: some View {
        // グループ（配置 / Restore / ディスプレイ移動）ごとに区切り線で区切って並べる。
        ForEach(Array(WindowAction.Group.allCases.enumerated()), id: \.offset) { index, group in
            if index > 0 { Divider() }
            ForEach(WindowAction.allCases.filter { $0.group == group && isVisible($0) }) { action in
                Button {
                    WindowManager.shared.apply(action)
                } label: {
                    Label(action.localizedTitle, systemImage: action.symbol)
                }
            }
        }

        Divider()

        // monitor memory（Spike・手動）: 現在の配置を記録／このディスプレイ構成で復元。
        Button {
            MonitorMemory.shared.saveCurrentLayout()
        } label: {
            Label("Save Window Layout", systemImage: "square.and.arrow.down")
        }
        Button {
            MonitorMemory.shared.restoreCurrentLayout()
        } label: {
            Label("Restore Window Layout", systemImage: "square.and.arrow.up")
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

    /// 「特定ディスプレイへ移動」は、ディスプレイが複数ありその番号が存在するときだけメニューに出す。
    /// （単一ディスプレイでは無意味なので隠す。他のアクションは常に表示。）
    private func isVisible(_ action: WindowAction) -> Bool {
        guard let n = action.displayNumber else { return true }
        let count = NSScreen.screens.count
        return count >= 2 && n <= count
    }
}
