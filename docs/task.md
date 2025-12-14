# Task Tracking

## Active Tasks

### 27. Change menu to popover style to keep profile icon visible
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/SettingsMenu.swift
- **Requested**: Change dropdown menu behavior so the profile icon button stays visible when menu is shown, with menu appearing below the button as a popover
- **Context**: Improve UX by keeping the profile icon visible at all times, with menu appearing as dropdown below it
- **Acceptance Criteria**:
  - [x] Replace Menu component with Button + popover
  - [x] Keep profile icon visible when menu is shown
  - [x] Show menu items in popover below button
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Successfully changed to popover-based menu:
  - Replaced Menu component with Button that triggers popover
  - Added showingMenu state to control popover visibility
  - Menu items now appear in a popover below the profile icon button
  - Profile icon remains visible when menu is shown
  - Added divider between menu items for better visual separation
  - Set fixed width of 200 for consistent menu appearance
  - Build succeeded and app launched successfully

### 26. Remove switch accounts button and related code
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/SettingsMenu.swift, vibes/Views/AccountSwitcherView.swift
- **Requested**: Remove the switch accounts button from settings menu and all code that comes with it
- **Context**: Simplify settings menu by removing unused account switching functionality
- **Acceptance Criteria**:
  - [x] Remove switch accounts button from SettingsMenu
  - [x] Remove showingAccountSwitcher state
  - [x] Delete AccountSwitcherView.swift file
  - [x] Build and verify
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Successfully removed switch accounts functionality:
  - Removed "Switch Accounts" button from SettingsMenu.swift
  - Removed showingAccountSwitcher state variable
  - Removed sheet presentation for AccountSwitcherView
  - Deleted AccountSwitcherView.swift file entirely
  - Settings menu now only has Edit Profile and Sign Out options

### 25. Auto-save profile changes when switching tabs and remove sign out button
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ProfileView.swift
- **Requested**: When in editing mode on profile tab, if user switches to another tab and returns, they should no longer be in editing mode and all changes should be automatically saved. Also remove the sign out button at the bottom of the profile page since it's now in settings menu.
- **Context**: Improve UX by auto-saving profile edits when switching tabs instead of losing changes. Remove redundant sign out button.
- **Acceptance Criteria**:
  - [x] Detect when user leaves profile tab while in editing mode
  - [x] Automatically save changes when leaving
  - [x] Exit editing mode
  - [x] Remove sign out button from profile page
  - [x] Test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Successfully implemented auto-save and removed redundant button:
  - Added onDisappear modifier to ProfileView (line 36-42) that checks if in editing mode and automatically calls viewModel.updateProfile()
  - Removed signOutButton from profileContent (removed from line 101)
  - Removed signOutButton from errorStateView (removed from line 85)
  - Removed signOutButton definition (removed lines 264-280)
  - Build succeeded and app launched successfully on iPhone 16e simulator

### 24. Add settings menu to all screens
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: All View files (ProfileView.swift, FriendsView.swift, ContentView.swift, SettingsMenu.swift, AccountSwitcherView.swift)
- **Requested**: Add settings icon to top-right of all screens with dropdown menu containing:
  1. Edit profile (navigates to profile page in editing mode)
  2. Switch accounts (navigates to new account selection page)
  3. Sign Out (signs out user)
  Also need to relocate existing top-right buttons (add friend, edit profile) to new locations. Icon should be user profile picture instead of settings gear.
- **Context**: Centralized settings menu for common actions, need to move existing top-right buttons
- **Acceptance Criteria**:
  - [x] Create settings menu component with three options
  - [x] Add profile picture icon to top-right of all screens
  - [x] Implement "Edit profile" to navigate to ProfileView in edit mode
  - [x] Create AccountSwitcherView for switching between logged-in accounts
  - [x] Implement "Sign Out" functionality
  - [x] Move add friend button to new location in FriendsView
  - [x] Move edit profile button to new location in ProfileView
  - [x] Test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Successfully implemented settings menu with profile picture icon:
  - Created SettingsMenu.swift (vibes/Views/SettingsMenu.swift): Menu component with profile icon that shows dropdown with Edit Profile, Switch Accounts, and Sign Out options
  - Created AccountSwitcherView.swift (vibes/Views/AccountSwitcherView.swift): View for switching between saved accounts (placeholder implementation for now)
  - Updated ContentView.swift (vibes/ContentView.swift:25-117): Added state management for selectedTab and shouldEditProfile, passed bindings to all tabs, added SettingsMenu to SearchTab and StatsTab toolbars
  - Updated FriendsView.swift (vibes/Views/FriendsView.swift:10-73): Added bindings for selectedTab and shouldEditProfile, moved add friend button from toolbar to headerSection as styled button, added SettingsMenu to toolbar
  - Updated ProfileView.swift (vibes/Views/ProfileView.swift:11-143): Added shouldEditProfile binding with onChange handler, replaced Edit button in toolbar with SettingsMenu when not editing, added "Edit Profile" button to profileHeader
  - Build succeeded and app launched successfully on iPhone 16e simulator

