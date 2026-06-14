import CoreGraphics
import Foundation

/// ウインドウをどう配置するか。
///
/// 幾何計算はすべて Cocoa 座標（左下原点・Y は上方向）の visibleFrame を基準に行い、
/// Quartz への変換は呼び出し側（WindowManager）で `ScreenGeometry.flipY` を通す。
/// 表示名は String Catalog（`Localizable.xcstrings`）の英語キーを参照し、ハードコードしない。
enum WindowAction: String, CaseIterable, Identifiable {
    case leftHalf, rightHalf, topHalf, bottomHalf
    case topLeft, topRight, bottomLeft, bottomRight
    case leftThird, centerThird, rightThird
    case leftTwoThirds, rightTwoThirds
    case maximize
    case restore   // 履歴ベース: 配置前のフレームへ戻す（幾何計算なし。WindowManager が処理）

    var id: String { rawValue }

    /// メニューやショートカット一覧に表示するローカライズ済みの名称。
    /// 英語をソースキーとして String Catalog から解決する。
    var localizedTitle: String {
        switch self {
        case .leftHalf:       return String(localized: "Left Half")
        case .rightHalf:      return String(localized: "Right Half")
        case .topHalf:        return String(localized: "Top Half")
        case .bottomHalf:     return String(localized: "Bottom Half")
        case .topLeft:        return String(localized: "Top Left")
        case .topRight:       return String(localized: "Top Right")
        case .bottomLeft:     return String(localized: "Bottom Left")
        case .bottomRight:    return String(localized: "Bottom Right")
        case .leftThird:      return String(localized: "Left Third")
        case .centerThird:    return String(localized: "Center Third")
        case .rightThird:     return String(localized: "Right Third")
        case .leftTwoThirds:  return String(localized: "Left Two Thirds")
        case .rightTwoThirds: return String(localized: "Right Two Thirds")
        case .maximize:       return String(localized: "Maximize")
        case .restore:        return String(localized: "Restore")
        }
    }

    /// メニュー/設定で使う SF Symbol 名。
    var symbol: String {
        switch self {
        case .leftHalf:    return "rectangle.lefthalf.inset.filled"
        case .rightHalf:   return "rectangle.righthalf.inset.filled"
        case .topHalf:     return "rectangle.tophalf.inset.filled"
        case .bottomHalf:  return "rectangle.bottomhalf.inset.filled"
        case .maximize:    return "rectangle.inset.filled"
        case .restore:     return "arrow.uturn.backward"
        default:           return "square.split.2x2"
        }
    }

    /// 配置先の矩形を返す（Cocoa 座標）。`restore` は履歴ベースで幾何計算が無いため nil。
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
        case .restore:        return nil
        }
    }
}
