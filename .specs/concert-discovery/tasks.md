# Concert Discovery - Implementation Tasks

## Summary
- **Total tasks**: 12
- **Estimated complexity**: Medium
- **New files**: 10
- **Modified files**: 2

## Task Dependency Graph

```
Phase 1: Foundation (Models & Services)
┌─────────────┐  ┌─────────────┐
│   Task 1    │  │   Task 2    │
│   Models    │  │   Spotify   │
│             │  │   Service   │
└──────┬──────┘  └──────┬──────┘
       │                │
       └────────┬───────┘
                │
                v
        ┌───────────────┐
        │    Task 3     │
        │  Ticketmaster │
        │    Service    │
        └───────┬───────┘
                │
Phase 2: Business Logic
                v
        ┌───────────────┐
        │    Task 4     │
        │   ViewModel   │
        └───────┬───────┘
                │
Phase 3: UI Components
    ┌───────────┼───────────┐
    v           v           v
┌───────┐  ┌───────┐  ┌───────┐
│Task 5 │  │Task 6 │  │Task 7 │
│Artist │  │Concert│  │Search │
│ Row   │  │ Row   │  │Result │
└───┬───┘  └───┬───┘  └───┬───┘
    │          │          │
    └──────────┼──────────┘
               │
Phase 4: Main Views
               v
        ┌───────────────┐
        │    Task 8     │
        │  Discovery    │
        │    View       │
        └───────┬───────┘
                │
                v
        ┌───────────────┐
        │    Task 9     │
        │   Results     │
        │    View       │
        └───────┬───────┘
                │
Phase 5: Integration
                v
        ┌───────────────┐
        │   Task 10     │
        │  Navigation   │
        │  Integration  │
        └───────┬───────┘
                │
                v
        ┌───────────────┐
        │   Task 11     │
        │  Entry Point  │
        │  (FeedView)   │
        └───────┬───────┘
                │
Phase 6: Polish
                v
        ┌───────────────┐
        │   Task 12     │
        │   Testing &   │
        │   Polish      │
        └───────────────┘
```

---

## Tasks

### Task 1: Create Data Models
- **Status**: Completed
- **Dependencies**: None
- **Files**:
  - Create: `vibes/Models/RankedArtist.swift`
  - Create: `vibes/Models/RankedConcert.swift`
- **Requirements Addressed**: FR-2, FR-6, FR-9, FR-11
- **Description**:
  Create the two new model types needed for concert discovery: `RankedArtist` (artist with rank position) and `RankedConcert` (concert with artist rank and home city flag).
- **Implementation Notes**:
  - Both must conform to `Codable`, `Identifiable`, `Hashable`
  - `RankedArtist` wraps existing `UnifiedArtist` with `rank: Int`
  - `RankedConcert` wraps existing `Concert` with `artistRank: Int` and `isHomeCity: Bool`
  - Use computed `id` property delegating to wrapped type
- **Acceptance Criteria**:
  - [ ] `RankedArtist` struct created with artist and rank properties
  - [ ] `RankedConcert` struct created with concert, artistRank, isHomeCity properties
  - [ ] Both conform to Codable, Identifiable, Hashable
  - [ ] Project builds successfully

---

### Task 2: Create SpotifyDataService
- **Status**: Completed
- **Dependencies**: None
- **Files**:
  - Create: `vibes/Services/SpotifyDataService.swift`
- **Requirements Addressed**: FR-2, FR-4
- **Description**:
  Create service for fetching data from Spotify Web API: user's top artists and artist search. Uses existing `SpotifyAuthService` for authentication.
