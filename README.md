# Aulos

A high-performance, offline-first local audio player designed for focus and architectural elegance. Aulos serves as a unified hub for Music, Podcasts, Audiobooks, Internet Radio, and Ambient Noise.

Designed with clean, decoupled layers, Aulos uses the **Strategy Pattern** to adapt its user interface and playback controls contextually to whatever media type is playing.

---

## Why Aulos?

In a digital landscape dominated by algorithmically curated streams, auto-play traps, and platforms designed to lease your attention rather than serve it, Aulos is built as a sanctuary.

It is an offline-first, focus-driven companion designed for intentional listening. When you listen through Aulos, you are not a data point in a feedback loop; you are simply someone experiencing music, learning from a podcast, getting lost in a public-domain audiobook, or resting to the hum of ambient noise.

Architecturally, Aulos mirrors this philosophy of quiet isolation. Its core domain layer is completely decoupled, refusing dependencies on external frameworks or cloud services. It is an exercise in software craftsmanship: quiet, stable, local, and entirely yours.

---

## Key Features

* **Unified Media Support:** Contextual playback strategies for Music, Podcasts, Audiobooks, Internet Radio, and Ambient Noise.
* **Adaptive Now Playing UI:** Controls that change with the media type (skip-10s for podcasts, next-track for music, stop for radio), with strategy-based scope locks that prevent queue crossover auto-play.
* **Handwritten Aesthetics:**
  * Winamp-style frequency visualizers (oscilloscopes and spectrum bars) running at a capped 30fps with lightweight compute matrices.
  * Zero-CPU, dynamically rendered waveform seekbars, custom-painted and seeded by track ID.
* **Local Music Library:** High-performance filesystem indexing with metadata and artwork extraction.
* **Deep Metadata Enrichment:** MusicBrainz, Wikimedia, and Wikipedia integration for rich artist and author biographies, high-resolution cover art, and structured knowledge panels.
* **Smart Playlists:** Rule-based automated queue generation driven by ratings and metadata.
* **Mood Dashboard:** A tiled launch screen surfacing the most recently played media across every domain, reachable by vertical scroll from the Now Playing screen.
* **Podcast Discovery Suite:** RSS and PodcastIndex-backed browser with trending categories, rich HTML show notes, and timestamp-based seeking.
* **LibriVox Audiobook Storefront:** Public-domain audiobook discovery, streaming, and offline downloading with interactive chapters and clips.
* **Internet Radio Suite:** Worldwide station browser with live metadata (codec, bitrate) and custom bookmarks.
* **Cross-Device Sync:** Secure cryptographic handshakes and discovery services for role-agnostic Host/Client sync.
* **Hardened Resilience:** Async disposal guards, native thread-safety marshalling (Windows WinRT Dispatcher Queue), indexer collision prevention, and throttled skips.

---

## Tech Stack

* **Core Framework:** [Flutter](https://flutter.dev) and [Dart](https://dart.dev)
* **Audio Engine:** [Just_Audio](https://pub.dev/packages/just_audio) and [Audio_Service](https://pub.dev/packages/audio_service)
* **Local Database:** [Drift](https://drift.simonbinder.eu/), a reactive SQL database for Dart
* **Workspace Packages** (under [packages/](packages)): `themer_sdk` (compile-time reactive theming), `media_fetcher` (MusicBrainz and metadata client), and `qr_secure_handshake` (cross-device pairing).

---

## Architecture

Aulos enforces strict dependency-flow boundaries:

```
Presentation Layer (Flutter)
        |  observes ViewModels
        v
  Domain Layer (Pure Dart / framework-agnostic entities and interfaces)
        ^
        |  implemented by
  Data Layer (Drift DB / concrete services and API dispatchers)
```

### Decoupled Rules
1. **No External Frameworks in Domain:** the Domain layer depends on nothing.
2. **Domain Model Symmetry:** all cross-layer communication uses abstract domain models (e.g. `PlaybackTrack`) rather than database-specific schemas.
3. **Manual Dependency Injection:** wiring happens through constructor injection in `lib/main.dart`; no global singletons.

---

## Project Status

Aulos is under active development. Code quality is enforced by an automated verification gate (`tool/gate.dart`) that must pass before any build:

* Static analysis with zero errors and zero warnings.
* A one-way file-size ratchet: existing large files may only shrink over time.
* Structural and layering rules that reject forbidden cross-layer imports.
* The full test suite passing.

Run it locally with `dart tool/gate.dart`.

---

## Getting Started

### Prerequisites
* Flutter SDK (3.x or higher)
* Android SDK (for mobile targets) or Visual Studio (for Windows desktop targets)

### Setup and Run
1. Clone the repository:
   ```bash
   git clone https://github.com/parijjana/Aulos.git
   ```
2. Get packages:
   ```bash
   flutter pub get
   ```
3. Run the database and code generators:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Start the application:
   ```bash
   flutter run
   ```

### Running Tests
The full test suite must pass before compiling build releases:
```bash
flutter test
```

---

## Roadmap

See [FEATURE_TRACKER.md](FEATURE_TRACKER.md) for the complete feature checklist and timeline. Upcoming work includes the Jamendo royalty-free streaming UI and pluggable visualizer expansion with theme-reactive coloring.
