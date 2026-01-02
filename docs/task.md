# Task Tracking

## Active Tasks

### 133. Remove all code and start from scratch
- **Status**: IN_PROGRESS
- **Type**: Feature
- **Location**: vibes/, vibes.xcodeproj/, docs/, build/, vids/, .specs/, GoogleService-Info.plist
- **Requested**: User wants to remove all existing code and start fresh
- **Context**: Complete project reset
- **Acceptance Criteria**:
  - [ ] Remove vibes/ source code directory
  - [ ] Remove vibes.xcodeproj/ project file
  - [ ] Remove docs/ documentation
  - [ ] Remove build/ artifacts
  - [ ] Remove vids/ videos
  - [ ] Remove .specs/ folder
  - [ ] Remove root GoogleService-Info.plist
  - [ ] Keep .git, .gitignore, CLAUDE.md, .claude/
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Pending

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
- **Status**: IN_PROGRESS
- **Type**: Bug
- **Location**: Info.plist, vibes/GoogleService-Info.plist
- **Requested**: Google Sign-In fails with error "No active configuration. Make sure GIDClientID is set in Info.plist"
- **Context**: The GoogleService-Info.plist is missing the CLIENT_ID key. Info.plist needs the GIDClientID key and the reversed client ID URL scheme for Google Sign-In OAuth flow to work.
- **Acceptance Criteria**:
  - [ ] Get OAuth Client ID from Google Cloud Console
  - [ ] Add GIDClientID to Info.plist
  - [ ] Add reversed client ID to URL schemes
  - [ ] Google Sign-In works
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Pending

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

## Task Statistics
- Total Tasks: 141
- Completed: 139
- In Progress: 1
- Archived: Tasks 1-123

---

Older completed tasks (1-123) have been archived to docs/.archive/tasks-2025-01.md