- **Implementation Notes**:
  - Use singleton pattern: `static let shared`
  - Use `SpotifyAuthService.shared.getValidAccessToken()` for auth
  - Define `SpotifyTimeRange` enum (shortTerm, mediumTerm, longTerm)
  - Define response models: `SpotifyTopArtistsResponse`, `SpotifyArtist`, `SpotifyImage`, `SpotifySearchResponse`, `SpotifyArtistsPaging`
  - Implement `getTopArtists(limit:timeRange:)` calling `/me/top/artists`
  - Implement `searchArtists(query:limit:)` calling `/search?type=artist`
  - Convert `SpotifyArtist` to existing `UnifiedArtist` model
  - Handle token expiration (SpotifyAuthService handles refresh)
- **Acceptance Criteria**:
  - [ ] SpotifyTimeRange enum defined
  - [ ] Spotify API response models defined
  - [ ] getTopArtists() fetches and parses /me/top/artists
  - [ ] searchArtists() fetches and parses /search?type=artist
  - [ ] Results converted to [UnifiedArtist]
  - [ ] Errors properly thrown (network, auth, parsing)
  - [ ] Project builds successfully

---

### Task 3: Create TicketmasterService
- **Status**: Completed
- **Dependencies**: Task 1
- **Files**:
  - Create: `vibes/Services/TicketmasterService.swift`
- **Requirements Addressed**: FR-8, FR-9, FR-11
- **Description**:
  Create service for searching concerts from Ticketmaster Discovery API. Includes parallel search with rate limiting and home city detection.
- **Implementation Notes**:
  - Use singleton pattern: `static let shared`
  - Get API key from Keychain: `KeychainManager.shared.get(key: .ticketmasterApiKey)`
  - Define response models: `TicketmasterResponse`, `TicketmasterEmbedded`, `TicketmasterEvent`, `TicketmasterDates`, `TicketmasterStartDate`, `TicketmasterVenue`, `TicketmasterCity`, `TicketmasterAttraction`, `TicketmasterPriceRange`
  - Implement `searchConcerts(artistName:)` calling `/discovery/v2/events`
  - Query params: `keyword`, `classificationName=Music`, `size=20`
  - Implement `searchConcertsForArtists(artists:homeCity:)` with parallel requests
  - Use `TaskGroup` for parallel execution
  - Rate limit: delay 1 second every 5 requests
  - Home city detection: case-insensitive partial match
  - Deduplicate by concert ID
  - Convert to `RankedConcert` with proper artistRank and isHomeCity
- **Acceptance Criteria**:
  - [ ] Ticketmaster API response models defined
  - [ ] searchConcerts() fetches events for single artist
  - [ ] searchConcertsForArtists() searches all artists in parallel
  - [ ] Rate limiting implemented (1s delay per 5 requests)
  - [ ] Home city detection with case-insensitive partial match
  - [ ] Results deduplicated by concert ID
  - [ ] Results sorted by artistRank then date
  - [ ] Converts to [RankedConcert]
  - [ ] Project builds successfully

---

### Task 4: Create ConcertDiscoveryViewModel
- **Status**: Completed
- **Dependencies**: Task 1, Task 2, Task 3
- **Files**:
  - Create: `vibes/ViewModels/ConcertDiscoveryViewModel.swift`
- **Requirements Addressed**: FR-2, FR-3, FR-4, FR-5, FR-6, FR-7, FR-13, FR-14, FR-15
- **Description**:
  Create the main ViewModel for concert discovery. Manages artist list state, search, concert results, and persistence.
- **Implementation Notes**:
  - Use `@Observable` macro
  - State: `artists`, `concerts`, `searchQuery`, `searchResults`
  - Loading states: `isLoadingArtists`, `isLoadingConcerts`, `isSearching`
  - Error states: `artistsError`, `concertsError`, `searchError`
  - Computed: `canAddArtist` (count < 20), `canFindConcerts` (!empty && !loading)
  - `loadTopArtists()`: Check saved first, then fetch from Spotify
  - `searchArtists(query:)`: Debounce 300ms, call SpotifyDataService
  - `addArtist(_:)`: Append with next rank, enforce max 20, save
  - `removeArtist(at:)`: Remove and re-rank remaining, save
  - `moveArtist(from:to:)`: Reorder and update all ranks, save
  - `findConcerts()`: Call TicketmasterService, get home city from UserDefaults
  - `resetToSpotifyArtists()`: Clear saved, refetch from Spotify
  - Persistence: Save/load `[RankedArtist]` to UserDefaults key `"concertDiscoveryArtists"`
