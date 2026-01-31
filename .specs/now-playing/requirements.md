# Now Playing Requirements

## Functional Requirements (EARS Format)

### MiniPlayer Updates

**REQ-MINI-1**: The MiniPlayer shall NOT display play/pause or close buttons.

**REQ-MINI-2**: The MiniPlayer shall display: album art thumbnail, track name, artist name, and progress bar.

**REQ-MINI-3**: When the user taps anywhere on the MiniPlayer, the system shall present the NowPlayingView as a full-screen sheet.

**REQ-MINI-4**: The MiniPlayer progress bar shall be non-interactive (display only).

### Now Playing View

**REQ-NOW-1**: The NowPlayingView shall display the album artwork at a large size (minimum 300x300 points).

**REQ-NOW-2**: The NowPlayingView shall display the track name and artist name below the artwork.

**REQ-NOW-3**: The NowPlayingView shall display a progress bar showing current position and total duration.

**REQ-NOW-4**: When the user drags the progress bar, the system shall seek to the corresponding position in the track.

**REQ-NOW-5**: The progress bar shall display elapsed time on the left and remaining time on the right.

**REQ-NOW-6**: The NowPlayingView shall display a play/pause button that toggles playback state.

**REQ-NOW-7**: When the user swipes down or taps a close button, the system shall dismiss the NowPlayingView.

### Lyrics

**REQ-LYR-1**: When the NowPlayingView loads, the system shall fetch lyrics for the current track.

**REQ-LYR-2**: If synced (timed) lyrics are available, the system shall display them in a scrollable view.

**REQ-LYR-3**: The lyrics view shall automatically scroll to keep the current line visible and highlighted.

**REQ-LYR-4**: The current lyric line shall be visually distinguished (larger font, brighter color, or highlight).

**REQ-LYR-5**: Past lyrics shall appear dimmed, future lyrics shall appear at normal opacity.

**REQ-LYR-6**: If lyrics are unavailable, the system shall display a "Lyrics not available" message.

**REQ-LYR-7**: While lyrics are loading, the system shall display a loading indicator.

## Non-Functional Requirements

**REQ-NFR-1**: The sheet presentation animation shall complete within 300ms.

**REQ-NFR-2**: Lyrics scrolling shall be smooth (60fps) without jank.

**REQ-NFR-3**: Seeking via progress bar shall respond within 500ms.

**REQ-NFR-4**: The NowPlayingView shall support both light and dark mode.