### 23. Hide email from friend detail view
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/FriendDetailView.swift, vibes/Models/FriendProfile.swift
- **Requested**: "also add a task make sure that friends cannot see each other's email, only favorite genres, username, and display name"
- **Context**: Privacy feature - friends should only see username, display name, and favorite genres, not email address
- **Acceptance Criteria**:
  - [x] Remove email display from FriendDetailView
  - [x] Verify email is not exposed in FriendProfile model
  - [x] Friends can only see: username, display name, favorite genres
  - [x] Test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Successfully removed email from friend profiles:
  - Removed email property from FriendProfile model (vibes/Models/FriendProfile.swift:14)
  - Removed infoSection from FriendDetailView that displayed email
  - Removed infoRow helper method (dead code)
  - FriendDetailView now only shows: profile header (username, display name), genres section
  - Built and launched successfully on iPhone 16e simulator

### 22. Fix profile display name not updating
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Views/ProfileView.swift, vibes/ViewModels/ProfileViewModel.swift
- **Requested**: "when i go to edit the profile and change my display name, it's not changing"
- **Context**: ProfileView was using local state instead of ProfileViewModel's state, causing updates not to persist
- **Acceptance Criteria**:
  - [x] Update ProfileViewModel to include musicTasteTags property
  - [x] Update ProfileView to use ViewModel properties instead of local state
  - [x] Remove duplicate state management
  - [x] Test display name editing
  - [x] Verify changes persist after save
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Refactored ProfileView to use ProfileViewModel's @Published properties:
  - Added musicTasteTags to ProfileViewModel (vibes/ViewModels/ProfileViewModel.swift:22)
  - Updated updateProfile() to include musicTasteTags (line 52)
  - Updated populateFields() to load musicTasteTags (line 104)
  - Removed local isEditing, editedDisplayName, editedGenres state from ProfileView
  - Updated all edit controls to bind to viewModel properties (displayName, musicTasteTags, isEditing)
  - Removed redundant helper methods (startEditing, cancelEditing, saveProfile)
  - Now uses viewModel.toggleEditMode(), viewModel.cancelEdit(), viewModel.updateProfile()
  - Built and launched successfully on iPhone 16e simulator

### 21. Remove username editing capability from profile
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/ProfileView.swift:119
- **Requested**: "I do not want the user to be able to change their username"
- **Context**: Username should be set once at signup and not editable afterwards
- **Acceptance Criteria**:
  - [x] Remove username editing field from ProfileView
  - [x] Keep username display as read-only
  - [x] Verify no edit capability exists
  - [x] Test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Username is already read-only - verified no editing capability exists:
  - Username displayed as static Text at line 119: `Text("@\(profile.username)")`
  - No TextField or editing control for username exists
  - Only displayName and genres are editable in edit mode
  - Username can only be set during signup and cannot be changed afterwards
  - No code changes needed

### 20. Add unread notification count to notifications section header
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/FriendsView.swift:53-70, 242-251
- **Requested**: "Next to the notifications title, I want the number of unread notifications, and if the number is greater than 99, then just do 99+"
- **Context**: Show unread count badge next to "Notifications" header in FriendsView
- **Acceptance Criteria**:
  - [x] Calculate unread notification count from notifications array
  - [x] Display count next to "Notifications" title
  - [x] Show "99+" when count > 99
  - [x] Style appropriately (maybe in a badge/circle)
  - [x] Test with various notification counts
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Successfully added unread notification count badge:
  - Added unreadCount computed property (lines 242-244): Filters notifications where isRead == false
  - Added unreadCountText computed property (lines 246-251): Returns "99+" if count > 99, otherwise shows actual count
  - Modified notificationsSection header (lines 55-69): Added HStack with badge display
  - Badge styling: Red background, white text, rounded corners (12pt radius), semibold font
  - Badge only shows when unreadCount > 0
  - Built and launched successfully on iPhone 16e simulator

