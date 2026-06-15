import CoreGraphics
import Foundation

/// ウインドウをどう配置するか。
///
/// 幾何計算はすべて Cocoa 座標（左下原点・Y は上方向）の visibleFrame を基準に行い、
/// Quartz への変換は呼び出し側（WindowManager）で `ScreenGeometry.flipY` を通す。
/// 表示名は String Catalog（`Localizable.xcstrings`）の英語キーを参照し、ハードコードしない。
/// `restore` / `moveTo*Display` は幾何計算を持たない特殊アクション（WindowManager が別経路で処理）。
enum WindowAction: String, CaseIterable, Identifiable {
    case leftHalf, rightHalf, topHalf, bottomHalf
    case topLeft, topRight, bottomLeft, bottomRight
    case leftThird, centerThird, rightThird
    case leftTwoThirds, rightTwoThirds
    case maximize
    case restore                                    // 配置前のフレームへ戻す（履歴ベース）
    case moveToPreviousDisplay, moveToNextDisplay   // 隣のディスプレイへ比率保持で移動
    case moveToDisplay1, moveToDisplay2, moveToDisplay3  // 左から N 番目のディスプレイへ比率保持で移動

    var id: String { rawValue }

    /// メニュー・設定でのグループ分け。区切り線（Divider）の単位であり、表示順の単一の真実。
    /// `Group.allCases` の順（placement → restore → display）でセクションを並べる。
    enum Group: CaseIterable {
        case placement   // 半分・四隅・1/3・2/3・最大化
        case restore     // 配置前のフレームへ戻す
        case display     // 隣のディスプレイへ移動
    }

    /// このアクションが属するグループ。
    var group: Group {
        switch self {
        case .restore:
            return .restore
        case .moveToPreviousDisplay, .moveToNextDisplay,
             .moveToDisplay1, .moveToDisplay2, .moveToDisplay3:
            return .display
        default:
            return .placement
        }
    }

    /// 「特定ディスプレイへ移動」アクションが指す 1 始まりのディスプレイ番号。それ以外は nil。
    var displayNumber: Int? {
        switch self {
        case .moveToDisplay1: return 1
        case .moveToDisplay2: return 2
        case .moveToDisplay3: return 3
        default:              return nil
        }
    }

    /// メニューやショートカット一覧に表示するローカライズ済みの名称。
    /// 英語をソースキーとして String Catalog から解決する。
    var localizedTitle: String {
        // 選択言語の .lproj から解決する（メニュー/ショートカット名を即時切替対象にする）。
        let b = LanguageManager.shared.bundle
        switch self {
        case .leftHalf:              return String(localized: "Left Half", bundle: b)
        case .rightHalf:             return String(localized: "Right Half", bundle: b)
        case .topHalf:               return String(localized: "Top Half", bundle: b)
        case .bottomHalf:            return String(localized: "Bottom Half", bundle: b)
        case .topLeft:               return String(localized: "Top Left", bundle: b)
        case .topRight:              return String(localized: "Top Right", bundle: b)
        case .bottomLeft:            return String(localized: "Bottom Left", bundle: b)
        case .bottomRight:           return String(localized: "Bottom Right", bundle: b)
        case .leftThird:             return String(localized: "Left Third", bundle: b)
        case .centerThird:           return String(localized: "Center Third", bundle: b)
        case .rightThird:            return String(localized: "Right Third", bundle: b)
        case .leftTwoThirds:         return String(localized: "Left Two Thirds", bundle: b)
        case .rightTwoThirds:        return String(localized: "Right Two Thirds", bundle: b)
        case .maximize:              return String(localized: "Maximize", bundle: b)
        case .restore:               return String(localized: "Restore", bundle: b)
        case .moveToPreviousDisplay: return String(localized: "Move to Previous Display", bundle: b)
        case .moveToNextDisplay:     return String(localized: "Move to Next Display", bundle: b)
        case .moveToDisplay1, .moveToDisplay2, .moveToDisplay3:
            return String(localized: "Move to Display \(displayNumber ?? 0)", bundle: b)
        }
    }

