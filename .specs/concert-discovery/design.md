# Concert Discovery - Design

## Overview

The Concert Discovery feature follows MVVM architecture with two main screens:
1. **Artist List Screen** - Displays and manages the user's ranked artist list
2. **Concert Results Screen** - Shows concerts found from Ticketmaster, ranked by artist priority

The feature integrates with existing Spotify authentication, adds new API services for data fetching, and uses the established navigation patterns via AppRouter.

## Tech Stack

- **UI Framework**: SwiftUI
- **Architecture**: MVVM with @Observable ViewModels
- **Navigation**: NavigationStack with AppRouter (existing)
- **Networking**: URLSession with async/await
- **Storage**: UserDefaults for artist list persistence
- **Authentication**: SpotifyAuthService (existing)
- **Secure Storage**: KeychainManager (existing)

### APIs Used
- **Spotify Web API**: `/me/top/artists`, `/search`
- **Ticketmaster Discovery API**: `/discovery/v2/events`

### No New Dependencies
All functionality implemented with native iOS frameworks.

## Architecture Diagram

```
+------------------+     +------------------------+     +----------------------+
|                  |     |                        |     |                      |
|    FeedView      |---->| ConcertDiscoveryView   |---->| ConcertResultsView   |
|  (Entry Button)  |     |   (Artist List)        |     |   (Concert List)     |
|                  |     |                        |     |                      |
+------------------+     +------------------------+     +----------------------+
                                    |                            |
                                    v                            |
                         +------------------------+              |
                         |                        |              |
                         | ConcertDiscoveryVM     |<-------------+
                         |   - artists: [RankedArtist]           |
                         |   - concerts: [RankedConcert]         |
                         |   - searchResults: [UnifiedArtist]    |
                         |                        |              |
                         +------------------------+              |
                                    |                            |
                    +---------------+---------------+            |
                    |                               |            |
                    v                               v            |
         +------------------+           +--------------------+   |
         |                  |           |                    |   |
         | SpotifyDataService|          | TicketmasterService|   |
         |  - getTopArtists |           |  - searchConcerts  |   |
         |  - searchArtists |           |                    |   |
         +------------------+           +--------------------+   |
                    |                               |            |
                    v                               v            |
         +------------------+           +--------------------+   |
         | Spotify Web API  |           | Ticketmaster API   |   |
         +------------------+           +--------------------+
```

## Component Design

### New Files

#### `vibes/Services/SpotifyDataService.swift`
- **Type**: Service
- **Purpose**: Fetch user data and search from Spotify Web API
- **Dependencies**: SpotifyAuthService, URLSession
- **Key Methods**:
  - `getTopArtists(limit: Int, timeRange: TimeRange) async throws -> [UnifiedArtist]`
  - `searchArtists(query: String, limit: Int) async throws -> [UnifiedArtist]`

```swift
enum SpotifyTimeRange: String {
    case shortTerm = "short_term"   // ~4 weeks
    case mediumTerm = "medium_term" // ~6 months
    case longTerm = "long_term"     // years
}

class SpotifyDataService {
    static let shared = SpotifyDataService()
    private let baseURL = "https://api.spotify.com/v1"

    func getTopArtists(limit: Int = 10, timeRange: SpotifyTimeRange = .shortTerm) async throws -> [UnifiedArtist]
    func searchArtists(query: String, limit: Int = 10) async throws -> [UnifiedArtist]
}
```

---

#### `vibes/Services/TicketmasterService.swift`
- **Type**: Service
- **Purpose**: Search concerts from Ticketmaster Discovery API
- **Dependencies**: KeychainManager (for API key), URLSession
- **Key Methods**:
  - `searchConcerts(artistName: String) async throws -> [Concert]`
  - `searchConcertsForArtists(artists: [RankedArtist]) async throws -> [RankedConcert]`

```swift
class TicketmasterService {
    static let shared = TicketmasterService()
    private let baseURL = "https://app.ticketmaster.com/discovery/v2"

    func searchConcerts(artistName: String) async throws -> [Concert]
    func searchConcertsForArtists(artists: [RankedArtist]) async throws -> [RankedConcert]
}
```

---

#### `vibes/Models/RankedArtist.swift`
- **Type**: Model
- **Purpose**: Artist with rank position for concert discovery
- **Dependencies**: UnifiedArtist

