# CLAUDE.md — Sash

Claude Code はこのファイルを自動で読み込みます。プロジェクトの前提・制約・規約をここに集約しています。
詳細な機能仕様は `DESIGN.md`、実装順は `TASKS.md` を参照してください。

## プロジェクト概要
- macOS 用のキーボード中心ウインドウマネージャ（ShiftIt の後継的な自作アプリ、ただしゼロから設計）。
- メニューバー常駐。Dock アイコンなし。
- ShiftIt は参考程度。ウインドウ移動ロジックの参考実装は Rectangle（MIT, https://github.com/rxhanson/Rectangle ）。
- **世界配布を前提**とする（日本のみ向けではない）。

## 製品方針（重要・docs横断の前提）
- **名称: Sash**（renameable）。コード・project.yml・bundle id・表示名で統一。
- **bundle id: `io.github.gyugyu86.Sash`**（テストターゲットは `io.github.gyugyu86.SashTests`）。
- **多言語化前提**: 開発基準言語は英語。全ユーザー向け文字列は String Catalog（`Sash/Resources/Localizable.xcstrings`）で管理し、**ハードコードしない**。
  - SwiftUI は `LocalizedStringKey`（`Text("…")` / `Label("…")` などのリテラル）、Swift コードは `String(localized:)` を使う。
  - 正式対応言語は en(base) と ja。ko は任意。将来の RTL に備えてレイアウトは leading/trailing で組む。
- **配布: Mac App Store 不可（直接配布のみ）**。理由 ↓。
  - AX で他アプリのウインドウを操作する新規アプリは **App Sandbox 必須の MAS 要件に適合できない**（サンドボックス下では他アプリを AX 操作できない）。Magnet 等は旧仕様の例外で、新規申請には通らない前提。
  - 最終形は **Developer ID 署名＋公証（notarytool）済みの直接配布**（GitHub Releases）＋ **Homebrew cask**。
- **ライセンス: 未確定**。確認まで `LICENSE` は仮で MIT（後で確定）。

## ビルド / 実行
- Xcode 16+ / Swift / SwiftUI。**Deployment Target: macOS 14.0**。Apple Silicon。
- **プロジェクトは XcodeGen で生成**。`project.yml` が唯一の真実。生成される `Sash.xcodeproj` と `Sash/Info.plist` は gitignore 済み。
  - クローン後・project.yml 変更後は必ず `xcodegen generate` を実行してから Xcode で開く。
- 依存: KeyboardShortcuts（SPM, https://github.com/sindresorhus/KeyboardShortcuts ）。`project.yml` の `packages` で管理。
- 実行: Xcode で開き ⌘R。**署名チーム(`DEVELOPMENT_TEAM`)は `project.yml` に設定済み**なので Xcode UI の Signing は触らない（触っても次の `xcodegen generate` で消える）。初回はシステム設定 → プライバシーとセキュリティ → アクセシビリティ で **Sash を ON** にする。
- CLI でのビルド/テスト確認:
  ```
  xcodegen generate
  xcodebuild build -scheme Sash -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
  xcodebuild test  -scheme Sash -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
  ```

## 絶対に守る制約（重要）
0. **アドホック署名(`-`)で配らない・開発でも避ける**。`DEVELOPMENT_TEAM` を `project.yml` に持たせ、Apple Development 署名で安定した Designated Requirement を保つ。
   - アドホック署名や debug dylib 方式だと **アクセシビリティ許可が定着せず毎回プロンプトが出る**（過去に踏んだ罠。`ENABLE_DEBUG_DYLIB=NO` 済み）。
1. **App Sandbox は付けない / OFF**。サンドボックス下では他アプリのウインドウを Accessibility で操作できない。
   - 結果として Mac App Store には出せない（直接配布のみ）。これは仕様。entitlements も付与しない。
2. **`Application is agent (UIElement)` = YES**（`LSUIElement`、`project.yml` で設定済み）。メニューバー常駐・Dock アイコンなしを維持。
3. **座標系の変換は必ず `Core/ScreenGeometry.swift` に集約**し、ユニットテストを書く。
   - AX/Quartz: 左上原点・Y 下方向。Cocoa(NSScreen): 左下原点・Y 上方向。
   - 変換ミスは最頻出バグ。新しい配置を足したら必ずテストを追加。
