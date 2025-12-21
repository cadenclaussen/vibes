# Task Tracking

## Active Tasks

### 51. Add haptic feedback throughout app
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/HapticService.swift (new), multiple Views
- **Requested**: Add haptic feedback for button taps, success actions, achievements, vibestreak milestones, and other interactions
- **Context**: Haptic feedback improves perceived quality and provides tactile confirmation of actions
- **Acceptance Criteria**:
  - [x] Create HapticService with impact, notification, and selection feedback
  - [x] Add light impact haptics to button taps
  - [x] Add success haptics to message send, playlist save, friend request actions
  - [x] Add haptics to reaction picker selection
  - [x] Add haptics to vibestreak milestone notifications
  - [x] Add selection haptics to segmented controls and pickers
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created HapticService.swift with static methods for light/medium/heavy impact, success/warning/error notifications, and selection changed feedback. Added haptics throughout MessageThreadView, SearchView, PlaylistPickerView, FriendPickerView, AuthView, OnboardingView, AddFriendView, ProfileView, ChatsView, AIPlaylistView.

### 52. Replace song action buttons with long-press context menu
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/SearchView.swift, vibes/Views/MessageThreadView.swift
- **Requested**: Instead of there being plus buttons to add to spotify and little paper airplanes to send to friends, you have to hold on the song, then a menu will pop up with those options
- **Context**: Cleaner UI that hides actions behind a context menu, similar to Apple Music and Spotify
- **Acceptance Criteria**:
  - [x] Remove visible plus and send buttons from TrackRow in SearchView
  - [x] Add context menu to TrackRow with "Add to Playlist" and "Send to Friend" options
  - [x] Remove visible plus button from SongMessageBubbleView in MessageThreadView
  - [x] Add context menu to song messages with "Add to Playlist" option
  - [x] Add haptic feedback on context menu actions
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Removed buttons, added .contextMenu with options and haptic feedback to SearchView TrackRow, MessageThreadView SongMessageBubbleView, and PlaylistMessageBubbleView.

### 53. Add context menu to all song views throughout app
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Multiple views (ArtistDetailView, AlbumDetailView, PlaylistDetailView, DiscoverView)
- **Requested**: The long press context menu should work for any song, whether it be in an artist profile, an album, or something a friend sent
- **Context**: Consistent UX - users should be able to long-press any song anywhere to send or add to playlist
- **Acceptance Criteria**:
  - [x] Add context menu to ArtistDetailView track rows
  - [x] Add context menu to AlbumDetailView track rows
  - [x] Add context menu to PlaylistDetailView track rows
  - [x] Add context menu to DiscoverView song cards
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added context menu with "Send to Friend" and "Add to Playlist" to ArtistTopTrackRow, AlbumTrackRow (with fullTrack computed property), PlaylistTrackRow, RecommendationRow, and TrendingSongRow (with track computed property).

### 54. Fix profile picture upload error
- **Status**: N/A (Feature Removed)
- **Type**: Bug
- **Location**: N/A
- **Requested**: When trying to upload pictures, it says "upload failed: object profile picture/____ does not exist"
- **Context**: Profile picture upload failing - user does not have Firebase Storage (requires paid plan)
- **Acceptance Criteria**: N/A
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Profile picture upload feature was completely removed since user does not have Firebase Storage access. See Task #47 in archive.

### 55. Add achievement unlock banner and real-time updates
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/AchievementNotificationService.swift (new), vibes/Views/Components/AchievementsView.swift, vibes/ContentView.swift, vibes/Views/ProfileView.swift
- **Requested**: When I get an achievement, I have to refresh the page to see it updated. Instead I want a little banner in the app that says "you got so and so achievement", and I want it to update without switching tabs
- **Context**: Better UX for achievement unlocks with immediate feedback
- **Acceptance Criteria**:
  - [x] Create achievement unlock banner component
  - [x] Show banner when achievement is unlocked
  - [x] Auto-update achievements without tab switching
  - [x] Add haptic feedback on achievement unlock
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created AchievementNotificationService.swift singleton that tracks unlocked achievements via UserDefaults, queues new unlocks, and shows banners. Created AchievementBannerView and AchievementBannerOverlay with slide-down animation. Added overlay to MainTabView and integrated with ProfileView.

