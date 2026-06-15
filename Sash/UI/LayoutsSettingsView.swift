import SwiftUI

/// Layouts タブ: 現在のウインドウ配置を「名前付きレイアウト」として保存し、一覧・削除する。
/// 復元（適用）と専用ショートカットは後続スライス（Phase 8c / 8d）で追加する。
struct LayoutsSettingsView: View {
    @ObservedObject private var store = LayoutStore.shared
    @State private var newName: String = ""

    var body: some View {
        Form {
            Section("Save current layout") {
                HStack {
                    TextField("Layout name", text: $newName)
                    Button("Save") { saveCurrent() }
                }
                Text("Saves the position and size of every open window. Restoring comes in a later update.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Saved layouts") {
                if store.layouts.isEmpty {
                    Text("No layouts yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.layouts) { layout in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(layout.name)
                                Text("\(layout.windows.count) windows")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                store.delete(layout)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private func saveCurrent() {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? defaultName() : trimmed
        if store.saveCurrentWindows(named: name) {
            newName = ""
        } else {
            NSSound.beep()   // 取得できるウインドウが無い（権限なし等）
        }
    }

    /// 名前未入力時の既定名（保存日時）。
    private func defaultName() -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: Date())
    }
}
