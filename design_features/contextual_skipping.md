# Behavioral Feature: Contextual Media Skipping

## Summary
The player limits playback transitions (Auto-Skip, Skip Next/Prev) to the current media context. For example, if playing a Podcast, the player will never skip to a Music track even if both are in the queue.

## Rationale
Prevents jarring context shifts. Users listening to a podcast series expect to stay within that series or at least within the "Spoken Word" category, rather than being suddenly switched to music when an episode ends or is unavailable.

## Expected Behavior
- **Podcast Scope**: If the current media is a Podcast, skipping (auto or manual) will only proceed if the next item is also a Podcast. If the next item is Music, the player stops.
- **Radio Scope**: Radio stations never auto-skip to other items. Manual skip is ignored.
- **Music Scope**: Standard skipping logic applies within the music queue.
- **Error Handling**: If a podcast episode fails to load, it will attempt to skip to the next podcast in the queue instead of falling back to the first available music track.
