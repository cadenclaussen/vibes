# Task Tracking

## Active Tasks

### 157. Music Collaboration Feature
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/SocialService.swift, vibes/ViewModels/UserSearchViewModel.swift, vibes/ViewModels/FollowViewModel.swift, vibes/ViewModels/ShareViewModel.swift, vibes/Views/Social/, vibes/ContentView.swift, vibes/Views/NowPlaying/NowPlayingView.swift, vibes/Services/AppRouter.swift
- **Requested**: Implement social music sharing with follow model (Twitter/Instagram style). Users can follow each other, share songs directly, and see what friends are listening to.
- **Context**: Core differentiator - transforms app from Spotify frontend to social music platform
- **Acceptance Criteria**:
  - [x] Create Kiro specs in .specs/music-collaboration/
  - [x] SocialService with Firestore operations for follows/shares
  - [x] User search with debounced input
  - [x] Follow/unfollow functionality
  - [x] Followers/following lists on profile
  - [x] Share button on Now Playing view
  - [x] Share from search results (context menu)
  - [x] Activity feed with song shares from followed users
  - [x] Tap shared song to play
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full Music Collaboration feature (Phase 1: Following System):
  - **Kiro Specs**: Created .specs/music-collaboration/ with prd.md, requirements.md, design.md, tasks.md
  - **Services**: SocialService.swift with searchUsers, follow/unfollow, getFollowers/getFollowing, shareSong, getSharesFromFollowing
  - **ViewModels**: UserSearchViewModel (debounced search), FollowViewModel (followers/following lists), ShareViewModel (song sharing)
  - **Views**: UserSearchView (find people sheet), UserSearchRow (user card with follow button), FollowListView (followers/following), UserProfileView (other user's profile), ShareSheetView (share song to followers), SongShareCard (shared song in feed)
  - **Navigation**: Added SocialDestination enum, navigateToUserProfile, navigateToFollowers, navigateToFollowing, presentShareSheet to AppRouter
  - **Integration**: FindPeopleCard in Feed, share button in NowPlayingView actionRow, share context menu in SongSearchRow, profile followers/following counts
  - Build succeeds on iPhone 16e simulator

### 156. Now Playing View with Synced Lyrics
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/NowPlaying/, vibes/Views/Search/MiniPlayerView.swift, vibes/Services/
- **Requested**: Remove play/shuffle buttons from MiniPlayer, make it tappable to expand to full-screen Now Playing view with album art, song info, synced scrolling lyrics, and draggable progress bar
- **Context**: Enhanced music playback experience with lyrics support
- **Acceptance Criteria**:
  - [x] Create Kiro specs in .specs/now-playing/
  - [x] MiniPlayer simplified (removed buttons, tap to expand)
  - [x] NowPlayingView with large album art and track info
  - [x] Synced scrolling lyrics from LRCLIB API
  - [x] Current lyric line highlighted, auto-scrolls
  - [x] Draggable progress bar with seek functionality
  - [x] Play/pause button in full view
  - [x] Sheet presentation with swipe to dismiss
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full Now Playing feature:
  - **Models**: SyncedLyrics.swift with LRC parser
  - **Services**: LyricsService.swift (LRCLIB API), added seek() and isNowPlayingPresented to SpotifyRemoteService
  - **ViewModel**: NowPlayingViewModel.swift for lyrics loading and current line tracking
  - **Views**: NowPlayingView.swift (full-screen), LyricsView.swift (auto-scroll, highlighting), InteractiveProgressBar.swift (draggable)
  - **MiniPlayer**: Simplified to album art + track info + progress bar, tap presents NowPlayingView sheet

### 155. Implement Album Detail & Artist Profile Views
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Album/, vibes/Views/Artist/, vibes/ViewModels/, vibes/ContentView.swift
- **Requested**: Implement in-app Album Detail View and Artist Profile View to keep users within Vibes instead of redirecting to Spotify. All navigation is push-nav, all songs are playable, all albums are clickable.
- **Context**: Currently album/artist taps open Spotify. Need to build native views for better UX.
- **Acceptance Criteria**:
  - [x] Create Kiro specs in .specs/album-artist-views/
  - [x] Create AlbumDetailViewModel with loadTracks(), playAll(), shuffle()
  - [x] Create AlbumDetailView with header and track list
  - [x] Create AlbumHeaderView with cover art, metadata, play/shuffle buttons
  - [x] Create AlbumTrackRow with track number, name, duration, explicit badge
  - [x] Create ArtistProfileViewModel with loadData(), playTrack()
  - [x] Create ArtistProfileView with header, top songs, albums
  - [x] Create ArtistHeaderView with image, gradient, name, genres
  - [x] Create ArtistAlbumsSection with horizontal scrolling album thumbnails
  - [x] Update ContentView to use real views instead of placeholders
  - [x] Build succeeds on iPhone 16e simulator
  - [x] Cross-navigation works (album artist -> artist, artist album -> album)
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full Album Detail and Artist Profile features:
  - **Kiro Specs**: Created .specs/album-artist-views/ with prd.md, requirements.md, design.md, tasks.md
  - **Album Feature**: AlbumDetailViewModel.swift (loadTracks, playAll, shuffle), AlbumDetailView.swift, AlbumHeaderView.swift (cover art, artist link, play/shuffle buttons), AlbumTrackRow.swift (track number, explicit badge, context menu)
  - **Artist Feature**: ArtistProfileViewModel.swift (loadData with parallel top tracks + albums fetch), ArtistProfileView.swift, ArtistHeaderView.swift (large image with gradient, genre chips), ArtistAlbumsSection.swift (horizontal scroll)
  - **Navigation**: Updated ContentView to use real views in ExploreView and FeedView navigation destinations. Cross-nav works: album artist name -> artist profile, artist album thumbnail -> album detail
  - **Playback**: Integrated with SpotifyRemoteService, MiniPlayer shown on both views
  - Build succeeds on iPhone 16e simulator

### 133. Remove all code and start from scratch
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/, vibes.xcodeproj/, docs/, build/, vids/, .specs/, GoogleService-Info.plist
- **Requested**: User wants to remove all existing code and start fresh
- **Context**: Complete project reset - task was superseded by subsequent development
- **Acceptance Criteria**:
  - [x] Task superseded - app was rebuilt instead
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Task was superseded by subsequent development tasks that rebuilt the app

### 124. Add Apple Music as alternative to Spotify
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/, vibes/Models/, vibes/Views/ProfileView.swift
- **Requested**: Integrate Apple Music as another option alongside Spotify. Users should be able to choose which music service to connect.
- **Context**: Currently the app only supports Spotify. Apple Music integration would expand the user base significantly. Requires creating a music service abstraction layer since the app currently has direct Spotify dependencies throughout.
- **Acceptance Criteria**:
  - [x] Create MusicServiceProtocol abstraction layer
  - [x] Create service-agnostic data models (MusicTrack, MusicArtist, etc.)
  - [x] Implement AppleMusicService using MusicKit
  - [x] Update auth flow to let users choose Spotify or Apple Music
  - [x] Update all views to work with either service (ProfileView done)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Foundation complete. New files: UnifiedMusicModels.swift, MusicStreamingService.swift protocol, SpotifyModelExtensions.swift, SpotifyServiceAdapter.swift, AppleMusicService.swift, MusicServiceManager.swift, MusicServicePicker.swift. All views updated to use MusicServiceManager for unified access.

### 125. Navigation architecture redesign research
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: docs/nav.md (new)
- **Requested**: Navigation model is bad - needs to be fixed, made easier for users, less repetitive. Also wants to add a homepage. Create nav.md with options including upsides, downsides, and trade-offs. Follow-up: Should Search be integrated into Discover? Should Settings be separate from Profile? Deep thought on how app should work logically and beautifully.
- **Context**: Current navigation uses custom ScrollView-based tabs with bindings passed through multiple layers. No homepage, repetitive patterns, hacky cross-tab navigation.
- **Acceptance Criteria**:
  - [x] Analyze current navigation architecture
  - [x] Create nav.md with multiple options
  - [x] Include upsides, downsides, trade-offs for each
  - [x] Provide recommendation
  - [x] Deep analysis: Search integration into Discover
  - [x] Deep analysis: Profile vs Settings separation
  - [x] Home tab content design
  - [x] Router architecture design
  - [x] Migration path
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created comprehensive docs/nav.md with final design: Option 4 (Hybrid TabView + Router). 4 tabs: Home, Explore (Search integrated), Chats, Profile (Settings via cog). Detailed Home tab sections, Router architecture with AppRouter class, visual/interaction design principles, and 5-phase migration path.

### 126. AI Playlist Ideas fails with "failed to request developer token"
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/AppleMusicService.swift
- **Requested**: When trying to use AI playlist ideas feature, user gets error "failed to request developer token"
- **Context**: This is an Apple MusicKit error. MusicKit requires a valid developer token to authenticate with Apple's servers. The token is normally obtained automatically based on app entitlements and Team ID.
- **Acceptance Criteria**:
  - [x] Identify root cause of developer token failure
  - [x] Implement fix or provide clear guidance
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Root cause is MusicKit not being enabled for the App ID in Apple Developer portal. Added `performMusicKitRequest()` wrapper to all MusicKit API calls that catches developer token errors and throws a clear error message: "MusicKit not configured. Enable MusicKit for your App ID in the Apple Developer portal and regenerate your provisioning profile." User must: (1) Go to developer.apple.com, (2) Enable MusicKit capability for App ID, (3) Regenerate provisioning profile, (4) Re-download in Xcode.

### 127. Navigation redesign implementation
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/AppRouter.swift (new), vibes/Views/HomeView.swift (new), vibes/ViewModels/HomeViewModel.swift (new), vibes/Views/SettingsView.swift (new), vibes/Views/ExploreView.swift (new), vibes/ViewModels/ExploreViewModel.swift (new), vibes/ContentView.swift, vibes/Views/ChatsView.swift, vibes/Views/ProfileView.swift
- **Requested**: Implement navigation redesign from docs/nav.md - Option 4 (Hybrid TabView + Router). Replace custom ScrollView tabs with native TabView. Add Home tab, merge Search into Explore, extract Settings from Profile.
- **Context**: Current navigation used custom ScrollView-based tabs with bindings passed through multiple layers, causing repetitive patterns and hacky cross-tab navigation.
- **Acceptance Criteria**:
  - [x] Create AppRouter with centralized navigation state
  - [x] Create SettingsView (extracted from ProfileView)
  - [x] Create ExploreView and ExploreViewModel (merged Search + Discover)
  - [x] Create HomeView and HomeViewModel (new personalized hub)
  - [x] Update ContentView with native TabView + router
  - [x] Update ChatsView to use router
  - [x] Update ProfileView (remove settings, add cog icon)
  - [x] Delete old files (SearchView, DiscoverView, SearchViewModel, DiscoverViewModel)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full navigation redesign. Created AppRouter.swift with Tab enum, AppDestination enum, and navigation methods. Created HomeView with greeting, quick actions, recent chats, friend activity, today's pick, and vibestreak reminders. Created ExploreView merging Search + Discover with shared search bar. Extracted SettingsView from ProfileView. Updated ContentView to use native TabView(selection:) with 4 tabs. Updated ChatsView and ProfileView to use router environment. Deleted old Search/Discover files.

### 128. Fix "Connect to Spotify/Apple Music" navigating to wrong page
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/ExploreView.swift:434, vibes/Views/ProfileView.swift:287-314, vibes/Services/AppRouter.swift:158-160
- **Requested**: When clicking connect to spotify or apple music, it brings to the profile page, but there aren't any options to connect
- **Context**: Music service connection options were moved to SettingsView during navigation redesign, but navigation buttons still pointed to Profile tab
- **Acceptance Criteria**:
  - [x] ExploreView's "Go to Profile" button navigates to Settings
  - [x] ProfileView's stats "Connect Spotify" button navigates to Settings
  - [x] Add goToSettings() method to AppRouter
  - [x] Configure ProfileView's NavigationStack to use router.profilePath
  - [x] Add navigationDestination for AppDestination.settings
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated ProfileView to use router.profilePath with NavigationStack and added navigationDestination for .settings -> SettingsView. Added goToSettings() convenience method to AppRouter. Changed ExploreView and ProfileView's music connection buttons to call router.goToSettings() instead of showing Spotify auth directly or going to Profile.

### 129. Recreate nav.md with new feature-based navigation models
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: docs/nav.md
- **Requested**: Forget about current app, recreate nav.md from scratch. Core use cases: (1) Music Collaboration - follow model like Twitter/Instagram, sharing, trending, (2) Music Discovery - personal taste, top genres/artists/songs, LLM enhancement, user can rank/manipulate lists, Shazam, friend-based discovery, direct sharing, (3) Simple Search - artists/playlists/albums/songs with 30s previews, (4) Stats - top artists/songs/genres/recently played, (5) Trending - new releases, popular songs, concerts, (6) AI Playlist Creation - mood-based, filtering, friend blends, (7) Gamification - achievements, vibe-streaks, (8) Setup - music service connection with CTA/notifications until complete, (9) Profile management
- **Context**: Need fresh navigation architecture that organizes all these features logically. User wants multiple navigation model options with trade-offs.
- **Acceptance Criteria**:
  - [x] Create multiple navigation model options
  - [x] Each option has upsides and downsides
  - [x] Options address all core use cases
  - [x] Include recommendation
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created 5 navigation model options: (1) Social Hub - Home/Feed/Explore/Profile, (2) Activity-Centric - Home/Discover/Create/Me with dedicated Create tab, (3) Minimalist - 3 tabs Feed/Explore/Profile, (4) Instagram/TikTok Social - Home/Discover/Inbox/Profile emphasizing follow model, (5) Content-First - For You/Search/Library/Profile Spotify-like. Each has detailed tree structure, upsides/downsides, use case coverage table. Includes comparison matrix and recommendations based on primary value prop (Social→Option 4, Discovery→Option 3, Creation→Option 2). Added setup flow considerations and next steps.

### 130. Implement MVP according to first-implementation.md
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/, vibes/ViewModels/, vibes/Services/, vibes/ContentView.swift
- **Requested**: Implement first-implementation.md - MVP with 3 tabs (Feed, Explore, Profile), music service connection, concert discovery, AI recommendations, friend following + sharing. Remove: AI Playlist Creation, Friend Blends, Achievements, Vibe-Streaks, editable taste rankings, group chats.
- **Context**: Major app remodel to simplify to essential loop: connect music service, discover (concerts/AI), share with friends.
- **Acceptance Criteria**:
  - [x] 3-tab navigation: Feed, Explore, Profile
  - [x] Feed shows shares from friends, quick actions
  - [x] Explore has search, AI recommendations, concerts
  - [x] Profile has basic info, followers/following, settings access
  - [x] Friend following and song sharing works
  - [x] Remove: achievements, vibestreaks, AI playlist creation, friend blends, group chats
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented MVP remodel:
  1. Updated AppRouter: Changed from 4 tabs (home/explore/chats/profile) to 3 tabs (feed/explore/profile). Removed chatsPath, shouldShowNewChat, shouldShowBlend, goToBlend, goToChats, goToNewChat.
  2. Created FeedView.swift: New tab showing shares from friends, quick actions (Send Song, Search), friend activity.
  3. Created FeedViewModel.swift: Loads song shares and friend activity from Firestore.
  4. Simplified ExploreView: Removed AI Features section (Generate Playlist Ideas, Grow Playlists, Friend Blends), Trending Among Friends, Recently Active, New Releases. Kept: Search, For You recommendations, Concerts.
  5. Simplified ProfileView: Removed 3-tab picker (profile/stats/achievements), removed achievements section, stats section, music personality card, genres section. Kept: Profile header, setup card, followers/following counts, settings cog.
  6. Updated ContentView: Changed to 3 tabs with FeedView, ExploreView, ProfileView.
  7. Deleted files: HomeView.swift, HomeViewModel.swift, ChatsView.swift, ChatsViewModel.swift, ChatRowView.swift, GroupThreadView.swift, CreateGroupView.swift, AIPlaylistView.swift, FriendBlendView.swift, PlaylistRecommendationsView.swift.
  8. Fixed SettingsView: Changed Tab.home to Tab.feed.

### 131. Update navigation.md with unified scrollable Feed design
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: docs/navigation.md
- **Requested**: Feed should be a mix of all content types (shares, concerts, friend activity, etc.) in a unified scrollable feed. Users can scroll through items and tap any item to expand it to full screen with more details.
- **Context**: Current Feed separates content into distinct sections. User wants a more TikTok/Instagram-like experience where all content is mixed in a single stream.
- **Acceptance Criteria**:
  - [x] Update navigation.md Feed section with unified feed concept
  - [x] Define feed item types and their card designs
  - [x] Define full-screen detail view behavior
  - [x] Document content mixing/sorting algorithm
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated navigation.md with unified feed design:
  1. Feed is now a single scrollable stream mixing 5 content types: Song Shares, Concerts, Friend Activity, New Releases, AI Recommendations
  2. Each type has a card preview format and full-screen detail view defined
  3. Card design shows art + title + subtitle + context + play button
  4. Full screen detail views present as sheets with large header, actions, close button, swipe to dismiss
  5. Content sorting uses weighted score: recency, relevance (close friends), engagement (unread), variety
  6. Updated Navigation Destinations table and Core User Flow to reflect feed-centric design

### 132. Add "Grow Your Playlist" AI feature to Explore tab
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: docs/navigation.md
- **Requested**: Add an AI feature similar to Spotify's "Recommended" section that shows personalized track recommendations based on a selected playlist. Users see a list of tracks with album art, title, artist, album name, and "Add" button to add tracks directly to the playlist. This should be documented in navigation.md for the Explore tab.
- **Context**: Currently Explore has Search, For You recommendations, and Concerts. User wants a playlist-specific recommendation feature like Spotify's "Based on what's in this playlist" section.
- **Acceptance Criteria**:
  - [x] Update navigation.md Explore section to include Grow Your Playlist feature
  - [x] Document the UI design (playlist selector, track recommendations, add buttons)
  - [x] Document the data source (Spotify/Apple Music recommendations API)
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated navigation.md with "Grow Your Playlist" feature in Explore tab:
  1. Added to Explore tree structure showing Playlist Selector and Recommended Tracks
  2. Created detailed section with ASCII mockups showing playlist dropdown and track row layout
  3. Documented UI components: Header, Playlist Dropdown, Track Row (art, title, artist, album), Add Button, Success Toast
  4. Documented behavior flow: select playlist -> fetch recommendations -> show 10-20 tracks -> add removes from list
  5. Added Data Sources: "Playlist Recommendations" (Spotify seed_tracks API) and "User playlists" (Spotify/Apple Music API)

### 134. Implement Authentication Section from Kiro Spec
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/
- **Requested**: Implement the authentication section from .specs/tasks.md - Phase 1 Foundation (Tasks 1-4) and Phase 2 Auth (Tasks 5-7). Create project structure, models, KeychainManager, AppRouter, AuthManager, AuthView, TutorialView.
- **Context**: Fresh implementation following Kiro SDD workflow. App was reset, implementing from specs.
- **Acceptance Criteria**:
  - [x] Project structure created with all directories
  - [x] Data models implemented (UserProfile, Friendship, SongShare, FeedItem, etc.)
  - [x] KeychainManager for secure token storage
  - [x] AppRouter for navigation
  - [x] AuthManager with Google Sign-In
  - [x] AuthView with Google button
  - [x] TutorialView with 7 onboarding cards
  - [x] App builds successfully
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created complete authentication foundation:
  - **Models**: UserProfile, Friendship, SongShare, Concert, Achievement, UnifiedTrack, UnifiedAlbum, UnifiedArtist, UnifiedPlaylist, FeedItem, Message, MessageThread, ListeningStats, VibesError
  - **Services**: KeychainManager (secure token storage), AppRouter (@Observable navigation coordinator), AuthManager (@Observable with Google Sign-In via Firebase)
  - **Views**: AuthView (Google Sign-In button), TutorialView (7 swipeable onboarding cards), ContentView (3-tab navigation placeholder), LoadingView, EmptyStateView, ErrorView
  - **Configuration**: Added GoogleSignIn-iOS package, created Info.plist with URL scheme, created placeholder GoogleService-Info.plist
  - Build succeeds on iPhone 16e simulator

### 135. Google Sign-In fails: "No active configuration. Make sure GIDClientID is set in Info.plist"
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: Info.plist, vibes/GoogleService-Info.plist
- **Requested**: Google Sign-In fails with error "No active configuration. Make sure GIDClientID is set in Info.plist"
- **Context**: The GoogleService-Info.plist is missing the CLIENT_ID key. Info.plist needs the GIDClientID key and the reversed client ID URL scheme for Google Sign-In OAuth flow to work.
- **Acceptance Criteria**:
  - [x] Get OAuth Client ID from Google Cloud Console
  - [x] Add GIDClientID to Info.plist
  - [x] Add reversed client ID to URL schemes
  - [x] Google Sign-In works
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Configured OAuth Client ID in Google Cloud Console and added to Info.plist

### 137. Concert Discovery Feature
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: .specs/concert-discovery/, vibes/Views/ConcertDiscovery/, vibes/Services/, vibes/Models/, vibes/ViewModels/
- **Requested**: Implement concert discovery feature. Button on feed page pushes to a new screen. Screen shows user's top 10 artists from Spotify (last 3 months). List features: remove items, add artists via search bar with plus button, reorder list, max 20 artists. "Find Concerts" button searches Ticketmaster API for concerts from these artists, ranked by user's artist ranking (e.g., Drake #1 = first in concert results). Special icon for concerts in user's home city. Link to Ticketmaster for ticket purchase.
- **Context**: New feature to help users discover concerts from their favorite artists, leveraging their Spotify listening data and Ticketmaster's concert database.
- **Acceptance Criteria**:
  - [x] Create Kiro spec with PRD
  - [x] Feed page has button to navigate to concert discovery
  - [x] Screen shows top 10 Spotify artists (last 3 months)
  - [x] Can remove artists from list
  - [x] Can add artists via search bar
  - [x] Can reorder artist list
  - [x] Maximum 20 artists enforced
  - [x] "Find Concerts" button searches Ticketmaster API
  - [x] Concerts ranked by user's artist ranking
  - [x] Home city concerts have special icon
  - [x] Ticketmaster purchase link provided
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full concert discovery feature using Kiro SDD workflow:
  - Created `.specs/concert-discovery/` with prd.md, requirements.md, design.md, tasks.md
  - **New Models**: RankedArtist.swift, RankedConcert.swift
  - **New Services**: SpotifyDataService.swift (getTopArtists, searchArtists), TicketmasterService.swift (searchConcerts with parallel requests, rate limiting, home city detection)
  - **New ViewModel**: ConcertDiscoveryViewModel.swift (state management, persistence, debounced search)
  - **New Views**: ConcertDiscoveryView.swift (artist list with search, reorder, delete), ConcertResultsView.swift (concert list with home city badges), ArtistRow.swift, ConcertRow.swift, ArtistSearchResultRow.swift
  - **Modified**: AppRouter.swift (added ConcertDiscoveryDestination, navigateToConcertDiscovery), ContentView.swift (added ConcertDiscoveryCard entry point in FeedView)
  - Build succeeds on iPhone 16 simulator

### 138. Spotify connection state not syncing to profile
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/Setup/SpotifySetupView.swift:127-155
- **Requested**: User connected to Spotify but profile shows not connected even though setup says connected
- **Context**: SpotifySetupView was updating local SetupManager state (keychain check) but not syncing to AuthManager/Firestore. Profile and other views check AuthManager.isSpotifyLinked which reads from Firestore.
- **Acceptance Criteria**:
  - [x] connectSpotify() calls authManager.updateSpotifyLinked(true) after successful auth
  - [x] disconnectSpotify() calls authManager.updateSpotifyLinked(false) on disconnect
  - [x] Preview includes AuthManager.shared environment
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated SpotifySetupView.swift to sync state with Firestore via AuthManager:
  1. Added `try await authManager.updateSpotifyLinked(true)` after successful Spotify authorization
  2. Added `Task { try? await authManager.updateSpotifyLinked(false) }` when disconnecting
  3. Updated Preview to include `.environment(AuthManager.shared)`

### 139. Concert Discovery returns 0 artists
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/ViewModels/ConcertDiscoveryViewModel.swift:77-79
- **Requested**: Concert Discovery shows "No Artists" even though user has top artists on Spotify
- **Context**: The Spotify API was being called with `shortTerm` (4 weeks) time range, but user had no listening data in that window.
- **Acceptance Criteria**:
  - [x] Change time range from shortTerm to mediumTerm (6 months)
  - [x] Artists load successfully
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Changed `SpotifyDataService.getTopArtists()` call from `.shortTerm` to `.mediumTerm` to capture 6 months of listening data instead of just 4 weeks.

### 140. Artist rank numbers don't update when reordering
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/ConcertDiscovery/ArtistRow.swift, ConcertDiscoveryView.swift:146-154
- **Requested**: When switching two artists in edit mode, the rank numbers don't update visually
- **Context**: ArtistRow received a copy of RankedArtist struct, so when ranks were updated in the array, the view didn't re-render because the struct copy was unchanged.
- **Acceptance Criteria**:
  - [x] Rank numbers update immediately when artists are reordered
  - [x] Display rank based on array position, not stored property
- **Failure Count**: 0
- **Failures**: None
- **Solution**:
  1. Added `displayRank: Int` parameter to ArtistRow
  2. Changed ForEach to use enumerated array: `ForEach(Array(viewModel.artists.enumerated()), id: \.element.id)`
  3. Pass `index + 1` as displayRank instead of relying on stored `rankedArtist.rank`

### 141. Revoked Spotify token shows unhelpful error
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/SpotifyAuthService.swift:74-96, vibes/Views/ConcertDiscovery/ConcertDiscoveryView.swift:170-212
- **Requested**: Reset to Top Artists shows "Token exchange failed: Refresh token revoked" error with no way to reconnect Spotify
- **Context**: When Spotify refresh token is revoked (user disconnected app from Spotify settings), the error wasn't clearing invalid tokens or helping user reconnect.
- **Acceptance Criteria**:
  - [x] Detect revoked/invalid token errors in refreshAccessToken()
  - [x] Clear invalid tokens from keychain on auth failure
  - [x] Show "Spotify Disconnected" message instead of generic error
  - [x] Provide "Reconnect Spotify" button that navigates to Spotify setup
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**:
  1. Updated SpotifyAuthService.refreshAccessToken() to catch revoked/invalid token errors and call disconnect() to clear keychain
  2. Added isSpotifyAuthError() helper in ConcertDiscoveryView to detect auth errors
  3. Updated errorView() to show friendly "Spotify Disconnected" message with "Reconnect Spotify" button
  4. Added navigateToSpotifySetup() method to AppRouter

### 136. Initialize Kiro spec for Setup feature
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: .specs/setup/prd.md
- **Requested**: Initialize a Kiro-style Spec-Driven Development project for a setup feature to setup the three required things (Spotify, Gemini API Key, Concert City)
- **Context**: User wants focused specs for the setup flow that guides users through connecting required services
- **Acceptance Criteria**:
  - [x] Create .specs/setup/ directory
  - [x] Create prd.md with setup feature requirements
  - [x] Define the three required setup steps
  - [x] Document user flow and components
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created .specs/setup/prd.md with focused requirements for the 3 required setup steps: Spotify connection, Gemini API key entry, and Concert City selection. Includes setup components, user flow, and success metrics.

### 142. Releases Discovery Feature (Duplicate Concert Pattern)
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ReleasesDiscovery/, vibes/ViewModels/, vibes/Services/, vibes/Models/
- **Requested**: Duplicate the concert discovery pattern with artists removal, adding, and reordering. Instead of concerts, get upcoming releases and recent releases (within the last month) by these artists.
- **Context**: Users want to discover new music from their favorite artists. Mirrors the concert discovery UX pattern.
- **Acceptance Criteria**:
  - [x] Create RankedRelease model
  - [x] Add SpotifyDataService methods for artist albums
  - [x] Create ReleasesDiscoveryViewModel (mirror ConcertDiscoveryViewModel)
  - [x] Create ReleasesDiscoveryView with artist management
  - [x] Create ReleaseRow and ReleaseResultsView
  - [x] Add navigation from Feed/Explore
  - [x] Show upcoming and recent releases (last month)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented releases discovery feature mirroring concert discovery pattern:
  - **New Model**: `RankedRelease.swift` - wraps UnifiedAlbum with artistRank and isNew flag
  - **SpotifyDataService**: Added `getArtistAlbums()`, `getReleasesForArtists()`, and `parseReleaseDate()` methods
  - **New ViewModel**: `ReleasesDiscoveryViewModel.swift` - manages artist list and releases with persistence
  - **New Views**: `ReleasesDiscoveryView.swift` (artist management with search/add/remove/reorder), `ReleaseRow.swift` (album display with new badge), `ReleaseResultsView.swift` (results with Recent/Upcoming sections)
  - **Navigation**: Added `ReleasesDiscoveryDestination`, `navigateToReleasesDiscovery()` to AppRouter, `ReleasesDiscoveryCard` to Feed
  - Features: Top 10 Spotify artists (medium term), add/remove/reorder artists (max 20), search artists, persist selection, find releases from last 30 days + upcoming, open in Spotify

### 143. Discover Music Feature (Spotify Recommendations)
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: .specs/discover-music/, vibes/Views/, vibes/ViewModels/, vibes/Services/
- **Requested**: Create a push-nav widget on the feed page called "Discover Music". Uses Spotify recommendations API based on user's song library. Gets 10 songs from Spotify, displays 5. When user clicks a song (dissatisfied, already has it, or added to playlist), that song disappears and the 6th song takes its place. When queue drops below 7, fetch more songs to reach 10 again.
- **Context**: Personal music discovery feature using Spotify's recommendation engine with smart queue management.
- **Acceptance Criteria**:
  - [x] Create Kiro spec with PRD, requirements, design, tasks
  - [x] Push-nav widget on Feed page titled "Discover Music"
  - [x] Integrate with Spotify Recommendations API
  - [x] Display 5 visible songs at a time
  - [x] Queue of 10 songs (5 visible, 5 buffered)
  - [x] Tap to dismiss song, next queued song slides in
  - [x] Auto-replenish queue when below 7 songs
  - [x] Song cards show title, artist, album art
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented via Kiro spec-driven development. Initially added getRecommendations() to SpotifyDataService, but Spotify deprecated the Recommendations API on Nov 27, 2024. Implemented workaround using artist-based discovery: added getArtistTopTracks() and discoverTracks() methods that fetch top tracks from user's top artists, filter out tracks user already knows, and shuffle. Created DiscoverMusicViewModel with queue management using new discoverTracks() method. Created DiscoverMusicView and SongDiscoveryCard with animations and context menu actions. All files at .specs/discover-music/.

### 144. Add Popularity Filter to Discover Music
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/SpotifyDataService.swift, vibes/ViewModels/DiscoverMusicViewModel.swift, vibes/Views/DiscoverMusic/DiscoverMusicView.swift
- **Requested**: User found recommended songs too popular/mainstream. Add a popularity setting that filters for less popular (more obscure) songs when the setting is higher.
- **Context**: Spotify tracks have a popularity score (0-100). Filtering by max popularity lets users discover hidden gems from their favorite artists.
- **Acceptance Criteria**:
  - [x] Add maxPopularity parameter to discoverTracks() in SpotifyDataService
  - [x] Add maxPopularity setting to DiscoverMusicViewModel
  - [x] Add UI slider in DiscoverMusicView for adjusting obscurity level
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added maxPopularity parameter to discoverTracks() that filters tracks above the threshold. Added maxPopularity property to ViewModel. Created PopularitySettingsSheet with slider UI showing "Obscurity Level" from Mainstream to Hidden Gems. Slider button in toolbar opens settings sheet. Tapping "Find Songs" reloads with new filter.

### 145. Simplify PRD to user list with search
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: .specs/prd.md
- **Requested**: Update the PRD to just have a list of people on the app with search functionality, and mark the follow/unfollow feature for the future
- **Context**: Simplifying the app scope to focus on core user discovery functionality first
- **Acceptance Criteria**:
  - [x] PRD shows simple user list feature
  - [x] Search through users functionality documented
  - [x] Follow/unfollow marked as future feature
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Rewrote PRD to focus on MVP user discovery. Core feature is user list with search (filter by name/username). Future Features section includes follow/unfollow and all music features (Spotify, sharing, concerts, AI).

### 146. Concert discovery shows wrong artists (substring matching bug)
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/TicketmasterService.swift:75-87
- **Requested**: Having "Drake" on artist list shows concerts from "Drake Milligan" and "Drake Bell". Need exact artist matching, not substring matching.
- **Context**: The filtering logic uses `contains()` which matches substrings. "Drake Milligan".contains("Drake") returns true incorrectly.
- **Acceptance Criteria**:
  - [x] Searching for "Drake" only returns Drake concerts, not Drake Milligan/Bell
  - [x] Fix works generally for all artists (exact matching)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Changed filtering logic from substring matching (`contains()`) to exact matching. Now checks if any attraction (performer) in the Ticketmaster event exactly matches the searched artist name (case-insensitive). This ensures "Drake" only matches events where "Drake" is listed as a performer, not "Drake Milligan" or "Drake Bell".

### 147. Create use cases spec document
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: .specs/use-cases.md
- **Requested**: Create a file in .specs containing core use cases information for the app: Music Collaboration, Music Discovery, Trending, Playlist Creation, Gamification, Setup, Stats, Profile management
- **Context**: Document outlining all planned features and their details
- **Acceptance Criteria**:
  - [x] Create .specs/use-cases.md with all core use cases
  - [x] Format nicely with feature details
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created .specs/use-cases.md with 8 core use cases and detailed feature breakdowns

### 148. Create Kiro spec for Stats feature
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: .specs/stats/
- **Requested**: Create Kiro-style spec for Stats feature showing top artists, songs, genres, and recently played
- **Context**: Stats is the next logical feature - no dependencies, immediate value after Spotify connection
- **Acceptance Criteria**:
  - [x] Create .specs/stats/prd.md
  - [x] Create .specs/stats/requirements.md
  - [x] Create .specs/stats/design.md
  - [x] Create .specs/stats/tasks.md
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created full Kiro spec with PRD (problem, solution, user stories, scope), requirements (9 functional, 2 non-functional in EARS format), design (architecture, UI mockups, API endpoints, state management), and tasks (5 phases with dependency graph)

### 149. Implement Stats feature
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Stats/, vibes/ViewModels/, vibes/Services/, vibes/Models/
- **Requested**: Implement Stats feature per .specs/stats/ - preview card on Profile, full stats view with top artists/songs/genres/recently played
- **Context**: First feature after setup, shows users their listening data
- **Acceptance Criteria**:
  - [x] Phase 1: Data layer (Spotify API methods, TimeRange, RecentTrack)
  - [x] Phase 2: StatsViewModel
  - [x] Phase 3: Profile integration (StatsPreviewCard, navigation)
  - [x] Phase 4: Full StatsView with all sections
  - [x] Phase 5: Polish and testing
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full Stats feature:
  - **Models**: RecentTrack.swift (track + playedAt with relative time)
  - **Services**: Added getRecentlyPlayed(), extractTopGenres(), openInSpotify() to SpotifyDataService
  - **ViewModel**: StatsViewModel.swift with preview/full load, time range selection
  - **Views**: StatsPreviewCard (Profile integration), StatsView (full screen), TopArtistsSection, TopSongsSection, TopGenresSection, RecentlyPlayedSection
  - **Navigation**: StatsDestination enum, navigateToStats() in AppRouter
  - **Profile**: Added StatsPreviewCard showing top 3 artists, tap navigates to full StatsView

### 150. Profile shows "Connect Spotify" even though Spotify is connected
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/AuthManager.swift
- **Requested**: Profile and Settings still show "Connect Spotify" prompts even though Spotify API is working
- **Context**: Two sources of truth: SetupManager checks keychain (token exists), AuthManager.isSpotifyLinked checks Firestore. Firestore value was never synced.
- **Acceptance Criteria**:
  - [x] Sync keychain state to Firestore on profile load
  - [x] If token exists but Firestore says not linked, update Firestore
  - [x] Same for Gemini API key
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added syncSpotifyLinkedState() to AuthManager that runs on loadUserProfile(). Syncs both Spotify and Gemini keychain state to Firestore.

### 151. Implement Search feature
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Search/, vibes/ViewModels/, vibes/Services/
- **Requested**: Implement search with audio previews per .specs/search/
- **Context**: Core utility feature for finding music
- **Acceptance Criteria**:
  - [x] Search songs, artists, albums via Spotify API
  - [x] 30-second audio preview with AVPlayer
  - [x] Mini player when preview playing
  - [x] Recent searches persistence
  - [x] Open in Spotify on tap
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full search feature:
  - **Services**: Added search() method to SpotifyDataService, created AudioPreviewManager with AVPlayer
  - **ViewModel**: SearchViewModel with debounced search, recent searches persistence
  - **Views**: SongSearchRow, ArtistSearchRow, AlbumSearchRow, SearchResultsView, RecentSearchesView, MiniPlayerView
  - **Integration**: Updated ExploreView with search UI, mini player, and audio preview controls

### 152. Tapping songs should play preview, not open Spotify
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/Search/SongSearchRow.swift, vibes/Views/Search/SearchResultsView.swift, vibes/ContentView.swift
- **Requested**: Clicking on songs just opens the song in Spotify instead of playing the 30-second preview
- **Context**: Current behavior: tapping song row opens Spotify, play button plays preview. Expected: tapping song row should play preview.
- **Acceptance Criteria**:
  - [x] Tapping on a song row plays the 30-second audio preview
  - [x] Add "Open in Spotify" as context menu action
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Reversed tap behavior in SongSearchRow - tapping anywhere on the row now plays the preview. Added context menu with "Open in Spotify" option for long-press. Added play/pause icon overlay on album art to indicate preview availability. Shows "No preview" label for tracks without preview URLs.

### 153. Integrate Spotify iOS SDK for 30-second previews
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/SpotifyRemoteService.swift, vibes/vibesApp.swift, vibes/Views/Search/
- **Requested**: Integrate Spotify iOS SDK to enable 30-second previews since Web API no longer provides preview URLs
- **Context**: Spotify deprecated preview_url in Nov 2024. iOS SDK can control playback in the Spotify app.
- **Acceptance Criteria**:
  - [x] Add SpotifyiOS SDK package dependency
  - [x] Create SpotifyRemoteService for app remote connection
  - [x] Replace AudioPreviewManager with SpotifyRemoteService
  - [x] Handle case when Spotify app not installed
  - [x] Tapping song plays 30-second preview via Spotify
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added SpotifyiOS SDK via SPM from github.com/spotify/ios-sdk. Created SpotifyRemoteService.swift with SPTAppRemote integration for playback control. When user taps a song, it opens Spotify app to authorize and play the track for 30 seconds. Updated MiniPlayerView and SongSearchRow to use SpotifyRemoteService. Added URL handler in vibesApp for Spotify callbacks. Removed old AudioPreviewManager.

### 154. Play full songs instead of 30-second previews
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/SpotifyRemoteService.swift
- **Requested**: Instead of doing a 30-second preview, play the entire song
- **Context**: Currently SpotifyRemoteService limits playback to 30 seconds via previewDuration constant and schedulePreviewStop()
- **Acceptance Criteria**:
  - [x] Remove 30-second preview limit
  - [x] Songs play to completion
  - [x] Progress bar shows full song duration
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Removed previewDuration constant, schedulePreviewStop() method, and all related timers. Updated playerStateDidChange delegate to use actual track duration and playback position from Spotify player state. Songs now play to completion with accurate progress tracking.

### 158. Profile Enhancements - Edit Profile, Bio, Genres
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Profile/, vibes/Services/ProfileService.swift, vibes/ContentView.swift
- **Requested**: Implement profile enhancements from .specs/profile-enhancements/: editable display name (50 chars), bio (160 chars), profile picture upload to Firebase Storage, top genres display (5 genres as chips)
- **Context**: Makes profiles personal and expressive, shows music identity
- **Acceptance Criteria**:
  - [x] ProfileService for image upload and profile updates
  - [x] ProfileViewModel for genres loading
  - [x] EditProfileView sheet with form fields
  - [x] UIImage resize extension (400x400 max)
  - [x] GenreChipsView component
  - [x] Edit button on own profile
  - [x] Bio display on profile
  - [x] Genres display below follower counts
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full profile enhancements feature:
  - **New Files**:
    - `vibes/Extensions/UIImage+Resize.swift` - Image resizing to 400x400 max with JPEG compression
    - `vibes/Services/ProfileService.swift` - Firebase Storage upload and Firestore profile updates
    - `vibes/ViewModels/ProfileViewModel.swift` - Genre loading from Spotify top artists
    - `vibes/Views/Profile/GenreChipsView.swift` - Horizontal scrolling genre chips with shimmer loading
    - `vibes/Views/Profile/EditProfileView.swift` - Sheet with PhotosPicker, display name (50 char), bio (160 char)
  - **Modified Files**:
    - `vibes/ContentView.swift` - Added Edit button, bio display, GenreChipsView integration to ProfileView
  - Build succeeds and all features verified on iPhone 16e simulator

### 159. Pause playback when leaving the app
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/vibesApp.swift
- **Requested**: Song continues playing in Spotify when user leaves the app. Should pause when app goes to background.
- **Context**: Using SpotifyRemoteService to control Spotify playback. When user switches apps or closes Vibes, music keeps playing because Spotify is the actual player.
- **Acceptance Criteria**:
  - [x] Detect when app goes to background
  - [x] Pause Spotify playback on background
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added `@Environment(\.scenePhase)` observation to RootView. When scenePhase changes to `.background`, calls `spotifyRemote.pause()` to stop Spotify playback.

### 160. User Profile shows shared songs when tapping username
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Social/UserProfileView.swift, vibes/Views/Social/SongShareCard.swift, vibes/Services/SocialService.swift, vibes/ContentView.swift
- **Requested**: When clicking someone's name (anywhere it appears), navigate to their profile which shows songs they shared, sorted by most recent first. Song cards should look like the ones shown on the feed.
- **Context**: Makes user profiles meaningful by showing their sharing activity. All username instances should be tappable.
- **Acceptance Criteria**:
  - [x] SongShareCard sender username is tappable and navigates to profile
  - [x] Add getUserShares(userId:) method to SocialService
  - [x] UserProfileView shows user's shared songs sorted by most recent
  - [x] Song cards use same SongShareCard design as feed
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented user profile shared songs feature:
  - **SocialService.swift**: Added `getUserShares(userId:limit:)` to fetch a user's shared songs sorted by timestamp descending, and `getUserProfile(userId:)` for fetching profiles by ID
  - **SongShareCard.swift**: Made sender profile picture and username tappable by wrapping in Button with `onSenderTap` callback
  - **UserProfileView.swift**: Added `sharedSongsSection` that loads and displays user's shared songs using `SongShareCard` components, with loading state and empty state handling
  - **ContentView.swift (FeedView)**: Added `navigateToSender(share:)` function and passed `onSenderTap` callback to `SongShareCard` in feed to enable profile navigation
  - Build succeeds on iPhone 16e simulator

### 162. Simplify song sharing to broadcast to all followers
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Social/ShareSheetView.swift, vibes/ViewModels/ShareViewModel.swift, vibes/Services/SocialService.swift
- **Requested**: Change song sharing to broadcast to all followers instead of selecting specific recipients. When user clicks share, show a simple pop-up with message field and send button. No recipient selection needed.
- **Context**: Simplifies UX - sharing is like posting to followers, not DM-style
- **Acceptance Criteria**:
  - [x] Remove recipient selection from ShareSheetView
  - [x] Update ShareViewModel to not require selected users
  - [x] Update SocialService.shareSong() to set recipientId to nil (broadcast)
  - [x] Simpler UI: track info + message field + send button
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Simplified song sharing to broadcast model:
  - **SocialService.swift**: Changed `shareSong(_:to:message:)` to `shareSong(_:message:)`, removed userIds parameter, sets recipientId to nil for broadcast to all followers
  - **ShareViewModel.swift**: Removed selectedUserIds, following list loading, toggle/selection logic. Simplified canSend to just check !isSending
  - **ShareSheetView.swift**: Removed recipient selection UI (list, checkboxes, loading/empty states). New UI shows track header with "Sharing with all followers" label, message field, and "Share with Followers" button

### 161. Profile picture upload fails with "does not exist" error
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/ProfileService.swift:26-30
- **Requested**: When uploading a profile picture, Firebase Storage throws "Object users/{uid}/profile.jpg does not exist" error
- **Context**: The upload appears to complete but downloadURL() fails immediately after. Need to verify upload succeeded before getting URL.
- **Acceptance Criteria**:
  - [x] Profile picture upload succeeds without error
  - [x] URL is correctly returned after upload
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added retry logic for `downloadURL()` in ProfileService.swift. After `putDataAsync` completes, the download URL fetch now retries up to 3 times with 0.5s delays between attempts to handle Firebase Storage propagation delays.

### 163. Mute users to hide their shares from feed
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/SocialService.swift, vibes/Views/Social/UserProfileView.swift, vibes/Utilities/Constants.swift
- **Requested**: Add mute option on user profiles. When muted, their shared songs don't appear in your feed (only visible on their profile). Unmuting shows new shares going forward. Re-muting keeps existing feed items but hides new ones. No retroactive changes to feed.
- **Context**: Lets users control their feed without unfollowing. Mute filters feed queries, not stored data.
- **Acceptance Criteria**:
  - [x] Add mutes collection to Firestore (muterId, mutedId, createdAt)
  - [x] Add mute/unmute/isMuted methods to SocialService
  - [x] Filter muted users from getSharesFromFollowing query
  - [x] Add mute/unmute button to UserProfileView (for other users only)
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented mute feature:
  - **Constants.swift**: Added `mutes` collection name to Firestore constants
  - **SocialService.swift**: Added `mute(userId:)`, `unmute(userId:)`, `isMuted(userId:)`, `getMutedIds()` methods. Updated `getSharesFromFollowing()` to filter out muted users before querying shares.
  - **UserProfileView.swift**: Added `isMuted` and `isMuteLoading` state. Added toolbar menu with Mute/Unmute option (ellipsis button). Added `toggleMute()` function. Mute status loaded in `loadData()`.
  - Build succeeds on iPhone 16e simulator

### 164. Remove unfollow confirmation dialog
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Social/UserProfileView.swift
- **Requested**: Remove the confirmation dialog when unfollowing someone - should unfollow immediately like mute. Existing shares from unfollowed users should remain in feed (data not deleted), just no new shares appear.
- **Context**: Simplifies unfollow UX, consistent with mute behavior
- **Acceptance Criteria**:
  - [x] Remove confirmation dialog from unfollow button
  - [x] Unfollow happens immediately on tap
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Removed `showUnfollowConfirm` state and `.confirmationDialog` modifier from UserProfileView. Follow button now calls `unfollow()` directly when tapped while following. Note: SongShare documents are never deleted by unfollow - they remain in Firestore. Feed queries by current following list, so unfollowed users' shares won't appear on next feed refresh (same behavior as mute).

### 165. Missing permissions error doesn't offer reconnect button
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/Stats/StatsView.swift, vibes/Views/ConcertDiscovery/ConcertDiscoveryView.swift
- **Requested**: Stats and Concert Discovery show "Missing Spotify permissions" error but don't offer a way to reconnect Spotify. User needs to reconnect to get new token with updated scopes.
- **Context**: User connected Spotify before new scopes were added. Token doesn't have required permissions. Error shown but no reconnect button.
- **Acceptance Criteria**:
  - [x] StatsView shows "Reconnect Spotify" button on permission errors
  - [x] ConcertDiscoveryView's isSpotifyAuthError detects SpotifyDataError.forbidden
  - [x] Both views navigate to Spotify setup on reconnect
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated both views to detect `SpotifyDataError.forbidden` as an auth-related error:
  - **ConcertDiscoveryView.swift**: Added check for `SpotifyDataError.forbidden` and `.notAuthenticated` in `isSpotifyAuthError()` function
  - **StatsView.swift**: Added `@Environment(AppRouter.self)` and `isSpotifyAuthError()` function. Updated `errorView()` to show "Spotify Disconnected" with "Reconnect Spotify" button for auth/permission errors

### 166. Stats should navigate to in-app profiles and play songs natively
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/Stats/, vibes/ViewModels/StatsViewModel.swift
- **Requested**: Clicking an artist in stats should navigate to their ArtistProfileView in Vibes, not open Spotify. Clicking a song should play it via SpotifyRemoteService the way Vibes plays songs, not open Spotify.
- **Context**: Stats currently opens Spotify for all taps. Should use in-app navigation and playback.
- **Acceptance Criteria**:
  - [x] Tapping artist navigates to ArtistProfileView
  - [x] Tapping song plays via SpotifyRemoteService
  - [x] Songs are sharable via context menu
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated StatsView.swift to use router.navigateToArtistDetail() for artists and spotifyRemote.play() for songs. Added onShare callbacks to TopSongsSection and RecentlyPlayedSection with context menus for sharing. Changed arrow icons to play icons to indicate playback behavior.

### 167. Artist Top Songs full list view
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Artist/ArtistProfileView.swift, vibes/Views/Artist/ArtistTopSongsView.swift, vibes/Services/AppRouter.swift
- **Requested**: On artist profile, clicking "Top Songs" header should navigate to a full list of the artist's top songs sorted by popularity (most popular at top). All songs should be playable, sharable, and openable in Spotify.
- **Context**: Currently shows top 5 songs inline. User wants to see full list via push navigation.
- **Acceptance Criteria**:
  - [x] "Top Songs" header is tappable and navigates to ArtistTopSongsView
  - [x] ArtistTopSongsView shows all top tracks sorted by popularity
  - [x] Songs are playable via SpotifyRemoteService
  - [x] Songs are sharable via context menu
  - [x] Songs can be opened in Spotify via context menu
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full artist top songs feature:
  - **ArtistProfileViewModel.swift**: Changed to store `allTopTracks` sorted by popularity, `topTracks` computed property returns first 5 for preview
  - **ArtistProfileView.swift**: Made "Top Songs" header tappable with chevron, navigates to full list
  - **ArtistTopSongsView.swift**: New view with Apple Music-style layout - rank numbers (right-aligned), album art with playing indicator overlay, song title + artist name, duration on right, context menus for Share/Add to Playlist/Open in Spotify
  - **AppRouter.swift**: Added `ArtistTopSongsDestination` struct and `navigateToArtistTopSongs()` method
  - **ContentView.swift**: Added navigation destinations for `ArtistTopSongsDestination` in FeedView and ExploreView sections

### 168. Add 3-dot menu to all song rows for discoverability
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ (SongSearchRow, TopSongsSection, RecentlyPlayedSection, ArtistTopSongsView, AlbumTrackRow, SongDiscoveryCard)
- **Requested**: On any song in the entire app, there should be a little 3-dot menu near the end which when clicked pops up the send and open in Spotify options. This makes sharing discoverable since users may not know to hold down on a song.
- **Context**: Currently sharing is only available via long-press context menu. Users need visual affordance to discover the share functionality.
- **Acceptance Criteria**:
  - [x] All song row components have visible 3-dot menu button
  - [x] Tapping 3-dot shows "Send" and "Open in Spotify" options
  - [x] Consistent styling across all song displays
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added visible 3-dot ellipsis Menu button to all song row components:
  - **SongSearchRow.swift**: Added Menu with ellipsis icon after duration, shows "Send" and "Open in Spotify"
  - **TopSongsSection.swift**: Added onOpenInSpotify callback, SongRow now has Menu button
  - **RecentlyPlayedSection.swift**: Added onOpenInSpotify callback, RecentTrackRow now has Menu button
  - **ArtistTopSongsView.swift**: Added onShare/onOpenInSpotify callbacks to SongRow with Menu button
  - **AlbumTrackRow.swift**: Added Menu button after duration with "Send" and "Open in Spotify"
  - **SongDiscoveryCard.swift**: Added moreMenu property with ellipsis Menu before dismiss button
  - **ArtistProfileView.swift**: Removed redundant contextMenu since SongSearchRow now has built-in menu
  - All menus use consistent styling: ellipsis icon, secondary color, 28-32pt tap target

### 169. StatsPreviewCard shows wrong message on forbidden error
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/Stats/StatsPreviewCard.swift
- **Requested**: Console shows "Stats preview error: forbidden" twice but StatsPreviewCard displays "Listen to some music first" instead of showing a reconnect option
- **Context**: When Spotify token is missing `user-top-read` scope, API returns 403. StatsPreviewCard only checks if previewArtists is empty, not if there's a permission error.
- **Acceptance Criteria**:
  - [x] StatsPreviewCard checks for forbidden/permission errors
  - [x] Shows "Reconnect Spotify" message with button for auth errors
  - [x] Shows "Listen to some music first" only for empty results (not errors)
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added `isSpotifyAuthError` computed property that checks if viewModel.error is SpotifyDataError.forbidden or .notAuthenticated. Added `reconnectContent` view showing "Spotify Disconnected" with orange warning icon and "Tap to reconnect and grant permissions" message. Modified button action to navigate to Spotify setup (router.navigateToSpotifySetup()) when auth error detected, otherwise navigates to stats as before.

### 170. Ensure all songs have 3-dot menu AND long-press context menu
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ (all song row components)
- **Requested**: All songs across the entire app should have the three dots AND when you hold the song down it should also bring up the menu with Send and Open in Spotify
- **Context**: Task 168 added 3-dot menus but some may be missing context menus for long-press consistency
- **Acceptance Criteria**:
  - [x] All song components have visible 3-dot menu
  - [x] All song components have long-press context menu
  - [x] Both menus have "Send" and "Open in Spotify" options
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added `.contextMenu` modifiers to all song row components:
  - **SongSearchRow.swift**: Added context menu with Send and Open in Spotify
  - **TopSongsSection.swift**: Added context menu to SongRow
  - **RecentlyPlayedSection.swift**: Added context menu to RecentTrackRow
  - **ArtistTopSongsView.swift**: Added context menu to SongRow
  - **AlbumTrackRow.swift**: Added context menu with Send and Open in Spotify
  - **SongDiscoveryCard.swift**: Applied context menu (was defined but not used)
  - **SongShareCard.swift**: Added both 3-dot Menu AND context menu (had neither before), plus AppRouter environment and asUnifiedTrack computed property

### 171. Top Songs should support next/previous navigation
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/Stats/StatsView.swift
- **Requested**: In Top Songs, should be able to go to the next song unless it's the 10th song (end of list), same with backwards (can't go back on 1st song)
- **Context**: Currently `spotifyRemote.play(song)` plays a single song without queue. Should use `playWithQueue` to enable skip forward/backward.
- **Acceptance Criteria**:
  - [x] TopSongsSection uses playWithQueue with full song list
  - [x] RecentlyPlayedSection uses playWithQueue with full track list
  - [x] Next/previous buttons work within the list
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Changed StatsView.swift to use `spotifyRemote.playWithQueue(song, queue: viewModel.topSongs)` for TopSongsSection and `spotifyRemote.playWithQueue(track, queue: allTracks)` for RecentlyPlayedSection. This sets up the queue so next/previous buttons in MiniPlayer and NowPlayingView work to navigate through the list.

### 172. Add playing indicators to all song rows
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ (SongSearchRow, TopSongsSection, RecentlyPlayedSection, SongDiscoveryCard)
- **Requested**: When clicking to play a song, that song should have a visual indication that it is playing (on the song row itself, not just the miniplayer). If the same song appears twice, only the one with matching track ID shows as playing.
- **Context**: Some song row components lacked visual feedback when their song was currently playing
- **Acceptance Criteria**:
  - [x] All song rows show waveform animation on album art when playing
  - [x] Song title changes to accent color when playing
  - [x] Rank number (where applicable) changes to accent color when playing
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added playing indicators to all song row components:
  - **SongSearchRow.swift**: Changed from play/pause icon to waveform animation overlay, title now uses accent color when playing
  - **TopSongsSection.swift**: Added SpotifyRemoteService environment, isPlaying computed property, waveform overlay on album art, accent color on rank and title
  - **RecentlyPlayedSection.swift**: Added SpotifyRemoteService environment, isPlaying computed property, waveform overlay on album art, accent color on title
  - **SongDiscoveryCard.swift**: Added SpotifyRemoteService environment, isPlaying computed property, waveform overlay on album art, accent color on title
  - **ArtistTopSongsView.swift**: Already had playing indicators (waveform + accent title)
  - **AlbumTrackRow.swift**: Already had playing indicators (waveform replaces track number + green title)

### 174. Unified Content Feed with Artist Following
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Models/, vibes/Services/, vibes/ViewModels/, vibes/Views/Feed/, vibes/Views/Artist/, vibes/ContentView.swift
- **Requested**: Transform feed from static navigation widgets to dynamic content stream. Add artist following feature. Feed shows contextual cards (concerts, releases, recommendations) interleaved with social content. Setup card hides when complete. Clicking discovery cards navigates to full feature views.
- **Context**: Current feed has 5 static widget buttons before content. Convert to content-driven feed like Instagram/Spotify.
- **Acceptance Criteria**:
  - [x] FollowedArtist model created
  - [x] ArtistFollowService for Firestore persistence
  - [x] ArtistFollowButton on artist profiles
  - [x] ConcertFeedCard, ReleaseFeedCard, RecommendationFeedCard components
  - [x] FeedViewModel aggregates all content sources
  - [x] FeedView renders unified feed stream
  - [x] Static discovery widgets removed
  - [x] Setup card hides when all 3 items complete
  - [x] Cards navigate to respective feature views
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full Unified Content Feed feature:
  - **New Models**: FollowedArtist.swift (Firestore model with conversion methods)
  - **New Services**: ArtistFollowService.swift (follow/unfollow, Firestore persistence with caching)
  - **New Views**:
    - ArtistFollowButton.swift (optimistic UI updates)
    - ConcertFeedCard.swift (purple accent, navigates to ConcertDiscoveryView)
    - ReleaseFeedCard.swift (green accent, navigates to ReleasesDiscoveryView)
    - RecommendationFeedCard.swift (orange accent, play button, navigates to DiscoverMusicView)
  - **Modified**:
    - ArtistHeaderView.swift (added follow button below genre chips)
    - FeedViewModel.swift (aggregates song shares, concerts, releases, recommendations in parallel)
    - ContentView.swift FeedView (renders unified feed stream, Setup card shows only when not all complete, Find People always visible)
    - Constants.swift (added followedArtists collection)
  - **Removed**: Static DiscoverMusicCard, ConcertDiscoveryCard, ReleasesDiscoveryCard widgets
  - Build succeeds on iPhone 16e simulator

### 173. Fix Spotify requiring disconnect/reconnect after app relaunch
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/SpotifyRemoteService.swift, vibes/vibesApp.swift
- **Requested**: Whenever I relaunch the app I have to disconnect and reconnect Spotify for things to work properly
- **Context**: Access tokens expire after 1 hour. The app was using stale tokens from keychain without checking expiration or refreshing.
- **Acceptance Criteria**:
  - [x] SpotifyRemoteService.connect() validates and refreshes token before connecting
  - [x] App proactively refreshes token on launch and when becoming active
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Two fixes implemented:
  1. **SpotifyRemoteService.connect()**: Changed from directly accessing keychain token to calling `SpotifyAuthService.shared.getValidAccessToken()` which checks expiration and refreshes if needed
  2. **vibesApp.swift RootView**: Added `refreshSpotifyTokenIfNeeded()` function that checks `KeychainManager.shared.isSpotifyTokenExpired()` and refreshes token. Called on:
     - Initial app launch via `.task` modifier
     - When app becomes active via `.onChange(of: scenePhase)` with `.active` case

## Task Statistics
- Total Tasks: 174
- Completed: 174
- In Progress: 0
- Archived: Tasks 1-123

---

Older completed tasks (1-123) have been archived to docs/.archive/tasks-2025-01.md
