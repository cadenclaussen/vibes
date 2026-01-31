# Music Collaboration - Implementation Tasks

## Phase 1: Data Layer & Service

### Task 1.1: Create SocialService
- **File**: `vibes/Services/SocialService.swift`
- **Requirements**: FR-1, FR-2, FR-3, FR-4, FR-5, FR-7
- **Description**: Create the core service for all social operations
- **Subtasks**:
  - [ ] Create SocialService class with Firestore reference
  - [ ] Implement `searchUsers(query:)` with case-insensitive matching
  - [ ] Implement `follow(userId:)` - create Friendship document
  - [ ] Implement `unfollow(userId:)` - delete Friendship document
  - [ ] Implement `isFollowing(userId:)` - check if friendship exists
  - [ ] Implement `getFollowers(for:)` - query friendships where followingId matches
  - [ ] Implement `getFollowing(for:)` - query friendships where followerId matches
  - [ ] Implement `getFollowerCount(for:)` and `getFollowingCount(for:)`
  - [ ] Implement `shareSong(_:to:message:)` - create SongShare documents
  - [ ] Implement `getSharesFromFollowing(limit:)` - get shares from people user follows
- **Dependencies**: None
- **Estimated Complexity**: Medium

### Task 1.2: Create Firestore Indexes
- **File**: `firestore.indexes.json` or Firebase Console
- **Requirements**: NFR-1
- **Description**: Create composite indexes for efficient queries
- **Subtasks**:
  - [ ] Index: friendships (followerId ASC, createdAt DESC)
  - [ ] Index: friendships (followingId ASC, createdAt DESC)
  - [ ] Index: songShares (senderId ASC, timestamp DESC)
- **Dependencies**: None
- **Estimated Complexity**: Low

## Phase 2: Following System UI

### Task 2.1: Create UserSearchViewModel
- **File**: `vibes/ViewModels/UserSearchViewModel.swift`
- **Requirements**: FR-1
- **Description**: ViewModel for user search with debouncing
- **Subtasks**:
  - [ ] Create @Observable class with searchQuery, results, isLoading, error
  - [ ] Implement debounced search (300ms delay)
  - [ ] Cancel previous search when new query entered
  - [ ] Track follow state for each result
  - [ ] Implement follow/unfollow methods
- **Dependencies**: Task 1.1
- **Estimated Complexity**: Low

### Task 2.2: Create UserSearchView and UserSearchRow
- **Files**: `vibes/Views/Social/UserSearchView.swift`, `vibes/Views/Social/UserSearchRow.swift`
- **Requirements**: FR-1, FR-2, FR-3
- **Description**: Sheet for finding and following users
- **Subtasks**:
  - [ ] Create UserSearchRow with profile pic, name, username, follow button
  - [ ] Create UserSearchView with search field and results list
  - [ ] Add empty state for no results
  - [ ] Add loading indicator
  - [ ] Follow button shows loading state during operation
  - [ ] Follow button toggles between "Follow" and "Following"
- **Dependencies**: Task 2.1
- **Estimated Complexity**: Medium

### Task 2.3: Create FollowViewModel
- **File**: `vibes/ViewModels/FollowViewModel.swift`
- **Requirements**: FR-4, FR-5
- **Description**: ViewModel for followers/following lists
- **Subtasks**:
  - [ ] Create @Observable class with mode (followers/following), users array
  - [ ] Implement load() to fetch appropriate list
  - [ ] Implement refresh() for pull-to-refresh
  - [ ] Track follow state for each user
  - [ ] Implement follow/unfollow methods
- **Dependencies**: Task 1.1
- **Estimated Complexity**: Low

### Task 2.4: Create FollowListView
- **File**: `vibes/Views/Social/FollowListView.swift`
- **Requirements**: FR-4, FR-5
- **Description**: View for displaying followers or following list
- **Subtasks**:
  - [ ] Create list view using UserSearchRow
  - [ ] Add navigation title based on mode ("Followers" or "Following")
  - [ ] Show count in title
  - [ ] Add pull-to-refresh
  - [ ] Add empty state
  - [ ] Tap row navigates to user profile
- **Dependencies**: Task 2.2, Task 2.3
- **Estimated Complexity**: Low

### Task 2.5: Update ProfileView with Follow Counts
- **File**: `vibes/Views/Profile/ProfileView.swift`
- **Requirements**: FR-6
- **Description**: Add follower/following counts to profile header
- **Subtasks**:
  - [ ] Add follower count display
  - [ ] Add following count display
  - [ ] Make counts tappable
  - [ ] Navigate to FollowListView on tap
  - [ ] Load counts on appear
- **Dependencies**: Task 2.4
- **Estimated Complexity**: Low

### Task 2.6: Create UserProfileView
- **File**: `vibes/Views/Social/UserProfileView.swift`
- **Requirements**: FR-2, FR-3, FR-6
- **Description**: View for viewing another user's profile
- **Subtasks**:
  - [ ] Create profile header with picture, name, username
  - [ ] Show follower/following counts
  - [ ] Add follow/unfollow button
  - [ ] Show user's stats if public (optional)
  - [ ] Navigate to followers/following lists
