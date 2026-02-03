# Unified Content Feed - Requirements

## Functional Requirements

### FR-1: Setup Card Conditional Visibility
- **Type**: State-Driven
- **Statement**: While setup is incomplete (fewer than 3 items configured), the system shall display the Setup card at the top of the feed. When all 3 setup items are complete, the system shall hide the Setup card.
- **Acceptance Criteria**:
  - [ ] Setup card appears when `SetupManager.isAllComplete` is false
  - [ ] Setup card is hidden when `SetupManager.isAllComplete` is true
  - [ ] Setup card visibility updates immediately when final setup item is completed
  - [ ] Setup card remains in fixed position at top (not in scrollable feed)
- **Priority**: Must
- **Notes**: Uses existing `SetupManager.isAllComplete` property

### FR-2: Find People Card Persistence
- **Type**: Ubiquitous
- **Statement**: The system shall always display the Find People card at the top of the feed, below the Setup card (if visible).
- **Acceptance Criteria**:
  - [ ] Find People card is always visible regardless of other state
  - [ ] Find People card appears below Setup card when Setup is visible
  - [ ] Find People card appears at top when Setup card is hidden
  - [ ] Tapping Find People card opens the user search sheet
- **Priority**: Must
- **Notes**: Existing card behavior maintained

### FR-3: Concert Feed Card Display
- **Type**: Event-Driven
- **Statement**: When the feed loads or refreshes, the system shall fetch upcoming concerts for artists the user follows and display them as Concert Feed Cards in the feed stream.
- **Acceptance Criteria**:
  - [ ] Concert cards show artist name, venue, city, and date
  - [ ] Concert cards display artist image if available
  - [ ] Concert cards show price range if available
  - [ ] Only concerts within configured city radius are shown
  - [ ] Concerts are limited to reasonable count (e.g., 5) to avoid feed flooding
- **Priority**: Must
- **Notes**: Uses existing `TicketmasterService` and `Concert` model

### FR-4: Concert Card Navigation
- **Type**: Event-Driven
- **Statement**: When the user taps a Concert Feed Card, the system shall navigate to the Concert Discovery view.
- **Acceptance Criteria**:
  - [ ] Tapping concert card navigates to `ConcertDiscoveryView`
  - [ ] Navigation uses existing router pattern
  - [ ] Back navigation returns to feed
- **Priority**: Must
- **Notes**: Card acts as entry point to full feature

### FR-5: New Release Feed Card Display
- **Type**: Event-Driven
- **Statement**: When the feed loads or refreshes, the system shall fetch new album/single releases from artists the user follows and display them as Release Feed Cards in the feed stream.
- **Acceptance Criteria**:
  - [ ] Release cards show album name, artist name, and release date
  - [ ] Release cards display album artwork
  - [ ] Release cards indicate album type (album, single, EP) if available
  - [ ] Only releases from the past 2 weeks are shown
  - [ ] Releases are limited to reasonable count (e.g., 5) to avoid feed flooding
- **Priority**: Must
- **Notes**: Uses existing `SpotifyDataService` and `UnifiedAlbum` model

### FR-6: Release Card Navigation
- **Type**: Event-Driven
- **Statement**: When the user taps a Release Feed Card, the system shall navigate to the Releases Discovery view.
- **Acceptance Criteria**:
  - [ ] Tapping release card navigates to `ReleasesDiscoveryView`
  - [ ] Navigation uses existing router pattern
  - [ ] Back navigation returns to feed
- **Priority**: Must
- **Notes**: Card acts as entry point to full feature

### FR-7: Song Recommendation Feed Card Display
- **Type**: Event-Driven
- **Statement**: When the feed loads or refreshes, the system shall fetch personalized song recommendations and display them as Recommendation Feed Cards in the feed stream.
- **Acceptance Criteria**:
  - [ ] Recommendation cards show track name, artist name, and album art
  - [ ] Recommendation cards display a brief reason/context (e.g., "Based on your listening")
  - [ ] Recommendations are personalized based on user's listening history
  - [ ] Recommendations are limited to reasonable count (e.g., 3) to avoid feed flooding
- **Priority**: Must
- **Notes**: Uses existing AI/discovery services

