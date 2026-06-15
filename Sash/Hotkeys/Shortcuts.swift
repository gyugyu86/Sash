import KeyboardShortcuts

// 各アクションに対応するショートカット名と既定キー。
// ⌃⌥ を基準に割り当て（macOS の Spaces 切替 ⌃← 等とは衝突しない）。
// ディスプレイ間移動だけは ⌃⌥⌘ ＋ 矢印（半分配置 ⌃⌥矢印 と区別）。
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
    static let moveToPreviousDisplay = Self("moveToPreviousDisplay", default: .init(.leftArrow,  modifiers: [.control, .option, .command]))
    static let moveToNextDisplay     = Self("moveToNextDisplay",     default: .init(.rightArrow, modifiers: [.control, .option, .command]))
    static let moveToDisplay1        = Self("moveToDisplay1", default: .init(.one,   modifiers: [.control, .option, .command]))
    static let moveToDisplay2        = Self("moveToDisplay2", default: .init(.two,   modifiers: [.control, .option, .command]))
    static let moveToDisplay3        = Self("moveToDisplay3", default: .init(.three, modifiers: [.control, .option, .command]))
    // 4 画面目以降は既定キー割り当てなし（衝突回避）。必要なら設定で各自割り当てる。
    static let moveToDisplay4        = Self("moveToDisplay4")
    static let moveToDisplay5        = Self("moveToDisplay5")
    static let moveToDisplay6        = Self("moveToDisplay6")
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
        .init(name: .moveToPreviousDisplay, action: .moveToPreviousDisplay),
        .init(name: .moveToNextDisplay,     action: .moveToNextDisplay),
        .init(name: .moveToDisplay1,        action: .moveToDisplay1),
        .init(name: .moveToDisplay2,        action: .moveToDisplay2),
        .init(name: .moveToDisplay3,        action: .moveToDisplay3),
        .init(name: .moveToDisplay4,        action: .moveToDisplay4),
        .init(name: .moveToDisplay5,        action: .moveToDisplay5),
        .init(name: .moveToDisplay6,        action: .moveToDisplay6),
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
