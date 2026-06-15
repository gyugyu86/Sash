import AppKit
import SwiftUI

/// ウェルカム画面の許可状態を View に伝える小さな状態オブジェクト。
final class WelcomeModel: ObservableObject {
    @Published var isTrusted: Bool
    init() { isTrusted = PermissionsManager.shared.isTrusted }
}

/// 初回オンボーディング（AX 未許可時のウェルカム画面）のウインドウ管理。
///
/// SwiftUI の `WelcomeView` を `NSHostingController` でホストし、AX 許可を 1 秒間隔で
/// ポーリングする。付与されたら ✓ を一瞬見せて自動クローズ。LSUIElement（Dock なし）の
/// ため、表示時に `NSApp.activate` でアプリを前面に出す。
final class WelcomeWindowController: NSObject, NSWindowDelegate {
    static let shared = WelcomeWindowController()
    private override init() { super.init() }

    private var window: NSWindow?
    private let model = WelcomeModel()
    private var pollTimer: Timer?

    /// AX 未許可のときだけウェルカム画面を表示する（起動時に呼ぶ）。
    func showIfNeeded() {
        guard !PermissionsManager.shared.isTrusted else { return }
        show()
    }

    private func show() {
        if let window {                       // 既に出ていれば前面へ
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        // Sash を AX 許可リストに登録しつつ、標準プロンプトも一度だけ出す。
        PermissionsManager.shared.requestAccess()

        let root = WelcomeView(model: model)
            .environment(\.locale, LanguageManager.shared.locale)
        let hosting = NSHostingController(rootView: root)

        let win = NSWindow(contentViewController: hosting)
        win.styleMask = [.titled, .closable]
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .hidden
        win.title = ""                        // タイトルは画面内テキストで表現する
        win.isMovableByWindowBackground = true
        win.isReleasedWhenClosed = false
        win.delegate = self
        win.center()
        window = win

        startPolling()
        NSApp.activate(ignoringOtherApps: true)
        win.makeKeyAndOrderFront(nil)
    }

    private func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let trusted = PermissionsManager.shared.isTrusted
            if trusted != self.model.isTrusted { self.model.isTrusted = trusted }
            if trusted {
                self.pollTimer?.invalidate()
                self.pollTimer = nil
                // ✓ を一瞬見せてから閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    self?.window?.close()
                }
            }
        }
    }

    // 自動・手動どちらのクローズでもタイマーを止めて参照を解放する。
    func windowWillClose(_ notification: Notification) {
        pollTimer?.invalidate()
        pollTimer = nil
        window = nil
    }
}