### FR-8: Recommendation Card Navigation
- **Type**: Event-Driven
- **Statement**: When the user taps a Song Recommendation Feed Card, the system shall navigate to the Discover Music view.
- **Acceptance Criteria**:
  - [ ] Tapping recommendation card navigates to `DiscoverMusicView`
  - [ ] Navigation uses existing router pattern
  - [ ] Back navigation returns to feed
- **Priority**: Must
- **Notes**: Card acts as entry point to full feature

### FR-9: Song Share Card Display (Existing)
- **Type**: Ubiquitous
- **Statement**: The system shall display Song Share cards for songs shared by users the current user follows.
- **Acceptance Criteria**:
  - [ ] Song share cards display sender info, track info, and optional message
  - [ ] Song share cards support playback interaction
  - [ ] Song share cards appear in chronological order relative to other feed items
  - [ ] Existing `SongShareCard` component is reused
- **Priority**: Must
- **Notes**: Existing functionality maintained

### FR-10: Unified Feed Stream
- **Type**: Ubiquitous
- **Statement**: The system shall merge all feed card types (song shares, concerts, releases, recommendations) into a single scrollable stream, interleaved based on a sorting algorithm.
- **Acceptance Criteria**:
  - [ ] All card types appear in a single `ScrollView`/`LazyVStack`
  - [ ] Cards are sorted using the existing `FeedItem.sortScore` algorithm
  - [ ] Social content (song shares) is prioritized but not exclusively at top
  - [ ] Discovery cards are distributed throughout the feed, not clustered
- **Priority**: Must
- **Notes**: Uses existing `FeedItem` enum for unified model

### FR-11: Feed Refresh
- **Type**: Event-Driven
- **Statement**: When the user performs pull-to-refresh, the system shall reload all feed content sources (shares, concerts, releases, recommendations).
- **Acceptance Criteria**:
  - [ ] Pull-to-refresh triggers reload of all content types
  - [ ] Loading indicator shows during refresh
  - [ ] Feed updates with fresh content after refresh completes
  - [ ] Errors during refresh are handled gracefully (partial content shown)
- **Priority**: Must
- **Notes**: Existing `.refreshable` pattern

### FR-12: Remove Static Discovery Widgets
- **Type**: Ubiquitous
- **Statement**: The system shall remove the static navigation widgets (ConcertDiscoveryCard, ReleasesDiscoveryCard, DiscoverMusicCard) from the top of the feed.
- **Acceptance Criteria**:
  - [ ] `ConcertDiscoveryCard` is no longer rendered in feed
  - [ ] `ReleasesDiscoveryCard` is no longer rendered in feed
  - [ ] `DiscoverMusicCard` is no longer rendered in feed
  - [ ] Only Setup and Find People cards remain at top
- **Priority**: Must
- **Notes**: These are replaced by contextual content cards

### FR-13: Feed Card Visual Distinction
- **Type**: Ubiquitous
- **Statement**: The system shall visually distinguish each feed card type through consistent but differentiated design (icons, colors, layout).
- **Acceptance Criteria**:
  - [ ] Concert cards have distinct visual treatment (ticket/calendar icon, purple accent)
  - [ ] Release cards have distinct visual treatment (music note icon, green accent)
  - [ ] Recommendation cards have distinct visual treatment (sparkles icon, orange accent)
  - [ ] Song share cards maintain existing design
  - [ ] All cards follow consistent spacing and typography
- **Priority**: Should
- **Notes**: Visual consistency with existing app design system

### FR-14: Empty Feed State
- **Type**: State-Driven
- **Statement**: While the feed has no content (no shares, no concerts, no releases, no recommendations), the system shall display an appropriate empty state message.
- **Acceptance Criteria**:
  - [ ] Empty state shows when all content sources return empty
  - [ ] Empty state message encourages user action (follow people, connect Spotify)
  - [ ] Empty state is not shown if any content exists
- **Priority**: Should
- **Notes**: Existing `ContentUnavailableView` pattern

### FR-15: Artist Follow Button
- **Type**: Event-Driven
- **Statement**: When viewing an artist profile, the system shall display a follow/unfollow button that allows the user to follow or unfollow the artist.
- **Acceptance Criteria**:
  - [ ] Follow button appears on all artist profile views
  - [ ] Button shows "Follow" when not following, "Following" when following
  - [ ] Tapping "Follow" adds artist to user's followed artists
  - [ ] Tapping "Following" shows unfollow confirmation or unfollows
  - [ ] Follow state persists across app sessions
  - [ ] Button updates immediately on tap (optimistic UI)
