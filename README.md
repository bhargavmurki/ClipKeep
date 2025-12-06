# ClipKeep

_A fast, menu-bar–only clipboard manager for macOS with a sleek drop-down experience._

## Features

- **Menu Bar–Only UI**: Click the doc icon in the menu bar to open the drop-down popover; no separate window.
- **Instant History**: Captures clipboard changes automatically and keeps them deduplicated.
- **Search & Hover Details**: Filter quickly; hover any row to reveal source, timestamp, and copy count.
- **Light/Dark Friendly**: SwiftUI styling with subtle hover/press feedback for a modern feel.
- **One-Tap Actions**: Click to re-copy, clear all, or quit directly from the popover.

## Installation

```bash
git clone https://github.com/yourusername/ClipKeep.git
cd ClipKeep
open ClipKeep.xcodeproj   # or: xed .
```

Build & run in Xcode (Cmd+R) targeting “My Mac”. The menu bar icon (`doc.on.doc.fill`) hosts the entire experience.


## Usage
- Click the menu bar icon to open the popover; items are shown newest-first.
- Hover a row to see source, date/time, and copy frequency; click to copy.
- Use the search bar for quick filtering; “Clear All” wipes history; “Quit” exits the menu item.

## Build & Test (CLI)

- Build: `xcodebuild -scheme ClipKeep -destination 'platform=macOS' build`
- Test: `xcodebuild test -scheme ClipKeep -destination 'platform=macOS'` (UI tests currently skipped by design; add menu-bar scenarios before enabling).

## Security & Data

- Sandbox is enabled with user-selected read-only access; no network or external permissions.
- Clipboard history is stored locally under Application Support (`ClipKeep.store`). No data leaves the device.
- No secrets, API keys, or provisioning profiles are committed; keep it that way when contributing.

# License
MIT License

Copyright (c) 2024 Bhargav Murki
