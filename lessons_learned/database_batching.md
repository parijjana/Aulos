# Lesson: High-Volume Database Ingestion (Batching)

## Context
Aulos performs periodic synchronization of external data, such as marketplace search results (50-200 items) or audiobook chapter markers (30-100 items).

## Problem
Performing sequential `await into(table).insert(item)` calls in a loop causes high database thread contention. On slower hardware (or during heavy IO), this results in significant UI jank, "database is busy" exceptions, and slow ingestion times.

## Solution
Always use **`batch((b) => ...)`** for operations involving more than 10-20 rows.

### Implementation Pattern
```dart
await batch((b) {
  b.insertAll(table, companions, mode: InsertMode.insertOrReplace);
});
```

## Benefits
- **Atomic Transactions**: Ingestion is all-or-nothing, preventing corrupted partial states.
- **Drastic Speed Increase**: Batching hundreds of rows is often 10x-50x faster than individual inserts.
- **UI Smoothness**: Reduces the duration the database lock is held, allowing UI watchers to fire more efficiently.
