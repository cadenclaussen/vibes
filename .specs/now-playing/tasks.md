# Now Playing Implementation Tasks

## Phase 1: MiniPlayer Updates

### Task 1.1: Simplify MiniPlayer
**File**: vibes/Views/Search/MiniPlayerView.swift
**Description**: Remove play/pause and close buttons. Keep: album art, track info, progress bar (non-interactive). Add tap gesture to present sheet.

### Task 1.2: Add sheet presentation state
**File**: vibes/Services/SpotifyRemoteService.swift
**Description**: Add `isNowPlayingPresented: Bool` property to control sheet presentation.

## Phase 2: Now Playing View Structure

### Task 2.1: Create NowPlayingView
**File**: vibes/Views/NowPlaying/NowPlayingView.swift
**Dependencies**: None
**Description**: Main full-screen view with album art, track info, placeholder for lyrics, progress bar, play/pause button.

### Task 2.2: Create InteractiveProgressBar
**File**: vibes/Views/NowPlaying/InteractiveProgressBar.swift
**Dependencies**: None
**Description**: Draggable progress bar with time labels. Calls SpotifyRemoteService.seek() on drag end.

### Task 2.3: Add seek functionality
**File**: vibes/Services/SpotifyRemoteService.swift
**Dependencies**: None
**Description**: Add `seek(to position: TimeInterval)` method using SPTAppRemote playerAPI.

## Phase 3: Lyrics Feature

### Task 3.1: Create Lyrics models
**File**: vibes/Models/SyncedLyrics.swift
**Dependencies**: None
**Description**: Create SyncedLyrics and LyricLine structs.

### Task 3.2: Create LyricsService
**File**: vibes/Services/LyricsService.swift
**Dependencies**: Task 3.1
**Description**: Service to fetch lyrics from LRCLIB API. Parse LRC format into SyncedLyrics model.

### Task 3.3: Create NowPlayingViewModel
**File**: vibes/ViewModels/NowPlayingViewModel.swift
**Dependencies**: Task 3.1, 3.2
**Description**: ViewModel managing lyrics state, current line tracking, and playback position sync.

### Task 3.4: Create LyricsView
**File**: vibes/Views/NowPlaying/LyricsView.swift
**Dependencies**: Task 3.3
**Description**: Scrollable lyrics view with auto-scroll, current line highlighting, loading/error states.

### Task 3.5: Integrate lyrics into NowPlayingView
**File**: vibes/Views/NowPlaying/NowPlayingView.swift
**Dependencies**: Task 3.3, 3.4
**Description**: Add LyricsView to NowPlayingView, wire up ViewModel.

## Phase 4: Integration & Polish

### Task 4.1: Wire MiniPlayer to NowPlayingView
**File**: vibes/Views/Search/MiniPlayerView.swift, vibes/ContentView.swift
**Dependencies**: Task 2.1
**Description**: Present NowPlayingView as sheet when MiniPlayer tapped.

### Task 4.2: Polish animations
**Dependencies**: All above
**Description**: Smooth sheet presentation, lyrics scroll animation, progress bar interaction.

### Task 4.3: Handle edge cases
**Dependencies**: All above
**Description**: No lyrics available, lyrics loading timeout, track changes while viewing, ad detection.

## Dependency Graph

```
Phase 1 (MiniPlayer)
    │
    ▼
Phase 2 (NowPlayingView)
    │
    ├──► Task 2.1 (View) ◄─────────────┐
    ├──► Task 2.2 (ProgressBar)        │
    └──► Task 2.3 (Seek)               │
                                       │
Phase 3 (Lyrics)                       │
    │                                  │
    ├──► Task 3.1 (Models)             │
    │       │                          │
    │       ▼                          │
    ├──► Task 3.2 (Service)            │
    │       │                          │
    │       ▼                          │
    ├──► Task 3.3 (ViewModel)          │
    │       │                          │
    │       ▼                          │
    └──► Task 3.4 (LyricsView)─────────┘
            │
            ▼
        Task 3.5 (Integration)
            │
            ▼
Phase 4 (Polish)
```

## Files to Create
- vibes/Views/NowPlaying/NowPlayingView.swift
- vibes/Views/NowPlaying/InteractiveProgressBar.swift
- vibes/Views/NowPlaying/LyricsView.swift
- vibes/ViewModels/NowPlayingViewModel.swift
- vibes/Models/SyncedLyrics.swift
- vibes/Services/LyricsService.swift

## Files to Modify
- vibes/Views/Search/MiniPlayerView.swift
- vibes/Services/SpotifyRemoteService.swift