```swift
struct RankedArtist: Codable, Identifiable, Hashable {
    var id: String { artist.id }
    var artist: UnifiedArtist
    var rank: Int

    init(artist: UnifiedArtist, rank: Int)
}
```

---

#### `vibes/Models/RankedConcert.swift`
- **Type**: Model
- **Purpose**: Concert with associated artist rank for sorting
- **Dependencies**: Concert

```swift
struct RankedConcert: Codable, Identifiable, Hashable {
    var id: String { concert.id }
    var concert: Concert
    var artistRank: Int
    var isHomeCity: Bool

    init(concert: Concert, artistRank: Int, isHomeCity: Bool = false)
}
```

---

#### `vibes/ViewModels/ConcertDiscoveryViewModel.swift`
- **Type**: ViewModel
- **Purpose**: Manage state for artist list and concert search
- **Dependencies**: SpotifyDataService, TicketmasterService, SpotifyAuthService

```swift
@Observable
class ConcertDiscoveryViewModel {
    // State
    var artists: [RankedArtist] = []
    var concerts: [RankedConcert] = []
    var searchQuery: String = ""
    var searchResults: [UnifiedArtist] = []

    var isLoadingArtists: Bool = false
    var isLoadingConcerts: Bool = false
    var isSearching: Bool = false

    var artistsError: Error?
    var concertsError: Error?
    var searchError: Error?

    var hasSearchedConcerts: Bool = false

    // Computed
    var canAddArtist: Bool { artists.count < 20 }
    var artistCount: Int { artists.count }
    var canFindConcerts: Bool { !artists.isEmpty && !isLoadingConcerts }

    // Actions
    func loadTopArtists() async
    func searchArtists(query: String) async
    func addArtist(_ artist: UnifiedArtist)
    func removeArtist(at offsets: IndexSet)
    func moveArtist(from source: IndexSet, to destination: Int)
    func findConcerts() async
    func resetToSpotifyArtists() async

    // Persistence
    func saveArtists()
    func loadSavedArtists() -> Bool
}
```

---

#### `vibes/Views/ConcertDiscovery/ConcertDiscoveryView.swift`
- **Type**: View
- **Purpose**: Artist list screen with search, reorder, and find concerts button
- **Dependencies**: ConcertDiscoveryViewModel, AppRouter

```swift
struct ConcertDiscoveryView: View {
    @State private var viewModel = ConcertDiscoveryViewModel()
    @Environment(AppRouter.self) private var router

    var body: some View {
        // Search bar
        // Artist list (reorderable)
        // Artist count indicator
        // Find Concerts button
    }
}
```

---

#### `vibes/Views/ConcertDiscovery/ConcertResultsView.swift`
- **Type**: View
- **Purpose**: Display ranked concert results with home city highlighting
- **Dependencies**: ConcertDiscoveryViewModel

```swift
struct ConcertResultsView: View {
    @Bindable var viewModel: ConcertDiscoveryViewModel

    var body: some View {
        // Concert list
        // Each row: artist, venue, city, date, home icon, ticket button
    }
}
```

---

#### `vibes/Views/ConcertDiscovery/ArtistRow.swift`
- **Type**: View (Component)
- **Purpose**: Reusable row for artist display with rank and remove button

```swift
struct ArtistRow: View {
    let rankedArtist: RankedArtist
    let onRemove: () -> Void

    var body: some View {
        // Rank number, artist image, name, remove button
    }
}
```

---

#### `vibes/Views/ConcertDiscovery/ConcertRow.swift`
- **Type**: View (Component)
- **Purpose**: Reusable row for concert display with home city badge

```swift
struct ConcertRow: View {
    let rankedConcert: RankedConcert
    let onGetTickets: () -> Void

    var body: some View {
        // Artist image, name, venue, city, date, home icon, ticket button
    }
}
```

---

#### `vibes/Views/ConcertDiscovery/ArtistSearchResultRow.swift`
- **Type**: View (Component)
- **Purpose**: Row for search results with add button

```swift
struct ArtistSearchResultRow: View {
    let artist: UnifiedArtist
    let isAlreadyAdded: Bool
    let canAdd: Bool
    let onAdd: () -> Void

    var body: some View {
        // Artist image, name, genres, add button
    }
}
```

---

### Modified Files

