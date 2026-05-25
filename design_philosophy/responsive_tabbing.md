# Design Philosophy: Responsive Tabbing vs. Stacking

## Summary
When the user interface is constrained (narrow windows or mobile screens), multi-pane layouts must transition to a single-pane tabbed view rather than a vertically stacked list.

## Rationale
- **Cognitive Load**: Vertical stacking in complex views (like Podcast Details) results in "Endless Scroll" fatigue and hides important secondary information (like show notes) beneath long lists.
- **Stability**: Tabbed views provide bounded constraints for sub-widgets (like TabBarViews), preventing layout crashes and ensuring smooth scrolling.
- **Focus**: Tabs allow the user to perform one task at a time (Browse episodes vs. Read notes) without visual distraction from other panes.

## Expected Behavior
- **Transition Point**: Large layouts (e.g., 3-pane horizontal) should collapse into a `DefaultTabController` with a top `TabBar` when the width falls below a specific threshold (typically 900-1100px).
- **Tab Identity**: Tabs must be clearly labeled (e.g., INFO, EPISODES, NOTES) and maintain their internal scroll state during tab swaps.
- **Automatic Scaling**: The primary content (like cover art) should scale to fill the width of the tabbed container.
