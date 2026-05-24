# Feature: Radio Health Monitoring & Visibility

## Summary
A background system that verifies the availability of saved radio stations and provides UI tools to manage the clutter of the library.

## Rationale
Internet radio streams are volatile and often go offline. Startup health checks inform the user of dead links before they attempt playback. Visibility controls allow users to "archive" stations they don't want to see every day without permanently deleting them.

## Expected Behavior
- **Startup Health Check**: Pings all stations in the user's library upon application launch.
- **Availability Indicators**: Stations are marked with a green dot (available) or red dot (unavailable/error) on their favicon.
- **Hidden Status**: Users can hide stations via a context menu. Hidden stations are removed from the default view.
- **Visibility Toggle**: A "SHOW HIDDEN" button appears in the library to reveal archived stations.
- **Manual Health Check**: Adding a manual station triggers an immediate health check for that entry.