#### `vibes/ContentView.swift`
- **Changes**:
  - Add "Discover Concerts" button/card to FeedView
  - Add navigation destination for ConcertDiscoveryDestination
- **Reason**: Entry point for concert discovery feature

```swift
// In FeedView body, add after SetupCard:
ConcertDiscoveryCard()
    .padding(.horizontal)

// Add navigation destination:
.navigationDestination(for: ConcertDiscoveryDestination.self) { destination in
    switch destination {
    case .artistList:
        ConcertDiscoveryView()
    case .results(let viewModel):
        ConcertResultsView(viewModel: viewModel)
    }
}
```

---

#### `vibes/Services/AppRouter.swift`
- **Changes**: Add navigation method for concert discovery
- **Reason**: Integrate with existing navigation system

```swift
// Add to AppRouter:
func navigateToConcertDiscovery() {
    feedPath.append(ConcertDiscoveryDestination.artistList)
}

// Add destination enum:
enum ConcertDiscoveryDestination: Hashable {
    case artistList
    case results
}
```

---

## Data Flow

### Load Top Artists Flow

```
User opens ConcertDiscoveryView
         |
         v
+------------------+
| Check saved list |
| (UserDefaults)   |
+------------------+
         |
    Has saved? ----No----> Fetch from Spotify
         |                        |
        Yes                       v
         |              +-------------------+
         v              | SpotifyDataService|
   Load saved           | getTopArtists()   |
   artists              +-------------------+
         |                        |
         +-------+----------------+
                 |
                 v
         Display in list
```

### Search and Add Artist Flow

```
User types in search bar
         |
         v (debounced 300ms)
+-------------------+
| SpotifyDataService|
| searchArtists()   |
+-------------------+
         |
         v
Show results dropdown
         |
    User taps +
         |
         v
+------------------+
| Add to artists[] |
| with next rank   |
+------------------+
         |
         v
Save to UserDefaults
```

### Find Concerts Flow

```
User taps "Find Concerts"
         |
         v
+----------------------+
| For each artist:     |
| TicketmasterService  |
| searchConcerts()     |
| (parallel requests)  |
+----------------------+
         |
         v
+----------------------+
| Aggregate results    |
| Deduplicate by ID    |
| Attach artist rank   |
| Check home city      |
+----------------------+
         |
         v
+----------------------+
| Sort by:             |
| 1. Artist rank (asc) |
| 2. Date (asc)        |
+----------------------+
         |
         v
Navigate to ConcertResultsView
```

## Data Models

### RankedArtist

```swift
struct RankedArtist: Codable, Identifiable, Hashable {
    var id: String { artist.id }
    var artist: UnifiedArtist
    var rank: Int

    init(artist: UnifiedArtist, rank: Int) {
        self.artist = artist
        self.rank = rank
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RankedArtist, rhs: RankedArtist) -> Bool {
        lhs.id == rhs.id
    }
}
```

### RankedConcert

```swift
struct RankedConcert: Codable, Identifiable, Hashable {
    var id: String { concert.id }
    var concert: Concert
    var artistRank: Int
    var isHomeCity: Bool

    init(concert: Concert, artistRank: Int, isHomeCity: Bool = false) {
        self.concert = concert
        self.artistRank = artistRank
        self.isHomeCity = isHomeCity
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RankedConcert, rhs: RankedConcert) -> Bool {
        lhs.id == rhs.id
    }
}
```

### Spotify API Response Models

```swift
// For /me/top/artists
struct SpotifyTopArtistsResponse: Decodable {
    let items: [SpotifyArtist]
}

struct SpotifyArtist: Decodable {
    let id: String
    let name: String
    let images: [SpotifyImage]
    let genres: [String]
    let popularity: Int
    let uri: String
}

struct SpotifyImage: Decodable {
    let url: String
    let height: Int?
    let width: Int?
}

// For /search
struct SpotifySearchResponse: Decodable {
    let artists: SpotifyArtistsPaging
}

struct SpotifyArtistsPaging: Decodable {
    let items: [SpotifyArtist]
}
```

### Ticketmaster API Response Models

