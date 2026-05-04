# ClipKeep

_A macOS menu-bar clipboard manager built with SwiftUI and SwiftData._

## Current State

ClipKeep runs as a menu-bar app and stores clipboard history locally on the device. The active experience is a popover opened from the status-bar icon or with `Cmd+Shift+V`.

The app currently captures:

- Text clips
- Image clips (`png`/`tiff` data from the macOS pasteboard)

## Features

- **Menu-bar workflow**: No main app window is required for normal use.
- **Clipboard history**: New clips are stored newest-first in a local SwiftData store.
- **Deduplication**: Re-copying the same text or image updates an existing entry and increments its copy count.
- **Search**: Search is available in the popover for text clips.
- **Quick actions**: Click a row to copy it again, or use the context menu to copy/delete.
- **Image thumbnails**: Image clips render with a small preview in the menu-bar list.
- **Global hotkey**: `Cmd+Shift+V` toggles the popover and focuses search.

## Known Limitations

- Search only matches text clips today.
- Image support exists, but the image UX is still minimal.
- `ContentView.swift` remains in the project as older window-style UI and is not the primary app flow.
- Automated tests are mostly placeholders right now; UI tests are skipped.

## Installation

```bash
git clone https://github.com/yourusername/ClipKeep.git
cd ClipKeep
open ClipKeep.xcodeproj
```

Run the app from Xcode targeting `My Mac`.

## Usage

- Click the menu-bar icon to open the clipboard history popover.
- Copy text or images anywhere in macOS; ClipKeep will capture supported pasteboard changes.
- Click a clip to copy it back to the clipboard.
- Use the search field to filter text history.
- Use `Clear All` to remove stored history or `Quit` to exit the app.

## Build & Test

```bash
xcodebuild -scheme ClipKeep -destination 'platform=macOS' build
xcodebuild test -scheme ClipKeep -destination 'platform=macOS'
```

Note: the test targets exist, but current coverage is minimal and UI tests are intentionally skipped.

## Data & Security

- Clipboard history is stored locally in Application Support as `ClipKeep.store`.
- No network access or remote sync is built into the app.
- The repo should not contain signing assets, secrets, or provisioning profiles.

## License

MIT License

Copyright (c) 2024 Bhargav Murki