- **Acceptance Criteria**:
  - [ ] All state properties defined
  - [ ] loadTopArtists() checks cache then fetches
  - [ ] searchArtists() debounces and searches
  - [ ] addArtist() adds with correct rank, enforces max 20
  - [ ] removeArtist() removes and re-ranks
  - [ ] moveArtist() reorders and updates ranks
  - [ ] findConcerts() searches and populates concerts
  - [ ] Artist list persists to UserDefaults
  - [ ] resetToSpotifyArtists() clears and refetches
  - [ ] Project builds successfully

---

### Task 5: Create ArtistRow Component
- **Status**: Completed
- **Dependencies**: Task 1
- **Files**:
  - Create: `vibes/Views/ConcertDiscovery/ArtistRow.swift`
- **Requirements Addressed**: FR-2, FR-3, NFR-3, NFR-4
- **Description**:
  Create reusable row component for displaying a ranked artist with image, name, rank number, and remove action.
- **Implementation Notes**:
  - Props: `rankedArtist: RankedArtist`, `onRemove: () -> Void`
  - Layout: HStack with rank number, AsyncImage, VStack(name, genres), remove button
  - Use SF Symbol for remove: `minus.circle.fill`
  - Artist image: 50x50 circle with placeholder
  - Rank number: Bold, fixed width for alignment
  - Accessibility: Combined element with label "Artist name, ranked number N"
  - Dynamic Type: Use semantic font styles
- **Acceptance Criteria**:
  - [ ] Displays rank number prominently
  - [ ] Shows artist image with AsyncImage and placeholder
  - [ ] Shows artist name
  - [ ] Remove button calls onRemove
  - [ ] VoiceOver accessible with meaningful label
  - [ ] Supports Dynamic Type
  - [ ] Project builds successfully

---

### Task 6: Create ConcertRow Component
- **Status**: Completed
- **Dependencies**: Task 1
- **Files**:
  - Create: `vibes/Views/ConcertDiscovery/ConcertRow.swift`
- **Requirements Addressed**: FR-10, FR-11, FR-12, NFR-3, NFR-4
- **Description**:
  Create reusable row component for displaying a concert with artist, venue, date, home city badge, and ticket button.
- **Implementation Notes**:
  - Props: `rankedConcert: RankedConcert`, `onGetTickets: () -> Void`
  - Layout: HStack with artist image, VStack(artist, venue, city+date), home icon, ticket button
  - Home city: Show `house.fill` SF Symbol if `isHomeCity`
  - Date formatting: "Sat, Mar 15 at 8:00 PM"
  - Ticket button: `ticket.fill` SF Symbol, tappable
  - Accessibility: Combined element with full concert info
  - Include price range if available
- **Acceptance Criteria**:
  - [ ] Shows artist name and image
  - [ ] Shows venue name and city
  - [ ] Shows formatted date and time
  - [ ] Shows home icon when isHomeCity is true
  - [ ] Ticket button calls onGetTickets
  - [ ] VoiceOver accessible
  - [ ] Supports Dynamic Type
  - [ ] Project builds successfully

---

### Task 7: Create ArtistSearchResultRow Component
- **Status**: Completed
- **Dependencies**: None
- **Files**:
  - Create: `vibes/Views/ConcertDiscovery/ArtistSearchResultRow.swift`
- **Requirements Addressed**: FR-4, FR-5, NFR-3
- **Description**:
  Create row component for artist search results with image, name, genres, and add button.
