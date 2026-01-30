# Discover Music - Requirements

## Functional Requirements

### FR-1: Feed Widget Entry Point
- **Type**: Ubiquitous
- **Statement**: The system shall display a "Discover Music" push-navigation widget on the Feed page.
- **Acceptance Criteria**:
  - [ ] Widget appears on Feed below other discovery cards
  - [ ] Widget has music-themed icon (e.g., waveform or sparkles)
  - [ ] Widget has title "Discover Music" and descriptive subtitle
  - [ ] Tapping widget navigates to DiscoverMusicView
- **Priority**: Must
- **Notes**: Follow existing ConcertDiscoveryCard/ReleasesDiscoveryCard pattern

### FR-2: Initial Song Queue Loading
- **Type**: Event-Driven
- **Statement**: When the user opens the Discover Music view, the system shall fetch 10 song recommendations from Spotify based on the user's top tracks and artists.
- **Acceptance Criteria**:
  - [ ] System fetches user's top tracks (medium-term) as seed data
  - [ ] System calls Spotify Recommendations API with seed tracks/artists
  - [ ] 10 songs are loaded into the queue
  - [ ] Loading indicator shown during fetch
- **Priority**: Must
- **Notes**: Use up to 5 seed tracks from user's top tracks

### FR-3: Visible Song Display
- **Type**: Ubiquitous
- **Statement**: The system shall display exactly 5 songs from the queue as visible song cards.
- **Acceptance Criteria**:
  - [ ] 5 song cards are visible in a scrollable/swipeable layout
  - [ ] Each card shows album art, song title, and artist name
  - [ ] Cards are visually distinct and tappable
  - [ ] Remaining 5 songs are buffered but not visible
- **Priority**: Must
- **Notes**: Consider horizontal scroll or vertical stack layout

### FR-4: Song Card Display
- **Type**: Ubiquitous
- **Statement**: Each song card shall display the album artwork, song title, and artist name.
- **Acceptance Criteria**:
  - [ ] Album art displayed with AsyncImage and fallback placeholder
  - [ ] Song title displayed with .headline font
  - [ ] Artist name displayed with .subheadline font
  - [ ] Card uses consistent styling with app design system
- **Priority**: Must
- **Notes**: Follow ReleaseRow pattern for layout

### FR-5: Song Dismissal Interaction
- **Type**: Event-Driven
- **Statement**: When the user taps/dismisses a song card, the system shall remove that song and reveal the next buffered song.
- **Acceptance Criteria**:
  - [ ] Tap on card triggers dismissal
  - [ ] Dismissed song animates out (fade or slide)
  - [ ] Next buffered song animates into the visible area
  - [ ] Queue is updated (dismissed song removed)
- **Priority**: Must
- **Notes**: User dismisses when not interested, already has song, or added to playlist

### FR-6: Queue Auto-Replenishment
- **Type**: Event-Driven
- **Statement**: When the total queue count drops below 7 songs, the system shall automatically fetch additional songs to restore the queue to 10.
- **Acceptance Criteria**:
  - [ ] System monitors queue count after each dismissal
  - [ ] When count < 7, background fetch is triggered
  - [ ] Fetch requests enough songs to reach 10 (e.g., if 6 remain, fetch 4)
  - [ ] No loading spinner shown for background replenishment
  - [ ] New songs appended to end of queue
- **Priority**: Must
- **Notes**: Seamless experience without interruption

### FR-7: Add to Playlist Action
- **Type**: Event-Driven
- **Statement**: When the user long-presses a song card and selects "Add to Playlist", the system shall present a playlist picker and add the song to the selected playlist.
- **Acceptance Criteria**:
  - [ ] Long-press on card shows context menu
  - [ ] "Add to Playlist" option available in menu
  - [ ] Tapping shows playlist picker sheet
  - [ ] Song is added to selected playlist via Spotify API
  - [ ] Success toast/confirmation shown
  - [ ] Song is dismissed from queue after adding
- **Priority**: Should
- **Notes**: Reuse existing playlist picker component

### FR-8: Open in Spotify Action
- **Type**: Event-Driven
- **Statement**: When the user long-presses a song card and selects "Open in Spotify", the system shall open the song in the Spotify app.
- **Acceptance Criteria**:
  - [ ] "Open in Spotify" option in context menu
  - [ ] Opens Spotify app via URI scheme
  - [ ] Falls back to web URL if Spotify not installed
- **Priority**: Should
- **Notes**: Use spotifyUri from UnifiedTrack

### FR-9: Send to Friend Action
- **Type**: Event-Driven
- **Statement**: When the user long-presses a song card and selects "Send to Friend", the system shall present a friend picker to share the song.
- **Acceptance Criteria**:
  - [ ] "Send to Friend" option in context menu
  - [ ] Friend picker sheet presented
  - [ ] Song share created in Firestore
  - [ ] Success confirmation shown
- **Priority**: Could
- **Notes**: Reuse existing share flow

