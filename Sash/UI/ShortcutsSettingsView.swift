import SwiftUI
import KeyboardShortcuts

/// ショートカット設定: 各ウインドウ配置アクションの録画 UI（KeyboardShortcuts.Recorder）。
struct ShortcutsSettingsView: View {
    var body: some View {
        Form {
            Section("Window Placement") {
                ForEach(Shortcuts.all) { binding in
                    KeyboardShortcuts.Recorder(for: binding.name) {
                        Label(binding.action.localizedTitle, systemImage: binding.action.symbol)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
