# Search Feature Tasks

## Phase 1: Data Layer

### Task 1.1: Add search method to SpotifyDataService
- [ ] Add `search(query:types:limit:)` method
- [ ] Parse combined response into artists, albums, tracks
- [ ] Handle empty query (return empty results)

**Files**: `vibes/Services/SpotifyDataService.swift`

### Task 1.2: Create AudioPreviewManager
- [ ] Create singleton with AVPlayer
- [ ] `play(_ track: UnifiedTrack)` - plays preview URL
- [ ] `pause()` and `stop()` methods
- [ ] Track current playing state and progress
- [ ] Handle no preview URL gracefully

**Files**: `vibes/Services/AudioPreviewManager.swift`

## Phase 2: ViewModel

### Task 2.1: Create SearchViewModel
- [ ] Properties: query, artists, albums, songs, isSearching, error
- [ ] `search()` with 300ms debounce
- [ ] `clearSearch()` resets state
- [ ] Recent searches management (load, save, clear)

**Files**: `vibes/ViewModels/SearchViewModel.swift`

## Phase 3: UI Components

### Task 3.1: Create search result row components
- [ ] `ArtistSearchRow` - image, name, genres, chevron
- [ ] `AlbumSearchRow` - art, name, artist, year, chevron
- [ ] `SongSearchRow` - art, title, artist, duration, play button

**Files**: `vibes/Views/Search/ArtistSearchRow.swift`, `AlbumSearchRow.swift`, `SongSearchRow.swift`

### Task 3.2: Create RecentSearchesView
- [ ] List of recent search queries
- [ ] Tap to execute search
- [ ] Clear All button
- [ ] Clock icon for each item

**Files**: `vibes/Views/Search/RecentSearchesView.swift`

### Task 3.3: Create SearchResultsView
- [ ] Sections: Artists, Albums, Songs
- [ ] "See All" buttons (optional for MVP)
- [ ] Empty state when no results
- [ ] Loading state

**Files**: `vibes/Views/Search/SearchResultsView.swift`

### Task 3.4: Create MiniPlayerView
- [ ] Shows when preview is playing
- [ ] Album art, song title, artist
- [ ] Play/pause button
- [ ] Tap to stop
- [ ] Positioned at bottom of screen

**Files**: `vibes/Views/Search/MiniPlayerView.swift`

## Phase 4: Integration

### Task 4.1: Update ExploreView
- [ ] Add SearchViewModel as @State
- [ ] Connect searchable modifier to viewModel.query
- [ ] Show RecentSearchesView when focused and empty
- [ ] Show SearchResultsView when has results
- [ ] Show default content when not searching

**Files**: `vibes/ContentView.swift` (ExploreView section)

### Task 4.2: Wire up audio preview
- [ ] Play button in SongSearchRow triggers AudioPreviewManager.play()
- [ ] Show MiniPlayerView when playing
- [ ] Stop preview when navigating away

**Files**: `vibes/Views/Search/SongSearchRow.swift`, `vibes/ContentView.swift`

### Task 4.3: Open in Spotify
- [ ] Tap artist/album/song (not play button) opens in Spotify
- [ ] Use existing `openInSpotify(uri:)` method

**Files**: `vibes/Views/Search/*.swift`

## Phase 5: Polish

### Task 5.1: Recent searches persistence
- [ ] Save to UserDefaults on search
- [ ] Load on app launch
- [ ] Limit to 10 items
- [ ] Clear all functionality

### Task 5.2: Error handling
- [ ] Show error state if search fails
- [ ] Handle offline gracefully
- [ ] Retry button

### Task 5.3: Testing
- [ ] Test search with various queries
- [ ] Test audio preview plays/stops correctly
- [ ] Test open in Spotify works
- [ ] Test recent searches persist

## Dependencies

```
Phase 1 (Data) ──> Phase 2 (ViewModel) ──> Phase 3 (UI) ──> Phase 4 (Integration)
                                                                    |
                                                                    v
                                                            Phase 5 (Polish)
```

## File Summary

New files to create:
```
vibes/Services/AudioPreviewManager.swift
vibes/ViewModels/SearchViewModel.swift
vibes/Views/Search/ArtistSearchRow.swift
vibes/Views/Search/AlbumSearchRow.swift
vibes/Views/Search/SongSearchRow.swift
vibes/Views/Search/RecentSearchesView.swift
vibes/Views/Search/SearchResultsView.swift
vibes/Views/Search/MiniPlayerView.swift
```

Files to modify:
```
vibes/Services/SpotifyDataService.swift (add search method)
vibes/ContentView.swift (update ExploreView)
```
