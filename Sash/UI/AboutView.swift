import SwiftUI
import AppKit

/// About タブ: アプリ名・バージョン・一言説明・プライバシー方針（データ収集なし）を表示する。
/// ユーザー向け文字列は String Catalog 経由。アプリ名とバージョンは固有値なので
/// Bundle から読み取り `Text(verbatim:)` で表示する（翻訳対象外）。
struct AboutView: View {
    /// 表示用アプリ名（Info.plist の CFBundleName）。固有名詞なので非ローカライズ。
    private static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Sash"
    }

    /// "1.0 (1)" 形式のバージョン文字列（CFBundleShortVersionString + CFBundleVersion）。
    private static var versionString: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(short) (\(build))"
    }

    // ライブのリソース使用量（About を開いている間だけ 1 秒ごとに更新）。
    @State private var memoryText = "—"
    @State private var cpuText = "—"
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
                .padding(.bottom, 4)

            Text(verbatim: Self.appName)
                .font(.title)
                .fontWeight(.semibold)

            // "Version %@" として String Catalog に抽出される（versionString が %@）。
            Text("Version \(Self.versionString)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("A keyboard-first window manager for macOS.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            // Sash 自身の使用量。「軽い」ことが一目で分かる。値は verbatim、ラベルのみローカライズ。
            HStack(spacing: 16) {
                Label { Text("Memory") + Text(verbatim: " \(memoryText)") } icon: { Image(systemName: "memorychip") }
                Label { Text(verbatim: "CPU \(cpuText)") } icon: { Image(systemName: "cpu") }
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
            .monospacedDigit()
            .padding(.top, 6)

            Spacer()

            Text("Sash collects no data.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 48)
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
        .onAppear(perform: refreshStats)
        .onReceive(ticker) { _ in refreshStats() }
    }

    /// 自プロセスのメモリ/CPU を読み取って表示文字列を更新する。
    private func refreshStats() {
        if let mb = ProcessStats.memoryFootprintMB() {
            memoryText = String(format: "%.1f MB", mb)
        }
        if let cpu = ProcessStats.cpuUsagePercent() {
            cpuText = String(format: "%.1f%%", cpu)
        }
    }
}
