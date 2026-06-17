import SwiftUI
import AppKit
import KeyboardShortcuts

/// ショートカット設定: 各ウインドウ配置アクションの録画 UI を **2 列**で並べる。
/// 各セルは「名前＝左寄せ / 録画欄＝右寄せ」、左右の列の間に細い区切り線を入れる。
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
                Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 24) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, pair in
                        GridRow {
                            cell(pair[0])
                            if pair.count > 1 { cell(pair[1]) }
                        }
                    }
                }
                .padding(.vertical, 6)
                // 左右の列の境目に細い縦線
                .overlay(
                    Rectangle()
                        .fill(Color(nsColor: .separatorColor))
                        .frame(width: 1)
                )
            }
            .padding(20)
        }
    }

    /// 1 セル: 名前を左、録画欄を右に寄せる。
    private func cell(_ binding: ShortcutBinding) -> some View {
        HStack(spacing: 8) {
            Label(binding.action.localizedTitle, systemImage: binding.action.symbol)
            Spacer(minLength: 12)
            KeyboardShortcuts.Recorder(for: binding.name) { EmptyView() }
        }
        .frame(maxWidth: .infinity)
    }
}
