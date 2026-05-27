# Lesson: Deep State Isolation in Multi-Hub Apps

## Context
Aulos features multiple independent media hubs (Music, Audiobooks, Podcasts) within a single application frame.

## Problem
Using a single "selectedItem" or "navigationStack" variable in a global ViewModel causes state leakage. For example, if a user selects an Audiobook chapter and then switches to the Music tab, the Music tab might rebuild and try to display that Audiobook item, leading to UI corruption or crashes.

## Solution
Implement a **State Map** within the ViewModel to isolate navigation data per media mode.

### Implementation Pattern
1. Create a `NavigationState` container class.
2. Maintain a `Map<Mode, NavigationState>` in the ViewModel.
3. Provide mode-specific getters for the UI.

```dart
class LibraryNavigationState {
  final List<dynamic> navStack = [];
  dynamic selectedItem;
  // ... loaded tracks, scroll offsets, etc.
}

// In ViewModel
final Map<LibraryMode, LibraryNavigationState> _states = {};
LibraryNavigationState stateFor(LibraryMode m) => _states[m]!;
```

## Benefits
- **Zero Leakage**: Switching tabs never corrupts the view of another tab.
- **State Persistence**: Users can leave an Audiobook halfway through a chapter list, browse Music, and return to the exact same spot in the Audiobook hub.
- **Architectural Scalability**: Adding a new hub (e.g., Radio Library) is as simple as adding a new key to the state map.
