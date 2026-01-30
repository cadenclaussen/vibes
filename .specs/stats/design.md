# Stats Feature Design

## Architecture

```
ProfileView
    |
    v
StatsPreviewCard (mini view, shows top 3 artists)
    |
    v (tap)
StatsView (full view)
    |
    v
StatsViewModel (@Observable)
    |
    v
SpotifyDataService (existing)
    |
    v
Spotify Web API
```

## Data Flow

1. User navigates to Profile tab
2. StatsPreviewCard fetches minimal data (top 3 artists)
3. User taps card → navigates to full StatsView
4. StatsView fetches complete data:
   - GET /me/top/artists
   - GET /me/top/tracks
   - GET /me/player/recently-played
5. Extract genres from top artists
6. Display data in sections

## UI Design

### Profile Integration

```
+----------------------------------+
|  Profile                    [⚙️] |
+----------------------------------+
|         [Profile Photo]          |
|          Display Name            |
|           @username              |
|                                  |
|     [0 Following]  [0 Followers] |
+----------------------------------+
|                                  |
|  YOUR STATS                      |
|  +------------------------------+|
|  | [img] [img] [img]            ||
|  | Artist Artist Artist    [>] ||
|  | Top artists this month       ||
|  +------------------------------+|
|                                  |
+----------------------------------+
|  (Future: Achievements section)  |
+----------------------------------+
```

### StatsPreviewCard (on Profile)

Compact card showing just enough to entice tap:
- Top 3 artist images in a row
- Artist names
- Subtitle: "Top artists this month"
- Chevron indicating tap for more

```
+----------------------------------------+
|  Your Stats                            |
|  +------+  +------+  +------+          |
|  | img1 |  | img2 |  | img3 |     [>]  |
|  +------+  +------+  +------+          |
|  Drake, Taylor Swift, The Weeknd       |
|  Your top artists this month           |
+----------------------------------------+
```

### Full StatsView (push navigation)

```
+----------------------------------+
|  < Profile    Stats      [4w v] |  <- Back + Time range picker
+----------------------------------+
|                                  |
|  TOP ARTISTS                     |
|  +----+  +----+  +----+  +----+  |
|  | 1  |  | 2  |  | 3  |  | 4  |  |  <- Horizontal scroll
|  +----+  +----+  +----+  +----+  |
|  Name   Name   Name   Name       |
|                                  |
+----------------------------------+
|  TOP SONGS                       |
|  +------------------------------+|
|  | 1. Song Title                ||
|  |    Artist Name          [>] ||  <- Tap opens Spotify
|  +------------------------------+|
|  | 2. Song Title                ||
|  |    Artist Name          [>] ||
|  +------------------------------+|
|  ...                             |
+----------------------------------+
|  TOP GENRES                      |
|  [Rock] [Pop] [Hip-Hop] [R&B]   |  <- Chips/tags
|                                  |
+----------------------------------+
|  RECENTLY PLAYED                 |
|  +------------------------------+|
|  | Song Title                   ||
|  | Artist - 5 min ago           ||
|  +------------------------------+|
|  ...                             |
+----------------------------------+
```

## Components

### StatsPreviewCard
- Shows on Profile
- Fetches top 3 artists only (lightweight)
- Horizontal row of 3 artist images (48x48)
- Comma-separated artist names
- Subtitle with time context
- Tap navigates to full StatsView
- If no Spotify: shows "Connect Spotify to see your stats"

### StatsView (Full Screen)
Contains four sections:

#### TopArtistsSection
- Horizontal ScrollView
- Artist cards: 80x80 image, name below
- Rank number overlay (1, 2, 3...)
- Tap opens artist in Spotify

#### TopSongsSection
- Vertical List (top 10)
- Row: rank, album art (40x40), title, artist, Spotify link icon
- Tap opens in Spotify

#### TopGenresSection
- Horizontal flow of genre chips
- Chip style: rounded rectangle, secondary background
- Derived from top artists' genres

#### RecentlyPlayedSection
- Vertical List (last 20)
- Row: album art (40x40), title, artist, relative time ("5 min ago")
- Tap opens in Spotify

### Time Range Picker
- Menu in navigation bar (not segmented control - cleaner)
- Options: "4 Weeks" | "6 Months" | "All Time"
- Default: 4 Weeks (most relevant/recent)

## API Endpoints

### Top Artists
```
GET https://api.spotify.com/v1/me/top/artists
?time_range={short_term|medium_term|long_term}
&limit=10
```

### Top Tracks
```
GET https://api.spotify.com/v1/me/top/tracks
?time_range={short_term|medium_term|long_term}
&limit=10
```

### Recently Played
```
GET https://api.spotify.com/v1/me/player/recently-played
?limit=20
```

## State Management

```swift
enum TimeRange: String, CaseIterable {
    case shortTerm = "short_term"   // 4 weeks
    case mediumTerm = "medium_term" // 6 months
    case longTerm = "long_term"     // All time

    var displayName: String {
        switch self {
        case .shortTerm: return "4 Weeks"
        case .mediumTerm: return "6 Months"
        case .longTerm: return "All Time"
        }
    }
}

struct RecentTrack: Identifiable {
    let id: String
    let track: UnifiedTrack
    let playedAt: Date
}

@Observable
class StatsViewModel {
    var timeRange: TimeRange = .shortTerm
    var topArtists: [UnifiedArtist] = []
    var topSongs: [UnifiedTrack] = []
    var topGenres: [String] = []
    var recentlyPlayed: [RecentTrack] = []
    var isLoading = false
    var error: Error?

    // For preview card (lightweight fetch)
    var previewArtists: [UnifiedArtist] = []
    var isLoadingPreview = false

    func loadPreview() async      // Fetches top 3 artists only
    func loadStats() async        // Fetches all data
    func refresh() async          // Pull-to-refresh
    func setTimeRange(_ range: TimeRange) async
}
```

## Navigation

```swift
// In AppRouter
enum StatsDestination: Hashable {
    case stats
}

func navigateToStats() {
    profilePath.append(StatsDestination.stats)
}

// In ProfileView
.navigationDestination(for: StatsDestination.self) { _ in
    StatsView()
}
```

## Future Considerations

This design leaves room for:
1. **Editable taste** - Stats could evolve to let users pin/hide artists
2. **Achievements section** - Profile can add another card below Stats
3. **Sharing stats** - Share button in StatsView toolbar
4. **Comparisons** - Compare stats with friends (future social feature)
