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

    var id: String { rawValue }

    /// メニューやショートカット一覧に表示するローカライズ済みの名称。
    /// 英語をソースキーとして String Catalog から解決する。
    var localizedTitle: String {
        switch self {
        case .leftHalf:              return String(localized: "Left Half")
        case .rightHalf:             return String(localized: "Right Half")
        case .topHalf:               return String(localized: "Top Half")
        case .bottomHalf:            return String(localized: "Bottom Half")
        case .topLeft:               return String(localized: "Top Left")
        case .topRight:              return String(localized: "Top Right")
        case .bottomLeft:            return String(localized: "Bottom Left")
        case .bottomRight:           return String(localized: "Bottom Right")
        case .leftThird:             return String(localized: "Left Third")
        case .centerThird:           return String(localized: "Center Third")
        case .rightThird:            return String(localized: "Right Third")
        case .leftTwoThirds:         return String(localized: "Left Two Thirds")
        case .rightTwoThirds:        return String(localized: "Right Two Thirds")
        case .maximize:              return String(localized: "Maximize")
        case .restore:               return String(localized: "Restore")
        case .moveToPreviousDisplay: return String(localized: "Move to Previous Display")
        case .moveToNextDisplay:     return String(localized: "Move to Next Display")
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
        case .restore, .moveToPreviousDisplay, .moveToNextDisplay:
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
