# Lesson: Robust Windows Playback (Unicode & Large Files)

## Context
Just_audio on Windows relies on the native `libwinmedia` or similar backends which often have legacy path parsing limitations.

## Problem
1. **Unicode Characters**: Files with characters like the high-colon (`꞉`) in their name fail to load on Windows because the OS path string is incorrectly handled by the audio backend.
2. **Massive Files**: Large .m4b audiobooks (>500MB) can sometimes trigger "interrupted" errors during initial path resolution.

## Solution
Use a custom **`FileStreamSource`** (extending `StreamAudioSource`) to stream bytes directly from Dart to the engine.

### Implementation Pattern
1. Open the file in Dart using `File(path).openRead()`.
2. Wrap the stream in a `StreamAudioSource`.
3. Provide the correct MIME type (e.g., `audio/mp4` for .m4b) explicitly to help the backend decoder.

## Benefits
- **Hardware Independence**: Bypasses backend path parsing bugs by providing a raw byte stream.
- **Universal Support**: Correctly handles every possible Unicode character that the filesystem supports.
- **Improved Performance**: Allows for more granular control over the playback buffer for massive files.
