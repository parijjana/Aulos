# Lesson: Drift Database Migration Alignment

## Context
When adding or altering tables in a Flutter app using Drift/SQLite, new schema fields are defined in `tables.dart`.

## Problem
If new columns are added to `tables.dart` without incrementing `schemaVersion` and adding corresponding `onUpgrade` migration paths, existing users' databases will not be updated. When Drift tries to query those tables, it expects non-nullable columns to be present. In SQLite, missing columns return `null`, causing Drift's generated code to throw a runtime `"Null check operator used on a null value"` crash.

## Solution
Whenever a schema changes:
1. **Increment `schemaVersion`** in `app_database.dart`.
2. **Add `onUpgrade` block** in `MigrationStrategy` to run the corresponding `m.addColumn(...)` or table creation for the old schema versions.

### Migration Example
```dart
@override
int get schemaVersion => 23; // Increment version

// In MigrationStrategy:
onUpgrade: (m, from, to) async {
  ...
  if (from < 23) {
    await m.addColumn(albums, albums.librivoxId);
    await m.addColumn(albums, albums.isDownloadedViaAulos);
    await m.addColumn(tracks, tracks.isStream);
  }
}
```

## Benefits
- **Zero-Crash Schema Upgrades**: Safe migrations for existing users without data loss or application crashes.
- **Null Safety Alignment**: Ensures Drift's generated code gets non-null values for all declared non-nullable fields.