- **Priority**: Must
- **Notes**: Stored in Firestore under user document

### FR-16: Artist Follow Persistence
- **Type**: Ubiquitous
- **Statement**: The system shall persist followed artists in Firestore and sync across devices.
- **Acceptance Criteria**:
  - [ ] Followed artists stored in Firestore `users/{userId}/followedArtists` subcollection
  - [ ] Each followed artist document contains: artistId, artistName, artistImageURL, followedAt
  - [ ] Follow state loads on app launch
  - [ ] Follow state syncs when user logs in on new device
- **Priority**: Must
- **Notes**: Similar pattern to user following (SocialService)

### FR-17: Feed Uses Followed Artists
- **Type**: State-Driven
- **Statement**: While the user has followed artists, the system shall use those artists (instead of or in addition to Spotify top artists) to generate concert and release feed cards.
- **Acceptance Criteria**:
  - [ ] Concert cards prioritize followed artists over Spotify top artists
  - [ ] Release cards prioritize followed artists over Spotify top artists
  - [ ] If no followed artists, fall back to Spotify top artists
  - [ ] Feed refreshes when user follows/unfollows an artist
- **Priority**: Must
- **Notes**: Followed artists take precedence for personalization

### FR-18: Recommendations Use Followed Artists
- **Type**: State-Driven
- **Statement**: While the user has followed artists, the system shall use those artists as seed data for song recommendations, improving accuracy.
- **Acceptance Criteria**:
  - [ ] Song recommendations use followed artists as seeds when available
  - [ ] Recommendations blend followed artists with listening history
  - [ ] More followed artists = more personalized recommendations
- **Priority**: Should
- **Notes**: Enhances existing recommendation logic

## Non-Functional Requirements

### NFR-1: Feed Load Performance
- **Category**: Performance
- **Statement**: The system shall load and display the initial feed within 2 seconds under normal network conditions.
- **Acceptance Criteria**:
  - [ ] Feed renders within 2 seconds of view appearing
  - [ ] Loading indicator shown during fetch
  - [ ] Partial content renders as it becomes available
- **Priority**: Should

### NFR-2: Scroll Performance
- **Category**: Performance
- **Statement**: The system shall maintain smooth scrolling (60fps) through the feed regardless of content volume.
- **Acceptance Criteria**:
  - [ ] `LazyVStack` used for efficient rendering
  - [ ] No frame drops during normal scrolling
  - [ ] Images load asynchronously
- **Priority**: Must

### NFR-3: Accessibility
- **Category**: Accessibility
- **Statement**: The system shall support VoiceOver for all feed cards with appropriate labels.
- **Acceptance Criteria**:
  - [ ] All cards have accessibility labels describing content type and key info
  - [ ] Interactive elements are properly labeled
  - [ ] Dynamic Type is supported
- **Priority**: Should

## Constraints

- Must use existing data services (`TicketmasterService`, `SpotifyDataService`, `SocialService`)
- Must use existing navigation pattern (`AppRouter`)
- Must use existing `FeedItem` enum model
- Must maintain compatibility with `MiniPlayerView` at bottom of feed
- Cannot add new backend dependencies (use existing Firebase/Spotify/Ticketmaster)

## Assumptions

- User has Spotify connected for release and recommendation data
- User has Ticketmaster configured for concert data
- Existing services return data in compatible formats

## Edge Cases

- **No Spotify connection**: Show only song shares in feed; hide release/recommendation cards
- **No Ticketmaster setup**: Show only song shares and Spotify-based cards; hide concert cards
- **No followed artists (in-app) and no Spotify**: Show song shares only; display contextual empty state for discovery sections
- **No followed artists (in-app) but has Spotify**: Fall back to Spotify top artists for concerts/releases
- **All services fail**: Show error state with retry option
- **Slow network**: Show skeleton/placeholder cards during load
- **Very old content**: Don't show concerts from the past or releases older than 2 weeks
- **Artist already followed**: Follow button shows "Following" state, tapping shows unfollow option
- **Offline follow action**: Queue follow/unfollow and sync when online
