# Task Tracking

## Active Tasks

### 81. First-time user onboarding tutorial
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/TutorialView.swift (new), vibes/ContentView.swift
- **Requested**: Create a polished, visually appealing tutorial for first-time users after account creation/sign-in. Should explain all AI features (AI Playlists, AI Picks, Friend Blends), how to use them, how to navigate through menus, and be a comprehensive guide. Keep it brief but cover all key features including: Discover tab, Search, Chats/Messaging, Settings, Vibestreaks, Achievements, sending songs, adding to playlists, long-press context menus, Spotify connection, and AI configuration.
- **Context**: Improves user onboarding and feature discoverability
- **Acceptance Criteria**:
  - [x] Create TutorialView with multiple pages/slides
  - [x] Polished UI with animations and smooth transitions
  - [x] Cover all 4 main tabs (Discover, Search, Chats, Settings)
  - [x] Explain AI features (AI Playlists, AI Picks, Friend Blends)
  - [x] Explain social features (Vibestreaks, sending songs, messaging)
  - [x] Explain achievements system
  - [x] Explain context menus and interactions
  - [x] Show on first sign-in only (UserDefaults flag)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created comprehensive TutorialView.swift with 8 polished pages covering all features with animations.

### 82. Fix achievements sharing across accounts
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/Components/AchievementsView.swift (LocalAchievementStats), vibes/Services/AuthManager.swift
- **Requested**: Achievements are being shared across accounts. Example: Night Owl secret achievement unlocked on main account also shows up on second account.
- **Context**: LocalAchievementStats uses UserDefaults without user-specific keys, causing achievement data to leak between accounts
- **Acceptance Criteria**:
  - [x] Make LocalAchievementStats user-specific
  - [x] Clear local stats on sign out
  - [x] Verify achievements don't leak between accounts
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Made LocalAchievementStats user-specific with key() helper appending userId to all UserDefaults keys.

### 83. Add 3 super secret achievements (Butterfly Effect, The Contrarian, The Resurrection)
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Components/AchievementsView.swift, vibes/ViewModels/MessageThreadViewModel.swift, vibes/Services/AudioPlayerService.swift, vibes/ViewModels/DiscoverViewModel.swift
- **Requested**: Add 3 super secret achievements that don't appear until unlocked
- **Context**: Creative, hard-to-get hidden achievements for dedicated users
- **Acceptance Criteria**:
  - [x] Add Butterfly Effect, The Contrarian, The Resurrection achievement definitions
  - [x] Track song share chains, monthly play counts, removed songs
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added 3 super secret achievements with isSuperSecret=true flag (completely invisible until unlocked).

### 84. Search/filter friends list
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ChatsView.swift
- **Requested**: Add a search bar to filter friends by name or username in the Chats tab
- **Context**: As friend lists grow, users need a quick way to find specific friends
- **Acceptance Criteria**:
  - [x] Add search bar at top of friends/chats list
  - [x] Filter friends in real-time as user types
  - [x] Search by display name and username
  - [x] Show "No results" state when no matches
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added search bar with filteredChats computed property filtering by displayName or username.

### 85. Visual depth with shadows and elevation
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Components/CardStyle.swift (new), multiple views
- **Requested**: Apply consistent shadows to cards and components for visual hierarchy
- **Context**: Subtle shadows create depth and help separate UI elements
- **Acceptance Criteria**:
  - [x] Add shadow to card components
  - [x] Apply consistent corner radius across cards
  - [x] Test in both light and dark mode
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created CardStyle.swift ViewModifier with adaptive shadows for light/dark mode.

### 86. Music taste compatibility scores
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/CompatibilityService.swift (new), vibes/Views/ChatRowView.swift, vibes/ViewModels/ChatsViewModel.swift
- **Requested**: Calculate and display music compatibility percentage between users
- **Context**: Helps users discover friends with similar music taste
- **Acceptance Criteria**:
  - [x] Analyze shared artists, genres, and listening patterns
  - [x] Calculate compatibility score (0-100%)
  - [x] Display percentage on friend profiles
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created CompatibilityService with Jaccard-like overlap algorithm and CompatibilityBadge component.

