# Unified Content Feed - Design

## Overview

Transform the feed from static navigation widgets to a dynamic content stream. The architecture introduces:
1. A `FeedViewModel` that aggregates content from multiple sources
2. New feed card components for concerts, releases, and recommendations
3. An `ArtistFollowService` for managing followed artists in Firestore
4. Integration of followed artists into feed content generation

## Tech Stack

- **UI Framework**: SwiftUI
- **Architecture**: MVVM with @Observable
- **Backend**: Firebase Firestore (followed artists storage)
- **APIs**: Spotify Web API, Ticketmaster Discovery API
- **State Management**: @Observable, @Environment

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                           FeedView                               │
│  ┌──────────┐ ┌──────────────┐ ┌─────────────────────────────┐  │
│  │SetupCard │ │FindPeopleCard│ │      Feed Content Stream    │  │
│  │(if !done)│ │  (always)    │ │  ┌─────────────────────────┐│  │
│  └──────────┘ └──────────────┘ │  │ ConcertFeedCard         ││  │
│                                │  │ ReleaseFeedCard         ││  │
│                                │  │ RecommendationFeedCard  ││  │
│                                │  │ SongShareCard (existing)││  │
│                                │  └─────────────────────────┘│  │
│                                └─────────────────────────────────┘
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                        FeedViewModel                             │
│  - feedItems: [FeedItem]                                        │
│  - isLoading: Bool                                              │
│  - loadFeed() async                                             │
│  - refreshFeed() async                                          │
└─────────────────────────────────────────────────────────────────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          ▼                       ▼                       ▼
┌─────────────────┐   ┌─────────────────┐   ┌─────────────────────┐
│ ArtistFollow    │   │ SocialService   │   │ SpotifyDataService  │
│ Service         │   │ (existing)      │   │ (existing)          │
│                 │   │                 │   │                     │
│ - followArtist  │   │ - getShares     │   │ - getTopArtists     │
│ - unfollowArtist│   │   FromFollowing │   │ - getArtistAlbums   │
│ - getFollowed   │   │                 │   │ - getRecommendations│
│   Artists       │   │                 │   │                     │
└─────────────────┘   └─────────────────┘   └─────────────────────┘
          │                                           │
          ▼                                           ▼