- **Implementation Notes**:
  - Props: `artist: UnifiedArtist`, `isAlreadyAdded: Bool`, `canAdd: Bool`, `onAdd: () -> Void`
  - Layout: HStack with AsyncImage, VStack(name, genres), add button
  - Add button: `plus.circle.fill` SF Symbol
  - Disable/hide add button if `isAlreadyAdded` or `!canAdd`
  - Show "Added" text instead if already in list
  - Genres: Show first 2-3 genres as secondary text
- **Acceptance Criteria**:
  - [ ] Shows artist image with placeholder
  - [ ] Shows artist name
  - [ ] Shows genres as secondary text
  - [ ] Add button enabled when canAdd and not already added
  - [ ] Shows "Added" when isAlreadyAdded
  - [ ] Add button disabled when list is full
  - [ ] Project builds successfully

---

### Task 8: Create ConcertDiscoveryView (Artist List Screen)
- **Status**: Completed
- **Dependencies**: Task 4, Task 5, Task 7
- **Files**:
  - Create: `vibes/Views/ConcertDiscovery/ConcertDiscoveryView.swift`
- **Requirements Addressed**: FR-2, FR-3, FR-4, FR-5, FR-6, FR-7, FR-13
- **Description**:
  Create the main artist list screen with search bar, reorderable list, artist count, and Find Concerts button.
- **Implementation Notes**:
  - `@State private var viewModel = ConcertDiscoveryViewModel()`
  - `@Environment(AppRouter.self) private var router`
  - `@State private var isEditing = false` for edit mode
  - Search bar at top (TextField or .searchable)
  - Show search results as overlay/dropdown when searching
  - Artist list with ForEach + onMove + onDelete
  - Count indicator: "N/20 artists"
  - "Find Concerts" button at bottom, disabled if empty
  - Empty state when no artists
  - Loading state during initial fetch
  - Error state with retry button
  - On appear: `viewModel.loadTopArtists()`
  - Reset button in toolbar to reload from Spotify
- **Acceptance Criteria**:
  - [ ] Search bar visible and functional
  - [ ] Search results appear as overlay
  - [ ] Artist list displays with ArtistRow
  - [ ] Swipe to delete works
  - [ ] Edit mode enables drag to reorder
  - [ ] Artist count shows "N/20 artists"
  - [ ] Find Concerts button navigates to results
  - [ ] Button disabled when list empty
  - [ ] Loading state shown during fetch
  - [ ] Empty state shown when no artists
  - [ ] Reset toolbar button works
  - [ ] Project builds successfully

---

### Task 9: Create ConcertResultsView
- **Status**: Completed
- **Dependencies**: Task 4, Task 6
- **Files**:
  - Create: `vibes/Views/ConcertDiscovery/ConcertResultsView.swift`
- **Requirements Addressed**: FR-9, FR-10, FR-11, FR-12, FR-14
- **Description**:
  Create the concert results screen showing ranked concerts with home city highlighting and ticket links.
- **Implementation Notes**:
  - `@Bindable var viewModel: ConcertDiscoveryViewModel` (shared from discovery view)
  - List of concerts using ConcertRow
  - LazyVStack for performance with many results
  - On ticket tap: `UIApplication.shared.open(url)`
  - Empty state if no concerts found
  - Loading state during search
  - Error state with retry
  - Navigation title: "Concerts"
- **Acceptance Criteria**:
  - [ ] Displays concerts sorted by artist rank then date
  - [ ] Each concert shows via ConcertRow
  - [ ] Home city concerts highlighted
  - [ ] Tapping ticket opens Ticketmaster URL
  - [ ] Empty state when no concerts
  - [ ] Loading state during search
  - [ ] Uses LazyVStack for performance
  - [ ] Project builds successfully

---

### Task 10: Update AppRouter for Navigation
- **Status**: Completed
- **Dependencies**: Task 8, Task 9
- **Files**:
  - Modify: `vibes/Services/AppRouter.swift`
- **Requirements Addressed**: FR-1, FR-7
- **Description**:
  Add navigation destination enum and helper method for concert discovery flow.
