# Task Tracking

## Active Tasks

### 124. Add Apple Music as alternative to Spotify
- **Status**: IN_PROGRESS
- **Type**: Feature
- **Location**: vibes/Services/, vibes/Models/, vibes/Views/ProfileView.swift
- **Requested**: Integrate Apple Music as another option alongside Spotify. Users should be able to choose which music service to connect.
- **Context**: Currently the app only supports Spotify. Apple Music integration would expand the user base significantly. Requires creating a music service abstraction layer since the app currently has direct Spotify dependencies throughout.
- **Acceptance Criteria**:
  - [x] Create MusicServiceProtocol abstraction layer
  - [x] Create service-agnostic data models (MusicTrack, MusicArtist, etc.)
  - [x] Implement AppleMusicService using MusicKit
  - [x] Update auth flow to let users choose Spotify or Apple Music
  - [ ] Update all views to work with either service (ProfileView done)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Phase 1 complete - foundation built. New files: UnifiedMusicModels.swift, MusicStreamingService.swift protocol, SpotifyModelExtensions.swift, SpotifyServiceAdapter.swift, AppleMusicService.swift, MusicServiceManager.swift, MusicServicePicker.swift. ProfileView updated with music service picker. Existing Spotify users auto-migrate.

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

## Task Statistics
- Total Tasks: 129
- Completed: 128
- In Progress: 1
- Archived: Tasks 1-123

---

Older completed tasks (1-123) have been archived to docs/.archive/tasks-2025-01.md
