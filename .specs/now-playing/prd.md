# Now Playing View PRD

## Problem Statement

The current MiniPlayer is minimal and non-interactive beyond play/pause controls. Users cannot:
1. See a full-screen view of the currently playing track
2. View lyrics while listening
3. Scrub through the track with precision

## Solution

Create an expandable Now Playing experience:
1. **MiniPlayer**: Simplified - tappable to expand, shows track info and progress only
2. **NowPlayingView**: Full-screen sheet with album art, track info, synced lyrics, and draggable progress bar

## User Stories

### MiniPlayer
- As a user, I want to tap the MiniPlayer to see more details about the current track
- As a user, I want a clean, minimal player bar that doesn't distract from content

### Now Playing View
- As a user, I want to see large album artwork for the song I'm listening to
- As a user, I want to see lyrics that scroll automatically with the song
- As a user, I want to drag the progress bar to skip to any part of the song
- As a user, I want play/pause/skip controls in the full view
- As a user, I want to swipe down to dismiss and return to the MiniPlayer

## Scope

### In Scope
- Remove play/shuffle buttons from MiniPlayer
- Make MiniPlayer tappable to present NowPlayingView as sheet
- NowPlayingView with:
  - Large album artwork
  - Song name and artist
  - Synced scrolling lyrics (auto-scroll to current line)
  - Draggable progress bar with time labels
  - Play/pause button
  - Close/dismiss button
- Lyrics fetching from API (Musixmatch or similar)
- Graceful fallback when lyrics unavailable

### Out of Scope
- Skip to next/previous track (Spotify Free limitations)
- Queue management
- Sharing from Now Playing view
- Lyrics translation
- Karaoke mode (word-by-word highlighting)

## Success Metrics

1. MiniPlayer tap expands to full view
2. Lyrics display and auto-scroll with playback
3. Progress bar is draggable and seeks accurately
4. Smooth animations between states
