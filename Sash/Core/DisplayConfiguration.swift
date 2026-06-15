import CoreGraphics

/// 「いまどのディスプレイ構成か」を表す安定シグネチャを作る純ロジック。
///
/// monitor memory は、この構成シグネチャをキーにウインドウ配置を覚え、同じ構成に
/// 戻ったとき復元する。AppKit に依存しない純関数にしてテスト可能にしておく
/// （NSScreen からの値抽出は呼び出し側＝`MonitorMemory` が行う）。
enum DisplayConfiguration {
    /// 表示中ディスプレイ（id と frame）の集合から、順不同でも一意なシグネチャを作る。
    /// 同じ物理構成なら同じ文字列、ディスプレイの増減・解像度変更で別の文字列になる。
    static func signature(from displays: [(id: UInt32, frame: CGRect)]) -> String {
        displays
            .map { "\($0.id):\(Int($0.frame.width.rounded()))x\(Int($0.frame.height.rounded()))" }
            .sorted()
            .joined(separator: "|")
    }
}
