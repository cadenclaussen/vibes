# Now Playing Design

## Architecture

### Components

```
MiniPlayerView (updated)
├── Album art thumbnail (40x40)
├── Track info (name, artist)
├── Progress bar (non-interactive)
└── Tap gesture -> presents NowPlayingView

NowPlayingView (new)
├── DragIndicator (pill at top)
├── Album artwork (300x300)
├── Track info (name, artist)
├── LyricsView
│   ├── Loading state
│   ├── Lyrics scroll view
│   └── "Not available" state
├── ProgressBarView (interactive)
│   ├── Slider
│   ├── Elapsed time label
│   └── Remaining time label
└── PlayPauseButton
```

### Services

**LyricsService** (new)
- Fetches lyrics from external API
- Parses synced lyrics (LRC format or JSON timestamps)
- Caches lyrics by track ID
- Methods: `getLyrics(trackId:, trackName:, artistName:) async throws -> SyncedLyrics?`

### Models

**SyncedLyrics**
```swift
struct SyncedLyrics {
    let lines: [LyricLine]
}

struct LyricLine: Identifiable {
    let id: UUID
    let text: String
    let startTime: TimeInterval  // seconds
    let endTime: TimeInterval?   // optional
}
```

## UI Mockups

### MiniPlayer (Updated)
```
┌─────────────────────────────────────────┐
│ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬░░░░░░░░░░░░░░░░░░░░░░░ │  <- progress bar
│ ┌────┐                                  │
│ │ 🎵 │  Song Name                       │
│ │    │  Artist Name                     │
│ └────┘                                  │
└─────────────────────────────────────────┘
        ^ tap anywhere to expand
```

### NowPlayingView (Full Screen Sheet)
```
┌─────────────────────────────────────────┐
│              ─────                      │  <- drag indicator
│                                         │
│         ┌─────────────────┐             │
│         │                 │             │
│         │   Album Cover   │             │
│         │     300x300     │             │
│         │                 │             │
│         └─────────────────┘             │
│                                         │
│           Song Name                     │
│           Artist Name                   │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│     ♪ Previous lyric line (dimmed)      │
│                                         │
│   ► CURRENT LYRIC LINE (highlighted)    │
│                                         │
│     ♪ Next lyric line                   │
│     ♪ Future lyric line                 │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  1:23 ▬▬▬▬▬▬▬▬▬●░░░░░░░░░░░░░░░ -2:15  │
│                                         │
│               advancement button              │
│                                         │
└─────────────────────────────────────────┘
```

## Lyrics API Options

### Option 1: Musixmatch API (Recommended)
- Has synced lyrics with timestamps
- Free tier: 2000 calls/day
- Requires API key
- Endpoint: `matcher.lyrics.get` + `track.subtitles.get`

### Option 2: LRCLIB (Free, no API key)
- Community-contributed synced lyrics
- No rate limits
- Less coverage than Musixmatch
- Endpoint: `https://lrclib.net/api/get?artist_name={}&track_name={}`

### Option 3: Spotify Lyrics (Not Available)
- Spotify has lyrics but no public API
- Would require reverse engineering (not recommended)

**Recommendation**: Start with LRCLIB (free, no key needed), fallback to plain text "lyrics not available"

## State Management

**NowPlayingViewModel**
```swift
@Observable
class NowPlayingViewModel {
    var lyrics: SyncedLyrics?
    var isLoadingLyrics: Bool
    var lyricsError: Error?
    var currentLineIndex: Int

    func loadLyrics(for track: UnifiedTrack)
    func updateCurrentLine(playbackPosition: TimeInterval)
}
```

## Interaction Details

### Progress Bar Dragging
1. User touches progress bar
2. Playback continues but progress updates pause
3. User drags to desired position
4. On release, seek to new position
5. Resume progress updates

### Lyrics Scrolling
1. Timer checks playback position every 100ms
2. Find lyric line where `startTime <= position < nextLine.startTime`
3. If line changed, scroll to center that line with animation
4. Update highlighting

## Accessibility

- VoiceOver: Read current lyric line
- Dynamic Type: Scale lyrics text
- Reduce Motion: Disable auto-scroll, show static view