```swift
struct TicketmasterResponse: Decodable {
    let _embedded: TicketmasterEmbedded?
}

struct TicketmasterEmbedded: Decodable {
    let events: [TicketmasterEvent]
}

struct TicketmasterEvent: Decodable {
    let id: String
    let name: String
    let url: String
    let dates: TicketmasterDates
    let _embedded: TicketmasterEventEmbedded?
    let priceRanges: [TicketmasterPriceRange]?
}

struct TicketmasterDates: Decodable {
    let start: TicketmasterStartDate
}

struct TicketmasterStartDate: Decodable {
    let localDate: String
    let localTime: String?
}

struct TicketmasterEventEmbedded: Decodable {
    let venues: [TicketmasterVenue]?
    let attractions: [TicketmasterAttraction]?
}

struct TicketmasterVenue: Decodable {
    let name: String
    let city: TicketmasterCity
    let address: TicketmasterAddress?
}

struct TicketmasterCity: Decodable {
    let name: String
}

struct TicketmasterAddress: Decodable {
    let line1: String?
}

struct TicketmasterAttraction: Decodable {
    let name: String
    let images: [TicketmasterImage]?
}

struct TicketmasterImage: Decodable {
    let url: String
}

struct TicketmasterPriceRange: Decodable {
    let min: Double?
    let max: Double?
    let currency: String?
}
```

## State Management

### View State

| State Property | Type | Location | Purpose |
|---------------|------|----------|---------|
| `artists` | `[RankedArtist]` | ViewModel | User's ranked artist list |
| `concerts` | `[RankedConcert]` | ViewModel | Search results |
| `searchQuery` | `String` | ViewModel | Current search input |
| `searchResults` | `[UnifiedArtist]` | ViewModel | Search autocomplete results |
| `isLoadingArtists` | `Bool` | ViewModel | Loading state for initial fetch |
| `isLoadingConcerts` | `Bool` | ViewModel | Loading state for concert search |
| `isSearching` | `Bool` | ViewModel | Loading state for artist search |
| `isEditing` | `Bool` | View (@State) | Edit mode for reordering |

### Persistence

| Data | Storage | Key |
|------|---------|-----|
| Artist list | UserDefaults | `"concertDiscoveryArtists"` |
| Home city | UserDefaults | `"concertCity"` (existing) |
| Spotify token | Keychain | (existing) |
| Ticketmaster key | Keychain | `"ticketmasterApiKey"` (existing) |

## Error Handling

### Error Types

```swift
enum ConcertDiscoveryError: LocalizedError {
    case spotifyNotConnected
    case ticketmasterKeyMissing
    case networkError(Error)
    case invalidResponse
    case noResults

    var errorDescription: String? {
        switch self {
        case .spotifyNotConnected:
            return "Connect Spotify to see your top artists"
        case .ticketmasterKeyMissing:
            return "Add your Ticketmaster API key in Settings"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .noResults:
            return "No concerts found"
        }
    }
}
```

### Error Display Strategy

| Error Type | UI Treatment |
|------------|--------------|
| Spotify not connected | Show prompt card with "Connect Spotify" button |
| Ticketmaster key missing | Show prompt card with "Add API Key" button |
| Network error | Show error view with "Retry" button |
| No top artists | Show empty state with search prompt |
| No concerts found | Show empty state with "Go Back" button |
| Partial failures | Show results with warning banner |

## Security Considerations

- **API Keys**: Ticketmaster API key stored in Keychain (existing pattern)
- **OAuth Tokens**: Spotify tokens stored in Keychain with automatic refresh
- **No Sensitive Data in UserDefaults**: Only artist IDs and ranks persisted locally
- **HTTPS Only**: All API calls over HTTPS
- **No Hardcoded Secrets**: API credentials from Keychain only

## Performance Considerations

### API Call Optimization

- **Parallel Requests**: Concert search for all artists runs concurrently using `TaskGroup`
- **Debounced Search**: Artist search debounced 300ms to reduce API calls
- **Request Limiting**: Respect Ticketmaster rate limit (5 req/sec) with delay between batches

```swift
// Parallel concert search with rate limiting
func searchConcertsForArtists(artists: [RankedArtist]) async throws -> [RankedConcert] {
    try await withThrowingTaskGroup(of: (Int, [Concert]).self) { group in
        for (index, rankedArtist) in artists.enumerated() {
            // Add delay every 5 requests to respect rate limit
            if index > 0 && index % 5 == 0 {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
            group.addTask {
                let concerts = try await self.searchConcerts(artistName: rankedArtist.artist.name)
                return (rankedArtist.rank, concerts)
            }
        }
        // Collect and process results...
    }
}
```