- **Dependencies**: Task 2.4, Task 1.1
- **Estimated Complexity**: Medium

### Task 2.7: Update AppRouter for Social Navigation
- **File**: `vibes/Services/AppRouter.swift`
- **Requirements**: FR-4, FR-5
- **Description**: Add navigation destinations for social features
- **Subtasks**:
  - [ ] Add SocialDestination enum (userProfile, followers, following)
  - [ ] Add navigateToFollowers(for:) method
  - [ ] Add navigateToFollowing(for:) method
  - [ ] Update Sheet enum with findUsers case
  - [ ] Add presentFindUsers() method
- **Dependencies**: None
- **Estimated Complexity**: Low

### Task 2.8: Add "Find People" Entry Point
- **File**: `vibes/Views/Feed/FeedView.swift` or `vibes/Views/Profile/ProfileView.swift`
- **Requirements**: FR-1
- **Description**: Add button to open user search
- **Subtasks**:
  - [ ] Add "Find People" button to Feed or Profile
  - [ ] Present UserSearchView as sheet
  - [ ] Wire up through AppRouter
- **Dependencies**: Task 2.2, Task 2.7
- **Estimated Complexity**: Low

## Phase 3: Song Sharing

### Task 3.1: Create ShareViewModel
- **File**: `vibes/ViewModels/ShareViewModel.swift`
- **Requirements**: FR-7, FR-8
- **Description**: ViewModel for sharing songs
- **Subtasks**:
  - [ ] Create @Observable class with following list, selectedUserIds, message
  - [ ] Load user's following list on init
  - [ ] Implement toggleSelection() for multi-select
  - [ ] Implement send() to share to selected users
  - [ ] Track sending state
- **Dependencies**: Task 1.1
- **Estimated Complexity**: Low

### Task 3.2: Create ShareSheetView
- **File**: `vibes/Views/Social/ShareSheetView.swift`
- **Requirements**: FR-7, FR-8
- **Description**: Sheet for sharing a song to followers
- **Subtasks**:
  - [ ] Show track info (art, name, artist)
  - [ ] Add optional message text field (140 char limit)
  - [ ] Show following list with checkboxes
  - [ ] Add "Send" button with selection count
  - [ ] Show success toast and dismiss
  - [ ] Handle empty following list state
- **Dependencies**: Task 3.1
- **Estimated Complexity**: Medium

### Task 3.3: Add Share Button to NowPlayingView
- **File**: `vibes/Views/NowPlaying/NowPlayingView.swift`
- **Requirements**: FR-7
- **Description**: Add share action to Now Playing
- **Subtasks**:
  - [ ] Add share button (arrow.up.circle or square.and.arrow.up)
  - [ ] Position in action row below track info
  - [ ] Present ShareSheetView on tap
  - [ ] Pass current track to sheet
- **Dependencies**: Task 3.2
- **Estimated Complexity**: Low

### Task 3.4: Add Share to Search Context Menu
- **File**: `vibes/Views/Search/SongSearchRow.swift`
- **Requirements**: FR-8
- **Description**: Add share option to long-press menu
- **Subtasks**:
  - [ ] Add "Share" option to existing context menu
  - [ ] Present ShareSheetView with selected track
  - [ ] Use SF Symbol "square.and.arrow.up"
- **Dependencies**: Task 3.2
- **Estimated Complexity**: Low

## Phase 4: Activity Feed

### Task 4.1: Create SongShareCard
- **File**: `vibes/Views/Social/SongShareCard.swift`
- **Requirements**: FR-9, FR-10
- **Description**: Card component for displaying a song share
- **Subtasks**:
  - [ ] Show sender profile pic and username
  - [ ] Show relative timestamp ("2h ago")
  - [ ] Show optional message
  - [ ] Show track art, name, artist
  - [ ] Add play button
  - [ ] Tap plays song via SpotifyRemoteService
- **Dependencies**: None
- **Estimated Complexity**: Medium

### Task 4.2: Update FeedView with Song Shares
- **File**: `vibes/Views/Feed/FeedView.swift`
- **Requirements**: FR-10, FR-11
- **Description**: Integrate song shares into the feed
- **Subtasks**:
  - [ ] Add songShares array to view state or ViewModel
  - [ ] Load shares from SocialService.getSharesFromFollowing()
  - [ ] Display SongShareCards in feed
  - [ ] Add pull-to-refresh
  - [ ] Add empty state when no shares
  - [ ] Mix with existing feed content or create dedicated section
- **Dependencies**: Task 4.1, Task 1.1
- **Estimated Complexity**: Medium

### Task 4.3: Update FeedViewModel
- **File**: `vibes/ViewModels/FeedViewModel.swift`
- **Requirements**: FR-10
- **Description**: Add song share loading to feed
- **Subtasks**:
  - [ ] Add songShares property
  - [ ] Load shares on init/refresh
  - [ ] Implement pagination for older shares
  - [ ] Handle loading and error states
- **Dependencies**: Task 1.1
- **Estimated Complexity**: Low

