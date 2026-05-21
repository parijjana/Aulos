# Aulos: Architecture Map (ARCH_MAP)

## Core Rules
- **R1 (DI):** Manual constructor injection only; no singletons.
- **R2 (Gatekeeper):** Centralized `RateLimitDispatcher` for all external APIs.
- **R3 (Symmetry):** Host/Client logic must be role-agnostic.
- R4 (TDD): Every feature must be verified by a corresponding test in the `test/` directory.
- R5 (Quality): Maintain a minimum 85% test coverage floor. Health Checks must verify this before major releases.


## System Overview
- **Domain Layer:** Pure Dart logic and interfaces.
- **Data Layer:** Implementation of domain interfaces (e.g., `JustAudioPlaybackEngine`).
- **Presentation Layer:** Flutter widgets and ViewModels.
- **Core Layer:** Utilities and shared components like `RateLimitDispatcher`.

## Now Playing: Source of Truth (UX)
The `NowPlayingScreen` must adapt dynamically based on the `MediaType` of the active stream:

### 1. Contextual Controls
| Media Type | Primary Controls | Secondary Controls | Specialized |
| :--- | :--- | :--- | :--- |
| **Music** | Prev, Next, Play/Pause | Shuffle, Repeat | - |
| **Podcast** | -10s, +15s, Play/Pause | Speed (0.5x-2.0x) | Bookmark |
| **Audiobook** | Prev, Next, -10s, +15s, Play/Pause | Speed (0.5x-2.0x) | Bookmark |
| **Radio** | Play/Stop | - | Station Meta |

### 2. Information Area (Bottom Section)
- **Music & Audiobook:** Displays the **Queue** (Up Next). Tapping an item skips to it.
- **Podcast:** Displays **Show Notes** (HTML supported). 
    - **Timestamps:** Tapping `[00:12:34]` seeks the player to that position.
    - **Web Links:** Opens in the system browser.
- **Radio:** Displays live **Stream Metadata** (e.g., current song/show title from ICY headers).

### 3. State Management
The `PlayerViewModel` is responsible for identifying the `MediaType` based on the launch source and providing the appropriate command set to the UI.
