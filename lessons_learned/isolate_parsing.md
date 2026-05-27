# Lesson: Isolate-Based Data Parsing

## Context
Aulos processes large amounts of external data, specifically RSS feeds for podcasts and large JSON responses from the iTunes search API.

## Problem
Parsing a 2MB RSS feed or a search response with 200+ items using `RssFeed.parse()` or `json.decode()` on the main thread causes the UI to "freeze" or drop frames. This is because Dart is single-threaded, and heavy synchronous computation blocks the event loop.

## Solution
Always offload heavy data transformation to a background isolate using Flutter's `compute()` function.

### Implementation Pattern
1. Define a **top-level function** for the parsing logic (it cannot be a non-static method of a class).
2. Call it using `await compute(function, data)`.

```dart
// TOP LEVEL
RssFeed _parseRss(String body) => RssFeed.parse(body);

// INSIDE SERVICE
final rss = await compute(_parseRss, response.body);
```

## Benefits
- **Zero UI Lag**: The main thread remains responsive to user input and animations.
- **Improved Stability**: Prevents "Application Not Responding" (ANR) triggers on mobile.
