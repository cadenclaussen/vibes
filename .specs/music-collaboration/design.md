# Music Collaboration - Design

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                           Views                                  │
├─────────────────────────────────────────────────────────────────┤
│  UserSearchView    │  FollowListView   │  ShareSheetView        │
│  UserProfileView   │  SongShareCard    │  FriendActivityView    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        ViewModels                                │
├─────────────────────────────────────────────────────────────────┤
│  UserSearchViewModel  │  FollowViewModel  │  ShareViewModel     │
│  FeedViewModel (update)                                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Services                                 │
├─────────────────────────────────────────────────────────────────┤
│  SocialService (new)  │  AuthManager (update)                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Data Layer                                  │
├─────────────────────────────────────────────────────────────────┤
│  Firestore: users, friendships, songShares                      │
│  Existing: Friendship, SongShare, UserProfile models            │
└─────────────────────────────────────────────────────────────────┘
```

## New Files

### Services
- `vibes/Services/SocialService.swift` - Firestore operations for follows and shares

### ViewModels
- `vibes/ViewModels/UserSearchViewModel.swift` - User search with debounce
- `vibes/ViewModels/FollowViewModel.swift` - Follow/unfollow operations
- `vibes/ViewModels/ShareViewModel.swift` - Song sharing operations

### Views
- `vibes/Views/Social/UserSearchView.swift` - Find users sheet
- `vibes/Views/Social/UserSearchRow.swift` - User row with follow button
- `vibes/Views/Social/FollowListView.swift` - Followers/following list
- `vibes/Views/Social/UserProfileView.swift` - View another user's profile
- `vibes/Views/Social/ShareSheetView.swift` - Share song to followers
- `vibes/Views/Social/SongShareCard.swift` - Share card in feed
- `vibes/Views/Social/FriendActivityView.swift` - Currently playing sidebar

### Modified Files
- `vibes/Services/AppRouter.swift` - Add social navigation destinations
- `vibes/Views/Feed/FeedView.swift` - Integrate song shares and friend activity
- `vibes/Views/Profile/ProfileView.swift` - Add follower/following counts
- `vibes/Views/NowPlaying/NowPlayingView.swift` - Add share button
- `vibes/Views/Search/SongSearchRow.swift` - Add share to context menu

## Firestore Schema

### Collections (Existing)

**users/{userId}**
```json
{
  "uid": "string",
  "username": "string",
  "displayName": "string",
  "profilePictureURL": "string?",
  "currentlyPlaying": {
    "trackId": "string",
    "trackName": "string",
    "artistName": "string",
    "albumArtURL": "string",
    "updatedAt": "timestamp"
  }
}
```

**friendships/{friendshipId}**
```json
{
  "followerId": "string",
  "followingId": "string",
  "createdAt": "timestamp",
  "vibestreak": "number",
  "lastInteractionDate": "timestamp?"
}
```

**songShares/{shareId}**
```json
{
  "senderId": "string",
  "senderUsername": "string",
  "senderProfilePicture": "string?",
  "recipientId": "string?",
  "spotifyTrackId": "string",
  "trackName": "string",
  "artistName": "string",
  "albumArtURL": "string",
  "previewURL": "string?",
  "message": "string?",
  "timestamp": "timestamp"
}
```

### Required Indexes

```
friendships: followerId ASC, createdAt DESC
friendships: followingId ASC, createdAt DESC
songShares: recipientId ASC, timestamp DESC
users: username ASC (for search)
```

## UI Mockups

### User Search View (Sheet)

```
┌────────────────────────────────────┐
│  ─────────────────────────────     │  <- Drag indicator
│                                    │
│  Find People                   ✕   │
│  ┌────────────────────────────┐   │
│  │ 🔍 Search by name...       │   │
│  └────────────────────────────┘   │
│                                    │
│  ┌────────────────────────────┐   │
│  │ 🖼 John Smith              │   │
│  │   @johnsmith         Follow │   │
│  └────────────────────────────┘   │
│  ┌────────────────────────────┐   │
│  │ 🖼 Jane Doe                │   │
│  │   @janedoe       Following │   │
│  └────────────────────────────┘   │
│                                    │
└────────────────────────────────────┘
```

### Follow/Following List

```
┌────────────────────────────────────┐
│  ←  Followers (42)                 │
│  ─────────────────────────────────│
│  ┌────────────────────────────┐   │
│  │ 🖼 John Smith              │   │
│  │   @johnsmith         Follow │   │
│  └────────────────────────────┘   │
│  ┌────────────────────────────┐   │
│  │ 🖼 Jane Doe                │   │
│  │   @janedoe       Following │   │
│  └────────────────────────────┘   │
│                                    │
│            Pull to refresh         │
└────────────────────────────────────┘
```

### Share Sheet

```
┌────────────────────────────────────┐
│  ─────────────────────────────     │
│                                    │
│  Share Song                    ✕   │
│                                    │
│  ┌────────────────────────────┐   │
│  │ 🎵 Song Name               │   │
│  │    Artist Name             │   │
│  └────────────────────────────┘   │
│                                    │
│  Add a message (optional)          │
│  ┌────────────────────────────┐   │
│  │ Check out this song!       │   │
│  └────────────────────────────┘   │
│                                    │
│  Send to:                          │
│  ☑ @johnsmith                      │
│  ☐ @janedoe                        │
│  ☐ @musiclover                     │
│                                    │
│  ┌────────────────────────────┐   │
│  │         Send (1)           │   │
│  └────────────────────────────┘   │
└────────────────────────────────────┘
```

### Song Share Card (Feed)

```
┌────────────────────────────────────┐
│  🖼 @johnsmith · 2h ago            │
│     "Check out this song!"         │
│                                    │
│  ┌────────────────────────────┐   │
│  │ 🎵│ Song Name              │ ▶ │
│  │   │ Artist Name            │   │
│  └────────────────────────────┘   │
└────────────────────────────────────┘
```

### Profile Header Update

```
┌────────────────────────────────────┐
│           🖼                       │
│       Display Name                 │
│       @username                    │
│                                    │
│    42 Followers  │  128 Following  │  <- Tappable
│                                    │
└────────────────────────────────────┘
```

### Now Playing with Share Button

```
┌────────────────────────────────────┐
│           ─────                    │
│                                    │
│        ┌──────────┐               │
│        │          │               │
│        │  Album   │               │
│        │   Art    │               │
│        │          │               │
│        └──────────┘               │
│                                    │
│         Song Name                  │
│         Artist Name                │
│                                    │
│    ♡        ⬆ Share        •••    │  <- New share button
│                                    │
│  ════════════════════════════════ │
│                                    │
│    ⟲    ◀◀    ▶    ▶▶    🔀       │
└────────────────────────────────────┘
```

## Component Details

### SocialService

```swift
@Observable
class SocialService {
    static let shared = SocialService()