### 56. Add context menu to recently played and top songs in Profile
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ProfileView.swift
- **Requested**: The recently played and top songs sections in Profile should have the same long-press context menu as other songs (hold down to play or send to friends). Also make top artists clickable.
- **Context**: Consistent UX - all songs should have the same context menu behavior
- **Acceptance Criteria**:
  - [x] Add context menu to TopTrackRow with "Send to Friend" and "Add to Playlist" options
  - [x] Add context menu to RecentlyPlayedCell with same options
  - [x] Add state and sheets for FriendPickerView and PlaylistPickerView
  - [x] Make top artists clickable to navigate to ArtistDetailView
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added onSendTapped and onAddToPlaylistTapped callbacks with context menus to TopTrackRow and RecentlyPlayedCell. Added trackToSend/trackToAddToPlaylist state and sheet modifiers. Wrapped TopArtistCell in NavigationLink to ArtistDetailView.

### 57. Move AI Features from menu to Profile next to Connect Spotify
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ProfileView.swift, vibes/Views/SettingsMenu.swift
- **Requested**: The AI features should be a part of the profile next to connect spotify, instead of in the menu
- **Context**: Better discoverability - AI configuration should be alongside Spotify connection
- **Acceptance Criteria**:
  - [x] Remove AI Features option from SettingsMenu
  - [x] Add AI Features section to ProfileView after Spotify section
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Removed AI Features button and showingAISettings state from SettingsMenu. Added aiFeaturesSection to ProfileView right after spotifySection with similar styling. Shows "Set Up AI Features" button when not configured, or "Manage AI Settings" when configured.

### 58. Real-time Now Playing
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/NowPlayingService.swift (new), vibes/Views/ChatsView.swift, vibes/Models/User.swift, vibes/Models/FriendProfile.swift
- **Requested**: Show what friends are currently listening to on Spotify in real-time
- **Context**: Social feature for music discovery through friends' listening activity
- **Acceptance Criteria**:
  - [x] Add now playing fields to UserProfile and FriendProfile
  - [x] Create NowPlayingService to poll Spotify and update Firestore
  - [x] Add updateNowPlaying/clearNowPlaying to FirestoreService
  - [x] Add Now Playing section to ChatsView with NowPlayingCard
  - [x] Start/stop polling based on app lifecycle
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created NowPlayingService.swift singleton that polls Spotify every 30 seconds and updates Firestore. Added nowPlayingTrackId/Name/Artist/AlbumArt/UpdatedAt fields to UserProfile and FriendProfile. Created NowPlayingCard component with album art and animated equalizer. Added Now Playing section to ChatsView that shows friends currently listening.

### 59. Predefined genre selection
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Components/GenrePickerView.swift (new), vibes/Views/ProfileView.swift
- **Requested**: Replace free-text genre input with predefined genre picker
- **Context**: Better data quality with consistent genre names
- **Acceptance Criteria**:
  - [x] Create MusicGenre model with 35+ genres
  - [x] Create GenrePickerView with grid of selectable genres
  - [x] Replace text input with genre picker sheet
  - [x] Add haptic feedback on selection
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created GenrePickerView.swift with 35 predefined genres across categories (Pop, Hip-Hop, Electronic, Jazz, Latin, etc.). Each genre has name, icon, and color. GenreChip component shows circular icon with selection state. Replaced TextField in ProfileView with "Add Genres" button that opens picker sheet.

### 60. Smooth animations and transitions
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/MessageThreadView.swift, vibes/Views/ChatsView.swift, vibes/Views/Components/GenrePickerView.swift
- **Requested**: Add spring animations and smooth transitions throughout app
- **Context**: Polish for a more refined user experience
- **Acceptance Criteria**:
  - [x] Add message appear animation (scale + opacity)
  - [x] Add reaction animation (spring scale)
  - [x] Add Now Playing card transition animation
  - [x] Add genre selection animation
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added spring animations throughout: messages appear with scale+opacity transition, reactions display with spring animation, Now Playing cards animate in/out, genre chips animate on selection. All use .spring() with appropriate response/dampingFraction values.

### 61. Add play functionality to profile top songs and recently played
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ProfileView.swift
- **Requested**: In profile page, be able to play/send/add to playlist top songs and recently played songs. Currently only send and add to playlist work via context menu. Need to add tap-to-play functionality like SearchView has.
- **Context**: Consistency with SearchView where tapping a track plays its preview
- **Acceptance Criteria**:
  - [x] Make TopTrackRow tappable to play track preview
  - [x] Make RecentlyPlayedCell tappable to play track preview
  - [x] Show play/pause indicator on currently playing track
  - [x] Handle tracks without preview URLs gracefully
  - [x] Add "Open in Spotify" option to context menu
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added AudioPlayerService to TopTrackRow and RecentlyPlayedCell. Made both tappable to play track previews using iTunes 30-second previews (fetched via iTunesService as fallback when Spotify preview unavailable). Added play/pause indicator overlay on album art with progress bar. Tracks without preview show dimmed (0.5 opacity) and display "No Preview Available" alert with option to open in Spotify. Added "Open in Spotify" context menu option.

