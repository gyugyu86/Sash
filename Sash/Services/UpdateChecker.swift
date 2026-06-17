import Foundation

/// 更新確認の状態。
enum UpdateState: Equatable {
    case idle
    case checking
    case upToDate
    case available(version: String, url: URL)
    case failed
}

/// 軽量な更新確認（オプトイン・既定OFF）。
///
/// GitHub Releases の最新版を取得して現在版と比較するだけ。**個人データは送信せず**、
/// 取得するのは最新バージョン番号とリリースページ URL のみ。Sparkle のような自動インストールは持たない。
final class UpdateChecker {
    static let shared = UpdateChecker()
    private init() {}

    /// Info.plist の CFBundleShortVersionString（例 "1.1"）。
    static var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    private static let latestURL = URL(string: "https://api.github.com/repos/gyugyu86/Sash/releases/latest")!

    /// GitHub から最新リリースを取得して状態を返す。失敗時は `.failed`。
    func check() async -> UpdateState {
        var req = URLRequest(url: Self.latestURL)
        req.timeoutInterval = 10
        req.setValue("Sash", forHTTPHeaderField: "User-Agent")               // GitHub API は UA 必須
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                  let release = try? JSONDecoder().decode(GitHubRelease.self, from: data),
                  let url = URL(string: release.htmlURL) else { return .failed }
            let latest = release.tagName.hasPrefix("v") ? String(release.tagName.dropFirst()) : release.tagName
            return Self.isNewer(latest, than: Self.currentVersion)
                ? .available(version: latest, url: url)
                : .upToDate
        } catch {
            return .failed
        }
    }

    /// `latest` が `current` より新しいか。`.` 区切りの数値比較。純関数（テスト対象）。
    static func isNewer(_ latest: String, than current: String) -> Bool {
        let l = latest.split(separator: ".").map { Int($0) ?? 0 }
        let c = current.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0..<max(l.count, c.count) {
            let a = i < l.count ? l[i] : 0
            let b = i < c.count ? c[i] : 0
            if a != b { return a > b }
        }
        return false
    }

    private struct GitHubRelease: Decodable {
        let tagName: String
        let htmlURL: String
        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case htmlURL = "html_url"
        }
    }
}
