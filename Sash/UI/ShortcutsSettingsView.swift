import SwiftUI
import KeyboardShortcuts

/// ショートカット設定: 各ウインドウ配置アクションの録画 UI（KeyboardShortcuts.Recorder）。
/// 項目数が多いので **2 列**に並べ、スクロール無しで全部見えるようにする。
struct ShortcutsSettingsView: View {
    /// `Shortcuts.all` を 2 個ずつの行に分割（2 列グリッド用）。
    private var rows: [[ShortcutBinding]] {
        stride(from: 0, to: Shortcuts.all.count, by: 2).map { start in
            Array(Shortcuts.all[start ..< min(start + 2, Shortcuts.all.count)])
        }
    }

    var body: some View {
        ScrollView {
            GroupBox("Window Placement") {
                Grid(alignment: .leading, horizontalSpacing: 28, verticalSpacing: 10) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, pair in
                        GridRow {
                            recorder(pair[0])
                            if pair.count > 1 { recorder(pair[1]) }
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            .padding(20)
        }
    }

    private func recorder(_ binding: ShortcutBinding) -> some View {
        KeyboardShortcuts.Recorder(for: binding.name) {
            Label(binding.action.localizedTitle, systemImage: binding.action.symbol)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
