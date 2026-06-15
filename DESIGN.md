# Sash v1.0 — 設計仕様（Design Spec）

ShiftIt（参考程度）を土台にゼロから作る、キーボード中心の macOS ウインドウマネージャ。
**「macOS 標準タイルより速く、ShiftIt より親切。少数の機能を最高品質で。」**

対象環境: Apple Silicon / macOS 14.0+（開発機は M5 Air / macOS 26 Tahoe）。
言語: Swift + SwiftUI。
配布: **直接配布**（Developer ID 署名＋公証）＋ **Homebrew cask**。App Sandbox 不可のため Mac App Store 不可（理由は CLAUDE.md 参照）。
多言語化: 開発基準言語は英語。ユーザー向け文字列は String Catalog（`Sash/Resources/Localizable.xcstrings`）。正式対応は en(base)/ja/ko、アプリ内で言語切替可能（`LanguageManager`）。

---

## 1. 機能スコープ

### v1.0 に入れる（=必要な機能）
1. **キーボード配置**（MVP済み）: 左右上下の半分、四隅、1/3・2/3、最大化。
2. **Restore（元に戻す）**: 直前のスナップ前のフレームに戻すアクション。新規追加。
3. **連続サイクル**: 同じ方向キーを連続で押すと `1/2 → 2/3 → 1/3` と幅が循環。設定で ON/OFF。
4. **ディスプレイ間移動**: 最前面ウインドウを次/前のディスプレイへ移動（移動先の visibleFrame に比率を合わせてリサイズ）。
5. **ドラッグスナップ（目玉機能）**: ウインドウを画面端/隅へドラッグ → 半透明プレビュー → 離すとスナップ。設定で ON/OFF。
6. **ギャップ（余白）**: ウインドウと画面端の間隔を px 指定（既定0）。タイル時の見た目を整える。
7. **アクションHUD**（任意・既定OFF）: 配置時に「Left Half」等を一瞬だけ控えめに表示。
8. **権限オンボーディング**: 初回にアクセシビリティ許可へ誘導するフローを整備。
9. **ログイン時起動**（MVP済み）／**メニューバー常駐**（MVP済み）。
10. **アプリ内 言語切替**: System/English/日本語/한국어 をシステム言語を変えずに即時切替（`LanguageManager`）。OS リロード無し。en/ja/ko 全文字列翻訳済み。

### v1.0 から外す（=不要として削る機能）
- X11 / 非 Cocoa ウインドウ対応（ShiftIt にはあったが 2026 年では無意味）
- 自動タイル / BSP タイリング（yabai の領域。別ジャンルなので作らない）
- Spaces / 仮想デスクトップ管理
- Sparkle 等の自動アップデータ（配布時は再ビルド or 直接 DL / Homebrew で更新）
- ウインドウ間フォーカス移動（v1 では対象外）
- 設定のクラウド同期

### バックログ（v1.1 以降）
- **名前付きレイアウト保存/復元 ＝ v1.1 旗艦（Phase 8・差別化の中核）**（Moom 的だが**キーボード中心**。複数アプリのウインドウ配置を「レイアウト」として保存し、1キーで一括復元）。Rectangle 無料版にも macOS 標準タイルにも無く、Apple が当面入れない領域。実装計画は `TASKS.md` の Phase 8 を参照。
- **ラジアル選択 UI**（Loop 的。修飾キー長押しで放射状ゾーン → フリックで選択）。
- アプリ別の除外ルール / カスタムグリッド / 任意比率の指定 UI。
- **ディスプレイ間移動時の再フィット（任意トグル）**: 大画面へ移したとき割合維持ではなく、タイル貼り直し/快適サイズへ再フィットする選択肢。（比率方式＝物理サイズ追従なので既定は現状維持で十分）
- **ドラッグスナップ**: v1.0 では見送り（macOS 15+/26 にOS標準のドラッグタイルがあり重複・競合）。OS標準が不十分なら、OSに無い差別化（1/3 ドラッグ等）に絞って再検討。