### 87. Group chats
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ChatsView.swift, vibes/Models/GroupThread.swift (new), vibes/Views/CreateGroupView.swift (new), vibes/Views/GroupThreadView.swift (new)
- **Requested**: Add group messaging functionality for multiple friends to chat together
- **Context**: Users want to share music with multiple friends at once
- **Acceptance Criteria**:
  - [x] Create GroupThread model with name, participants
  - [x] Add "New Group" button to create groups
  - [x] Multi-select friends to add to group
  - [x] Show group conversations in Chats tab
  - [x] Display sender names in group messages
  - [x] Support text and song messages in groups
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented complete group chat functionality with GroupThread model, CreateGroupView, GroupThreadView.

### 88. Fix group chats not showing in conversations
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/ChatsView.swift, vibes/Services/FirestoreService.swift
- **Requested**: Group chats are not showing up in conversations after being created
- **Context**: Groups section was conditionally hidden when empty, and Firestore listener errors were being silently ignored
- **Acceptance Criteria**:
  - [x] Make groups section always visible (even when empty)
  - [x] Add helpful empty state with create button
  - [x] Add error logging to Firestore group listener
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Made groups section always visible with empty state and added error logging.

### 89. Fix achievements sharing across accounts (again)
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/Components/AchievementsView.swift
- **Requested**: Achievements are broken again - data leaking between accounts
- **Context**: The key() function in LocalAchievementStats returned base key (without user suffix) when currentUserId was nil
- **Acceptance Criteria**:
  - [x] Fix key() function to never return shared keys
  - [x] Fall back to Firebase Auth current user if cached userId is nil
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated key() function to fall back to FirebaseAuth and return dummy key if no user logged in.

### 90. Fix Discover page sometimes missing sections
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/DiscoverView.swift
- **Requested**: Sometimes the Discover page appears without New Releases and AI Picks sections
- **Context**: Sections were only shown when data was not empty, race condition with authentication state
- **Acceptance Criteria**:
  - [x] Add onChange handler to reload data when Spotify authenticates
  - [x] Add onChange handler to load AI recommendations when Gemini configures
  - [x] Show sections while loading (not just when data exists)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added onChange handlers and loading indicators for each section.

### 91. Prevent duplicate group chats and add moderator controls
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/FirestoreService.swift, vibes/Views/CreateGroupView.swift, vibes/Views/GroupThreadView.swift
- **Requested**: Only allow creating a group if one with the same members doesn't exist. The creator should be a moderator who can change the group name.
- **Context**: Prevents duplicate groups and gives the creator admin privileges
- **Acceptance Criteria**:
  - [x] Check for existing group with same participants before creating
  - [x] Show alert when duplicate group detected
  - [x] Add pencil icon for creator to edit group name
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added findExistingGroup() check and edit functionality for group creator.

### 92. Add delete group functionality for moderator
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/FirestoreService.swift, vibes/Views/GroupThreadView.swift
- **Requested**: As a moderator/creator, allow deleting the entire group chat
- **Context**: Gives moderator full control including ability to remove the group
- **Acceptance Criteria**:
  - [x] Add deleteGroup function to FirestoreService
  - [x] Verify requester is creator before allowing delete
  - [x] Add delete button in edit group sheet
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added deleteGroup() that deletes all messages and group document with confirmation.

### 93. Fix music compatibility using Spotify top artists instead of empty profile data
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/FirestoreService.swift, vibes/Views/ProfileView.swift, vibes/ViewModels/DiscoverViewModel.swift
- **Requested**: Compatibility shows only 20% even though users have the same top listeners
- **Context**: The favoriteArtists field in Firestore was initialized as empty and never synced from Spotify
- **Acceptance Criteria**:
  - [x] Add syncTopArtistsToProfile function to FirestoreService
  - [x] Sync top artists when Profile Stats loads
  - [x] Sync top artists when Discover page loads
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added syncTopArtistsToProfile() called from ProfileView and DiscoverViewModel.

