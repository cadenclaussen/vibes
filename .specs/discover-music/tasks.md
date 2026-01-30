# Discover Music - Implementation Tasks

## Summary
- Total tasks: 8
- Estimated complexity: Medium

## Task Dependency Graph

```
T1 [SpotifyDataService API] ──┐
                              ├──> T4 [ViewModel] ──> T5 [DiscoverMusicView] ──> T7 [Context Menu Actions]
T2 [AppRouter Navigation] ────┤                                │
                              │                                v
T3 [DiscoverMusicCard] ───────┘                          T6 [Animations]
                                                               │
                                                               v
                                                         T8 [Build & Test]
```

## Tasks

### Task 1: Add Spotify API Methods for Recommendations
- **Status**: Completed
- **Dependencies**: None
- **Files**:
  - Modify: `vibes/Services/SpotifyDataService.swift`
- **Requirements Addressed**: FR-2
- **Description**:
  Add two new methods to SpotifyDataService: `getTopTracks()` to fetch user's top tracks as seed data, and `getRecommendations()` to fetch song recommendations from Spotify's Recommendations API.
- **Implementation Notes**:
  - Add `getTopTracks(limit: Int, timeRange: SpotifyTimeRange) async throws -> [UnifiedTrack]`
  - Add `getRecommendations(seedTracks: [String], limit: Int) async throws -> [UnifiedTrack]`
  - Add private response models: `SpotifyTopTracksResponse`, `SpotifyRecommendationsResponse`, `SpotifyTrack`
  - `SpotifyTrack` needs `toUnifiedTrack()` method
  - Endpoints: `/v1/me/top/tracks`, `/v1/recommendations`
  - Follow existing error handling pattern (401 -> notAuthenticated, etc.)
- **Acceptance Criteria**:
  - [ ] `getTopTracks()` fetches user's top tracks with time range parameter
  - [ ] `getRecommendations()` accepts seed track IDs and returns UnifiedTrack array
  - [ ] Both methods handle auth errors properly
  - [ ] Response models decode Spotify JSON correctly

---

### Task 2: Add Navigation Destination for Discover Music
- **Status**: Completed
- **Dependencies**: None
- **Files**:
  - Modify: `vibes/Services/AppRouter.swift`
- **Requirements Addressed**: FR-1
- **Description**:
  Add the navigation destination enum and navigation method for the Discover Music feature.
- **Implementation Notes**:
  - Add `DiscoverMusicDestination` enum with `.main` case
  - Add `navigateToDiscoverMusic()` method that appends to feedPath
  - Follow existing pattern from ConcertDiscoveryDestination
- **Acceptance Criteria**:
  - [ ] `DiscoverMusicDestination` enum defined
  - [ ] `navigateToDiscoverMusic()` method works
  - [ ] Compiles without errors

---

### Task 3: Add DiscoverMusicCard Widget to Feed
- **Status**: Completed
- **Dependencies**: Task 2 (navigation destination must exist)
- **Files**:
  - Modify: `vibes/ContentView.swift`
- **Requirements Addressed**: FR-1
- **Description**:
  Add the DiscoverMusicCard widget to FeedView and register the navigation destination.
- **Implementation Notes**:
  - Create `DiscoverMusicCard` struct following `ConcertDiscoveryCard` pattern
  - Use sparkles or waveform icon with orange/pink gradient
  - Title: "Discover Music", Subtitle: "Find new songs you'll love"
  - Add card to FeedView's VStack after ReleasesDiscoveryCard
  - Register `.navigationDestination(for: DiscoverMusicDestination.self)`
  - Initially point to placeholder view (will be replaced in Task 5)
- **Acceptance Criteria**:
  - [ ] DiscoverMusicCard appears on Feed page
  - [ ] Card has appropriate icon, title, subtitle
  - [ ] Tapping card triggers navigation
  - [ ] Navigation destination is registered

---

### Task 4: Create DiscoverMusicViewModel
- **Status**: Completed
- **Dependencies**: Task 1 (API methods must exist)
- **Files**:
  - Create: `vibes/ViewModels/DiscoverMusicViewModel.swift`
