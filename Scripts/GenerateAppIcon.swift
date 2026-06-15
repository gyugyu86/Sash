#!/usr/bin/env swift
//
// GenerateAppIcon.swift — Sash の仮アプリアイコンを生成する（依存ゼロ・決定論的）。
//
// デザイン: ブルーのグラデーション角丸スクエア（macOS の squircle 風、角丸 ≈22.37%）に、
// 2/3 + 1/3 に分割した白いタイル（Sash の中核機能のモチーフ）。
//
// 使い方:
//   swift Scripts/GenerateAppIcon.swift <出力ディレクトリ=AppIcon.appiconset のパス>
// 出力先に各サイズの PNG を書き出す。最終アイコンへ差し替えるときはこの描画を直すだけ。
//
import AppKit
import CoreGraphics

// MARK: - 描画

/// 指定ピクセルサイズのアイコン画像を 1 枚描画する。
func makeIcon(size s: CGFloat) -> CGImage {
    let pixels = Int(s)
    let space = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(
        data: nil, width: pixels, height: pixels,
        bitsPerComponent: 8, bytesPerRow: 0, space: space,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    ctx.interpolationQuality = .high

    // 背景: 角丸スクエア（フルブリード）にクリップして縦グラデーションを塗る。
    let bgRect = CGRect(x: 0, y: 0, width: s, height: s)
    let radius = s * 0.2237
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()
    let top = CGColor(red: 0x3E/255.0, green: 0x8B/255.0, blue: 0xFF/255.0, alpha: 1)
    let bottom = CGColor(red: 0x1F/255.0, green: 0x66/255.0, blue: 0xE8/255.0, alpha: 1)
    let gradient = CGGradient(colorsSpace: space, colors: [top, bottom] as CFArray, locations: [0, 1])!
    // CG は y 上向き。上端(y=s)を明るい青、下端(y=0)を濃い青にする。
    ctx.drawLinearGradient(gradient,
                           start: CGPoint(x: s / 2, y: s),
                           end: CGPoint(x: s / 2, y: 0),
                           options: [])
    ctx.restoreGState()

    // 前景: 2/3 + 1/3 の白いタイル（上下左右の余白・タイル間ギャップは比率で固定）。
    let tileY = s * 0.22
    let tileH = s * 0.56
    let tileRadius = s * 0.05
    let leftTile = CGRect(x: s * 0.20, y: tileY, width: s * 0.38, height: tileH)
    let rightTile = CGRect(x: s * 0.61, y: tileY, width: s * 0.19, height: tileH)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.addPath(CGPath(roundedRect: leftTile, cornerWidth: tileRadius, cornerHeight: tileRadius, transform: nil))
    ctx.addPath(CGPath(roundedRect: rightTile, cornerWidth: tileRadius, cornerHeight: tileRadius, transform: nil))
    ctx.fillPath()

    return ctx.makeImage()!
}

/// CGImage を PNG として書き出す。
func writePNG(_ image: CGImage, to url: URL) {
    let rep = NSBitmapImageRep(cgImage: image)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode PNG: \(url.lastPathComponent)")
    }
    try! data.write(to: url)
}

// MARK: - エントリポイント

// appiconset の各スロット（ファイル名, ピクセルサイズ）。
let slots: [(name: String, pixels: CGFloat)] = [
    ("icon_16",     16),
    ("icon_16@2x",  32),
    ("icon_32",     32),
    ("icon_32@2x",  64),
    ("icon_128",    128),
    ("icon_128@2x", 256),
    ("icon_256",    256),
    ("icon_256@2x", 512),
    ("icon_512",    512),
    ("icon_512@2x", 1024),
]

guard CommandLine.arguments.count >= 2 else {
    FileHandle.standardError.write(Data("usage: swift GenerateAppIcon.swift <output-dir>\n".utf8))
    exit(1)
}
let outDir = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

for slot in slots {
    let image = makeIcon(size: slot.pixels)
    writePNG(image, to: outDir.appendingPathComponent("\(slot.name).png"))
    print("wrote \(slot.name).png (\(Int(slot.pixels))px)")
}