### 94. Fix achievement banner not visible
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/Components/AchievementsView.swift, vibes/Views/ProfileView.swift
- **Requested**: Achievement banners just aren't working - not appearing when achievements are unlocked
- **Context**: Banner overlay had no safe area padding, and checkLocalAchievements() only loaded local stats
- **Acceptance Criteria**:
  - [x] Add safe area padding to banner overlay
  - [x] Fix achievement comparison logic
  - [x] Build and test
- **Failure Count**: 1
- **Failures**:
  - Attempt 1: Fixed banner positioning but discovered the real issue was incomplete stats comparison
- **Solution**: Added padding to banner and cacheFirestoreStats() for complete achievement comparison.

### 95. Update New Releases to last 3 months and top 20 artists
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/ViewModels/DiscoverViewModel.swift:85-138
- **Requested**: Change New Releases section to only show releases from the last 3 months (instead of 1 year), and use top 20 artists (instead of top 5)
- **Context**: User wants more recent releases from a broader set of their favorite artists
- **Acceptance Criteria**:
  - [x] Change date filter from 1 year to 3 months
  - [x] Change top artists limit from 5 to 20
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated loadNewReleases() to use 3 months and top 20 artists.

### 96. Increase AI playlist song count to 15
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/GeminiService.swift:142
- **Requested**: Change AI playlists from 6 songs to 15 songs
- **Context**: User wants longer AI-generated playlists
- **Acceptance Criteria**:
  - [x] Update Gemini prompt to request 15 songs per playlist
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Changed prompt from "Include 5-6 songs per playlist" to "Include exactly 15 songs per playlist"

### 98. Group chat info view - clickable name instead of edit button
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/GroupThreadView.swift
- **Requested**: Fix group chat menu. Instead of edit button next to name, make the group name clickable which opens a view showing all group info: members, name, and moderator options (delete group, rename).
- **Context**: Improves UX by consolidating group management into a single info view
- **Acceptance Criteria**:
  - [x] Remove edit pencil button from toolbar
  - [x] Make group name in nav bar tappable
  - [x] Create GroupInfoView showing group name, all members, created date
  - [x] Moderator sees rename and delete options
  - [x] Load and display member profiles
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Replaced toolbar pencil button with tappable group name that opens GroupInfoView sheet. GroupInfoView shows group name (editable for moderator), all members with profile pictures and "Moderator" badge, created date, and delete group option for moderator.

### 99. Make DM input bar match group chat style
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/MessageThreadView.swift:638-661
- **Requested**: Change the DM message input bar to look like the group chat input bar, and remove the plus sign next to the bar
- **Context**: UI consistency between DM and group chat interfaces
- **Acceptance Criteria**:
  - [x] Remove plus button from MessageInputBar
  - [x] Change TextField style from .roundedBorder to .plain with custom background
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Removed plus button, changed TextField to .plain style with Color(.tertiarySystemFill) background and cornerRadius(20) to match group chat style.

### 97. Song sharing with multiple friends - individual or group option
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/FriendPickerView.swift
- **Requested**: When selecting a song to send to friends and selecting multiple friends, provide two options: (1) Send to each friend independently as individual messages, or (2) Create or use an existing group chat to send the song to all selected friends at once
- **Context**: Users need flexibility when sharing songs - sometimes they want individual conversations, other times they want to start a group discussion
- **Acceptance Criteria**:
  - [x] After selecting multiple friends, show action sheet with two options
  - [x] Option 1: Send individually to each selected friend
  - [x] Option 2: Send to group chat (create new or use existing)
  - [x] If group exists with same members, use it; otherwise create new
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added confirmationDialog to FriendPickerView that appears when >1 friend selected. Two options: "Send Individually" uses existing behavior, "Send to Group Chat" finds or creates group and sends song there.

### 101. Achievement banners only appear when visiting achievements page
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/ProfileView.swift:661-719, vibes/Views/Components/AchievementsView.swift
- **Requested**: Achievement banners are only appearing when navigating to the achievements page, not when achievements are actually earned during normal app usage
- **Context**: The `loadAchievements()` function which calls `checkForNewAchievements()` is only triggered when the achievements tab is viewed. Firestore stats are only cached at that point, so local achievement checks can't work properly until the user visits the page.
- **Acceptance Criteria**:
  - [x] Achievement banners appear immediately when achievements are unlocked
  - [x] Firestore stats are cached proactively (not just when viewing achievements)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added `loadAndCacheFirestoreStats()` function to LocalAchievementStats that fetches Firestore stats and profile data, caches them, and syncs the initial achievement state with AchievementNotificationService. This is now called from AuthManager when user signs in, so achievement checks work properly from the start of the session.

