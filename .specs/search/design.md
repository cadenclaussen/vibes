# Search Feature Design

## Architecture

```
ExploreView (existing)
    |
    v
SearchResultsView
    |
    v
SearchViewModel (@Observable)
    |
    v
SpotifyDataService (add search methods)
    |
    v
Spotify Web API
```

## Data Flow

1. User types in search bar (ExploreView)
2. SearchViewModel debounces input (300ms)
3. Calls SpotifyDataService.search(query:)
4. API returns artists, albums, tracks
5. Results displayed in sections
6. Tap play → AudioPreviewManager plays 30s clip
7. Tap result → opens in Spotify

## UI Design

### Explore Tab with Search Active

```
+----------------------------------+
| [< ] Search songs, artists...  X |  <- Search bar
+----------------------------------+
|                                  |
|  RECENT SEARCHES                 |  <- When focused, empty query
|  [clock] drake                   |
|  [clock] blinding lights         |
|  [clock] taylor swift            |
|                     [Clear All]  |
+----------------------------------+
```

### Search Results

```
+----------------------------------+
| [< ] "drake"                   X |
+----------------------------------+
|                                  |
|  ARTISTS                         |
|  +----+ Drake                    |
|  |img | Hip-Hop, Rap        [>] |
|  +----+                          |
|  +----+ Drake Bell               |
|  |img | Pop                 [>] |
|  +----+                          |
|                       [See All]  |
+----------------------------------+
|  ALBUMS                          |
|  +----+ Views                    |
|  |img | Drake - 2016        [>] |
|  +----+                          |
|  +----+ Scorpion                 |
|  |img | Drake - 2018        [>] |
|  +----+                          |
|                       [See All]  |
+----------------------------------+
|  SONGS                           |
|  +----+ One Dance           3:27 |
|  |img | Drake            [play] |
|  +----+                          |
|  +----+ God's Plan          3:19 |
|  |img | Drake            [play] |
|  +----+                          |
|                       [See All]  |
+----------------------------------+
|                                  |
|  [mini player: One Dance  [||] ] |  <- When preview playing
+----------------------------------+
```

## Components

### SearchViewModel

```swift
@Observable
class SearchViewModel {
    var query: String = ""
    var artists: [UnifiedArtist] = []
    var albums: [UnifiedAlbum] = []
    var songs: [UnifiedTrack] = []
    var recentSearches: [String] = []

    var isSearching = false
    var hasSearched = false
    var error: Error?

    func search() async
    func clearSearch()
    func addRecentSearch(_ query: String)
    func clearRecentSearches()
}
```

### AudioPreviewManager

```swift
@Observable
class AudioPreviewManager {
    static let shared = AudioPreviewManager()

    var currentTrack: UnifiedTrack?
    var isPlaying = false
    var progress: Double = 0

    func play(_ track: UnifiedTrack) async
    func pause()
    func stop()
}
```

### UI Components

- **SearchResultsView**: Container showing all result sections
- **ArtistSearchRow**: Artist image, name, genres
- **AlbumSearchRow**: Album art, name, artist, year
- **SongSearchRow**: Album art, title, artist, duration, play button
- **RecentSearchesView**: List of recent queries
- **MiniPlayerView**: Floating preview player

## API Endpoints

### Search
```
GET https://api.spotify.com/v1/search
?q={query}
&type=artist,album,track
&limit=5
&market=US
```

### Extended Search (See All)
```
GET https://api.spotify.com/v1/search
?q={query}
&type={artist|album|track}
&limit=20
&market=US
```

## State Management

```swift
enum SearchState {
    case idle           // Default explore content
    case focused        // Search bar focused, show recent
    case searching      // Loading results
    case results        // Showing results
    case empty          // No results found
    case error(Error)   // Search failed
}
```

## Audio Preview

Using AVPlayer for 30-second preview URLs:

```swift
class AudioPreviewManager {
    private var player: AVPlayer?

    func play(_ track: UnifiedTrack) {
        guard let urlString = track.previewURL,
              let url = URL(string: urlString) else { return }

        player = AVPlayer(url: url)
        player?.play()
    }
}
```

## Navigation

Search lives in ExploreView. No new tabs or navigation destinations needed for MVP.

Optional future: Artist/Album detail views as push navigation.

## Persistence

Recent searches stored in UserDefaults:
- Key: `recentSearches`
- Value: `[String]` (last 10 queries)
