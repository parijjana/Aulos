# Lesson: Avoiding Recursion in Derived State

## Context
ViewModels often provide derived boolean states like `isPlaying` or `currentMediaType` based on a combination of lower-level hardware variables.

## Problem
If `isPlaying` calls `currentMediaType`, and `currentMediaType` calls `isPlaying` (to determine if the "Active" type is actually currently making sound), an infinite recursive loop occurs. This leads to a **Stack Overflow** crash the moment a state change is emitted.

## Solution
Always calculate complex derived states using the **underlying private hardware variables** directly, rather than calling other public getters that might be interdependent.

### Implementation Pattern
```dart
// BAD
bool get isPlaying => currentMediaType == MediaType.music ? _hardwareIsPlaying : ...;
MediaType get currentMediaType => isPlaying ? _activeType : ...;

// GOOD
bool get isPlaying {
  if (_noiseVM?.isPlaying ?? false) return true;
  return _engineIsPlaying || _isBuffering; // Use private hardware flags
}

MediaType get currentMediaType {
  // Check private hardware flags directly
  if (_noiseVM?.isPlaying ?? false) return MediaType.noise;
  if (_engineIsPlaying) return _getMediaTypeForTrack(_currentTrack);
  // ...
}
```

## Benefits
- **Crash Prevention**: Eliminates risk of stack overflows.
- **Predictability**: State derivation logic becomes linear and easier to debug.
- **Performance**: Reduces the overhead of multiple getter calls during high-frequency stream events.
