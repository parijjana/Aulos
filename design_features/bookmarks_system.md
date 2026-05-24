# Feature: Bookmarks & Audio Clips

## Summary
A reusable system for marking specific segments of an audio file for quick reference.

## Rationale
Crucial for podcasts and audiobooks where users want to save specific insights or interesting parts without manual scrubbing.

## Expected Behavior
- **Creation**: A Range Slider UI to select start and end times.
- **Persistence**: Save title and timestamps to the database.
- **Playback**: A dedicated "Saved Clips" tab that plays only the bounded segment and stops automatically.