    // Search
    func searchUsers(query: String) async throws -> [UserProfile]

    // Follow operations
    func follow(userId: String) async throws
    func unfollow(userId: String) async throws
    func isFollowing(userId: String) async throws -> Bool
    func getFollowers(for userId: String) async throws -> [UserProfile]
    func getFollowing(for userId: String) async throws -> [UserProfile]
    func getFollowerCount(for userId: String) async throws -> Int
    func getFollowingCount(for userId: String) async throws -> Int

    // Song sharing
    func shareSong(_ track: UnifiedTrack, to userIds: [String], message: String?) async throws
    func getReceivedShares(limit: Int) async throws -> [SongShare]
    func getSharesFromFollowing(limit: Int) async throws -> [SongShare]

    // Currently playing
    func updateCurrentlyPlaying(_ track: UnifiedTrack?) async throws
    func getFriendsCurrentlyPlaying() async throws -> [(UserProfile, UnifiedTrack)]
}
```

### UserSearchViewModel

```swift
@Observable
class UserSearchViewModel {
    var searchQuery = ""
    var results: [UserProfile] = []
    var isLoading = false
    var error: Error?

    private var searchTask: Task<Void, Never>?

    func search() // Debounced, cancels previous
    func follow(_ user: UserProfile) async
    func unfollow(_ user: UserProfile) async
    func isFollowing(_ user: UserProfile) -> Bool
}
```

### FollowViewModel

```swift
@Observable
class FollowViewModel {
    enum Mode { case followers, following }

    var users: [UserProfile] = []
    var isLoading = false
    var error: Error?

    let mode: Mode
    let userId: String

    func load() async
    func refresh() async
    func follow(_ user: UserProfile) async
    func unfollow(_ user: UserProfile) async
}
```

### ShareViewModel

```swift
@Observable
class ShareViewModel {
    var following: [UserProfile] = []
    var selectedUserIds: Set<String> = []
    var message = ""
    var isLoading = false
    var isSending = false
    var error: Error?

    let track: UnifiedTrack

    func load() async
    func send() async throws
    func toggleSelection(_ user: UserProfile)
}
```

## Navigation Updates

### AppRouter Additions

```swift
// New destinations
enum SocialDestination: Hashable {
    case userProfile(UserProfile)
    case followers(String)  // userId
    case following(String)  // userId
}

// New methods
func navigateToFollowers(for userId: String)
func navigateToFollowing(for userId: String)
func presentShareSheet(for track: UnifiedTrack)
func presentFindUsers()
```

## State Flow

### Follow Flow
```
User taps Follow → Button shows loading →
SocialService.follow() → Firestore creates Friendship →
Button updates to "Following" → Follower count increments
```

### Share Flow
```
User taps Share → Share sheet presents →
User selects recipients → User taps Send →
SocialService.shareSong() → Creates SongShare docs →
Toast confirms success → Sheet dismisses
```

### Feed Load Flow
```
FeedView appears → FeedViewModel.load() →
SocialService.getSharesFromFollowing() →
Firestore query: songShares where senderId in followingIds →
Display SongShareCards in list
```

## Error Handling

| Error | User Message | Action |
|-------|--------------|--------|
| Network failure | "Couldn't connect. Pull to retry." | Show retry option |
| User not found | "This user no longer exists." | Remove from list |
| Already following | (Silent) | Update UI to "Following" |
| Rate limited | "Slow down! Try again shortly." | Disable button temporarily |
| Share failed | "Couldn't send. Tap to retry." | Inline retry button |