### 62. Sort conversations by most recent message
- **Status**: ABANDONED
- **Type**: Bug
- **Location**: vibes/ViewModels/ChatsViewModel.swift:63
- **Requested**: User wants conversations sorted by most recent text/message without having to refresh
- **Context**: Sorting logic exists but real-time updates kept failing due to Firestore listener overwriting local state
- **Acceptance Criteria**:
  - [x] Verify sorting logic is correct
  - [ ] Add real-time local thread updates when messages are sent
  - [ ] Ensure conversations move to top immediately without refresh
  - [ ] Build and test
- **Failure Count**: 3
- **Failures**:
  - Attempt 1: Assumed existing sorting was working
  - Attempt 2: Added NotificationCenter updates but Firestore listener overwrote local state
  - Attempt 3: Added local/server merge but still not working correctly
- **Solution**: Reverted all changes. Basic sorting via Firestore listener remains (works on refresh).

### 63. Fix duplicate song playing indicator across entire app
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: Multiple views (MessageThreadView, ProfileView, PlaylistDetailView)
- **Requested**: When clicking play on a song, if there are duplicate songs in the list, all instances show as playing instead of just the one clicked. Fix across the entire app.
- **Context**: The trackId was using spotifyTrackId/track.id which is the same for duplicate songs. Need to use unique identifiers per instance.
- **Acceptance Criteria**:
  - [x] Only the specific song clicked shows as playing
  - [x] Duplicate songs can be played independently
  - [x] Fix in MessageThreadView (same song sent multiple times)
  - [x] Fix in ProfileView TopTrackRow (use rank-based ID)
  - [x] Fix in ProfileView RecentlyPlayedCell (use playedAt timestamp)
  - [x] Fix in PlaylistDetailView (playlists can have duplicate songs)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Used unique identifiers for each song instance:
  - MessageThreadView: Use `message.id` instead of `spotifyTrackId`
  - ProfileView TopTrackRow: Use `"top-\(rank)-\(track.id)"`
  - ProfileView RecentlyPlayedCell: Use `"\(track.id)-\(playHistory.playedAt)"`
  - PlaylistDetailView: Use `"playlist-\(index)-\(track.id)"` with enumerated ForEach

### 65. Wrong song plays for certain tracks (Sky, His and Hers)
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/iTunesService.swift:24-95
- **Requested**: When playing certain songs, the wrong song plays. Examples: "Sky" by Playboi Carti and "His and Hers" by Internet Money ft. Don Toliver play incorrect audio
- **Context**: Preview URLs may be mismatched or iTunes search returning wrong tracks as fallback
- **Acceptance Criteria**:
  - [x] Identify root cause of wrong song playing
  - [x] Fix preview URL resolution for affected tracks
  - [x] Verify "Sky" by Playboi Carti plays correctly
  - [x] Verify "His and Hers" by Internet Money plays correctly
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Root cause was iTunesService.searchPreview() falling back to the first search result when no match was found (line 52). For common song names like "Sky", this returned wrong songs. Fixed by:
  1. Removed fallback to first result - now returns nil if no good match
  2. Added scoring system to find best matching track
  3. Added normalizeTrackName() to strip "(feat.)", "(Remaster)", etc.
  4. Added extractArtistNames() to handle "ft.", "feat.", "&", etc. for featured artists
  5. Increased result limit from 5 to 10 for better matching
  6. Both track name AND artist must match now (previously could fall back without artist match)