### FR-10: Preview Playback
- **Type**: Event-Driven
- **Statement**: When the user taps the play button on a song card, the system shall play the 30-second preview if available.
- **Acceptance Criteria**:
  - [ ] Play button visible on each card
  - [ ] Tapping plays 30-second preview audio
  - [ ] Visual indicator shows playback state
  - [ ] Tapping again pauses playback
  - [ ] Only one preview plays at a time
- **Priority**: Should
- **Notes**: Use previewURL from UnifiedTrack, graceful handling if no preview

### FR-11: Empty Seed Data State
- **Type**: State-Driven
- **Statement**: While the user has no Spotify listening history (no seed data available), the system shall display an empty state with guidance.
- **Acceptance Criteria**:
  - [ ] Empty state message explains why no recommendations
  - [ ] Suggests listening to music on Spotify first
  - [ ] Provides option to retry
- **Priority**: Must
- **Notes**: Edge case for new Spotify users

### FR-12: Spotify Not Connected State
- **Type**: State-Driven
- **Statement**: While Spotify is not connected, the system shall display a prompt to connect Spotify.
- **Acceptance Criteria**:
  - [ ] Message indicates Spotify connection required
  - [ ] "Connect Spotify" button navigates to settings
  - [ ] View updates when connection status changes
- **Priority**: Must
- **Notes**: Reuse existing auth error pattern

## Non-Functional Requirements

### NFR-1: Seamless Queue Replenishment
- **Category**: Performance
- **Statement**: The system shall replenish the queue in the background without visible loading states or UI interruption.
- **Acceptance Criteria**:
  - [ ] No spinner or loading indicator during replenishment
  - [ ] User can continue dismissing songs during fetch
  - [ ] Fetch completes before queue empties (under normal conditions)
- **Priority**: Must

### NFR-2: API Rate Limit Handling
- **Category**: Reliability
- **Statement**: If Spotify API rate limits are hit, the system shall gracefully handle the error without crashing.
- **Acceptance Criteria**:
  - [ ] Rate limit errors caught and handled
  - [ ] User informed only if queue is depleted
  - [ ] Automatic retry with exponential backoff
- **Priority**: Should

### NFR-3: Smooth Animations
- **Category**: Usability
- **Statement**: The system shall animate song dismissals and queue updates with smooth, native-feeling animations.
- **Acceptance Criteria**:
  - [ ] Dismissal animation completes in < 300ms
  - [ ] New song slides in smoothly
  - [ ] No janky or stuttering transitions
- **Priority**: Should

### NFR-4: Accessibility Support
- **Category**: Accessibility
- **Statement**: The Discover Music view shall support VoiceOver and Dynamic Type.
- **Acceptance Criteria**:
  - [ ] All interactive elements have accessibility labels
  - [ ] Song cards announce title, artist, and available actions
  - [ ] Text scales with Dynamic Type settings
  - [ ] Dismiss action accessible via VoiceOver
- **Priority**: Should

### NFR-5: Memory Efficiency
- **Category**: Performance
- **Statement**: The system shall manage memory efficiently by not caching excessive song data.
- **Acceptance Criteria**:
  - [ ] Only 10 songs held in memory at a time
  - [ ] Dismissed songs are deallocated
  - [ ] Album art images use appropriate caching
- **Priority**: Should

## Constraints

### Technical Constraints
- Must use existing Spotify authentication (SpotifyAuthService)
- Must use Spotify Recommendations API endpoint
- Limited to 5 seed items (tracks + artists combined) per recommendation request
- Songs must be UnifiedTrack model for consistency
- Must follow MVVM pattern with @Observable

### Business Constraints
- Spotify Premium not required (recommendations API is available to all)
- Cannot cache recommendations for offline use (per Spotify ToS)

## Assumptions

- User has a Spotify account connected to the app
- User has some listening history for seed data (top tracks/artists available)
- Spotify Recommendations API returns diverse results (not repeated songs)
- Network connectivity is available for API calls
- Spotify will not return songs the user has already saved (API behavior)

## Edge Cases

### EC-1: Queue Depleted Before Replenishment
- **Scenario**: User dismisses songs faster than API can replenish
- **Handling**: Show brief loading state, continue when new songs arrive

### EC-2: Duplicate Recommendations
- **Scenario**: Spotify returns a song already in queue or previously dismissed
- **Handling**: Filter out duplicates, fetch additional songs if needed

### EC-3: Network Failure During Replenishment
- **Scenario**: Background fetch fails due to network error
- **Handling**: Retry on next dismissal, show error only if queue empties

### EC-4: No Preview URL Available
- **Scenario**: Song doesn't have 30-second preview
- **Handling**: Hide or disable play button, indicate preview unavailable

### EC-5: Spotify Session Expired
- **Scenario**: Token expires during discovery session
- **Handling**: Attempt silent refresh, show reconnect prompt if refresh fails

### EC-6: All Recommendations Exhausted
- **Scenario**: User has dismissed many songs, recommendations become repetitive
- **Handling**: Use different seed tracks, inform user to try again later if truly exhausted
