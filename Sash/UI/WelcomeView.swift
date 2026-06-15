import SwiftUI
import AppKit

/// 初回（AX 未許可）に出すウェルカム画面の中身。
/// 権限の必要性を説明し、設定ペインを開くボタンを提供する。許可状態は `WelcomeModel` が反映し、
/// 付与されると `WelcomeWindowController` がこの画面を自動で閉じる。文字列は String Catalog 経由。
struct WelcomeView: View {
    @ObservedObject var model: WelcomeModel

    var body: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 84, height: 84)

            Text("Welcome to Sash")
                .font(.title)
                .fontWeight(.semibold)

            Text("Sash arranges your windows with the keyboard. To move other apps’ windows, it needs Accessibility permission.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: model.isTrusted
                      ? "checkmark.circle.fill"
                      : "exclamationmark.triangle.fill")
                    .foregroundStyle(model.isTrusted ? .green : .orange)
                Text(model.isTrusted ? "Permission granted" : "Waiting for permission…")
                    .foregroundStyle(.secondary)
            }
            .font(.callout)

            if !model.isTrusted {
                Button("Open Accessibility Settings…") {
                    PermissionsManager.shared.openAccessibilitySettings()
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)

                Text("Find Sash in the list and turn it on. This window closes automatically once enabled.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(32)
        .frame(width: 420)
    }
}
