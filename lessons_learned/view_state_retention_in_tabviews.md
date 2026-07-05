# Lesson Learned: View State Retention in TabViews

## The Problem
When using Flutter's `TabBarView` or `PageView` for nested tab navigation (such as swapping between "Your Library" and "Find More" tabs in Podcasts, Audiobooks, and Radio), child states are automatically disposed by the Flutter framework when they are not actively visible. 

When the user returns, the screen's `State` class is re-instantiated from scratch, resulting in a frustrating user experience:
* Scroll offsets in grids and lists are reset back to `0.0`.
* Active text search parameters and filtered lists are wiped out.
* Deeply nested sub-pages (like active category details) are lost, forcing the user to start over.

## The Solution
To deliver a desktop-browser-like tab experience where each tab operates as an independent navigable sandbox:

1. **Equip State Classes with `AutomaticKeepAliveClientMixin`**:
   All discover, search, and library view states that sit directly as pages inside parent `PageView`/`TabBarView` widgets must mix in `AutomaticKeepAliveClientMixin` and override `wantKeepAlive` to return `true`:
   ```dart
   class _BrowserScreenState extends State<BrowserScreen> with AutomaticKeepAliveClientMixin {
     @override
     bool get wantKeepAlive => true;

     @override
     Widget build(BuildContext context) {
       super.build(context); // Must be called first!
       return Scaffold(...);
     }
   }
   ```

2. **Leverage unique `PageStorageKey` identifiers**:
   To guarantee scroll persistence, assign unique keys to the primary list/grid builders in each tab:
   ```dart
   ListView.builder(
     key: const PageStorageKey('radio_browser_list'),
     ...
   )
   ```

3. **Avoid Re-fetching in `initState`**:
   Ensure `initState` or building lifecycle hooks do not reset ViewModel states or trigger fresh API calls if data is already loaded, preventing unnecessary network and compute cycles when returning to a cached tab.
