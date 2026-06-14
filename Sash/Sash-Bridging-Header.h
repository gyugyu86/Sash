#import <ApplicationServices/ApplicationServices.h>

// 非公開だが安定して使われている AX API: AXUIElement から CGWindowID を得る。
// 公開ヘッダに無いだけで ApplicationServices には存在する（Rectangle / yabai も使用）。
// Mac App Store には出さない直接配布アプリなので使用上の問題はない。
AXError _AXUIElementGetWindow(AXUIElementRef element, CGWindowID *identifier);
