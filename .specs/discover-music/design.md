# Discover Music - Design

## Overview

A queue-based music discovery feature using Spotify's Recommendations API. Users see 5 song cards at a time, with 5 more buffered. Dismissing a song reveals the next in queue. The queue auto-replenishes when it drops below 7 songs, providing a seamless, endless discovery experience.

## Tech Stack

- **Framework**: SwiftUI with iOS 17+ Observation
- **Architecture**: MVVM with @Observable
- **Data Source**: Spotify Recommendations API (`/v1/recommendations`)
- **Dependencies**: Existing SpotifyAuthService, SpotifyDataService
- **Navigation**: NavigationStack with type-safe destinations

## Architecture Diagram

```
+------------------+     +------------------------+     +----------------------+
|   ContentView    |     |  DiscoverMusicView     |     | DiscoverMusicViewModel |
|   (FeedView)     |---->|  (Main Discovery UI)   |---->|  (@Observable)       |
+------------------+     +------------------------+     +----------------------+
        |                         |                              |
        v                         v                              v
+------------------+     +------------------------+     +----------------------+
| DiscoverMusic    |     |  SongDiscoveryCard     |     | SpotifyDataService   |
| Card (Widget)    |     |  (Individual Card)     |     | (API calls)          |
+------------------+     +------------------------+     +----------------------+
                                                                 |
                                                                 v
                                                        +----------------------+
                                                        | Spotify API          |
                                                        | /v1/recommendations  |
                                                        | /v1/me/top/tracks    |
                                                        +----------------------+
```

## Component Design

### New Files

#### vibes/Views/DiscoverMusic/DiscoverMusicView.swift
- **Type**: View
- **Purpose**: Main discovery view showing 5 song cards with dismissal interaction
- **Dependencies**: DiscoverMusicViewModel, AppRouter
- **Key Properties**:
  - `@State private var viewModel = DiscoverMusicViewModel()`
  - `@Environment(AppRouter.self) private var router`
- **Key Methods**:
  - Body renders loading/error/content states
  - `dismissSong(at:)` handles card dismissal with animation

#### vibes/Views/DiscoverMusic/SongDiscoveryCard.swift
- **Type**: View
- **Purpose**: Individual song card showing album art, title, artist with dismiss/action buttons
- **Dependencies**: UnifiedTrack
- **Key Properties**:
  - `let track: UnifiedTrack`
  - `let onDismiss: () -> Void`
  - `let onPlay: () -> Void`
  - `@State private var isPlaying: Bool`
- **Key Methods**:
  - Body renders card with album art, text, buttons
  - Context menu with long-press actions

#### vibes/ViewModels/DiscoverMusicViewModel.swift
- **Type**: ViewModel (@Observable)
- **Purpose**: Manages song queue, fetches recommendations, handles dismissals
- **Dependencies**: SpotifyDataService, SpotifyAuthService
- **Key Properties**:
  ```swift
  var songQueue: [UnifiedTrack] = []
  var visibleSongs: [UnifiedTrack] { Array(songQueue.prefix(5)) }
  var dismissedSongIds: Set<String> = []
  var seedTrackIds: [String] = []

  var isLoading: Bool = false
  var isReplenishing: Bool = false
  var error: Error?
  ```
- **Key Methods**:
  - `loadInitialRecommendations()` - Fetch seeds and initial 10 songs
  - `dismissSong(at:)` - Remove song, trigger replenish if needed
  - `replenishQueueIfNeeded()` - Background fetch when < 7 songs
  - `fetchRecommendations(count:)` - Call Spotify API

### Modified Files

#### vibes/Services/SpotifyDataService.swift
- **Changes**: Add methods for Recommendations API and Top Tracks
- **New Methods**:
  ```swift
  func getTopTracks(limit: Int, timeRange: SpotifyTimeRange) async throws -> [UnifiedTrack]
  func getRecommendations(seedTracks: [String], limit: Int) async throws -> [UnifiedTrack]
  ```
- **New Private Models**:
  ```swift
  private struct SpotifyTopTracksResponse: Decodable
  private struct SpotifyRecommendationsResponse: Decodable
  private struct SpotifyTrack: Decodable
  ```

#### vibes/Services/AppRouter.swift
- **Changes**: Add navigation destination for Discover Music
- **New Properties**:
  ```swift
  func navigateToDiscoverMusic() {
      feedPath.append(DiscoverMusicDestination.main)
  }
  ```