- **Implementation Notes**:
  - Add `ConcertDiscoveryDestination` enum with cases: `.artistList`, `.results`
  - Enum must be `Hashable` for NavigationPath
  - Add `navigateToConcertDiscovery()` method that appends to feedPath
  - Results navigation will be handled within ConcertDiscoveryView
- **Acceptance Criteria**:
  - [ ] ConcertDiscoveryDestination enum added
  - [ ] navigateToConcertDiscovery() method added
  - [ ] Pushes to feedPath correctly
  - [ ] Project builds successfully

---

### Task 11: Add Entry Point to FeedView
- **Status**: Completed
- **Dependencies**: Task 10
- **Files**:
  - Modify: `vibes/ContentView.swift`
- **Requirements Addressed**: FR-1
- **Description**:
  Add "Discover Concerts" button/card to FeedView and navigation destination for concert discovery screens.
- **Implementation Notes**:
  - Create `ConcertDiscoveryCard` component (inline or separate)
  - Card with ticket icon, "Discover Concerts" title, subtitle, arrow
  - Place after SetupCard in FeedView
  - On tap: `router.navigateToConcertDiscovery()`
  - Add `.navigationDestination(for: ConcertDiscoveryDestination.self)`
  - Route to ConcertDiscoveryView
- **Acceptance Criteria**:
  - [ ] Discover Concerts card visible on Feed
  - [ ] Card has ticket icon and clear CTA
  - [ ] Tapping navigates to ConcertDiscoveryView
  - [ ] Navigation destination properly configured
  - [ ] Back navigation returns to Feed
  - [ ] Project builds successfully

---

### Task 12: Testing and Polish
- **Status**: Completed
- **Dependencies**: Task 11
- **Files**:
  - All created files
- **Requirements Addressed**: All NFRs
- **Description**:
  Final testing, polish, and verification. Run app on simulator, test all flows, fix any issues.
- **Implementation Notes**:
  - Test happy path: Load artists → Customize → Find concerts → View results → Get tickets
  - Test edge cases:
    - Spotify not connected
    - No top artists
    - Ticketmaster key missing
    - No concerts found
    - Network errors
    - Max 20 artists limit
  - Verify accessibility with VoiceOver
  - Verify Dynamic Type scaling
  - Verify persistence works across app restarts
  - Check for memory leaks (Instruments)
  - Polish UI animations and transitions
- **Acceptance Criteria**:
  - [ ] Full flow works end-to-end
  - [ ] All edge cases handled gracefully
  - [ ] No crashes or runtime errors
  - [ ] VoiceOver works on all screens
  - [ ] Dynamic Type scales properly
  - [ ] Persistence works correctly
  - [ ] App builds and runs on simulator
  - [ ] Ready for user testing

---

## Implementation Order

1. **Task 1** - Create RankedArtist and RankedConcert models
2. **Task 2** - Create SpotifyDataService for fetching top artists and search
3. **Task 3** - Create TicketmasterService for concert search
4. **Task 4** - Create ConcertDiscoveryViewModel with all business logic
5. **Task 5** - Create ArtistRow component
6. **Task 6** - Create ConcertRow component
7. **Task 7** - Create ArtistSearchResultRow component
8. **Task 8** - Create ConcertDiscoveryView (artist list screen)
9. **Task 9** - Create ConcertResultsView
10. **Task 10** - Update AppRouter with navigation
11. **Task 11** - Add entry point to FeedView
12. **Task 12** - Testing and polish

---

## Integration Checklist

- [ ] All 12 tasks completed
- [ ] App builds without errors
- [ ] App runs on iPhone 16 simulator
- [ ] Full flow testable end-to-end
- [ ] Spotify auth works (if connected)
- [ ] Ticketmaster search works (if API key set)
- [ ] Accessibility verified
- [ ] Code follows style guide
- [ ] Task tracking updated in docs/task.md
