# Design Philosophy: Navigation Hierarchy & Breadcrumbs

## Summary
The application maintains a clear navigational path using breadcrumbs and consistent primary/secondary navigation elements.

## Rationale
- **Context Awareness**: Users should always know where they are in the library (e.g., MUSIC > Artist > Album).
- **Predictable Exit**: The "Back" action should be consistent in every module, typically labeled with the name of the parent context (e.g., "LIBRARY").

## Expected Behavior
- **Main View Title**: The root of each module (Music, Podcasts, Radio) displays its name in the primary color, bold, with letter spacing.
- **Breadcrumbs**: Sub-views use a chevron separator (`>`) and a dimmed label for the parent context.
- **Library Button**: Deep sub-views feature a secondary "LIBRARY" button on the right to provide an immediate escape hatch to the module root.
