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

## Now Playing Architecture (Strategy Pattern)
The `NowPlayingScreen` follows a **Strategy Pattern** to handle diverse media types within a unified visual frame.

- **NowPlayingHost**: Manages the common frame (Glass card, Volume, Background gradient).
- **NowPlayingStrategy**: Interface defining media-specific `buildContent()` and `buildControls()`.
- **Implementations**: `MusicStrategy`, `PodcastStrategy`, `AudiobookStrategy`, `RadioStrategy`, `NoiseStrategy`.

### 1. Contextual Controls
| Media Type | Primary Controls | Secondary Controls | Specialized |
| :--- | :--- | :--- | :--- |
| **Music** | Prev, Next, Play/Pause | Shuffle, Repeat | Ratings |
| **Podcast** | -10s, +15s, Play/Pause | Speed (0.5x-2.0x) | Bookmark |
| **Audiobook** | Prev, Next, -10s, +15s, Play/Pause | Speed (0.5x-2.0x) | Bookmark/Chapters |
| **Radio** | Play/Stop | - | Library Add |
| **Noise** | Play/Pause | - | Tune/Mix |

### 2. Information Area (Bottom Section)
- **Music:** Displays the **Queue** (Up Next) with mini-art.
- **Audiobook:** Dual-pane **Chapters & Clips** view. Prioritizes `.cue` markers.
- **Podcast:** Displays **Show Notes** (HTML supported) with timestamp seeking.
- **Radio:** Displays live **Stream Metadata** and station homepage link.
- **Noise:** Displays loop source and CC0 attribution details.

### 3. State Management
The `PlayerViewModel` is responsible for identifying the `MediaType` based on the launch source and providing the appropriate command set to the UI.
