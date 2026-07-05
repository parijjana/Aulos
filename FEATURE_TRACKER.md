## About
A high-performance, offline-first local audio player designed for focus and architectural elegance. It serves as a unified hub for Music, Podcasts, Audiobooks, and Radio.

## Stack
Flutter, Dart, Just_Audio, Drift

## GitHub
https://github.com/parijjana/AULOS

## Philosophy
Built with "Overengineered" quality at its heart, Aulos features a completely decoupled architecture where the Domain layer depends on nothing.

## Architecture
Presentation Layer (Flutter)
  ↓ observes
Domain Layer (Pure Dart)
  ↑ implemented by
Data Layer (Drift / Services)

## Capabilities
• Strategy-Pattern Playback: Contextual UI and controls that adapt automatically to the media type.<br>
• Aesthetic Systems: Winamp-style frequency visualizers and custom-painted waveform seekbars.<br>
• Hardened Resilience: Native thread-safety guarding for Windows (WinRT) and async disposal protection.

# Feature Tracker

## Features
- [x] 2026-06-11: **Universal Media Support:** Unified playback strategies for Music, Podcasts, Audiobooks, Radio, and Noise.
- [x] 2026-06-13: **Local Music Library:** High-performance filesystem indexing with metadata and artwork extraction.
- [x] 2026-06-13: **Podcast Discovery Suite:** Full RSS-based browser with trending categories, show notes (HTML), and timestamp seeking.
- [x] 2026-06-15: **LibriVox Storefront:** Public domain audiobook discovery with live streaming and download-to-local capabilities.
- [x] 2026-06-13: **Internet Radio Suite:** Worldwide station browser with live metadata (codec, bitrate) and "Add to Library" support.
- [x] 2026-06-13: **Adaptive Now Playing UI:** Contextual controls that change based on media type (e.g., skip-10s for podcasts vs. next-track for music).
- [x] 2026-06-13: **Aesthetic Systems:** Winamp-style frequency visualizers and zero-CPU track-specific waveform seekbars.
- [x] 2026-06-12: **Hardened Database Architecture:** Modularized Drift databases for isolated storage of music, audiobooks, and radio data.
- [x] 2026-06-06: **Cross-Device Sync:** Secure cryptographic handshake and discovery services for host/client role-agnostic logic.
- [x] 2026-06-13: **Responsive Layouts:** Mobile-to-Desktop adaptive views including compact/overlay modes for small viewports.
- [x] 2026-06-29: **Mood Dashboard:** A tiled launch screen surfacing the most recently played media across all domains (Music, Podcasts, Audiobooks, Noise) accessible via vertical scroll from the Now Playing screen.
- [ ] **Jamendo Music Integration:** High-quality royalty-free music streaming and discovery (Core implemented, UI currently parked).
- [x] 2026-07-04: **Advanced Smart Playlists:** Rule-based automated queue generation (ratings and metadata-driven).
- [ ] **Deep Metadata Enrichment:** Extended integration with MusicBrainz and Wikimedia for rich artist biographies and high-res covers.
- [ ] **Wikipedia Knowledge Integration:** Structured information display for artists, authors, podcast hosts/guests, and radio station history.
- [ ] **Visualizer Expansion:** Additional pluggable visualizer painters and theme-reactive coloring.
