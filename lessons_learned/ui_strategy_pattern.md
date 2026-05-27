# Lesson: UI Strategy Pattern for Adaptive Controls

## Context
The "Now Playing" screen must support diverse media types (Music, Podcasts, Audiobooks, Radio, Ambient Noise), each with unique controls (Shuffle vs. Speed vs. Bookmark) and metadata.

## Problem
Monolithic widgets with massive `if/else` or `switch` blocks for every button and info field become impossible to maintain. Adding a feature for one media type (like chapters for books) often introduces layout bugs for others (like missing station info for radio).

## Solution
Apply the **Strategy Pattern** to the UI layer.

### Implementation Pattern
1. Define a `NowPlayingStrategy` interface with `buildContent` and `buildControls` methods.
2. Create concrete implementations for each media type.
3. The host widget selects the strategy based on the active `MediaType` and delegates the rendering.

```dart
abstract class NowPlayingStrategy {
  Widget buildControls(BuildContext context, PlayerViewModel vm, ...);
  Widget buildContent(BuildContext context, PlayerViewModel vm, ...);
}

class AudiobookStrategy implements NowPlayingStrategy { ... }
```

## Benefits
- **Logic Isolation**: Changing the chapter list logic for books cannot break the music queue.
- **Clean Code**: Individual strategy files remain small and focused (under our 200-line threshold).
- **Extensibility**: Adding a "Video" or "Stream" mode only requires a new strategy implementation, not a refactor of the entire screen.