### 64. Standardize context menu on all songs app-wide
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Multiple views
- **Requested**: Every single song anywhere in the entire app should have a long-press context menu with three options: Send to Friend, Add to Playlist, Open in Spotify
- **Context**: Consistent UX across all song displays
- **Acceptance Criteria**:
  - [x] SearchView TrackRow - add "Open in Spotify"
  - [x] MessageThreadView SongMessageBubbleView - add "Send to Friend" and "Open in Spotify"
  - [x] ArtistDetailView ArtistTopTrackRow - add "Open in Spotify"
  - [x] AlbumDetailView AlbumTrackRow - add "Open in Spotify"
  - [x] PlaylistDetailView PlaylistTrackRow - add "Open in Spotify"
  - [x] DiscoverView RecommendationRow - add "Open in Spotify"
  - [x] DiscoverView TrendingSongRow - add "Open in Spotify"
  - [x] AIPlaylistView ResolvedSongRow - add full context menu
  - [x] FriendBlendView BlendSongRow - add full context menu
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added "Open in Spotify" to all track rows that already had "Send to Friend" and "Add to Playlist". Added full context menus (all 3 options) to AIPlaylistView ResolvedSongRow and FriendBlendView BlendSongRow which previously had no context menu. All context menus now consistently have: Send to Friend, Add to Playlist, Open in Spotify (opens https://open.spotify.com/track/{trackId}).

### 66. Add 50 more achievements
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Components/AchievementsView.swift
- **Requested**: Add approximately 50 more achievements to the app
- **Context**: Expand gamification with more achievements across categories
- **Acceptance Criteria**:
  - [x] Add new achievement categories (Messaging, Reactions, AI, Listening)
  - [x] Add 50+ new AchievementDefinition entries
  - [x] Update AchievementStats with new trackable stats
  - [x] Update buildAchievements() to handle new achievement IDs
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added 4 new categories (Messaging, Reactions, AI, Listening) and 50 new achievements (now 65 total across 8 categories):
  - **Sharing (8)**: Added share_250, share_500, share_1000, unique_artists_25
  - **Social (10)**: Added friends_50, friends_100, friend_requests_sent_5/25, first_blend, blends_10
  - **Streaks (8)**: Added streak_3, streak_14, streak_60, streak_180
  - **Discovery (10)**: Added playlist_share_5/25, genres_3/10, songs_added_10/50/100
  - **Messaging (10)**: first_message, messages_10/50/100/500/1000, conversations_3/10, song_messages_25/100
  - **Reactions (8)**: first_reaction, reactions_10/50/100/500, received_reactions_10/50/100
  - **AI (6)**: ai_config, first_ai_playlist, ai_playlists_5/10/25/50
  - **Listening (10)**: preview_plays_10/50/100/500, artists_viewed_10/50, albums_viewed_10/50, search_queries_25/100
  - **Secret (5)**: Hidden achievements that show "?????" until unlocked:
    - "The Collector" - Unlock 50 other achievements
    - "Social Royalty" - Have 250 friends
    - "Night Owl" - Play 1000 song previews
    - "Reaction Machine" - Give 1000 reactions
    - "Eternal Vibe" - Maintain a 500-day vibestreak
  Also updated AchievementStats with 15 new trackable stats and added `isSecret` flag to Achievement model.

### 67. Reorganize Profile tab into Settings with 3 subtabs
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ProfileView.swift, vibes/ContentView.swift
- **Requested**: Divide up the profile page into 3 subtabs and rename the entire tab to Settings:
  - Achievements: contains all of the achievements
  - Stats: Contains your top artists, top songs, and recently listened to
  - Profile: Contains your name, username, the edit profile button, spotify connection, ai features connection, your card, favorite genres, and email
- **Context**: Better organization of settings/profile content into logical categories
- **Acceptance Criteria**:
  - [x] Rename "Profile" tab to "Settings" in ContentView
  - [x] Add segmented picker for subtabs (Achievements, Stats, Profile)
  - [x] Move achievements section to Achievements subtab
  - [x] Move top artists, top songs, recently played to Stats subtab
  - [x] Move profile header, spotify, AI features, music card, genres, email to Profile subtab
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added SettingsTab enum with 3 cases (achievements, stats, profile). Updated ContentView to show "Settings" tab with gearshape.fill icon. Added segmented picker at top of ProfileView. Reorganized content into 3 tab views: achievementsTabContent (achievements section), statsTabContent (time range picker, top artists, top songs, recently played), profileTabContent (profile header, spotify, AI features, music personality card, genres, email). Added statsNotConnectedView for when Spotify isn't connected on Stats tab.

### 68. Fix Settings subtab order and Stats page appearance
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/ProfileView.swift
- **Requested**: Reorder subtabs to Profile, Stats, Achievements. Fix Stats page having two identical-looking segmented pickers stacked.
- **Context**: UX improvement - tabs should be in logical order and Stats page looks cluttered
- **Acceptance Criteria**:
  - [x] Reorder SettingsTab enum to Profile, Stats, Achievements
  - [x] Style time range picker differently from main tab picker
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Reordered SettingsTab enum cases to profile, stats, achievements. Changed time range picker from segmented style to menu style with a "Time Range" label on the left, displayed in a rounded card matching other sections.

### 69. Replace Edit Profile menu option with Settings
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/SettingsMenu.swift
- **Requested**: Replace the "Edit Profile" option in the top right menu with "Settings" which navigates to the Settings page
- **Context**: Better navigation flow - users go to Settings page instead of directly into edit mode
- **Acceptance Criteria**:
  - [x] Change "Edit Profile" to "Settings" in SettingsMenu
  - [x] Change icon from person.circle to gearshape
  - [x] Remove shouldEditProfile trigger, just navigate to tab 3
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated SettingsMenu to show "Settings" with gearshape icon instead of "Edit Profile". Now just navigates to Settings tab without triggering edit mode.

### 70. Show completed achievements in grid view
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Components/AchievementsView.swift:927-934
- **Requested**: On the achievements grid view, show all of the completed achievements instead of incomplete achievements
- **Context**: Better UX - users want to see what they've accomplished, not what's locked
- **Acceptance Criteria**:
  - [x] Filter to only show unlocked achievements in grid
  - [x] Show up to 8 completed achievements (was 6 incomplete)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Changed AchievementsGridView displayedAchievements to filter only unlocked achievements and show up to 8 of them.

### 71. Fix achievement notifications re-appearing and clear all data on account delete
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/AchievementNotificationService.swift, vibes/Services/AuthManager.swift
- **Requested**: When signing out and back in, achievement notifications for already-completed achievements appear again. Also, when deleting an account, all data should be erased including achievements, Spotify connections, and AI settings.
- **Context**: UserDefaults key for seen achievements is not user-specific. Account deletion doesn't clear local UserDefaults or Keychain data.
- **Acceptance Criteria**:
  - [x] Make achievement notification tracking user-specific
  - [x] Sync seen achievements from Firestore on first sign-in (no re-notifications)
  - [x] Clear all UserDefaults data on account deletion
  - [x] Clear Gemini API key from Keychain on account deletion
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Made AchievementNotificationService user-specific by storing unlocked achievements with key `unlocked_achievements_\(userId)`. Added setCurrentUser() called from AuthManager's auth state handler. Added first-time detection to skip notifications on initial sign-in (just syncs achievements). For account deletion, added clearUserData() methods to AchievementNotificationService, GeminiService, and LocalAchievementStats. AuthManager.deleteAccount() now calls all cleanup methods: SpotifyService.signOut(), GeminiService.clearUserData(), AchievementNotificationService.clearUserData(), LocalAchievementStats.clearAllData(), and removes recent_searches from UserDefaults.

### 72. Add AI Blend feature to Discover tab
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/DiscoverView.swift, vibes/ViewModels/DiscoverViewModel.swift
- **Requested**: Add AI Blend feature in the Discover tab's AI Features section. Show horizontal scrolling friend cards sorted by messaging frequency. Users can tap a friend card to create a blend. Combine with existing AI Playlist feature so both are accessible.
- **Context**: Friend Blend already exists (FriendBlendView) but is only accessible from Chats. Adding to Discover increases discoverability.
- **Acceptance Criteria**:
  - [x] Add BlendableFriend model with message count
  - [x] Add loadBlendableFriends() to DiscoverViewModel sorted by messaging frequency
  - [x] Rename AI Playlist section to "AI Features"
  - [x] Add horizontal scrolling friend blend cards
  - [x] Cards navigate to FriendBlendView
  - [x] Keep existing AI Playlist navigation
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added BlendableFriend model with friend profile, message count, and last message date. Created loadBlendableFriends() that queries Firestore for message counts per friend thread and sorts by frequency. Renamed "AI Playlist Ideas" section to "AI Features". Added "Blend with a Friend" subsection with horizontal scrolling BlendFriendCard components (circular profile pics with blend icon overlay, friend name, message count). Cards navigate to existing FriendBlendView. Preserved AI Playlist generation card above blend section.

## Task Statistics
- Total Tasks: 72
- Completed: 70
- Removed: 2
- Deferred: 0
- In Progress: 0
- Pending: 0

---

Older completed tasks (1-50) have been archived to docs/.archive/tasks-2025-01.md