- **Requirements Addressed**: FR-2, FR-3, FR-5, FR-6, FR-11, FR-12, NFR-1
- **Description**:
  Create the ViewModel that manages the song queue, fetches recommendations, handles dismissals, and triggers auto-replenishment.
- **Implementation Notes**:
  - Use `@Observable` macro
  - Properties:
    ```swift
    var songQueue: [UnifiedTrack] = []
    var visibleSongs: [UnifiedTrack] { Array(songQueue.prefix(5)) }
    var dismissedSongIds: Set<String> = []
    var seedTrackIds: [String] = []
    var isLoading: Bool = false
    var isReplenishing: Bool = false
    var error: Error?
    private let queueTargetSize = 10
    private let replenishThreshold = 7
    ```
  - Methods:
    - `loadInitialRecommendations()` - Get seeds, fetch 10 songs
    - `dismissSong(at index: Int)` - Remove song, add to dismissedIds, call replenishIfNeeded
    - `replenishQueueIfNeeded()` - If count < 7, background fetch
    - `fetchRecommendations(count: Int) async throws -> [UnifiedTrack]` - API call with duplicate filtering
    - `clearSession()` - Reset state on view disappear
  - Filter out songs in `dismissedSongIds` and songs already in queue
  - Handle empty seed data case (throw DiscoverMusicError.noSeedData)
- **Acceptance Criteria**:
  - [ ] ViewModel loads initial 10 recommendations
  - [ ] `visibleSongs` returns first 5 from queue
  - [ ] `dismissSong(at:)` removes song and triggers replenishment check
  - [ ] Queue replenishes when count drops below 7
  - [ ] Duplicates are filtered out
  - [ ] Loading and error states managed correctly

---

### Task 5: Create DiscoverMusicView and SongDiscoveryCard
- **Status**: Completed
- **Dependencies**: Task 3, Task 4
- **Files**:
  - Create: `vibes/Views/DiscoverMusic/DiscoverMusicView.swift`
  - Create: `vibes/Views/DiscoverMusic/SongDiscoveryCard.swift`
  - Modify: `vibes/ContentView.swift` (update navigation destination)
- **Requirements Addressed**: FR-3, FR-4, FR-5, FR-11, FR-12, NFR-4
- **Description**:
  Create the main discovery view showing 5 song cards and the individual card component.
- **Implementation Notes**:
  - **DiscoverMusicView**:
    - `@State private var viewModel = DiscoverMusicViewModel()`
    - `@Environment(AppRouter.self) private var router`
    - `.task { await viewModel.loadInitialRecommendations() }`
    - Show loading state (ProgressView)
    - Show error state with retry (ContentUnavailableView)
    - Show Spotify not connected state with "Connect Spotify" button
    - Show empty seed data state with guidance
    - Content: ScrollView with LazyVStack of SongDiscoveryCard
    - `.onDisappear { viewModel.clearSession() }`
  - **SongDiscoveryCard**:
    - Parameters: `track: UnifiedTrack`, `onDismiss: () -> Void`
    - Layout: HStack with 64x64 album art, VStack with title/artist/album, dismiss button
    - AsyncImage with placeholder for album art
    - Button with X icon for dismiss
    - Accessibility labels and hints
  - Update ContentView's navigationDestination to point to DiscoverMusicView
- **Acceptance Criteria**:
  - [ ] View shows loading state initially
  - [ ] View shows 5 song cards when loaded
  - [ ] Each card displays album art, title, artist
  - [ ] Dismiss button removes card from list
  - [ ] Error states display appropriately
  - [ ] Spotify not connected shows connect button
  - [ ] VoiceOver labels are set

---

### Task 6: Add Dismissal Animations
- **Status**: Completed
- **Dependencies**: Task 5
- **Files**:
  - Modify: `vibes/Views/DiscoverMusic/DiscoverMusicView.swift`
  - Modify: `vibes/Views/DiscoverMusic/SongDiscoveryCard.swift`
- **Requirements Addressed**: FR-5, NFR-3
- **Description**:
  Add smooth animations for card dismissal and queue updates.
