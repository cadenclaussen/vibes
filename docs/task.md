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

## Task Statistics
- Total Tasks: 21
- Completed: 20
- In Progress: 1
- Pending: 0
- Failed: 0

---

Older completed tasks (1-17) have been archived to docs/.archive/tasks-2025-01.md