- **New Destination**:
  ```swift
  enum DiscoverMusicDestination: Hashable {
      case main
  }
  ```

#### vibes/ContentView.swift
- **Changes**: Add DiscoverMusicCard to FeedView, register navigation destination
- **New Components**:
  - `DiscoverMusicCard` struct (follows ConcertDiscoveryCard pattern)
  - `.navigationDestination(for: DiscoverMusicDestination.self)`

## Data Flow

```
User Opens Feature
        |
        v
+-------------------+
| Load Top Tracks   |  <-- getTopTracks(limit: 5, timeRange: .mediumTerm)
| (Seeds)           |
+-------------------+
        |
        v
+-------------------+
| Fetch 10 Songs    |  <-- getRecommendations(seedTracks: [...], limit: 10)
+-------------------+
        |
        v
+-------------------+
| Display 5 Songs   |  <-- visibleSongs computed property
| Buffer 5 Songs    |
+-------------------+
        |
        v (user dismisses)
+-------------------+
| Remove from Queue |
| Check Count       |
+-------------------+
        |
        v (if count < 7)
+-------------------+
| Background Fetch  |  <-- replenishQueueIfNeeded()
| Append to Queue   |
+-------------------+
```

## Data Models

### Queue Management (ViewModel Internal)
```swift
@Observable
class DiscoverMusicViewModel {
    // Core queue (max 10, replenish at < 7)
    var songQueue: [UnifiedTrack] = []

    // Computed: first 5 are visible
    var visibleSongs: [UnifiedTrack] {
        Array(songQueue.prefix(5))
    }

    // Track dismissed songs to avoid duplicates
    var dismissedSongIds: Set<String> = []

    // Seeds for recommendations (top 5 track IDs)
    var seedTrackIds: [String] = []

    // Queue thresholds
    private let queueTargetSize = 10
    private let replenishThreshold = 7
}
```

### Spotify API Response Models (Private)
```swift
private struct SpotifyTopTracksResponse: Decodable {
    let items: [SpotifyTrack]
}

private struct SpotifyRecommendationsResponse: Decodable {
    let tracks: [SpotifyTrack]
}

private struct SpotifyTrack: Decodable {
    let id: String
    let name: String
    let artists: [SpotifyTrackArtist]
    let album: SpotifyTrackAlbum
    let previewUrl: String?
    let uri: String
    let durationMs: Int
    let explicit: Bool
    let popularity: Int

    enum CodingKeys: String, CodingKey {
        case id, name, artists, album, uri, explicit, popularity
        case previewUrl = "preview_url"
        case durationMs = "duration_ms"
    }

    func toUnifiedTrack() -> UnifiedTrack { ... }
}
```

## State Management

### View State Hierarchy
```
DiscoverMusicView
    |
    +-- @State viewModel: DiscoverMusicViewModel
    |       |
    |       +-- songQueue: [UnifiedTrack]
    |       +-- isLoading: Bool
    |       +-- isReplenishing: Bool (no UI indicator)
    |       +-- error: Error?
    |
    +-- @Environment router: AppRouter
```

### State Transitions
1. **Initial**: `isLoading = true`, empty queue
2. **Loaded**: `isLoading = false`, queue has 10 songs
3. **Dismissing**: Remove song, animate, check threshold
4. **Replenishing**: `isReplenishing = true` (background, no UI change)
5. **Error**: `error != nil`, show error view with retry

### Animation States
```swift
// Card dismissal animation
withAnimation(.easeOut(duration: 0.25)) {
    viewModel.dismissSong(at: index)
}

// New card appearance
.transition(.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
))
```

## Error Handling

### Error Types
```swift
enum DiscoverMusicError: LocalizedError {
    case noSeedData          // No top tracks available
    case spotifyNotConnected // Auth not configured
    case networkError(Error) // API call failed
    case exhausted           // No more recommendations

    var errorDescription: String? { ... }
    var recoverySuggestion: String? { ... }
}
```

### Recovery Strategies
| Error | UI | Recovery |
|-------|----|---------|
| spotifyNotConnected | Connect Spotify button | Navigate to SpotifySetupView |
| noSeedData | Empty state with guidance | Suggest listening on Spotify |
| networkError | Retry button | Call loadInitialRecommendations() |
| exhausted | Info message | Suggest trying again later |