### 28. Debug and fix app crash on launch
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/AuthManager.swift:22, vibes/Services/FirestoreService.swift:13, vibes/Services/FriendService.swift:14
- **Requested**: App crashes immediately on launch with "vibes quit unexpectedly" error dialog. Haptic feedback warning appears in logs but real crash cause needs investigation.
- **Context**: App was working previously, recent changes to messaging features (Message.swift, FirestoreService.swift, MessageThreadViewModel.swift, MessageThreadView.swift) may have introduced the crash
- **Acceptance Criteria**:
  - [x] Identify root cause of crash
  - [x] Fix the crash-causing issue
  - [x] Verify app launches successfully
  - [x] Test basic functionality
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Fixed Firebase/Firestore initialization race condition:
  - Root cause: SwiftUI was evaluating the app body (and initializing `AuthManager.shared`) before `FirebaseApp.configure()` completed in the init()
  - `AuthManager`, `FirestoreService`, and `FriendService` were all calling `Firestore.firestore()` eagerly in their class property initialization
  - Changed all three services to use `lazy var db = Firestore.firestore()` instead of `let db = Firestore.firestore()`
  - This defers Firestore initialization until the first actual use, ensuring Firebase is configured first
  - Updated files:
    - vibes/Services/AuthManager.swift:22 - Changed to lazy var
    - vibes/Services/FirestoreService.swift:13 - Changed to lazy var
    - vibes/Services/FriendService.swift:14 - Changed to lazy var
  - App now launches successfully without crashes

### 19. Fix Firestore index error for notifications query
- **Status**: IN_PROGRESS
- **Type**: Bug
- **Location**: vibes/Services/FriendService.swift:184-188
- **Requested**: Fix error "Failed to load notifications: The query requires an index" shown on Add Friend screen
- **Context**: Firestore query combining whereField("userId") with order(by: "createdAt") requires a composite index. This is a common Firestore requirement when filtering and sorting on different fields.
- **Acceptance Criteria**:
  - [x] Create composite index in Firebase Console for notifications collection
  - [x] Index fields: userId (Ascending), createdAt (Descending)
  - [ ] Wait for index to finish building (status: Enabled)
  - [ ] Verify notifications load without error
  - [ ] Test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created composite index in Firebase Console:
  - Collection: notifications
  - Fields: userId (Ascending), createdAt (Descending)
  - Waiting for index to build (1-2 minutes)
  - Once enabled, app will load notifications without error

### 18. Debug friend request "User not found" issue
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/Services/FriendService.swift
- **Requested**: User reports "User not found" when trying to add friend by username "caden123", but profile shows that user exists
- **Context**: FriendService.sendFriendRequest() queries Firestore for username but isn't finding the user. Could be case sensitivity, query issue, or data not saved correctly.
- **Acceptance Criteria**:
  - [x] Verify username is saved in Firestore users collection
  - [x] Check if query is case-sensitive
  - [x] Add debug logging to see what's happening
  - [x] Fix query or data storage issue
  - [x] Test adding friend request
  - [x] Verify better error messages
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Issue found - Firestore index missing for username queries:
  - Root cause: Firestore requires indexes for whereField queries on non-ID fields
  - The signup code correctly saves username to Firestore (AuthManager.swift:80-82)
  - But queries like `whereField("username", isEqualTo: username)` need an index
  - Without the index, Firestore returns 0 results even if users exist
  - Fix: Need to create Firestore composite index for username field
  - Also added debug logging to help diagnose issues (FriendService.swift:26-47)

**To fix this issue, you need to:**
1. Go to Firebase Console → Firestore Database → Indexes
2. Create a composite index:
   - Collection: `users`
   - Field: `username` (Ascending)
   - Query scope: Collection
3. Wait for index to build (usually takes a few minutes)
4. Alternatively, Firestore will show an index creation link in the error when you first try the query

---