┌─────────────────┐                       ┌─────────────────────┐
│ Firestore       │                       │ TicketmasterService │
│ users/{uid}/    │                       │ (existing)          │
│ followedArtists │                       │                     │
└─────────────────┘                       └─────────────────────┘
```

## Component Design

### New Files

#### `vibes/ViewModels/FeedViewModel.swift`
- **Type**: ViewModel
- **Purpose**: Aggregates content from all sources, manages feed state
- **Dependencies**: ArtistFollowService, SocialService, SpotifyDataService, TicketmasterService
- **Key Properties**:
  - `feedItems: [FeedItem]` - Merged, sorted feed content
  - `isLoading: Bool` - Loading state
  - `error: Error?` - Error state
- **Key Methods**:
  - `loadFeed() async` - Initial load of all content
  - `refreshFeed() async` - Pull-to-refresh handler
  - `fetchConcerts() async -> [FeedItem]` - Get concert cards
  - `fetchReleases() async -> [FeedItem]` - Get release cards
  - `fetchRecommendations() async -> [FeedItem]` - Get recommendation cards

#### `vibes/Services/ArtistFollowService.swift`
- **Type**: Service
- **Purpose**: Manage followed artists in Firestore
- **Dependencies**: Firebase Firestore, AuthManager
- **Key Methods**:
  - `followArtist(_ artist: UnifiedArtist) async throws`
  - `unfollowArtist(_ artistId: String) async throws`
  - `getFollowedArtists() async throws -> [FollowedArtist]`
  - `isFollowing(artistId: String) async -> Bool`
  - `getFollowedArtistsAsRanked() async throws -> [RankedArtist]`

#### `vibes/Models/FollowedArtist.swift`
- **Type**: Model
- **Purpose**: Represents a followed artist stored in Firestore
- **Properties**:
  - `id: String` - Document ID (same as artistId)
  - `artistId: String` - Spotify artist ID
  - `artistName: String`
  - `artistImageURL: String?`
  - `followedAt: Date`

#### `vibes/Views/Feed/ConcertFeedCard.swift`
- **Type**: View
- **Purpose**: Display a concert in the feed stream
- **Dependencies**: Concert model, AppRouter
- **Key Features**:
  - Shows artist image, name, venue, city, date
  - Purple accent color with ticket icon
  - Tappable to navigate to ConcertDiscoveryView

#### `vibes/Views/Feed/ReleaseFeedCard.swift`
- **Type**: View
- **Purpose**: Display a new release in the feed stream
- **Dependencies**: UnifiedAlbum model, AppRouter
- **Key Features**:
  - Shows album art, name, artist, release date
  - Green accent color with music note icon
  - Tappable to navigate to ReleasesDiscoveryView

#### `vibes/Views/Feed/RecommendationFeedCard.swift`
- **Type**: View
- **Purpose**: Display a song recommendation in the feed stream
- **Dependencies**: UnifiedTrack model, AppRouter, SpotifyRemoteService
- **Key Features**:
  - Shows album art, track name, artist, reason text
  - Orange accent color with sparkles icon
  - Tappable to navigate to DiscoverMusicView
  - Play button for inline playback

#### `vibes/Views/Artist/ArtistFollowButton.swift`
- **Type**: View
- **Purpose**: Follow/unfollow button for artist profiles
- **Dependencies**: ArtistFollowService, UnifiedArtist
- **Key Features**:
  - Shows "Follow" or "Following" state
  - Optimistic UI update on tap
  - Handles loading and error states

### Modified Files

#### `vibes/ContentView.swift` (FeedView)
- **Changes**:
  - Remove static discovery widgets (ConcertDiscoveryCard, ReleasesDiscoveryCard, DiscoverMusicCard)
  - Add conditional rendering of SetupCard based on `setupManager.isAllComplete`
  - Replace `songShares` state with `feedViewModel`
  - Render unified feed using `FeedItem` enum and switch on type
- **Reason**: Core feed transformation

#### `vibes/Models/FeedItem.swift`
- **Changes**:
  - Already has required cases (concert, newRelease, aiRecommendation)
  - May need to add `reason: String` to aiRecommendation case if not present
  - Verify sortScore algorithm meets requirements
- **Reason**: Ensure model supports all card types

#### `vibes/Views/Artist/ArtistProfileView.swift`
- **Changes**:
  - Add ArtistFollowButton to header area
  - Pass artist to follow button component
- **Reason**: Enable artist following from profile

#### `vibes/Views/Artist/ArtistHeaderView.swift`
- **Changes**:
  - Add slot for follow button or integrate directly
  - Layout adjustment to accommodate button
- **Reason**: UI placement for follow action

## Data Flow

### Feed Load Sequence

```
┌──────────┐     ┌─────────────┐     ┌─────────────────┐
│ FeedView │     │FeedViewModel│     │    Services     │
└────┬─────┘     └──────┬──────┘     └────────┬────────┘
     │                  │                     │
     │  .task           │                     │
     │─────────────────>│                     │
     │                  │                     │
     │                  │  loadFeed()         │
     │                  │────────────────────>│
     │                  │                     │
     │                  │    Parallel fetch:  │
     │                  │    - getFollowedArtists()
     │                  │    - getSharesFromFollowing()
     │                  │<────────────────────│
     │                  │                     │
     │                  │  With followed artists:
     │                  │    - fetchConcerts()│
     │                  │    - fetchReleases()│
     │                  │    - fetchRecommendations()
     │                  │<────────────────────│
     │                  │                     │
     │                  │  Merge & sort by    │
     │                  │  FeedItem.sortScore │
     │                  │                     │
     │  feedItems       │                     │
     │<─────────────────│                     │
     │                  │                     │
     │  Render cards    │                     │
     │                  │                     │
```

### Artist Follow Sequence

```
┌──────────────────┐  ┌───────────────────┐  ┌─────────────────┐
│ArtistFollowButton│  │ArtistFollowService│  │    Firestore    │
└────────┬─────────┘  └─────────┬─────────┘  └────────┬────────┘
         │                      │                     │
         │  Tap "Follow"        │                     │
         │─────────────────────>│                     │
         │                      │                     │
         │  Optimistic UI       │                     │
         │  (show "Following")  │                     │
         │                      │                     │
         │                      │  Add document       │
         │                      │  users/{uid}/       │
         │                      │  followedArtists/   │
         │                      │  {artistId}         │
         │                      │────────────────────>│
         │                      │                     │
         │                      │  Success            │
         │                      │<────────────────────│
         │                      │                     │
         │  Confirm state       │                     │
         │<─────────────────────│                     │
         │                      │                     │
