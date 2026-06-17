# TASKS.md — 実装フェーズ

Claude Code は **小さく検証可能な単位**で回すと最も精度・コスト効率が良い。
各フェーズ末で必ずビルド＆動作確認 → コミット（Conventional Commits）してから次へ。
新規の全文字列は英語ベースで String Catalog（`Sash/Resources/Localizable.xcstrings`）へ。座標計算を変えたら `Tests/ScreenGeometryTests.swift` を実行。

---

## Phase 0 — リファクタ＆土台づくり ✅ 完了
MVP を `DESIGN.md` のモジュール構成へ分割。座標計算を `Core/ScreenGeometry.swift` に切り出し、
`Services/Preferences.swift`・`Services/PermissionsManager.swift`・`Services/LoginItem.swift` を新設。
`Tests/ScreenGeometryTests.swift` で flipY と inset のテスト。Shoji→Sash リネーム、英語ベース＋String Catalog 化（en/ja）、XcodeGen 化。

- 結果: ビルド成功 / ユニットテスト 6 件グリーン / ja ローカライズがバンドルに反映。
- 残: 人間ゲート（Xcode で Signing チーム選択 → ⌘R → アクセシビリティ許可 → 既存ショートカット動作確認）。

## Phase 1 — Restore（元に戻す）✅ 完了
`Core/PlacementHistory.swift` を追加。配置前のフレームを CGWindowID 別に記録し、`WindowAction.restore`（⌃⌥⌫）で復元。
方針は「元の位置に戻す」: 連続配置の途中では復元先を上書きせず、ユーザーが動かしたときだけ更新（純関数 `shouldUpdateRestoreFrame` + テスト）。
CGWindowID は非公開 API `_AXUIElementGetWindow`（`Sash-Bridging-Header.h`）で取得。

- 検証: 適当に配置 → ⌃⌥⌫ で元のサイズ/位置に戻る（人間ゲート: 実機確認）。

## Phase 2 — ギャップ（余白）✅ 完了
`WindowAction.targetFrame(visibleFrame:gap:)` で**均等ギャップ**（画面端もウインドウ間も等しく gap）を適用、`Preferences.gap` で制御。
スライダーは「一般」タブに追加（専用 Snapping タブはドラッグスナップの器なので Phase 6 で作成）。

- 検証: gap を 8px にすると各配置が内側に寄り、ウインドウ間も等間隔（人間ゲート: 実機確認）。

## Phase 3 — ディスプレイ間移動 ✅ 完了【人間ゲート: 外部モニタ・確認済み】
`Core/DisplayMover.swift`（隣接ディスプレイ選択の純関数 `adjacentVisibleFrame`）＋ `ScreenGeometry.proportionalFrame`（比率写像）。
`WindowManager.moveToDisplay` が AX 適用。`moveToPreviousDisplay`/`moveToNextDisplay` を **⌃⌥⌘ ← / →** に割り当て（メニュー・設定にも表示）。

- 検証: 外部モニタ接続時、ウインドウが隣の画面へ移動し比率が保たれる（人間ゲート: 実機）。

## Phase 4 — 連続サイクル ✅ 完了
左右の半分キー連打で `1/2 → 2/3 → 1/3` を循環（縦は 1/3 が無いため対象外）。`CycleSequencer`（純関数）が
`PlacementHistory` の直前アクション+時刻（既定 1.5 秒タイムアウト）から次段階を決定。`Preferences.cycleEnabled` で ON/OFF。

- 検証: 左/右半分キー連打で幅が循環。OFF なら常に半分。Restore は最初の自由配置へ（人間ゲート: 実機）。

## Phase 5 — アクションHUD（任意）⏭ v1 では見送り（後日検討可）
`UI/ActionHUD.swift`: 配置時に「Left Half」等を一瞬だけ控えめに表示する borderless NSPanel。
`Preferences.hudEnabled`（既定OFF）で制御。

- 検証: ON で配置時に短い HUD が出てフェードアウト。邪魔にならないこと。

## Phase 6 — ドラッグスナップ ⏭ v1 では見送り（macOS 26 標準のタイル機能と重複。v1.1 で必要なら再検討）【参考: 以下に当初の段階計画】
`Snapping/DragSnapper.swift` `SnapZone.swift` `SnapOverlayWindow.swift` を追加。feature ブランチで進める。
**段階的に（6a→6d、各段階で手動検証）**:
- 6a: `NSEvent` グローバル監視を入れ、mouseDown/Drag/Up をログ出力。
- 6b: ドラッグ中のカーソル下ウインドウを AX で特定。
- 6c: 端/隅ゾーン判定 → `SnapOverlayWindow` で半透明プレビュー表示。
- 6d: mouseUp がゾーン内なら `WindowManager.apply(zone.action)`。
- `Preferences.dragSnapEnabled` で全体 ON/OFF。Rectangle の `SnapManager`（MIT）を参照。

- 検証: 各段階ごとに確認。最終的に画面端ドラッグでスナップする。