### 100. Pass dismissed tracks to Gemini to avoid re-suggesting them
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/GeminiService.swift, vibes/ViewModels/DiscoverViewModel.swift
- **Requested**: When all AI recommendations are dismissed, pass the dismissed track list to Gemini so it knows to suggest different songs instead of the same ones
- **Context**: Currently Gemini keeps suggesting the same songs that get filtered out as "dismissed", resulting in 0 visible recommendations
- **Acceptance Criteria**:
  - [x] Modify generatePersonalizedRecommendations to accept dismissed tracks list
  - [x] Update Gemini prompt to exclude previously dismissed songs
  - [x] Retry automatically when all recommendations are dismissed
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added `avoidSongs` parameter to GeminiService.generatePersonalizedRecommendations() with prompt section to avoid previously dismissed songs. DiscoverViewModel stores dismissed song names (last 50) in UserDefaults and passes them to Gemini. Added loadAIRecommendationsWithRetry() that retries up to 3 times if all recommendations are filtered out.

### 102. Group chat messages don't count towards chatterbox achievements
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/GroupThreadView.swift:515-526
- **Requested**: Messages sent to group chats don't count towards the chatterbox series of achievements
- **Context**: The sendMessage function in GroupThreadViewModel doesn't increment LocalAchievementStats.shared.messagesSent like the DM MessageThreadViewModel does
- **Acceptance Criteria**:
  - [x] Increment messagesSent when sending group messages
  - [x] Call checkLocalAchievements() after sending
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added LocalAchievementStats.shared.messagesSent += 1 and checkLocalAchievements() call after successfully sending a group message in GroupThreadView.swift:523-525.

### 103. Songs in group chats can't be played
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/GroupThreadView.swift:349-461
- **Requested**: Can't play songs that are in group chats
- **Context**: GroupMessageBubble's songBubble view only shows album art, title, and artist - no play button like the DM SongMessageBubbleView has
- **Acceptance Criteria**:
  - [x] Add AudioPlayerService integration to GroupMessageBubble
  - [x] Add play button to songBubble
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added @ObservedObject audioPlayer, trackId/isCurrentTrack/isPlaying/hasPreview computed properties, and playButton view to GroupMessageBubble. Updated songBubble to include play button with proper styling for both sender and receiver states.

### 105. Interactive in-app tutorial with coach marks
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/CoachMarksService.swift (new), vibes/Views/Components/CoachMarksOverlay.swift (new), vibes/ContentView.swift, vibes/Views/DiscoverView.swift, vibes/Views/ChatsView.swift, vibes/Views/ProfileView.swift
- **Requested**: Replace or augment the current standalone tutorial with an interactive in-app tutorial that overlays the real app UI. The tutorial should highlight actual buttons and UI elements, showing users exactly where to tap and how to navigate. Users should be able to see and interact with the real interface while being guided step-by-step.
- **Context**: The current tutorial is informative but doesn't show users the actual app. An interactive walkthrough with coach marks/tooltips pointing to real UI elements will be more effective for teaching users how to use the app.
- **Acceptance Criteria**:
  - [x] Create coach marks/tooltip overlay system
  - [x] Highlight actual UI elements (buttons, tabs, etc.)
  - [x] Step-by-step walkthrough of key features
  - [x] Allow users to tap highlighted elements to progress
  - [x] Persist tutorial progress so users can resume
  - [x] Option to restart tutorial from Settings
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created CoachMarksService singleton with 4 tutorial steps: Add Friends, Create Groups, Settings Menu, and AI Playlists & Blends. Created CoachMarksOverlay with SpotlightView (semi-transparent overlay with transparent cutout using blendMode) and CoachMarkTooltip (callout bubble with Back/Next/Skip). Added coachMarkTarget() modifier for view position tracking via PreferenceKey. Coach marks start automatically after slideshow tutorial completes. Updated ProfileView "Replay Tutorial" to reset both slideshow and coach marks.