```

## Data Models

### FollowedArtist (New)

```swift
struct FollowedArtist: Codable, Identifiable {
    var id: String { artistId }
    let artistId: String
    let artistName: String
    let artistImageURL: String?
    let followedAt: Date

    init(from artist: UnifiedArtist) {
        self.artistId = artist.id
        self.artistName = artist.name
        self.artistImageURL = artist.imageURL
        self.followedAt = Date()
    }
}
```

### Firestore Schema

```
users/{userId}/
  followedArtists/{artistId}/
    - artistId: String
    - artistName: String
    - artistImageURL: String?
    - followedAt: Timestamp
```

## State Management

### FeedView State
```swift
@Environment(SetupManager.self) private var setupManager
@Environment(AppRouter.self) private var router
@State private var viewModel = FeedViewModel()
```

### ArtistFollowButton State
```swift
@State private var isFollowing: Bool = false
@State private var isLoading: Bool = false
let artist: UnifiedArtist
```

### FeedViewModel State
```swift
@Observable
class FeedViewModel {
    var feedItems: [FeedItem] = []
    var isLoading = false
    var error: Error?

    private let artistFollowService = ArtistFollowService.shared
    private let socialService = SocialService.shared
    private let spotifyService = SpotifyDataService.shared
    private let ticketmasterService = TicketmasterService.shared
}
```

## Error Handling

| Error Scenario | Handling |
|----------------|----------|
| No Spotify connection | Hide release/recommendation cards, show only social content |
| No Ticketmaster setup | Hide concert cards |
| No followed artists | Fall back to Spotify top artists |
| Network failure (partial) | Show available content, log error |
| Network failure (complete) | Show error state with retry button |
| Firestore write failure | Revert optimistic UI, show toast |

## Security Considerations

- Firestore rules: Users can only read/write their own `followedArtists` subcollection
- No sensitive data stored in followed artists (public artist info only)
- API keys remain in Keychain (existing pattern)

### Firestore Security Rules
```javascript
match /users/{userId}/followedArtists/{artistId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

## Performance Considerations

### Feed Loading
- Fetch followed artists first (single Firestore query)
- Parallel fetch: song shares, concerts, releases, recommendations
- Limit each content type (5 concerts, 5 releases, 3 recommendations)
- Use `LazyVStack` for efficient rendering

### Image Loading
- `AsyncImage` with placeholders (existing pattern)
- Album art and artist images load asynchronously
- No pre-fetching needed for feed-sized content

### Caching
- Followed artists: Cache in memory, refresh on pull-to-refresh
- Feed content: No persistent cache (always fresh on load)
- Consider adding Firestore offline persistence (future)

## Accessibility

### VoiceOver Labels
- Concert card: "Concert: {artist} at {venue} on {date}"
- Release card: "New release: {album} by {artist}"
- Recommendation card: "Recommended song: {track} by {artist}"
- Follow button: "Follow {artist}" or "Following {artist}, double tap to unfollow"

### Dynamic Type
- All text uses semantic font styles (.headline, .subheadline, .caption)
- Cards expand vertically to accommodate larger text
- No fixed heights that would clip text

## Testing Strategy

### Unit Tests
- `FeedViewModel`: Test feed loading, sorting, error handling
- `ArtistFollowService`: Test follow/unfollow, persistence
- `FeedItem.sortScore`: Test sorting algorithm

### Integration Tests
- Feed loads with mixed content types
- Artist follow persists and reflects in feed
- Pull-to-refresh updates content

### UI Tests
- Setup card visibility based on completion state
- Card tap navigation to correct views
- Follow button state changes

## File Structure

```
vibes/
├── Models/
│   ├── FeedItem.swift (modify)
│   └── FollowedArtist.swift (new)
├── ViewModels/
│   └── FeedViewModel.swift (new)
├── Services/
│   └── ArtistFollowService.swift (new)
├── Views/
│   ├── Feed/
│   │   ├── ConcertFeedCard.swift (new)
│   │   ├── ReleaseFeedCard.swift (new)
│   │   └── RecommendationFeedCard.swift (new)
│   └── Artist/
│       ├── ArtistProfileView.swift (modify)
│       ├── ArtistHeaderView.swift (modify)
│       └── ArtistFollowButton.swift (new)
└── ContentView.swift (modify - FeedView section)
```
