# Lesson: Database Overlap Isolation in Split-Architecture Projects

## Context
When refactoring a monolithic database into domain-specific split databases (e.g., separating `AppDatabase` for music from `AudiobookDatabase` for audiobooks), data files are decoupled into separate SQLite stores, but domain models (like `Album` or `Artist`) and shared view models (like `LibraryViewModel`) may remain shared.

## Problem
If separate database files are used, they will both start auto-incrementing integer primary keys from `1`. If the view models or services reuse generic domain model wrappers (e.g. `Album`) without explicitly branching on the media type context (e.g., `isAudiobook == true`), key overlap collisions occur. 
Calling a shared retrieval method (like `getTracksForAlbum(album.id)`) or updating table metadata (like updating `db.albums` with the audiobook ID) will route requests to the wrong database, causing music albums with ID `1` to receive audiobook metadata or play music tracks instead of audiobook chapters.

## Solution
1. **Context-Aware Routing:** In shared controllers, view models, or services, always inspect the media type properties (e.g., `item.isAudiobook`) before querying or writing.
2. **Explicit Database Targets:** Avoid generic database getter helpers that default to a single database. Explicitly route audiobook queries to `audiobookDb` and music queries to `db` (AppDatabase).
3. **Specific Helper Methods:** Use distinct interface methods (e.g. `getChapters(bookId)` for audiobooks and `getTracksForAlbum(albumId)` for music) instead of overloaded or generic getters.

### Routing Example
```dart
Future<List<Track>> getTracksForItem(dynamic item) async {
  if (item is Album) {
    if (item.isAudiobook) {
      return _libraryService.getChapters(item.id);
    }
    return _libraryService.getTracksForAlbum(item.id);
  }
  ...
}
```

## Benefits
- **Strict Data Isolation:** Prevents overlapping key collisions from returning incorrect tracks or crossing database boundaries.
- **Clean Architecture:** Preserves the decoupling of domain logic while reusing standard presentation wrappers.
