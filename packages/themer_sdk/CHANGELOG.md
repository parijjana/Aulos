# Changelog - Themer SDK

## [1.2.0] - 2026-05-09

### Added
- **Visual Styles Support**: Added formal support for `style` in `ThemerEffects`. Supported values: `glass`, `flat`, `hatched`, `ceramic`.
- **Explicit Effects Properties**: Added `opacity` and `blur` as first-class properties in `ThemerEffects` model and JSON spec.
- **Contrast Mandate**: Added logic in `ThemerParser` to ensure all standard color tokens are parsed, enabling better readability for light/dark themes.

### Changed
- **Breaking Change**: `ThemerEffects` is no longer limited to `roundness` and `elevation`.
- **Parser Update**: `ThemerParser` now looks for the new effects fields in `.themer` (JSON) files.

### Fixed
- **Readability**: Themes can now explicitly define `onSurface`, `onBackground`, etc., allowing for dark text on light backgrounds or vice versa, solving previous contrast issues in lighter themes.
