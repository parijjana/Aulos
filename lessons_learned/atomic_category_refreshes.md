# Lesson: Atomic Database Category Refreshes

## Context
Aulos uses a `DiscoveryDatabase` with a bridge table (`DiscoveryCategoryRelations`) to link podcasts to categories like "Trending" or "Search:Query".

## Problem
Simply inserting new search results doesn't clear the old ones. Over time, a search for "Podcast A" will also return results for "Podcast B" (from a previous search) if they were both tagged with the same generic "Search" category ID, leading to a cluttered and incorrect UI.

## Solution
Always **clear existing bridge relations** for a specific category ID before inserting new ones within an atomic operation.

### Implementation Pattern
```dart
Future<void> upsertPodcasts(List<Companion> podcasts, String categoryId) async {
  // 1. Clear old relations for THIS specific query/category
  await (delete(discoveryCategoryRelations)..where((t) => t.categoryId.equals(categoryId))).go();

  await batch((b) {
    // 2. Insert/Update the actual items
    b.insertAll(discoveredPodcasts, podcasts, mode: InsertMode.insertOrReplace);
    // 3. Link them to the fresh category
    for (var p in podcasts) {
      b.insert(discoveryCategoryRelations, ...);
    }
  });
}
```

## Benefits
- **Data Integrity**: Search results always accurately reflect the latest API response.
- **UI Consistency**: Prevents "phantom items" from appearing in lists.
- **Atomic State**: The delete + insert sequence ensures the UI never sees a partial or corrupted state.