### Task 4.4: Show "Shared by" in Now Playing (Optional)
- **File**: `vibes/Views/NowPlaying/NowPlayingView.swift`
- **Requirements**: FR-11
- **Description**: Show share context when playing a shared song
- **Subtasks**:
  - [ ] Add sharedBy property to track context
  - [ ] Display "Shared by @username" below track info when applicable
  - [ ] Style subtly (smaller, secondary color)
- **Dependencies**: Task 4.2
- **Estimated Complexity**: Low

## Phase 5: Polish & Edge Cases

### Task 5.1: Add Confirmation for Unfollow
- **File**: `vibes/Views/Social/UserSearchRow.swift`, `vibes/Views/Social/FollowListView.swift`
- **Requirements**: FR-3
- **Description**: Add confirmation dialog before unfollowing
- **Subtasks**:
  - [ ] Add .confirmationDialog when tapping "Following"
  - [ ] Show "Unfollow @username?" message
  - [ ] Only unfollow if confirmed
- **Dependencies**: Task 2.2
- **Estimated Complexity**: Low

### Task 5.2: Add Loading States
- **Requirements**: NFR-1
- **Description**: Ensure all async operations show loading
- **Subtasks**:
  - [ ] Follow button shows spinner during operation
  - [ ] Share send button shows spinner
  - [ ] Feed shows skeleton or spinner on load
  - [ ] Search shows spinner while querying
- **Dependencies**: All UI tasks
- **Estimated Complexity**: Low

### Task 5.3: Handle Offline State
- **Requirements**: NFR-3
- **Description**: Graceful handling when offline
- **Subtasks**:
  - [ ] Show cached feed when offline
  - [ ] Disable follow/share buttons when offline
  - [ ] Show "You're offline" banner
- **Dependencies**: Phase 4
- **Estimated Complexity**: Medium

### Task 5.4: Update use-cases.md
- **File**: `.specs/use-cases.md`
- **Description**: Mark Music Collaboration as complete
- **Subtasks**:
  - [ ] Update status from [ ] to [x]
  - [ ] Check off completed sub-features
- **Dependencies**: All phases complete
- **Estimated Complexity**: Low

## Dependency Graph

```
Phase 1: Data Layer
    Task 1.1 (SocialService) ─────────────────────────────┐
    Task 1.2 (Indexes) ──────────────────────────────────┐│
                                                         ││
Phase 2: Following System                                ││
    Task 2.1 (UserSearchViewModel) ◄─────────────────────┘│
         │                                                │
         ▼                                                │
    Task 2.2 (UserSearchView) ───────────────────────────┐│
         │                                               ││
    Task 2.3 (FollowViewModel) ◄─────────────────────────┼┘
         │                                               │
         ▼                                               │
    Task 2.4 (FollowListView) ◄──────────────────────────┤
         │                                               │
         ├──► Task 2.5 (ProfileView update)              │
         │                                               │
         └──► Task 2.6 (UserProfileView) ◄───────────────┤
                                                         │
    Task 2.7 (AppRouter update) ─────────────────────────┤
         │                                               │
         ▼                                               │
    Task 2.8 (Find People entry) ◄───────────────────────┘

Phase 3: Song Sharing
    Task 3.1 (ShareViewModel) ◄──────────────────────────┐
         │                                               │
         ▼                                               │
    Task 3.2 (ShareSheetView) ───────────────────────────┤
         │                                               │
         ├──► Task 3.3 (NowPlaying share)                │
         │                                               │
         └──► Task 3.4 (Search context menu)             │
                                                         │
Phase 4: Activity Feed                                   │
    Task 4.1 (SongShareCard) ────────────────────────────┤
         │                                               │
         ▼                                               │
    Task 4.2 (FeedView update) ◄─────────────────────────┤
         │                                               │
    Task 4.3 (FeedViewModel update) ◄────────────────────┘
         │
         ▼
    Task 4.4 (Shared by in NowPlaying)

Phase 5: Polish
    Task 5.1 (Unfollow confirm)
    Task 5.2 (Loading states)
    Task 5.3 (Offline handling)
    Task 5.4 (Update use-cases.md)
```

## Implementation Order

1. **Task 1.1** - SocialService (foundation for everything)
2. **Task 1.2** - Firestore indexes (can be done in parallel)
3. **Task 2.7** - AppRouter updates (needed for navigation)
4. **Task 2.1** - UserSearchViewModel
5. **Task 2.2** - UserSearchView + UserSearchRow
6. **Task 2.3** - FollowViewModel
7. **Task 2.4** - FollowListView
8. **Task 2.5** - ProfileView follow counts
9. **Task 2.6** - UserProfileView
10. **Task 2.8** - Find People entry point
11. **Task 3.1** - ShareViewModel
12. **Task 3.2** - ShareSheetView
13. **Task 3.3** - NowPlaying share button
14. **Task 3.4** - Search context menu share
15. **Task 4.1** - SongShareCard
16. **Task 4.2** - FeedView update
17. **Task 4.3** - FeedViewModel update
18. **Task 4.4** - Shared by context (optional)
19. **Task 5.1-5.4** - Polish tasks

## Estimated Total: 19 tasks across 5 phases
