import KeyboardShortcuts

// 各アクションに対応するショートカット名と既定キー。
// ⌃⌥ を基準に割り当て（macOS の Spaces 切替 ⌃← 等とは衝突しない）。
extension KeyboardShortcuts.Name {
    static let leftHalf       = Self("leftHalf",       default: .init(.leftArrow,  modifiers: [.control, .option]))
    static let rightHalf      = Self("rightHalf",      default: .init(.rightArrow, modifiers: [.control, .option]))
    static let topHalf        = Self("topHalf",        default: .init(.upArrow,    modifiers: [.control, .option]))
    static let bottomHalf     = Self("bottomHalf",     default: .init(.downArrow,  modifiers: [.control, .option]))
    static let topLeft        = Self("topLeft",        default: .init(.u, modifiers: [.control, .option]))
    static let topRight       = Self("topRight",       default: .init(.i, modifiers: [.control, .option]))
    static let bottomLeft     = Self("bottomLeft",     default: .init(.j, modifiers: [.control, .option]))
    static let bottomRight    = Self("bottomRight",    default: .init(.k, modifiers: [.control, .option]))
    static let leftThird      = Self("leftThird",      default: .init(.d, modifiers: [.control, .option]))
    static let centerThird    = Self("centerThird",    default: .init(.f, modifiers: [.control, .option]))
    static let rightThird     = Self("rightThird",     default: .init(.g, modifiers: [.control, .option]))
    static let leftTwoThirds  = Self("leftTwoThirds",  default: .init(.e, modifiers: [.control, .option]))
    static let rightTwoThirds = Self("rightTwoThirds", default: .init(.t, modifiers: [.control, .option]))
    static let maximize       = Self("maximize",       default: .init(.return, modifiers: [.control, .option]))
    static let restore        = Self("restore",        default: .init(.delete, modifiers: [.control, .option]))
}

/// ショートカット名 ↔ アクションの対応表。設定画面の一覧にもこれを使う。
struct ShortcutBinding: Identifiable {
    let name: KeyboardShortcuts.Name
    let action: WindowAction
    var id: String { action.rawValue }
}

enum Shortcuts {
    static let all: [ShortcutBinding] = [
        .init(name: .leftHalf,       action: .leftHalf),
        .init(name: .rightHalf,      action: .rightHalf),
        .init(name: .topHalf,        action: .topHalf),
        .init(name: .bottomHalf,     action: .bottomHalf),
        .init(name: .topLeft,        action: .topLeft),
        .init(name: .topRight,       action: .topRight),
        .init(name: .bottomLeft,     action: .bottomLeft),
        .init(name: .bottomRight,    action: .bottomRight),
        .init(name: .leftThird,      action: .leftThird),
        .init(name: .centerThird,    action: .centerThird),
        .init(name: .rightThird,     action: .rightThird),
        .init(name: .leftTwoThirds,  action: .leftTwoThirds),
        .init(name: .rightTwoThirds, action: .rightTwoThirds),
        .init(name: .maximize,       action: .maximize),
        .init(name: .restore,        action: .restore),
    ]

    /// 起動時に全ショートカットを登録
    static func registerAll() {
        for binding in all {
            KeyboardShortcuts.onKeyDown(for: binding.name) {
                WindowManager.shared.apply(binding.action)
            }
        }
    }
}