### Image Loading

- Use `AsyncImage` with placeholder for artist/concert images
- Consider caching with NSCache for frequently viewed images

### List Performance

- Use `LazyVStack` for long concert lists
- Limit initial results to 50 concerts with "Load More"

## Accessibility

### VoiceOver Support

```swift
// Artist row
ArtistRow(rankedArtist: artist)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(artist.artist.name), ranked number \(artist.rank)")
    .accessibilityHint("Swipe left to remove, or use edit mode to reorder")

// Concert row
ConcertRow(rankedConcert: concert)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("""
        \(concert.concert.artistName) at \(concert.concert.venueName),
        \(concert.concert.city),
        \(formattedDate(concert.concert.date))
        \(concert.isHomeCity ? ", in your home city" : "")
        """)
    .accessibilityHint("Double tap to get tickets")
```

### Dynamic Type

- All text uses semantic font styles (`.headline`, `.subheadline`, etc.)
- Layouts use `VStack` and `HStack` with flexible spacing
- Images have fixed minimum size but content scales

### Reorder Accessibility

```swift
List {
    ForEach(viewModel.artists) { artist in
        ArtistRow(rankedArtist: artist)
    }
    .onMove(perform: viewModel.moveArtist)
}
.environment(\.editMode, .constant(.active)) // Or toggle with EditButton
.accessibilityAction(named: "Reorder") {
    // Announce reorder mode
}
```

## Testing Strategy

### Unit Tests

| Test | Component | Description |
|------|-----------|-------------|
| `testGetTopArtists` | SpotifyDataService | Verify API call and response parsing |
| `testSearchArtists` | SpotifyDataService | Verify search and debouncing |
| `testSearchConcerts` | TicketmasterService | Verify concert search and parsing |
| `testAddArtist` | ViewModel | Verify artist added with correct rank |
| `testRemoveArtist` | ViewModel | Verify removal and re-ranking |
| `testReorderArtists` | ViewModel | Verify ranks update correctly |
| `testMaxArtistLimit` | ViewModel | Verify 20 artist limit enforced |
| `testConcertRanking` | ViewModel | Verify sort by artist rank then date |
| `testHomeCityDetection` | ViewModel | Verify city matching logic |
| `testPersistence` | ViewModel | Verify save/load from UserDefaults |

### UI Tests

| Test | Description |
|------|-------------|
| `testNavigationToDiscovery` | Tap button on Feed, verify navigation |
| `testAddArtistViaSearch` | Search, tap +, verify appears in list |
| `testSwipeToDelete` | Swipe artist row, verify removal |
| `testDragToReorder` | Long press and drag, verify new order |
| `testFindConcertsNavigation` | Tap Find Concerts, verify results screen |
| `testGetTicketsOpensURL` | Tap ticket button, verify Safari opens |

### Mock Data

Create mock responses for testing without network:

```swift
struct MockSpotifyDataService: SpotifyDataServiceProtocol {
    func getTopArtists(limit: Int, timeRange: SpotifyTimeRange) async throws -> [UnifiedArtist] {
        return [
            UnifiedArtist(id: "1", name: "Drake", imageURL: nil, genres: ["Hip-Hop"]),
            UnifiedArtist(id: "2", name: "Taylor Swift", imageURL: nil, genres: ["Pop"]),
            // ...
        ]
    }
}
```

## File Structure Summary

```
vibes/
├── Models/
│   ├── RankedArtist.swift          (NEW)
│   └── RankedConcert.swift         (NEW)
├── Services/
│   ├── SpotifyDataService.swift    (NEW)
│   └── TicketmasterService.swift   (NEW)
├── ViewModels/
│   └── ConcertDiscoveryViewModel.swift  (NEW)
├── Views/
│   └── ConcertDiscovery/           (NEW FOLDER)
│       ├── ConcertDiscoveryView.swift
│       ├── ConcertResultsView.swift
│       ├── ArtistRow.swift
│       ├── ConcertRow.swift
│       └── ArtistSearchResultRow.swift
├── ContentView.swift               (MODIFIED)
└── AppRouter.swift                 (MODIFIED in Services/)
```

**Total New Files**: 10
**Total Modified Files**: 2
