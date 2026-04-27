# HabitifyBar

A native macOS menu bar app that surfaces your [Habitify](https://habitify.me) habits without opening the Habitify app.

![HabitifyBar screenshot](screenshot.png)

## Features

- **Live count** — menu bar icon shows today's completed/total habit count at a glance
- **Habit list** — each row shows a color dot, habit name, flame streak badge, and current status icon; window height adjusts to content (no scroll for 5 or fewer habits, scrollable for more)
- **Action popover** — tap any habit row to reveal Done / Fail / Skip buttons; tap again to Undo
- **Filter modes** — choose how habits are filtered from the Settings window:
  - *All Habits* — show every habit regardless of time
  - *Current Time of Day* — automatically shows Morning, Afternoon, or Evening habits based on the clock
  - *By Time of Day* — reveals a tab bar to manually switch between Morning, Afternoon, and Evening
- **Settings window** — gear icon (or right-click the menu bar icon) opens a dedicated Settings window with filter mode selection and Launch at Login toggle
- **Right-click menu** — right-click the menu bar icon for quick access to Settings, Log Out, and Quit
- **Secure key storage** — first-run setup saves your Habitify API key to macOS Keychain
- **Manual refresh** — refresh button pulls the latest habit data on demand

## Requirements

- macOS 14 (Sonoma) or later
- Apple Silicon (arm64)
- Xcode Command Line Tools

## Installation

1. **Install Xcode Command Line Tools** if you haven't already:

   ```bash
   xcode-select --install
   ```

   Verify Swift is available:

   ```bash
   swift --version
   ```

2. **Clone the repository:**

   ```bash
   git clone https://github.com/xozai/HabitifyBar.git && cd HabitifyBar
   ```

3. **Build and install:**

   ```bash
   make install
   ```

   This compiles a release binary, assembles a signed `.app` bundle, and copies it to `~/Applications`.

4. **Launch the app:**

   ```bash
   open ~/Applications/HabitifyBar.app
   ```

5. **Connect your Habitify account** — on first launch, a setup screen appears. Paste your API key (found at Habitify → Settings → API → API Key) and click Connect.

6. **Optional — launch at login:** open Settings from the gear icon and enable Launch at Login.

## Updating

`make install` is idempotent — re-running it rebuilds and reinstalls cleanly over any existing version.

## Uninstalling

```bash
make uninstall
```

This removes `HabitifyBar.app` from `~/Applications`.

## Architecture

HabitifyBar is a Swift Package Manager project with no Xcode project file.

| Component | Role |
|---|---|
| `SwiftUI` + `MenuBarExtra` | Menu bar window (`.window` style); `LSUIElement = YES` suppresses the Dock icon |
| `HabitifyAPI` actor | async/await `URLSession` client; hits the Habitify V2 REST API (`api.habitify.me/v2`); API key sent as `X-API-Key` header; uses `POST /habits/{id}/logs` with `value + unitSymbol` to mark habits complete |
| `HabitViewModel` | `@Observable` class; drives all views; stores `filterMode` in UserDefaults; applies optimistic status updates and reverts on API failure |
| `FilterMode` | Enum with three cases (`allHabits`, `currentTimeOfDay`, `byTimeOfDay`); persisted to UserDefaults |
| `KeychainStore` | Thin enum wrapping `SecItemAdd` / `SecItemCopyMatching` from the Security framework |
| `LaunchAtLoginManager` | `@Observable` wrapper around `SMAppService.mainApp` |
| `Makefile` | Builds the release binary, assembles the `.app` bundle, ad-hoc codesigns it, and installs to `~/Applications` |

## License

MIT License

Copyright © 2026 xozai

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