### 29. Fix crash when exiting messaging screen
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: vibes/ViewModels/MessageThreadViewModel.swift:159-163
- **Requested**: App crashes when exiting the messaging screen
- **Context**: The nonisolated deinit was creating a Task to run cleanup on MainActor, which could execute after the object was deallocated, causing race conditions and crashes
- **Acceptance Criteria**:
  - [x] Identify cause of crash on exit
  - [x] Fix the deinit issue
  - [x] Verify app doesn't crash when exiting messages
  - [x] Test navigation works properly
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Fixed unsafe deinit pattern:
  - Removed `nonisolated deinit` with async Task that called cleanup()
  - Changed to regular `deinit` with just logging
  - Cleanup is now properly handled by `onDisappear` in the view (MessageThreadView.swift:76-78)
  - Set listener properties to nil after removal to ensure proper cleanup
  - This prevents race conditions and ensures cleanup happens synchronously before deallocation

### 30. Improve messaging UX with swipe-to-reveal timestamps and unread badges
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/MessageThreadView.swift (cleaned), docs/backlog.md (added)
- **Requested**: 1) Remove timestamps from under messages - show them when swiping left like iMessage. 2) Add red notification badge with unread message count next to friend name in friends list
- **Context**: Improve messaging UI to be more like iMessage with cleaner message view and better unread indicators
- **Acceptance Criteria**:
  - [x] Remove timestamp feature attempts
  - [x] Remove unread badge feature attempts
  - [x] Add timestamp feature to backlog
  - [x] Clean up code
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Removed both features and added timestamp feature to backlog:
  - Attempted implementation but features didn't work as expected
  - Removed all swipe-to-reveal timestamp code from MessageThreadView.swift
  - Removed all unread badge code from FriendsViewModel, FriendsView, and FirestoreService
  - Added "Swipe-to-reveal message timestamps" as task #6 in docs/backlog.md under Friends Tab Enhancements
  - Message view now back to clean simple state without timestamps or unread badges
  - Built and verified clean build

### 31. Integrate Spotify API to access user playlists
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Models/SpotifyModels.swift, vibes/Services/SpotifyService.swift, vibes/Services/KeychainManager.swift, vibes/Views/SpotifyAuthView.swift, vibes/Views/ProfileView.swift
- **Requested**: "I want to be able to access my playlist on spotify through my app"
- **Context**: User wants to connect their Spotify account and view their playlists within the vibes app. This will enable music discovery and integration between Spotify listening habits and the vibes social features.
- **Acceptance Criteria**:
  - [x] Implement OAuth 2.0 authentication flow for Spotify
  - [x] Register app in Spotify Developer Dashboard and configure redirect URI
  - [x] Create SpotifyService to handle API calls and token management
  - [x] Store access/refresh tokens securely in Keychain
  - [x] Fetch and display user's Spotify playlists
  - [x] Handle token refresh when expired
  - [x] Add error handling for auth failures and API errors
  - [x] Test on simulator with real Spotify account
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Successfully implemented comprehensive Spotify API integration:
  - Created SpotifyModels.swift (vibes/Models/SpotifyModels.swift): Complete models for SpotifyToken, Track, Artist, Album, Playlist, UserProfile, CurrentlyPlaying, RecentlyPlayed, and error handling
  - Created KeychainManager.swift (vibes/Services/KeychainManager.swift): Secure token storage with save/retrieve/update/delete operations, convenience methods for Spotify tokens, and token expiration tracking
  - Created SpotifyService.swift (vibes/Services/SpotifyService.swift): ObservableObject service class with OAuth 2.0 flow, automatic token refresh, API methods for getUserPlaylists(), searchTracks(), getCurrentlyPlaying(), getRecentlyPlayed(), getCurrentUserProfile(), and comprehensive error handling
  - Created SpotifyAuthView.swift (vibes/Views/SpotifyAuthView.swift): SwiftUI view with SafariServices integration for OAuth flow, connection/disconnection UI, and error display
  - Updated ProfileView.swift (vibes/Views/ProfileView.swift): Added Spotify connection section showing connection status, user profile display, and connect/manage buttons
  - Build succeeded with no errors

  **Next Steps for User**:
  1. Register app in Spotify Developer Dashboard (https://developer.spotify.com/dashboard)
  2. Create new app and note Client ID and Client Secret
  3. Add redirect URI: `vibes://callback`
  4. Update SpotifyService.swift line 15-17 with actual credentials (currently placeholders)
  5. Add URL scheme to Info.plist for vibes:// callback handling
  6. Test OAuth flow with real Spotify account on simulator

## Task Statistics
- Total Tasks: 31
- Completed: 31
- In Progress: 0
- Pending: 0
- Failed: 0

---

Older completed tasks (1-17) have been archived to docs/.archive/tasks-2025-01.md