---

## 2. UX 指針（ShiftIt からの改善点）

- **設定は SwiftUI ネイティブ＋ショートカット録画 UI**（KeyboardShortcuts パッケージ）。旧 ShortcutRecorder の置換。
- **権限状態を可視化**（緑✓/橙⚠）し、ワンクリックでシステム設定へ。ShiftIt の「なぜか動かない」を解消。
- **ドラッグスナップ**でマウス操作派もカバー（ShiftIt はキーボードのみ）。
- **HUD とプレビューは控えめ**に。邪魔をしないのが上位ツールの条件。
- 既定ショートカットは ⌃⌥ ＋ キー。macOS の Spaces 切替（⌃＋方向キー）と衝突させない。
- **多言語**: 全文言を英語ベースで書き String Catalog に載せる。en/ja/ko を正式対応し、アプリ内で言語を切り替えられる。RTL に備え leading/trailing で組む。

---

## 3. アーキテクチャ / モジュール構成

座標計算を純関数として切り出し、**ユニットテスト可能**にするのが要点（最もバグりやすい箇所）。
リポジトリ直下に `Sash/`（アプリ本体ソース）と `Tests/`（テストターゲット）を置き、`project.yml`（XcodeGen）で組み立てる。

```
<repo root>/
├── project.yml                  // XcodeGen 定義（唯一の真実）
├── .gitignore                   // *.xcodeproj / Sash/Info.plist 等の生成物を無視
├── LICENSE                      // 仮 MIT（未確定）
├── CLAUDE.md / DESIGN.md / TASKS.md
├── Sash/                        // アプリターゲットのソース
│   ├── App/
│   │   ├── SashApp.swift        // @main, MenuBarExtra, Settings scene
│   │   ├── AppDelegate.swift    // 起動時: ショートカット登録 / 初回フロー（将来: スナップ開始）
│   │   └── MenuContent.swift    // メニューバーのドロップダウン
│   ├── Core/
│   │   ├── WindowAction.swift   // アクション列挙 + 幾何計算（将来 restore/サイクルを追加）
│   │   ├── WindowManager.swift  // AX エンジン: 最前面ウインドウ取得 / frame 取得・設定 / apply
│   │   ├── ScreenGeometry.swift // 座標変換（純関数・テスト対象）/ 画面特定 / ギャップ適用
│   │   ├── DisplayMover.swift    // [Phase 3] ディスプレイ間移動（比率リサイズ）
│   │   └── PlacementHistory.swift// [Phase 1/4] 直前フレーム（Restore）/ サイクル状態
│   ├── Snapping/                 // [Phase 6]
│   │   ├── DragSnapper.swift     // グローバルマウス監視 / ドラッグ検出 / ゾーン判定
│   │   ├── SnapZone.swift        // ゾーン定義（端・隅 → WindowAction）
│   │   └── SnapOverlayWindow.swift// 半透明プレビュー（NSPanel）
│   ├── Hotkeys/
│   │   └── Shortcuts.swift       // KeyboardShortcuts 名 + 登録
│   ├── UI/
│   │   ├── SettingsView.swift    // TabView コンテナ
│   │   ├── GeneralSettingsView.swift
│   │   ├── ShortcutsSettingsView.swift
│   │   ├── SnappingSettingsView.swift // [Phase 2]
│   │   ├── AboutView.swift        // [Phase 7]
│   │   └── ActionHUD.swift        // [Phase 5] 任意のフィードバック HUD（NSPanel）
│   ├── Services/
│   │   ├── Preferences.swift      // UserDefaults を包む ObservableObject
│   │   ├── PermissionsManager.swift// AX 権限の確認/要求
│   │   └── LoginItem.swift        // SMAppService
│   └── Resources/
│       └── Localizable.xcstrings  // String Catalog（en base / ja）
└── Tests/
    └── ScreenGeometryTests.swift  // 座標計算のユニットテスト（高価値）
```

