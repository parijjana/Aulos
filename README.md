# Aulos

A high-performance, offline-first local audio player designed for focus and architectural elegance. Aulos serves as a unified hub for Music, Podcasts, Audiobooks, Internet Radio, and Ambient Noise.

Designed with clean, decoupled layers, Aulos uses the **Strategy Pattern** to adapt its user interface and playback controls contextually to whatever media type is playing.

---

## 🕯️ Why Aulos?

In a digital landscape dominated by algorithmically curated streams, auto-play traps, and platforms designed to lease your attention rather than serve it, Aulos is built as a sanctuary. 

It is an offline-first, focus-driven companion designed for intentional listening. When you listen through Aulos, you are not a data point in a feedback loop; you are simply someone experiencing music, learning from a podcast, getting lost in a public-domain audiobook, or resting to the hum of ambient noise. 

Architecturally, Aulos mirrors this philosophy of quiet isolation. Its core domain layer is completely decoupled, refusing dependencies on external frameworks or cloud services. It is an exercise in software craftsmanship—quiet, stable, local, and entirely yours.

---

## 🚀 Key Features

* **Unified Media Support:** Strategies for Music, Podcasts, Audiobooks, Radio, and Noise.
* **Handwritten Aesthetics:** 
  * Winamp-style frequency visualizers (oscilloscopes and spectrum bars running at capped 30fps with lightweight compute matrices).
  * Zero-CPU, dynamically rendered waveform seekbars custom-painted and seeded by track ID.
* **Local Music Library:** High-performance filesystem indexing with metadata and artwork extraction.
* **Podcast Discovery Suite:** Full RSS-based browser with trending categories, rich HTML show notes, and timestamp-based seeking.
* **LibriVox Audiobook Storefront:** Public domain audiobook discovery, streaming, and offline downloading with interactive chapters/clips support.
* **Internet Radio Suite:** Worldwide station browser with live metadata (codec, bitrate) and custom bookmarks.
* **Cross-Device Sync:** Secure cryptographic handshakes and discovery services for role-agnostic Host/Client sync.
* **Hardened Resilience:** Async disposal guards, native thread-safety marshalling (Windows WinRT Dispatcher Queue), indexer collision prevention, and throttled skips.

---

## 🛠️ Tech Stack

* **Core Framework:** [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
* **Audio Engine:** [Just_Audio](https://pub.dev/packages/just_audio) & [Audio_Service](https://pub.dev/packages/audio_service)
* **Local Database:** [Drift](https://drift.simonbinder.eu/) (Reactive SQL database for Dart)
* **Custom Theming:** [Themer SDK](file:///D:/Programming/geminicli/LocalAudioPlayer/packages/themer_sdk) (Compile-time reactive custom visual styling)

---

## 🏗️ Architecture

Aulos enforces strict dependency flow boundaries:

```
Presentation Layer (Flutter)
       ↓ (observes ViewModels)
  Domain Layer (Pure Dart / Framework-Agnostic Entities & Interfaces)
       ↑ (implemented by)
  Data Layer (Drift DB / Concrete Services & API Dispatchers)
```

### Decoupled Rules
1. **No External Frameworks in Domain:** The Domain layer depends on nothing.
2. **Domain Model Symmetry:** All communication across layers uses abstract domain models (e.g. `PlaybackTrack`) rather than database-specific model schemas.
3. **Manual Dependency Injection:** Manual constructor injection is used inside [main.dart](file:///D:/Programming/geminicli/LocalAudioPlayer/lib/main.dart); no magic/global singletons.

---

## 🛠️ Getting Started

### Prerequisites
* Flutter SDK (3.x or higher)
* Android SDK (for mobile targets) or Visual Studio (for Windows desktop targets)

### Setup & Run
1. Clone the repository:
   ```bash
   git clone https://github.com/parijjana/AULOS.git
   ```
2. Get packages:
   ```bash
   flutter pub get
   ```
3. Run database/code generators:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Start the application:
   ```bash
   flutter run
   ```

### Running Tests
Aulos requires TDD-verified implementation. The full suite of tests must pass before compiling build releases:
```bash
flutter test
```

---

## 📜 Development Guidelines & Lore
For deep details on our engineering strategies, layout structures, and design tokens, see the internal documentation:
* [ARCHITECTURE.md](file:///D:/Programming/geminicli/LocalAudioPlayer/ARCHITECTURE.md) - Deep structural map and system rules.
* [FEATURE_TRACKER.md](file:///D:/Programming/geminicli/LocalAudioPlayer/FEATURE_TRACKER.md) - High-level user features checklist and release timeline.
* [GEMINI.md](file:///D:/Programming/geminicli/LocalAudioPlayer/GEMINI.md) - Project mandates and operational rules.
