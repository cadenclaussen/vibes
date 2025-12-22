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

## Task Statistics
- Total Tasks: 102
- Completed: 97
- Removed: 2
- Abandoned: 1
- In Progress: 1
- Pending: 0

---

Older completed tasks (1-80) have been archived to docs/.archive/tasks-2025-01.md