> `[Phase N]` の付いたファイルは該当フェーズで新規追加する（Phase 0 時点では未作成）。

---

## 4. 主要インターフェース（実装ターゲット。中身は実装側で）

### Preferences
```swift
final class Preferences: ObservableObject {
    static let shared = Preferences()
    @AppStorage("gap")             var gap: Double = 0       // px
    @AppStorage("dragSnapEnabled") var dragSnapEnabled = true
    @AppStorage("cycleEnabled")    var cycleEnabled = true
    @AppStorage("hudEnabled")      var hudEnabled = false
}
```

### ScreenGeometry（純関数・テスト対象）— Phase 0 で実装済み
```swift
enum ScreenGeometry {
    static func primaryHeight() -> CGFloat
    static func flipY(_ rect: CGRect, primaryHeight: CGFloat) -> CGRect   // Cocoa⇄Quartz
    static func screen(containingCocoa rect: CGRect) -> NSScreen?
    static func inset(_ rect: CGRect, by gap: CGFloat) -> CGRect          // ギャップ適用
}
```

### PermissionsManager — Phase 0 で実装済み
```swift
final class PermissionsManager {
    static let shared = PermissionsManager()
    var isTrusted: Bool { AXIsProcessTrusted() }
    func requestAccess()   // 未許可ならシステムのプロンプトを表示
}
```

### WindowAction 追加（Phase 1〜）
```swift
case restore   // スナップ前のフレームへ戻す
// 連続サイクル: 直前アクション+時刻を見て 1/2 → 2/3 → 1/3 の幅を返すロジックを追加
```

### DisplayMover（Phase 3）
```swift
enum DisplayMover {
    enum Direction { case next, previous }
    static func move(window: AXUIElement, _ direction: Direction)  // 比率リサイズして移動
}
```

### PlacementHistory（Phase 1/4）
```swift
final class PlacementHistory {
    // CGWindowID をキーに「スナップ前フレーム」と「直前アクション+時刻」を保持
    func recordBeforeSnap(_ frame: CGRect, for id: CGWindowID)
    func previousFrame(for id: CGWindowID) -> CGRect?
    func lastAction(for id: CGWindowID) -> (WindowAction, Date)?
}
```

### DragSnapper（Phase 6・最重要・最高リスク）
```swift
final class DragSnapper {
    func start()
    // 1. NSEvent.addGlobalMonitorForEvents で .leftMouseDown/.leftMouseDragged/.leftMouseUp を監視
    // 2. down 時にカーソル下のウインドウを AX で特定し、ドラッグ追跡を開始
    // 3. drag が端/隅ゾーンに入ったら SnapOverlayWindow でプレビュー表示
    // 4. up がゾーン内なら WindowManager.apply(zone.action)
}
```

---

## 5. リスクと注意（実装時の落とし穴）

- **App Sandbox は必ず OFF**。サンドボックス下では他アプリのウインドウを AX で操作できない。→ Mac App Store 配布不可（直接配布のみ）。
- **座標系**: AX/Quartz は左上原点・Y 下方向、Cocoa(NSScreen) は左下原点・Y 上方向。変換は必ず `ScreenGeometry` 経由。**ここを必ずユニットテストする**。
- **frame 適用順**: 最小サイズ制約を持つアプリのため `position → size → position` の順で設定。
- **DragSnapper が最大の難所**。任意アプリのウインドウドラッグを観測する公開 API は無い。`NSEvent` グローバル監視 + AX で代用。**Rectangle（MIT）の `SnapManager` を参照**し、段階的に実装・手動検証。最後に着手。
- **配布**: Developer ID 署名＋公証（notarytool）。認証情報は keychain/env から読み、コードに書かない。Homebrew cask で配布。
- **多言語化**: 文字列をハードコードしない。新規文言は英語ベースで String Catalog に追加。
