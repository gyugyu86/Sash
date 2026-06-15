# Sash

A keyboard-first window manager for macOS. Snap, resize, and move windows with
a few shortcuts — fast, quiet, and out of your way. Sash lives in the menu bar,
has no Dock icon, and collects no data.

> Status: pre-release (v1.0). Built from scratch as a modern, friendlier
> successor to ShiftIt; window-move logic references [Rectangle](https://github.com/rxhanson/Rectangle) (MIT).

## Features

- **Keyboard placement**: halves, quarters, thirds, two-thirds, and maximize.
- **Restore**: snap a window back to where it was before the last placement.
- **Width cycling**: press the same left/right key again to step the width
  `1/2 → 2/3 → 1/3` (toggleable).
- **Move across displays**: send the front window to the next/previous display,
  keeping its relative size (proportional to the new screen).
- **Gaps**: even spacing between windows and screen edges (0 by default).
- **In-app language switch**: English / 日本語 / 한국어 / System — switch the
  app's language from Settings without changing your macOS system language.
- **Menu bar resident** with optional launch at login.
- **Guided first run** for Accessibility permission.

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon

## Install

### Homebrew (recommended)

```sh
brew install --cask gyugyu86/tap/sash
```

### Direct download

Grab the latest signed & notarized build from
[Releases](https://github.com/gyugyu86/Sash/releases), unzip, and move
`Sash.app` to `/Applications`.

## First launch

Sash needs **Accessibility** permission to move other apps' windows. On first
launch it shows a welcome window with a button to open
System Settings → Privacy & Security → Accessibility. Turn Sash on in the list;
the welcome window closes itself once permission is granted.

## Default shortcuts

All defaults use `⌃⌥` (Control + Option) so they don't clash with macOS Spaces
switching (`⌃` + arrows). Every shortcut is rebindable in Settings → Shortcuts.

| Action | Shortcut |
| --- | --- |
| Left / Right / Top / Bottom half | `⌃⌥` + ← / → / ↑ / ↓ |
| Top-left / Top-right / Bottom-left / Bottom-right | `⌃⌥` + U / I / J / K |
| Left / Center / Right third | `⌃⌥` + D / F / G |
| Left / Right two-thirds | `⌃⌥` + E / T |
| Maximize | `⌃⌥` + ↩ |
| Restore | `⌃⌥` + ⌫ |
| Move to previous / next display | `⌃⌥⌘` + ← / → |

## Privacy

Sash collects no data. It makes no network requests, has no analytics, and
stores only your preferences locally. The Accessibility permission is used
solely to position windows.

## Building from source

The project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen);
`project.yml` is the single source of truth (the generated `Sash.xcodeproj` and
`Sash/Info.plist` are git-ignored).

```sh
brew install xcodegen          # if needed
xcodegen generate
open Sash.xcodeproj             # then ⌘R in Xcode
```

CLI build & test (no signing required):

```sh
xcodegen generate
xcodebuild build -scheme Sash -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
xcodebuild test  -scheme Sash -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
```

Dependencies: [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) (SPM).

## Why not the Mac App Store?

A new app that controls other apps' windows via Accessibility cannot meet the
App Store's mandatory App Sandbox requirement (sandboxed apps can't drive other
apps over AX). Sash is therefore distributed directly: a Developer ID–signed and
notarized build via GitHub Releases and Homebrew.

## Roadmap

- **v1.1 — Named layouts (flagship)**: save the arrangement of multiple apps'
  windows as a named layout and restore it with one shortcut — the main thing
  Rectangle's free tier and macOS native tiling don't do.

## License

[MIT](LICENSE) © INGYU EUM
