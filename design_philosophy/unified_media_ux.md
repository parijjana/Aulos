# Design Philosophy: Unified Media UX

## Summary
A standardized architectural and UX framework applied to all media modules (Music, Podcasts, Radio) and future expansions (Audiobooks, Noise Loops). The goal is zero learning curve when switching between media types.

## 1. Unified Navigation & Header Structure
Every media root screen MUST adhere to a unified, horizontal header layout to conserve vertical space and provide predictable navigation.

### Header Components (Left to Right):
1.  **Module Title / Breadcrumb**: 
    - At root: Primary color, bold, letter-spaced (e.g., `MUSIC`, `PODCASTS`).
    - In sub-view: Back button (`<`) followed by dimmed parent context and bright current context (e.g., `< MUSIC > ALBUM`).
2.  **Primary Navigation (Tabs)**:
    - Root level categorization (e.g., `GENRE | COUNTRY | LANGUAGE` for Radio, `YOUR LIBRARY | FIND MORE` for Podcasts).
    - Rendered as dense, pill-shaped buttons that highlight when active.
3.  **Flexible Spacer**: Pushes controls to the right.
4.  **Module-Specific Tools**:
    - **Search**: Must be a *collapsible* icon button (`Icons.search`) that expands into a text field over the header space to prevent permanent UI clutter.
    - **Filters/Layouts**: Collapsed into a single dropdown (`PopupMenuButton`). E.g., The `Icons.grid_view_rounded` button containing List/Grid/Orbit options.
5.  **Global Actions**: Refresh/Sync buttons or Manual Add actions.
6.  **Escape Hatch (Sub-views only)**: A secondary `LIBRARY` button on the far right of sub-views to instantly jump back to the module root.

## 2. Responsive Layouts (Tabbing vs. Stacking)
- **Desktop/Wide (>1100px)**: Utilize horizontal space. Use multi-pane layouts (e.g., 3-pane podcast details) or persistent sidebars (e.g., Bookmark viewer).
- **Mobile/Narrow (<900px)**: NEVER use infinitely scrolling vertical stacks for complex views. 
    - Convert sidebars to End-Drawers.
    - Convert multi-pane details into a `DefaultTabController` (e.g., `INFO | EPISODES | NOTES`).

## 3. Contextual Isolation (Scope Locks)
- **Playback**: The audio engine must never auto-skip across media boundaries. A podcast queue ending should never trigger a random music track.
- **UI State**: Entering an error state (e.g., dead radio link) must lock the UI to the *intended* media type, preventing the display from falling back to music queue elements.

## 4. Future Expansions Blueprint

### Audiobooks (Future)
- **Header**: `AUDIOBOOKS` -> `YOUR LIBRARY | STORE/FIND MORE`
- **Layout**: Adapts the Podcast 3-pane layout. `INFO | CHAPTERS | SAVED CLIPS`.
- **Playback**: Shares Podcast resume logic (`PlaybackPositions`) and dual-slider Bookmark UX.

### Noise Loops (Future)
- **Header**: `NOISE` -> `NATURE | URBAN | BINAURAL`
- **Layout**: Grid-first, utilizing the Radio Browser's popularity sorting logic.
- **Playback**: Shares Radio's "Live Stream" UI logic (no functional seekbar, infinite duration) but adds a built-in Sleep Timer overlay.
