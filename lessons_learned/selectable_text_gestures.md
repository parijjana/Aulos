# Lesson: SelectionArea and SelectableText Conflicts

## Context
In Flutter, text selection can be enabled page-wide or container-wide using `SelectionArea`, or on specific text widgets using `SelectableText`.

## Problem
Nesting a `SelectableText` widget inside a parent `SelectionArea` causes selection gesture conflicts. Both widgets attempt to capture gestures (tap, drag, long-press) and manage selection handles, resulting in the text becoming completely unselectable and copy-paste capabilities being broken.

## Solution
Use a standard `Text` widget inside a `SelectionArea` rather than `SelectableText`. `SelectionArea` automatically detects and handles selection for all descendant `Text` widgets, enabling smooth drag-selection, copy-paste, and scrolling.

### Implementation Pattern
```dart
// CORRECT: SelectionArea manages text selection for descendants
SelectionArea(
  child: Scrollbar(
    child: SingleChildScrollView(
      child: Text(
        logBuffer,
        style: TextStyle(fontFamily: 'monospace'),
      ),
    ),
  ),
)
```

## Benefits
- **Clean Gesture Delivery**: No widget-level gesture overlapping.
- **Copy-Paste Selectability**: Fully functional text selection and copying.
- **Natural Scrolling**: Smooth integration with scrollbars and mouse-drags.