### 104. Add context menu to group chat song messages
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/GroupThreadView.swift:349-570, vibes/Services/FirestoreService.swift:177-182, vibes/Models/GroupThread.swift:44
- **Requested**: Group chat songs should have context menu with react, send to friend, add to playlist, and open in Spotify options like DM song messages
- **Context**: DM SongMessageBubbleView has full context menu, GroupMessageBubble only has play button
- **Acceptance Criteria**:
  - [x] Add context menu with reaction options
  - [x] Add "Send to Friend" option with FriendPickerView sheet
  - [x] Add "Add to Playlist" option with PlaylistPickerView sheet
  - [x] Add "Open in Spotify" option
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added SpotifyService, state variables, trackUri/trackForSharing computed properties to GroupMessageBubble. Added context menu with React submenu, Send to Friend, Add to Playlist, and Open in Spotify options. Added sheet presentations for PlaylistPickerView and FriendPickerView. Added addGroupReaction() to FirestoreService. Added reaction display below song bubbles. Made reactions field default to empty dict in GroupMessage model.

### 109. Change New Releases to use top 10 artists instead of top 20
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/ViewModels/DiscoverViewModel.swift:97,124
- **Requested**: Change new releases to check top 10 artists on Spotify, not top 3 (currently using top 20)
- **Context**: User wants a smaller, more focused set of top artists for new releases
- **Acceptance Criteria**:
  - [x] Change getTopArtists limit from 20 to 10
  - [x] Change prefix from 20 to 10
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Changed getTopArtists limit from 15 to 10 for both short_term and medium_term time ranges, and changed prefix from 20 to 10 when iterating through artists to fetch albums.

### 108. Vibestreak visual indicator for daily completion status
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Components/VibestreakView.swift, vibes/Models/FriendProfile.swift, vibes/Views/ChatRowView.swift
- **Requested**: When a vibestreak has already been completed today (both users have sent a message to each other), make the symbol red. Otherwise, leave it gray and don't fill it in until both people have sent a message, incrementing the vibestreak for that day.
- **Context**: Users need visual feedback on whether they've completed their daily vibestreak interaction
- **Acceptance Criteria**:
  - [x] Add `vibestreakCompletedToday` computed property to FriendProfile
  - [x] Update VibestreakView to accept `completedToday` parameter
  - [x] Show red filled flame when completed today
  - [x] Show gray outline flame when not completed today
  - [x] Pass completion status through ChatItem to VibestreakView
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added `vibestreakCompletedToday` computed property to FriendProfile and MessageThreadViewModel that checks if `streakLastUpdated` is today. Updated VibestreakView and VibestreakBadgeView to accept `completedToday` parameter - when true shows red filled flame, when false shows gray outline flame. Added `vibestreakCompletedToday` field to ChatItem and passed it through ChatsViewModel and ChatRowView.

### 110. Increase Discover header left padding
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/DiscoverView.swift:72-73
- **Requested**: Move the Discover header to the right a little bit, it's pushed up against the edge too much
- **Context**: UI polish - content needs more breathing room from the left edge
- **Acceptance Criteria**:
  - [x] Increase horizontal padding on Discover content
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Changed `.padding()` to `.padding(.vertical)` and `.padding(.horizontal, 20)` to increase horizontal spacing from 16pt to 20pt.

