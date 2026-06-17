# Sash

A keyboard-first window manager for macOS. Snap, resize, and move windows with
a few shortcuts — fast, quiet, and out of your way. Sash lives in the menu bar,
has no Dock icon, and collects no data.

> Built from scratch as a modern, friendlier successor to ShiftIt; window-move
> logic references [Rectangle](https://github.com/rxhanson/Rectangle) (MIT).

## Features

- **Keyboard placement**: halves, quarters, thirds, two-thirds, and maximize.
- **Restore**: snap a window back to where it was before the last placement.
- **Width cycling**: press the same left/right key again to step the width
  `1/2 → 2/3 → 1/3` (toggleable).
- **Move across displays**: send the front window to the next/previous display,
  or jump it straight to a specific display (up to 6), keeping its relative size.
- **Gaps**: even spacing between windows and screen edges (0 by default).
- **In-app language switch**: English / 日本語 / 한국어 / 简体中文 / System — switch
  the app's language from Settings without changing your macOS system language.
- **Menu bar resident** with optional launch at login.
- **Guided first run** for Accessibility permission.
- **Lightweight**: a live memory/CPU readout in the About tab shows how little
  Sash uses.
- **Optional update check**: off by default; when enabled, fetches only the
  latest version number from GitHub (no personal data sent).

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

On first launch macOS shows a one-time "Sash is an app downloaded from the
Internet — are you sure you want to open it?" prompt — click **Open**. It even
says Apple checked it for malware and found none (that's the notarization). It
won't appear again, and Homebrew installs skip it entirely.

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
| Move to display 1 / 2 / 3 | `⌃⌥⌘` + 1 / 2 / 3 (4–6 assignable) |

## Privacy

Sash collects no data, has no analytics, and stores only your preferences
locally. By default it makes no network requests; the optional update check
(off by default) fetches only the latest version number from GitHub when you
turn it on. The Accessibility permission is used solely to position windows.

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

## Known limitations

- Sash positions windows within the **current Space**. It does not create,
  delete, or switch macOS Spaces (virtual desktops), and can't restore window
  layouts across multiple Spaces — macOS exposes no public API for that. Use the
  built-in Mission Control shortcuts (`⌃` + number) to switch Spaces.

## Roadmap

Sash aims to stay small and predictable rather than match every feature of
larger tools. No big features are planned; fixes and polish only.

## License

[MIT](LICENSE) © INGYU EUM