## Phase 7 — 仕上げ ✅ 完了
- **About タブ**: アプリ名 / バージョン（Bundle から）/ 一言説明 / 「データ収集なし」。アイコンは実アプリアイコンを表示。
- **メニュー整理**: `WindowAction.Group`（placement / restore / display）でドロップダウンを区切り線グループ化。
- **初回オンボーディング**: AX 未許可時にウェルカム画面（`WelcomeWindowController` + `WelcomeView`）。`PermissionsManager.openAccessibilitySettings()` で設定ペインへ誘導し、許可をポーリングして自動クローズ。標準ダイアログは出さず案内は1ウインドウに集約（`registerInAccessibilityList()` でダイアログ無し登録）。
- **仮アプリアイコン**: `Scripts/GenerateAppIcon.swift`（CoreGraphics・依存ゼロ）で生成 → `Assets.xcassets/AppIcon.appiconset`。最終デザインは人間ゲート。
- **追加（仕様変更）— アプリ内 言語切替**: `LanguageManager` で System/English/日本語/한국어 を切替。`Text` は `.environment(\.locale)`、`String(localized:)` は `bundle`（選択言語の .lproj）で解決。ko を正式対応へ格上げ。
- 専用 Snapping タブは Phase 6 見送りに伴い不要のため作成せず。
- 検証: 実機で初回フロー・言語切替・各タブ・アイコン表示を確認済み。

## Phase 8 以降 — 差別化の探索（結論: 軽量路線で確定）
Phase 7 後、Rectangle/標準タイルに対する差別化を検討・実装したが、最終的に**強い差別化機能は持たず軽量路線**で v1.0 を出すと決めた。実ユーザー調査（Rectangle の GitHub issue・口コミ）起点で候補を当たった結果:

- **特定ディスプレイへ移動（最大6画面）✅ 採用・実装済み**: ⌃⌥⌘1/2/3（4–6は任意割当）。`DisplayMover.visibleFrame(atDisplayIndex:)`（純関数＋テスト）。Rectangle 無料版に無い小さな実利。
- **自分のメモリ/CPU ライブ表示（About）✅ 採用・実装済み**: `ProcessStats`（公開 Mach API、開いている間だけポーリング）。「軽い」ことの可視化。
- **名前付きレイアウト（旧 Phase 8 旗艦）❌ 取り下げ**: 設定もの色が強く、作り手が日常使いしないため未着手で見送り。
- **monitor memory（ディスプレイ構成ごとの配置記憶・自動復元）❌ 実装したが除去**: 基本の保存→復元が不安定。加えて macOS は**他 Space のウインドウを公開APIで扱えない**ため複数 Spaces 運用では構造的に機能しない（Stay/Display Maid と同じ壁）。投資対効果が悪く除去（コードは git 履歴に残置、将来きちんと作り直す余地あり）。
- **Spaces（仮想デスクトップ）作成/削除/切替/窓移動 ❌ 対象外**: 公開API無し＝yabai 同等（非公開API＋SIP無効化）で安定配布方針と両立しない。切替は macOS 標準（⌃+数字）で代替。
- **カスタムサイズ editor / アプリ別自動配置 ❌ 見送り**: 設定もの色が強く、軽量路線と合わない。

→ **v1.0 は feature-complete**。残りはリリース作業（R）のみ。

## v1.1 — ShiftIt 参考の小機能バッチ ✅
公開後、ShiftIt（約10年放置）を参考に軽量路線を崩さない小機能を追加（`feat/v1.1`、build+test 緑31件）:
- **簡体中文（zh-Hans）**: 全文字列翻訳・言語切替に「简体中文」追加（`AppLanguage.zhHans`）。
- **任意・既定OFF の更新確認**: `UpdateChecker`（GitHub Releases API・バージョン番号のみ取得）。純関数 `isNewer` をテスト。プライバシー文言を「既定は通信なし／任意で有効化時のみ取得」に更新。
- **「問題を報告」メニュー**: GitHub issues を開く。
- 不採用: メニューバーアイコン非表示（「隠すと再度開くまで何も見えない」UX が分かりにくく実機検証で取り下げ。FB あれば再検討）/ デバッグログ切替 / ズーム・全画面。

---

## L. 多言語化 ✅（en/ja/ko 対応済み・アプリ内切替あり）
- String Catalog の正式対応は en(base) / ja / ko（全文字列翻訳済み）。アプリ内で言語を切替可能（`LanguageManager`）。
- ja/ko のネイティブレビューは人間ゲート（任意）。
- 将来の RTL 対応に備え、レイアウトは leading/trailing で組む。

## R. リリース準備（最後）
- アプリアイコン: asset catalog 一式を生成（ソース画像があれば人間が提供。無ければ仮アイコン→最終承認は人間）。
- 署名・公証スクリプト（notarytool 前提。認証情報は keychain/env 経由。パスワード類はコードに書かない）。
- Homebrew cask formula、README、CHANGELOG、簡潔なプライバシー方針（データ収集なしを明記）。
- （任意）GitHub Actions で build→notarize の CI。
- 【人間ゲート】Apple Developer 登録($99/年)・公証認証情報の設定・GitHub リポジトリ作成とリモート認証・リリース公開と cask PR・ライセンス確定・アイコン/プライバシー文面の承認。

---

## 進め方のコツ
- 各フェーズ着手前に Plan モードで計画を提示 → 承認 → 実装 → ビルド確認 → コミット → 次へ。
- `CLAUDE.md` が前提を毎回読み込ませてくれる。
- Phase 6 だけ難所。詰まったら段階(6a→6d)を分け、必要ならその回だけ上位モデルに切り替える。
- 【人間ゲート】が来たら推測で進めず、何をすべきか具体的に提示して停止する。