### 107. AI Playlist Recommendations with checkmark system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/PlaylistRecommendationsView.swift, vibes/ViewModels/PlaylistRecommendationsViewModel.swift, vibes/Services/GeminiService.swift, vibes/Views/DiscoverView.swift
- **Requested**: Create AI feature where user can select an existing playlist and get 5 song recommendations to add. Songs must have 30-second iTunes previews (if not, find alternatives that do). Include checkmark system - when user checks a song it gets added to playlist. Once all 5 are checked or dismissed, generate new batch of 5.
- **Context**: Extends AI recommendation system to help grow existing playlists
- **Acceptance Criteria**:
  - [x] Playlist picker to select from user's existing playlists
  - [x] Generate 5 AI recommendations based on playlist content
  - [x] Ensure all recommendations have iTunes preview URLs
  - [x] Checkmark button to add song to playlist
  - [x] Dismiss option to skip a song
  - [x] Auto-generate new batch when all 5 processed
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created PlaylistRecommendationsView with playlist selection and recommendation cards. PlaylistRecommendationsViewModel manages state with visible (5) and pending (10) recommendation pools. Added generatePlaylistRecommendations() to GeminiService that analyzes playlist content. Added "Grow Your Playlists" card in DiscoverView's AI Features section. Songs filtered to only include those with iTunes preview URLs. Checkmark adds to Spotify playlist, X dismisses. Auto-fetches more when pool runs low.

### 106. Swipe gesture to navigate between tabs
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/ContentView.swift
- **Requested**: Add swipe gestures so swiping right moves to the previous tab and swiping left moves to the next tab
- **Context**: Improves navigation UX by allowing gesture-based tab switching
- **Acceptance Criteria**:
  - [x] Swipe left to go to next tab
  - [x] Swipe right to go to previous tab
  - [x] Respect tab bounds (0-3)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Replaced standard TabView with horizontal ScrollView using `.scrollTargetBehavior(.paging)` and `.scrollPosition(id:)` for smooth swipe animations. Created CustomTabBar component with pill-shaped selection indicator. Uses GeometryReader for full-width pages and ScrollViewReader for programmatic tab changes.

### 113. Remove interactive coach marks tutorial, keep only slideshow
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/CoachMarksService.swift, vibes/Views/Components/CoachMarksOverlay.swift, vibes/ContentView.swift, vibes/Views/ChatsView.swift, vibes/Views/ProfileView.swift, vibes/Views/DiscoverView.swift
- **Requested**: Remove the whole part of the tutorial where you are actually in the app, just keep the slideshow part of the tutorial
- **Context**: User wants to remove the interactive coach marks overlay and keep only the TutorialView slideshow
- **Acceptance Criteria**:
  - [x] Delete CoachMarksService.swift
  - [x] Delete CoachMarksOverlay.swift
  - [x] Remove coach mark references from ContentView.swift
  - [x] Remove coach mark targets from ChatsView.swift, DiscoverView.swift
  - [x] Update ProfileView.swift "Replay Tutorial" to only reset slideshow
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Deleted CoachMarksService.swift and CoachMarksOverlay.swift. Removed @StateObject coachMarksService, overlayPreferenceValue, and onAppear coach marks startup from ContentView.swift. Removed .coachMarkTarget() modifiers from ChatsView.swift (3 locations) and DiscoverView.swift (2 locations). Removed CoachMarksService.shared.hasCompletedCoachMarks reset from ProfileView.swift "Replay Tutorial" button.

### 112. iTunes preview sometimes plays wrong song version (remix or different song)
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/iTunesService.swift:24-125
- **Requested**: Sometimes when playing a song it plays a preview from the remix or a whole different song entirely
- **Context**: The iTunes search matching logic allows partial matches and doesn't penalize/filter remix versions when the original was requested
- **Acceptance Criteria**:
  - [x] Add remix/version detection to filter out wrong versions
  - [x] Prefer exact track name matches over partial matches
  - [x] Skip results that are remixes when original was requested
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added `isRemixOrAlternateVersion()` function that detects remix/alternate version indicators (remix, mix, edit, version, bootleg, live, acoustic, etc.). If the search query is NOT a remix but a result IS a remix, that result is skipped. Also added +2 bonus score for matching original versions when original was requested.

### 111. Always show AI Picks For You title
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/DiscoverView.swift:48-50, 283-304
- **Requested**: Always show the "AI Picks For You" title even when there are no songs showing up
- **Context**: When all AI recommendations are dismissed, the entire section disappears. User wants the title to always be visible.
- **Acceptance Criteria**:
  - [x] AI Picks section title always visible when Gemini is configured
  - [x] Show empty state message when no recommendations
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Changed condition from `!viewModel.aiRecommendations.isEmpty || viewModel.isLoadingAIRecommendations` to `geminiService.isConfigured`. Added empty state card with "No recommendations right now" message when aiRecommendations is empty and not loading.