### Auth Error Detection (Reuse Pattern)
```swift
private func isSpotifyAuthError(_ error: Error) -> Bool {
    // Reuse existing pattern from ConcertDiscoveryView
    if let authError = error as? SpotifyAuthError {
        switch authError {
        case .notAuthenticated: return true
        case .tokenExchangeFailed(let msg):
            let lower = msg.lowercased()
            return lower.contains("revoked") || lower.contains("invalid")
        default: return false
        }
    }
    return false
}
```

## Security Considerations

- **Token Management**: Use existing SpotifyAuthService.getValidAccessToken() which handles refresh
- **No Local Caching**: Per Spotify ToS, don't persist recommendation results
- **Dismissed IDs**: Store only track IDs (not full data) for duplicate filtering
- **Memory**: Clear dismissed IDs when view disappears (Session-scoped)

## Performance Considerations

### Lazy Loading
- Only 10 songs in memory at any time
- Album art uses AsyncImage with system caching
- Background replenishment prevents blocking UI

### Network Optimization
- Batch fetch: Request 10 songs, show 5, buffer 5
- Replenish threshold (< 7) provides buffer for slow networks
- Single API call per replenishment (not per song)

### Animation Performance
- Use simple opacity + position animations
- Avoid heavy effects during transitions
- Cards are lightweight (single HStack + image)

### Memory Management
```swift
// Clear session data on dismiss
.onDisappear {
    viewModel.clearSession()
}
```

## Accessibility

### VoiceOver Support
```swift
SongDiscoveryCard(track: track, ...)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(track.name) by \(track.artistName)")
    .accessibilityHint("Double tap to dismiss. Long press for more options.")
    .accessibilityAddTraits(.isButton)
```

### Dynamic Type
- All text uses semantic font styles (.headline, .subheadline, .caption)
- Card layout responds to text size changes
- Minimum tap target 44x44pt

### Accessibility Actions
```swift
.accessibilityAction(named: "Dismiss") {
    onDismiss()
}
.accessibilityAction(named: "Add to Playlist") {
    // Show playlist picker
}
.accessibilityAction(named: "Open in Spotify") {
    // Open URI
}
```

## UI Layout

### Card Design
```
+--------------------------------------------------+
|  +--------+                                       |
|  |        |  Song Title                    [>]   |
|  | Album  |  Artist Name                         |
|  |  Art   |  Album Name                    [X]   |
|  |        |                                       |
|  +--------+                                       |
+--------------------------------------------------+
     64x64      .headline / .subheadline    Play/Dismiss
```

### View Layout
```
+--------------------------------------------------+
|  < Back          Discover Music                  |
+--------------------------------------------------+
|                                                  |
|  +--------------------------------------------+  |
|  | Song Card 1                                |  |
|  +--------------------------------------------+  |
|                                                  |
|  +--------------------------------------------+  |
|  | Song Card 2                                |  |
|  +--------------------------------------------+  |
|                                                  |
|  +--------------------------------------------+  |
|  | Song Card 3                                |  |
|  +--------------------------------------------+  |
|                                                  |
|  +--------------------------------------------+  |
|  | Song Card 4                                |  |
|  +--------------------------------------------+  |
|                                                  |
|  +--------------------------------------------+  |
|  | Song Card 5                                |  |
|  +--------------------------------------------+  |
|                                                  |
+--------------------------------------------------+
```

## Testing Strategy

### Unit Tests (ViewModel)
- `testLoadInitialRecommendations_success`
- `testLoadInitialRecommendations_noSeedData`
- `testDismissSong_removesFromQueue`
- `testDismissSong_triggersReplenish`
- `testReplenish_preventsDirectDuplicates`
- `testReplenish_filtersDismissedSongs`

### Integration Tests
- Spotify API connectivity
- Token refresh during session
- Network failure recovery

### UI Tests
- Card dismissal animation
- Context menu actions
- Empty state display
- Error state with retry

### Manual Testing Checklist
- [ ] Initial load shows 5 songs
- [ ] Dismiss animates smoothly
- [ ] Queue replenishes at threshold
- [ ] No duplicate songs appear
- [ ] Long-press shows context menu
- [ ] "Add to Playlist" works
- [ ] "Open in Spotify" works
- [ ] Spotify disconnected state handled
- [ ] VoiceOver announces cards correctly
- [ ] Dynamic Type scales text properly