    /// メニュー/設定で使う SF Symbol 名。
    var symbol: String {
        switch self {
        case .leftHalf:              return "rectangle.lefthalf.inset.filled"
        case .rightHalf:             return "rectangle.righthalf.inset.filled"
        case .topHalf:               return "rectangle.tophalf.inset.filled"
        case .bottomHalf:            return "rectangle.bottomhalf.inset.filled"
        case .maximize:              return "rectangle.inset.filled"
        case .restore:               return "arrow.uturn.backward"
        case .moveToPreviousDisplay: return "arrow.left.to.line"
        case .moveToNextDisplay:     return "arrow.right.to.line"
        case .moveToDisplay1:        return "1.square"
        case .moveToDisplay2:        return "2.square"
        case .moveToDisplay3:        return "3.square"
        default:                     return "square.split.2x2"
        }
    }

    /// 配置先の矩形を返す（Cocoa 座標）。幾何計算を持たないアクション（restore / display 移動）は nil。
    /// - Parameter v: 対象スクリーンの visibleFrame（メニューバー・Dock を除いた領域）
    func targetFrame(visibleFrame v: CGRect) -> CGRect? {
        let w = v.width, h = v.height
        switch self {
        case .leftHalf:       return CGRect(x: v.minX,          y: v.minY,       width: w/2,   height: h)
        case .rightHalf:      return CGRect(x: v.minX + w/2,    y: v.minY,       width: w/2,   height: h)
        case .topHalf:        return CGRect(x: v.minX,          y: v.minY + h/2, width: w,     height: h/2)
        case .bottomHalf:     return CGRect(x: v.minX,          y: v.minY,       width: w,     height: h/2)
        case .topLeft:        return CGRect(x: v.minX,          y: v.minY + h/2, width: w/2,   height: h/2)
        case .topRight:       return CGRect(x: v.minX + w/2,    y: v.minY + h/2, width: w/2,   height: h/2)
        case .bottomLeft:     return CGRect(x: v.minX,          y: v.minY,       width: w/2,   height: h/2)
        case .bottomRight:    return CGRect(x: v.minX + w/2,    y: v.minY,       width: w/2,   height: h/2)
        case .leftThird:      return CGRect(x: v.minX,          y: v.minY,       width: w/3,   height: h)
        case .centerThird:    return CGRect(x: v.minX + w/3,    y: v.minY,       width: w/3,   height: h)
        case .rightThird:     return CGRect(x: v.minX + 2*w/3,  y: v.minY,       width: w/3,   height: h)
        case .leftTwoThirds:  return CGRect(x: v.minX,          y: v.minY,       width: 2*w/3, height: h)
        case .rightTwoThirds: return CGRect(x: v.minX + w/3,    y: v.minY,       width: 2*w/3, height: h)
        case .maximize:       return v
        case .restore, .moveToPreviousDisplay, .moveToNextDisplay,
             .moveToDisplay1, .moveToDisplay2, .moveToDisplay3:
            return nil
        }
    }

    /// ギャップ（余白）を均等に適用した配置先矩形（Cocoa 座標）。
    /// 「working area を gap/2 内側 → タイル計算 → タイルを gap/2 内側」とすることで、
    /// 画面端の余白もウインドウ間の余白も等しく gap になる。restore 等は nil。
    func targetFrame(visibleFrame v: CGRect, gap: CGFloat) -> CGRect? {
        guard gap > 0 else { return targetFrame(visibleFrame: v) }
        let half = gap / 2
        let working = ScreenGeometry.inset(v, by: half)
        guard let tile = targetFrame(visibleFrame: working) else { return nil }
        return ScreenGeometry.inset(tile, by: half)
    }
}
