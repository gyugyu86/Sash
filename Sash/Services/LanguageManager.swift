import Foundation
import SwiftUI

/// アプリの表示言語。`system` は macOS のシステム言語に追従する。
/// rawValue は `.lproj` 名・UserDefaults 保存値・`Locale` 識別子を兼ねる。
enum AppLanguage: String, CaseIterable, Identifiable {
    case system, en, ja, ko

    var id: String { rawValue }

    /// ピッカーに出す表示名。言語名は各言語の自称（autonym）で固定表示し、
    /// `system` のみローカライズする。
    var labelText: Text {
        switch self {
        case .system: return Text("System")          // ローカライズ対象
        case .en:     return Text(verbatim: "English")
        case .ja:     return Text(verbatim: "日本語")
        case .ko:     return Text(verbatim: "한국어")
        }
    }
}

/// アプリ内だけで表示言語を切り替えるためのマネージャ。
///
/// macOS のシステム言語には触れないため OS のリロードは起きない。選択は UserDefaults に
/// 永続化し、起動時から反映する。文字列は2系統あり、それぞれ別経路で解決する:
/// - SwiftUI の `Text`（LocalizedStringKey）→ `.environment(\.locale, locale)` で切り替え。
/// - `String(localized:)`（`WindowAction.localizedTitle`）→ `bundle`（選択言語の .lproj）で切り替え。
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    private static let key = "appLanguage"

    /// 現在の表示言語。変更は即座に UserDefaults へ保存し、購読側（App）が再描画する。
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Self.key) }
    }

    private init() {
        let raw = UserDefaults.standard.string(forKey: Self.key)
        language = raw.flatMap(AppLanguage.init(rawValue:)) ?? .system
    }

    /// SwiftUI の `Text`（LocalizedStringKey）解決に使うロケール。
    var locale: Locale {
        switch language {
        case .system: return Locale.current
        default:      return Locale(identifier: language.rawValue)
        }
    }

    /// `String(localized:)` の解決に使うバンドル（選択言語の .lproj）。
    /// `system` または .lproj が見つからない場合は main（システム言語に追従）。
    var bundle: Bundle {
        guard language != .system,
              let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let lproj = Bundle(path: path)
        else { return .main }
        return lproj
    }
}
