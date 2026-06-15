import SwiftUI

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

    var body: some View {
        VStack(spacing: 10) {
            // TODO(Phase 7-④): 仮アイコン確定後に Assets のアプリアイコンへ差し替える。
            Image(systemName: "rectangle.split.2x1.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
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

            Spacer()

            Text("Sash collects no data.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 48)
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
    }
}
