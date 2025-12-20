# Task Tracking

## Active Tasks

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
- **Context**: User wants to connect their Spotify account and view their playlists within the vibes app.
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
- **Solution**: Successfully implemented comprehensive Spotify API integration with OAuth 2.0 flow, Keychain token storage, and API methods for playlists, search, and playback status.

### 32. Implement Spotify song search in Search tab
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/SearchView.swift, vibes/ViewModels/SearchViewModel.swift, vibes/ContentView.swift
- **Requested**: Implement the search tab to search for songs and music from Spotify
- **Context**: SearchTab currently shows placeholder "Under Construction". SpotifyService already has searchTracks() method.
- **Acceptance Criteria**:
  - [x] Create SearchView with search bar
  - [x] Display search results with album art, track name, artist
  - [x] Handle loading and error states
  - [x] Handle case when Spotify not connected
  - [x] Replace placeholder SearchTab with actual implementation
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created SearchViewModel.swift and SearchView.swift with debounced search, results list, and Spotify connection handling.

### 33. Implement AVPlayer song preview in search results
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Services/AudioPlayerService.swift, vibes/Views/SearchView.swift
- **Requested**: Implement tap-to-play 30-second song previews using AVPlayer when users tap on search results
- **Context**: Spotify provides previewUrl on Track objects. Need AudioPlayerService singleton to manage playback.
- **Acceptance Criteria**:
  - [x] Create AudioPlayerService singleton with AVPlayer
  - [x] Handle play/pause/stop and track switching
  - [x] Update TrackRow to show play/pause overlay on album art
  - [x] Add sound wave animation for playing tracks
  - [x] Show indicator for tracks without preview
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created AudioPlayerService.swift with AVPlayer, iTunesService.swift for fallback previews, and SoundWaveBar animation component.

### 34. Send songs from search to friends with playable previews in DMs
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/SearchView.swift, vibes/Views/MessageThreadView.swift, vibes/Views/FriendPickerView.swift
- **Requested**: User wants to send songs from search results to friends, have the song appear in DMs, and allow friends to play the song preview directly
- **Context**: SearchView has song search with preview playback. Message model already supports song messages.
- **Acceptance Criteria**:
  - [x] Add "Send to Friend" action on search result tracks
  - [x] Show friend picker sheet when sending a song
  - [x] Send song as message to selected friend's DM thread
  - [x] Make play button functional in SongMessageBubbleView
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added send button to TrackRow, created FriendPickerView.swift, and connected SongMessageBubbleView to AudioPlayerService.

### 37. Implement group chats
- **Status**: DEFERRED
- **Type**: Feature
- **Location**: N/A (moved to backlog)
- **Requested**: Add group chat functionality with a new Chats tab replacing Friends tab
- **Context**: Enable users to create group conversations, send messages to multiple friends at once
- **Acceptance Criteria**:
  - [x] Create ChatsView (replaces FriendsView as tab) - kept for DMs
  - [x] Create ChatRowView for conversation list - kept for DMs
  - [ ] Group chat features - moved to backlog task #19
- **Failure Count**: 1
- **Failures**: Groups were creating but disappearing from the list due to Firestore composite index requirement
- **Solution**: Removed group chat features, kept Chats tab for DM conversations only. Group chats added to backlog as task #19 for future implementation with proper Firestore index setup.

### 36. Implement vibestreaks tracking
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Multiple files
- **Requested**: Implement vibestreaks - daily engagement tracking between friends with streak counters
- **Context**: Gamification feature to encourage daily music sharing between friends
- **Acceptance Criteria**:
  - [x] Add vibestreak to FriendProfile model
  - [x] Update FriendService to fetch vibestreak data with friends
  - [x] Display streak count (fire emoji) next to friends in friends list
  - [x] Calculate streak logic: both users must interact daily to maintain streak
  - [x] Increment streak when both users interact on consecutive days
  - [x] Reset streak to 0 when a day is missed
  - [x] Load vibestreak in MessageThreadViewModel
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented complete vibestreak system:
  - **FriendProfile.swift**: Added vibestreak and friendshipId fields
  - **Friendship.swift**: Added user1LastInteraction, user2LastInteraction, streakLastUpdated fields
  - **FriendService.swift**: Updated fetchFriends() to include vibestreak data from Friendship
  - **FriendsView.swift**: Added fire emoji with streak count next to friends in list
  - **FirestoreService.swift**: Added updateVibestreak() logic - tracks per-user interactions, increments streak when both users interact on consecutive days, resets if day missed, creates milestone notifications at 7/30/100/365 days
  - **MessageThreadViewModel.swift**: Added loadVibestreak() to fetch and listen to streak updates in real-time
  - Build succeeded on iPhone 16e simulator

### 35. Send messages with Return/Enter key
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: vibes/Views/MessageThreadView.swift:272-280
- **Requested**: Allow users to send messages by pressing Return/Enter instead of clicking the send button
- **Context**: Improves messaging UX by enabling faster message sending with keyboard (from backlog task #7)
- **Acceptance Criteria**:
  - [x] Add onSubmit handler to TextField in message input
  - [x] Add .submitLabel(.send) to show "Send" on keyboard
  - [x] Keep send button as alternative method
  - [x] Prevent sending empty messages (already implemented)
  - [x] Build and test on simulator
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Updated MessageInputBar in MessageThreadView.swift:
  - Changed TextField to single-line (removed axis: .vertical and lineLimit)
  - Added `.submitLabel(.send)` to show "Send" on the iOS keyboard return key
  - Added `.onSubmit` handler that calls onSend() when Return is pressed
  - Only sends if canSend is true (non-empty message) and not currently sending
  - Send button remains as alternative method
  - Build succeeded on iPhone 16e simulator

## Task Statistics
- Total Tasks: 37
- Completed: 36
- Deferred: 1
- In Progress: 0
- Pending: 0
- Failed: 0

---

Older completed tasks (1-29) have been archived to docs/.archive/tasks-2025-01.md
