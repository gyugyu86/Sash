import Foundation

/// 同じ方向キーの連打で幅を循環させるロジック（1/2 → 2/3 → 1/3）。
///
/// 「起点アクション（左/右半分）＋ 直前アクション＋時刻」から、次に適用すべきアクションを返す。
/// AX も可変状態も持たない純関数なのでテストしやすい。
enum CycleSequencer {
    /// 左右それぞれの幅サイクル。先頭（半分）がサイクルの起点。
    private static let groups: [[WindowAction]] = [
        [.leftHalf,  .leftTwoThirds,  .leftThird],
        [.rightHalf, .rightTwoThirds, .rightThird],
    ]

    /// 連打とみなす最大間隔（秒）。これを超えたら最初（半分）から再スタート。
    static let defaultTimeout: TimeInterval = 1.5

    /// triggered を起点に、直前アクション+時刻を見て次のサイクル段階を返す。
    /// triggered がサイクル起点（left/rightHalf）でなければそのまま返す。純関数。
    static func cycledAction(for triggered: WindowAction,
                             last: (action: WindowAction, time: Date)?,
                             now: Date,
                             timeout: TimeInterval = defaultTimeout) -> WindowAction {
        guard let group = groups.first(where: { $0.first == triggered }) else { return triggered }
        guard let last,
              let index = group.firstIndex(of: last.action),
              now.timeIntervalSince(last.time) < timeout else {
            return triggered   // サイクル開始（= group[0]）
        }
        return group[(index + 1) % group.count]
    }
}
