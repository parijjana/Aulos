# Behavioral Feature: View State & Scroll Retention

## Summary
The system preserves the visual state of parent screens when navigating into sub-views or swapping tabs. This specifically includes scroll positions in lists and grids, and active page indices in carousels or page views.

## Rationale
Prevents user disorientation and "context loss" when performing deep dives into the library. Users expect to return to the exact spot they left off in a long list of albums or podcasts.

## Expected Behavior
- **Scroll Persistence**: All major scrollable views (Music Grid, Podcast List, Radio Browser) must use `PageStorageKey` to automatically persist scroll offsets in the global `PageStorage`.
- **Navigation Sync**: When stepping into a sub-view (e.g., Artist -> Album) and returning, the parent list must remain at the previous scroll position.
- **Tab Swapping**: Switching between "Library" and "Browser" tabs in Podcasts/Radio must maintain the scroll position and active state of each tab independently.
- **Manual Overrides**: In cases where `PageStorage` is insufficient (e.g., complex nested navigation), ViewModels must explicitly save and restore offsets via `saveScrollOffset()` and `restoreScrollOffset()` methods.