### 114. Fix missing Firebase SPM packages in Xcode
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes.xcodeproj
- **Requested**: Xcode shows 4 errors: Missing package product 'FirebaseAuth', 'FirebaseFirestore', 'FirebaseStorage', 'FirebaseMessaging'
- **Context**: Swift Package Manager dependencies need to be resolved
- **Acceptance Criteria**:
  - [x] Resolve SPM packages
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Ran `xcodebuild -resolvePackageDependencies` to resolve the SPM package graph. All Firebase packages resolved successfully and build succeeded.

### 115. Fix GroupThread decoding error for missing lastMessageType
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Models/GroupThread.swift:18
- **Requested**: Fix decoding error "No value associated with key lastMessageType" when loading group chats from Firestore
- **Context**: GroupThread.lastMessageType is non-optional but some Firestore documents don't have this field
- **Acceptance Criteria**:
  - [x] Make lastMessageType optional with default value
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added custom init(from decoder:) that uses decodeIfPresent with "text" as default for lastMessageType. Also added memberwise init since providing custom init removes the auto-generated one.

### 116. Fix profile and friends failing to load due to missing Firestore fields
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Models/User.swift:11-118
- **Requested**: Profile shows "Failed to load profile" and friends list shows empty even though user has conversations and friends. This happens because UserProfile has many non-optional fields (spotifyLinked, favoriteArtists, favoriteSongs, favoriteAlbums, musicTasteTags, pinnedSongs, createdAt, updatedAt, privacySettings) and if any Firestore document is missing these fields, decoding fails completely.
- **Context**: Firestore documents may have been created before certain fields were added to the model, or may have been partially updated. The Codable decoder fails when required fields are missing.
- **Acceptance Criteria**:
  - [x] Add custom init(from decoder:) to UserProfile with defaults for missing fields
  - [x] Profile loads successfully even with incomplete Firestore data
  - [x] Friends list populates correctly
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added custom `init(from decoder:)` to both `UserProfile` and `PrivacySettings` that uses `decodeIfPresent` with default values for all fields that might be missing in Firestore documents. Non-optional fields now default to: spotifyLinked=false, arrays=[], dates=Date(), privacySettings=PrivacySettings(). Also made PrivacySettings decode with defaults for its fields.

### 118. Split AchievementsView.swift into smaller files
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/Components/AchievementsView.swift, vibes/Models/, vibes/Services/
- **Requested**: Code cleanup - split the massive AchievementsView.swift file (2145 lines) into smaller, more maintainable pieces
- **Context**: File was 2145 lines containing models, data, logic, and views all mixed together
- **Acceptance Criteria**:
  - [x] Create Achievement.swift with Achievement, AchievementCategory, AchievementDefinition
  - [x] Create AchievementDefinitions.swift with all achievement definitions
  - [x] Create LocalAchievementStats.swift with stats tracking and AchievementStats
  - [x] Keep only views in AchievementsView.swift
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Split into 4 files: Achievement.swift (103 lines - models), AchievementDefinitions.swift (766 lines - data), LocalAchievementStats.swift (860 lines - logic), AchievementsView.swift (371 lines - views only)

### 117. Fix context menu usability and reactions interaction
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/MessageThreadView.swift, vibes/Views/GroupThreadView.swift
- **Requested**: The menus are really hard to click on - user wants to be able to click anywhere in the row, not just the icon. The reactions list is not working well.
- **Context**: Currently the React option is a submenu requiring two taps. Reactions display is not interactive.
- **Acceptance Criteria**:
  - [x] Make reaction options directly in context menu (not a submenu)
  - [x] Make reactions tappable to toggle user's own reaction
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Flattened the reaction Menu submenu into direct Button items in the context menu for both DM (SongMessageBubbleView, PlaylistMessageBubbleView) and group chat (GroupMessageBubble) song messages. Updated ReactionsDisplayView to accept currentUserId and onReactionTapped callback, making each reaction pill tappable to add that reaction. Added visual highlighting (blue background and border) when the current user has reacted with that emoji.