- **Implementation Notes**:
  - Wrap dismissSong call in `withAnimation(.easeOut(duration: 0.25))`
  - Add transition modifier to cards:
    ```swift
    .transition(.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    ))
    ```
  - Use ForEach with explicit id for animation tracking
  - Test that animations are smooth (< 300ms)
- **Acceptance Criteria**:
  - [ ] Dismissed cards animate out to the left
  - [ ] New cards animate in from the right
  - [ ] Animations complete in < 300ms
  - [ ] No janky or stuttering transitions

---

### Task 7: Add Context Menu Actions
- **Status**: Completed
- **Dependencies**: Task 5
- **Files**:
  - Modify: `vibes/Views/DiscoverMusic/SongDiscoveryCard.swift`
- **Requirements Addressed**: FR-7, FR-8, FR-9
- **Description**:
  Add long-press context menu with "Add to Playlist", "Open in Spotify", and "Send to Friend" actions.
- **Implementation Notes**:
  - Add `.contextMenu` modifier to card
  - Actions:
    - "Add to Playlist" -> `router.presentPlaylistPicker(for: track)`, then dismiss card
    - "Open in Spotify" -> Open `track.spotifyUri` or fall back to web URL
    - "Send to Friend" -> `router.presentUserPicker(for: track)`
  - Use SF Symbols for menu icons (plus.circle, arrow.up.right, paperplane)
  - Add parameters to SongDiscoveryCard:
    - `onAddToPlaylist: () -> Void`
    - `onOpenInSpotify: () -> Void`
    - `onSendToFriend: () -> Void`
  - Add accessibility actions matching context menu
- **Acceptance Criteria**:
  - [ ] Long-press shows context menu
  - [ ] "Add to Playlist" presents playlist picker sheet
  - [ ] "Open in Spotify" opens Spotify app or web
  - [ ] "Send to Friend" presents user picker sheet
  - [ ] Accessibility actions work with VoiceOver

---

### Task 8: Build, Test, and Polish
- **Status**: Completed
- **Dependencies**: Task 6, Task 7
- **Files**:
  - All created/modified files
- **Requirements Addressed**: All
- **Description**:
  Final build verification, manual testing, and polish.
- **Implementation Notes**:
  - Run `xcodebuild` to verify compilation
  - Test on simulator:
    - [ ] Navigate to Discover Music from Feed
    - [ ] Initial load shows 5 songs
    - [ ] Dismiss cards and verify queue replenishes
    - [ ] Test context menu actions
    - [ ] Test error states (disconnect Spotify, no seed data)
    - [ ] Test VoiceOver navigation
    - [ ] Test Dynamic Type scaling
  - Fix any issues found
  - Update task.md status to COMPLETED
- **Acceptance Criteria**:
  - [ ] App builds without errors
  - [ ] All manual testing checklist items pass
  - [ ] No crashes or memory leaks
  - [ ] Feature is production-ready

---

## Implementation Order

1. **Task 1** - Add Spotify API methods (foundation)
2. **Task 2** - Add navigation destination (foundation)
3. **Task 3** - Add Feed widget (entry point)
4. **Task 4** - Create ViewModel (business logic)
5. **Task 5** - Create Views (UI)
6. **Task 6** - Add animations (polish)
7. **Task 7** - Add context menu (secondary features)
8. **Task 8** - Build and test (verification)

## Testing Checklist

### Manual Testing
- [ ] Widget appears on Feed page
- [ ] Tapping widget navigates to Discover Music view
- [ ] Initial load fetches and displays 5 songs
- [ ] Dismissing a song removes it and shows next
- [ ] Queue replenishes at < 7 songs
- [ ] No duplicate songs appear in session
- [ ] Animations are smooth
- [ ] Context menu shows all 3 actions
- [ ] "Add to Playlist" works
- [ ] "Open in Spotify" works
- [ ] "Send to Friend" works
- [ ] Spotify disconnected state handled
- [ ] Empty seed data state handled
- [ ] Network error state handled
- [ ] VoiceOver announces correctly
- [ ] Dynamic Type scales properly

## Integration Checklist
- [ ] All tasks completed
- [ ] App builds successfully
- [ ] Manual testing passed
- [ ] Task #143 in docs/task.md marked COMPLETED
