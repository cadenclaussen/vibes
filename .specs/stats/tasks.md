# Stats Feature Tasks

## Phase 1: Data Layer

### Task 1.1: Add Spotify API methods
- [ ] Add `getTopArtists(timeRange:limit:)` to SpotifyDataService
- [ ] Add `getTopTracks(timeRange:limit:)` to SpotifyDataService
- [ ] Add `getRecentlyPlayed(limit:)` to SpotifyDataService
- [ ] Create `TimeRange` enum (shortTerm, mediumTerm, longTerm)
- [ ] Create `RecentTrack` model (track + playedAt timestamp)

**Files**: `vibes/Services/SpotifyDataService.swift`, `vibes/Models/RecentTrack.swift`

### Task 1.2: Genre extraction
- [ ] Add `extractTopGenres(from artists:count:)` helper method
- [ ] Returns top N genres from artist genre arrays (deduplicated, ranked by frequency)
- [ ] Handle empty/missing genre data

**Files**: `vibes/Services/SpotifyDataService.swift`

## Phase 2: ViewModel

### Task 2.1: Create StatsViewModel
- [ ] Create `StatsViewModel.swift` with @Observable
- [ ] Properties: timeRange, topArtists, topSongs, topGenres, recentlyPlayed
- [ ] Properties: previewArtists (for card), isLoading, isLoadingPreview, error
- [ ] `loadPreview()` fetches top 3 artists only (for Profile card)
- [ ] `loadStats()` fetches all data in parallel
- [ ] `refresh()` for pull-to-refresh
- [ ] `setTimeRange(_:)` updates and reloads

**Files**: `vibes/ViewModels/StatsViewModel.swift`

## Phase 3: Profile Integration

### Task 3.1: Create StatsPreviewCard
- [ ] Shows on Profile below follower counts
- [ ] Displays top 3 artist images (48x48) in horizontal row
- [ ] Shows comma-separated artist names
- [ ] Subtitle: "Your top artists this month"
- [ ] Chevron indicating more
- [ ] Tap calls `router.navigateToStats()`
- [ ] If no Spotify connected: show "Connect Spotify to see stats" with button
- [ ] Loading state while fetching

**Files**: `vibes/Views/Stats/StatsPreviewCard.swift`

### Task 3.2: Add StatsPreviewCard to ProfileView
- [ ] Add StatsPreviewCard below follower counts section
- [ ] Initialize StatsViewModel and call loadPreview() on appear
- [ ] Add navigation destination for StatsDestination

**Files**: `vibes/Views/ProfileView.swift` (in ContentView.swift)

### Task 3.3: Add Stats navigation to AppRouter
- [ ] Create `StatsDestination` enum
- [ ] Add `navigateToStats()` method
- [ ] Appends to profilePath

**Files**: `vibes/Services/AppRouter.swift`

## Phase 4: Full Stats View

### Task 4.1: Create TopArtistsSection
- [ ] Horizontal ScrollView of artist cards
- [ ] Artist card: 80x80 image, name below, rank overlay
- [ ] Tap to open in Spotify

**Files**: `vibes/Views/Stats/TopArtistsSection.swift`

### Task 4.2: Create TopSongsSection
- [ ] Vertical list of top 10 songs
- [ ] Song row: rank number, album art (40x40), title, artist, Spotify icon
- [ ] Tap to open in Spotify

**Files**: `vibes/Views/Stats/TopSongsSection.swift`

### Task 4.3: Create TopGenresSection
- [ ] Horizontal flow layout of genre chips
- [ ] Chip styling: rounded rectangle, secondary background color
- [ ] Shows top 5 genres

**Files**: `vibes/Views/Stats/TopGenresSection.swift`

### Task 4.4: Create RecentlyPlayedSection
- [ ] Vertical list of last 20 tracks
- [ ] Row: album art (40x40), title, artist, relative time ("5 min ago")
- [ ] Tap to open in Spotify

**Files**: `vibes/Views/Stats/RecentlyPlayedSection.swift`

### Task 4.5: Create StatsView
- [ ] ScrollView combining all four sections
- [ ] Time range picker in toolbar (Menu style)
- [ ] Pull-to-refresh
- [ ] Loading state (skeleton or spinner)
- [ ] Error state with retry button
- [ ] Call loadStats() on appear

**Files**: `vibes/Views/Stats/StatsView.swift`

## Phase 5: Polish

### Task 5.1: Open in Spotify
- [ ] Add `openInSpotify(uri:)` helper
- [ ] Handle artist URIs, track URIs
- [ ] Fallback to web URL if Spotify app not installed

**Files**: `vibes/Services/SpotifyDataService.swift` or utility

### Task 5.2: Testing
- [ ] Build and run on simulator
- [ ] Test all three time ranges
- [ ] Test Spotify deep links work
- [ ] Test error states (no network, API failure)
- [ ] Test no-Spotify-connected state on preview card
- [ ] Verify pull-to-refresh works

## Dependencies

```
Phase 1 (Data) ──> Phase 2 (ViewModel) ──> Phase 3 (Profile Integration)
                                      └──> Phase 4 (Full Stats View)
                                                       |
                                                       v
                                               Phase 5 (Polish)
```

Parallel work possible:
- Tasks 4.1, 4.2, 4.3, 4.4 can be done in parallel after Phase 2
- Task 3.1 and Tasks 4.x can be done in parallel after Phase 2

## File Summary

New files to create:
```
vibes/Models/RecentTrack.swift
vibes/ViewModels/StatsViewModel.swift
vibes/Views/Stats/StatsPreviewCard.swift
vibes/Views/Stats/StatsView.swift
vibes/Views/Stats/TopArtistsSection.swift
vibes/Views/Stats/TopSongsSection.swift
vibes/Views/Stats/TopGenresSection.swift
vibes/Views/Stats/RecentlyPlayedSection.swift
```

Files to modify:
```
vibes/Services/SpotifyDataService.swift (add API methods)
vibes/Services/AppRouter.swift (add StatsDestination)
vibes/ContentView.swift (add StatsPreviewCard to ProfileView)
```