### 119. Nearby concerts for top Spotify artists
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/DiscoverView.swift, vibes/Services/TicketmasterService.swift (new), vibes/ViewModels/DiscoverViewModel.swift, vibes/Views/ConcertSettingsView.swift (new)
- **Requested**: Add feature to show upcoming concerts near the user for their top 10-20 Spotify artists. Use Ticketmaster API to search for events. Display concerts on the Discover page with date, venue, and ticket link.
- **Context**: Helps users discover live music from artists they already love
- **Acceptance Criteria**:
  - [x] Create TicketmasterService to fetch events
  - [x] Get user's top artists from Spotify
  - [x] Search for concerts near user's location
  - [x] Filter by upcoming events (60 days ahead)
  - [x] Display concerts section on Discover page
  - [x] Include venue, date, and link to buy tickets
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created TicketmasterService.swift with Ticketmaster Discovery API integration. Added Ticketmaster API key storage to KeychainManager. Created ConcertSettingsView for API key and city configuration. Added concertsSection to DiscoverView with ConcertCard for horizontal scrolling. Added loadUpcomingConcerts() to DiscoverViewModel that searches for concerts from user's top 20 Spotify artists. Added concertFeaturesSection to ProfileView settings.

### 120. Code cleanup - Split ProfileView and DiscoverView
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ProfileView.swift, vibes/Views/DiscoverView.swift, vibes/Views/Components/
- **Requested**: Code cleanup - split large view files into smaller, more maintainable pieces
- **Context**: ProfileView was 1305 lines, DiscoverView was 1207 lines - both containing many helper views
- **Acceptance Criteria**:
  - [x] Extract ProfileView helper views (TopArtistCell, TopTrackRow, RecentlyPlayedCell)
  - [x] Extract DiscoverView helper views (ConcertCard, BlendFriendCard, RecentlyActiveFriendCard, NewReleaseCard, RecommendationRow, TrendingSongRow, AIRecommendationRow)
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created ProfileHelperViews.swift (328 lines) and DiscoverHelperViews.swift (679 lines). ProfileView reduced from 1305 to 986 lines. DiscoverView reduced from 1207 to 531 lines.

### 121. Code cleanup - Split SearchView
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/SearchView.swift, vibes/Views/Components/SearchHelperViews.swift
- **Requested**: Code cleanup - split SearchView helper views into separate file
- **Context**: SearchView was 802 lines with helper row views mixed in
- **Acceptance Criteria**:
  - [x] Extract TrackRow, ArtistRow, AlbumRow, PlaylistRow, SoundWaveBar
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created SearchHelperViews.swift (439 lines). SearchView reduced from 802 to 371 lines (54% reduction).

### 122. Account creation fails with "missing or insufficient permissions"
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/AuthManager.swift:71-95
- **Requested**: When trying to create a new account, user sees "missing or insufficient permissions" error
- **Context**: Firestore username check query ran before user was created, but rules require authentication to read users collection
- **Acceptance Criteria**:
  - [x] Identify exact error message causing confusion
  - [x] Fix authentication order issue
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Reordered signUp to create Firebase Auth user first (so we're authenticated), then check username availability. If username is taken, delete the auth user and throw error.

### 123. Replay Tutorial shows wrong tab selected
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/ProfileView.swift:347-350, vibes/ContentView.swift:58
- **Requested**: When replaying tutorial from Settings, after tutorial completes, content shows Discover but tab bar still shows Settings selected
- **Context**: selectedTab wasn't being reset when tutorial was triggered, causing mismatch between scroll position and tab bar
- **Acceptance Criteria**:
  - [x] Pass selectedTab binding to ProfileView
  - [x] Reset selectedTab to 0 when replaying tutorial
  - [x] Build and test
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added selectedTab binding to ProfileView, set selectedTab = 0 before setting hasCompletedTutorial = false in replay button.

## Task Statistics
- Total Tasks: 123
- Completed: 113
- Removed: 2
- Abandoned: 1
- In Progress: 0
- Pending: 0

---

Older completed tasks (1-80) have been archived to docs/.archive/tasks-2025-01.md
