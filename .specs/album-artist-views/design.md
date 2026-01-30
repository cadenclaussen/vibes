# Album Detail & Artist Profile Design

## Architecture

### Components

```
AlbumDetailView
├── AlbumHeaderView (cover, metadata, buttons)
├── AlbumTrackRow (repeated for each track)
└── MiniPlayerView

ArtistProfileView
├── ArtistHeaderView (image, name, genres)
├── Top Songs Section (SongSearchRow reused)
├── ArtistAlbumsSection (horizontal scroll)
└── MiniPlayerView
```

### ViewModels

**AlbumDetailViewModel**
- Properties: album, tracks, isLoading, error
- Methods: loadTracks(), playTrack(), playAll(), shuffle()

**ArtistProfileViewModel**
- Properties: artist, topTracks, albums, isLoading, error
- Methods: loadData(), playTrack()

### Navigation

Album and Artist types already conform to Hashable and are registered in ContentView's navigationDestination. Update placeholders to use real views.

## UI Mockups

### Album Detail View
```
┌─────────────────────────────┐
│       [Album Cover]         │
│         300x300             │
│                             │
│      Album Name             │
│      Artist Name →          │
│    2024 • 12 tracks         │
│                             │
│   [▶ Play]  [⤮ Shuffle]    │
├─────────────────────────────┤
│ 1  Track Name         3:45  │
│ 2  Track Name [E]     4:12  │
│ 3  Track Name         3:21  │
│ ...                         │
├─────────────────────────────┤
│ [MiniPlayer if playing]     │
└─────────────────────────────┘
```

### Artist Profile View
```
┌─────────────────────────────┐
│ ╔═══════════════════════════╗
│ ║   Artist Header Image     ║
│ ║   with gradient overlay   ║
│ ║                           ║
│ ║   Artist Name             ║
│ ║   [Pop] [Rock] [Indie]    ║
│ ╚═══════════════════════════╝
├─────────────────────────────┤
│ Top Songs                   │
│ ┌───┬─────────────────┬────┐│
│ │ ♫ │ Song Name       │3:45││
│ │ ♫ │ Song Name       │4:12││
│ │ ♫ │ Song Name       │3:21││
│ └───┴─────────────────┴────┘│
├─────────────────────────────┤
│ Albums                      │
│ ┌─────┐ ┌─────┐ ┌─────┐    │
│ │     │ │     │ │     │ →  │
│ │Album│ │Album│ │Album│    │
│ └─────┘ └─────┘ └─────┘    │
├─────────────────────────────┤
│ [MiniPlayer if playing]     │
└─────────────────────────────┘
```

## API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/albums/{id}` | getAlbumTracks() | Get album tracks |
| `/artists/{id}/top-tracks` | getArtistTopTracks() | Get artist's popular songs |
| `/artists/{id}/albums` | getArtistAlbums() | Get artist's discography |

## State Management

Both ViewModels use @Observable pattern:
- Loading state during API calls
- Error state for failed requests
- Success state with populated data

Playback state managed by SpotifyRemoteService (environment object).

## Color Scheme

- Album cover uses dynamic sizing based on scroll position (optional future enhancement)
- Artist header uses gradient overlay (black to transparent, bottom to top)
- Genre chips use secondary background color
- Explicit badge uses red "E" in rounded rectangle
