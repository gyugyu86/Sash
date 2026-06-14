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

## Phase 1 — Restore（元に戻す）
`Core/PlacementHistory.swift` を追加。スナップ前のフレームを記録し、`WindowAction.restore` で復元。
ショートカット（例 ⌃⌥ Delete）を割り当て。

- 検証: 適当に配置 → restore で元のサイズ/位置に戻る。

## Phase 2 — ギャップ（余白）
`ScreenGeometry.inset(_:by:)` を配置計算に組み込み、`Preferences.gap` で制御。
`UI/SnappingSettingsView.swift` にスライダーを追加。

- 検証: gap を 8px にすると各配置がその分内側に収まる。

## Phase 3 — ディスプレイ間移動 【人間ゲート: 外部モニタで目視確認】
`Core/DisplayMover.swift` を追加。次/前ディスプレイへ比率リサイズして移動。
ショートカット（例 ⌃⌥ ⌘ ← / →）を割り当て。

- 検証: 外部モニタ接続時、ウインドウが隣の画面へ移動し比率が保たれる。

## Phase 4 — 連続サイクル
同じ方向キーの連続押下で `1/2 → 2/3 → 1/3` を循環。`PlacementHistory` の直前アクション+時刻を使用。
`Preferences.cycleEnabled` で ON/OFF。

- 検証: 左半分のキーを連続で押すと幅が循環する。OFF なら循環しない。

## Phase 5 — アクションHUD（任意）
`UI/ActionHUD.swift`: 配置時に「Left Half」等を一瞬だけ控えめに表示する borderless NSPanel。
`Preferences.hudEnabled`（既定OFF）で制御。

- 検証: ON で配置時に短い HUD が出てフェードアウト。邪魔にならないこと。

## Phase 6 — ドラッグスナップ（最重要・最後）【人間ゲート: 実機/外部モニタで目視確認】
`Snapping/DragSnapper.swift` `SnapZone.swift` `SnapOverlayWindow.swift` を追加。feature ブランチで進める。
**段階的に（6a→6d、各段階で手動検証）**:
- 6a: `NSEvent` グローバル監視を入れ、mouseDown/Drag/Up をログ出力。
- 6b: ドラッグ中のカーソル下ウインドウを AX で特定。
- 6c: 端/隅ゾーン判定 → `SnapOverlayWindow` で半透明プレビュー表示。
- 6d: mouseUp がゾーン内なら `WindowManager.apply(zone.action)`。
- `Preferences.dragSnapEnabled` で全体 ON/OFF。Rectangle の `SnapManager`（MIT）を参照。

- 検証: 各段階ごとに確認。最終的に画面端ドラッグでスナップする。

## Phase 7 — 仕上げ
設定タブの整理（一般/ショートカット/スナップ/About）、初回オンボーディング、アプリアイコン（`Assets.xcassets`）。

- 検証: 初回起動フローが自然 / 設定が分かりやすい。

---

## L. 多言語化（実装が一段落したら）
- String Catalog の正式対応は en(base) と ja。ko は任意で追加してよい。
- ja のレビューは私（人間）が行う。ko を入れる場合のネイティブレビューは任意。
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