4. ウインドウへの frame 適用は **position → size → position** の順（最小サイズ制約対策）。
5. グローバルショートカットは KeyboardShortcuts を使う（自前の Carbon 登録を書かない）。
   - 既定は ⌃⌥ ＋ キー。macOS の Spaces 切替（⌃＋方向キー）と衝突させない。
6. **ユーザー向け文字列は String Catalog 経由**。新規文字列を英語ベースで追加し、ハードコードしない。

## コード規約
- 1ファイル1責務。`DESIGN.md` のモジュール構成に従う。
- 座標計算など副作用のないロジックは純関数（enum の static）にしてテスト可能に。
- AX 操作は `Core/WindowManager.swift` に閉じ込める。UI 層から AX を直接触らない。
- 権限確認は `Services/PermissionsManager.swift`、設定値は `Services/Preferences.swift`（`@AppStorage`）経由。マジックナンバーを散らさない。
- コメントは日本語可。**識別子・ユーザー向け文字列は英語**。

## 既知の難所
- `Snapping/DragSnapper.swift`（ドラッグスナップ）が最大リスク。任意アプリのドラッグを観測する公開 API は無く、`NSEvent` グローバル監視 + AX で代用する。Rectangle の `SnapManager` を参照し、段階実装＋手動検証。**最後のフェーズで着手**。

## 検証の作法
- 各フェーズ完了時に必ずビルドが通ること、既存ショートカットが壊れていないことを確認。
- 座標計算の変更時は `Tests/ScreenGeometryTests.swift` を実行。
- ディスプレイ間移動・ドラッグスナップは外部モニタ接続で手動確認（人間ゲート）。

## 既知の無害ログ（無視してよい）
動作中に Xcode コンソールへ出るが、ウインドウ操作には影響しない:
- `Unable to obtain a task name port right for pid <N>: (os/kern) failure (0x5)`
  — `<N>` は **WindowServer**。そのタスクポートは設計上どのアプリも取得不可。AX が高速パスを試して通常パスにフォールバックする際のログで、全ウインドウマネージャで出る。
- `ViewBridge to RemoteViewService Terminated: ... NSViewBridgeErrorCanceled`
  — システムのビューコントローラ切断時のログ（"benign unless unexpected"）。
- `fopen failed for data file: errno = 2` — 任意データファイルの探索失敗。無害。

## Git / コミット規約
- `project.yml` が唯一の真実。生成物（`*.xcodeproj`, `Sash/Info.plist`）はコミットしない。
- `TASKS.md` のフェーズ完了ごとに 1 コミット。**Conventional Commits**（`feat:` `fix:` `refactor:` `chore:` …）。
- 大きな変更（特に Phase 6 ドラッグスナップ）は feature ブランチで進める。

## 現状
- **Phase 0 完了（実機検証済み）**: Shoji→Sash リネーム / モジュール分割（App・Core・Hotkeys・UI・Services）/ `ScreenGeometry` 切り出し＋ユニットテスト / `Preferences`・`PermissionsManager`・`LoginItem` 新設 / 英語ベース＋String Catalog 化（en/ja）/ XcodeGen 化。ビルド・テスト・**内蔵+外部モニタでの実機動作**ともにOK。
- MVP 機能: メニューバー常駐 / 半分・四隅・1/3・2/3・最大化 / KeyboardShortcuts / ログイン起動 / 権限要求。
  - `center`（中央寄せ）は撤去済み（現在サイズを保つだけで利用価値が低いため）。
- 開発環境: MacBook（内蔵）+ BenQ 外部モニタ。マルチディスプレイ検証が可能。
- **Phase 1（Restore / ⌃⌥⌫）実装済み**（ビルド・テストOK、実機確認待ち）。`PlacementHistory` で「元の位置に戻す」。
- 次は **Phase 2（Gap / 余白）** → Phase 3（ディスプレイ間移動）の順（ロードマップどおり）。
