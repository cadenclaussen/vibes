# Music Collaboration - Requirements

## Functional Requirements

### Following System

#### FR-1: User Search
- **Type**: Event-Driven
- **Statement**: When the user enters text in the user search field, the system shall query Firestore for users matching the search term by username or display name.
- **Acceptance Criteria**:
  - [ ] Search field with debounced input (300ms)
  - [ ] Results show profile picture, display name, username
  - [ ] Results update as user types
  - [ ] Empty state shown when no results
  - [ ] Current user excluded from results
- **Priority**: Must
- **Notes**: Leverages existing UserProfile model and Firestore

#### FR-2: Follow User
- **Type**: Event-Driven
- **Statement**: When the user taps the follow button on another user's profile or search result, the system shall create a Friendship document in Firestore with the current user as followerId.
- **Acceptance Criteria**:
  - [ ] Follow button visible on user search results
  - [ ] Follow button visible on user profile views
  - [ ] Button shows loading state during operation
  - [ ] Button changes to "Following" after success
  - [ ] Friendship document created with correct IDs and timestamp
- **Priority**: Must
- **Notes**: Uses existing Friendship model

#### FR-3: Unfollow User
- **Type**: Event-Driven
- **Statement**: When the user taps the "Following" button on a followed user, the system shall delete the corresponding Friendship document from Firestore.
- **Acceptance Criteria**:
  - [ ] Confirmation prompt before unfollowing
  - [ ] Button shows loading state during operation
  - [ ] Button reverts to "Follow" after success
  - [ ] Friendship document deleted from Firestore
- **Priority**: Must

#### FR-4: View Followers List
- **Type**: Event-Driven
- **Statement**: When the user taps on their followers count, the system shall display a list of all users who follow them.
- **Acceptance Criteria**:
  - [ ] List shows profile picture, display name, username
  - [ ] Each row has follow/following button
  - [ ] Tapping a user navigates to their profile
  - [ ] Empty state when no followers
  - [ ] Pull-to-refresh supported
- **Priority**: Must

#### FR-5: View Following List
- **Type**: Event-Driven
- **Statement**: When the user taps on their following count, the system shall display a list of all users they follow.
- **Acceptance Criteria**:
  - [ ] List shows profile picture, display name, username
  - [ ] Each row has "Following" button (tap to unfollow)
  - [ ] Tapping a user navigates to their profile
  - [ ] Empty state when not following anyone
  - [ ] Pull-to-refresh supported
- **Priority**: Must

#### FR-6: Follow Counts on Profile
- **Type**: Ubiquitous
- **Statement**: The system shall display follower and following counts on every user profile.
- **Acceptance Criteria**:
  - [ ] Counts displayed prominently near profile header
  - [ ] Counts are tappable to view lists
  - [ ] Counts update in real-time after follow/unfollow
- **Priority**: Must

### Song Sharing

#### FR-7: Share from Now Playing
- **Type**: Event-Driven
- **Statement**: When the user taps the share button on the Now Playing view, the system shall present a share sheet to select recipients from their following list.
- **Acceptance Criteria**:
  - [ ] Share button visible on Now Playing view
  - [ ] Share sheet shows following list with multi-select
  - [ ] Optional message field (max 140 characters)
  - [ ] Send button creates SongShare documents
  - [ ] Success confirmation shown
  - [ ] Track info auto-populated from current track
- **Priority**: Must
- **Notes**: Uses existing SongShare model

#### FR-8: Share from Search Results
- **Type**: Event-Driven
- **Statement**: When the user long-presses a song in search results, the system shall show a context menu with a "Share" option that opens the share sheet.
- **Acceptance Criteria**:
  - [ ] Long-press gesture triggers context menu
  - [ ] "Share" option in context menu
  - [ ] Share sheet identical to Now Playing share
  - [ ] Track info populated from selected song
- **Priority**: Must

#### FR-9: Receive Song Share
- **Type**: Event-Driven
- **Statement**: When a user receives a song share, the system shall display it in their activity feed with sender info and track details.
- **Acceptance Criteria**:
  - [ ] Shared song appears in feed
  - [ ] Shows sender profile picture, name, timestamp
  - [ ] Shows track name, artist, album art
  - [ ] Optional message displayed if present
  - [ ] Tapping plays the song
- **Priority**: Must

### Activity Feed

#### FR-10: Feed Display
- **Type**: Ubiquitous
- **Statement**: The system shall display a chronological feed of song shares from users the current user follows.
- **Acceptance Criteria**:
  - [ ] Feed on Feed tab shows shares from followed users
  - [ ] Most recent shares first
  - [ ] Each item shows sender, track, timestamp, message
  - [ ] Pull-to-refresh loads new shares
  - [ ] Infinite scroll for older shares
  - [ ] Empty state when no shares
- **Priority**: Must

#### FR-11: Play Shared Song
- **Type**: Event-Driven
- **Statement**: When the user taps a shared song in the feed, the system shall play that song via SpotifyRemoteService.
- **Acceptance Criteria**:
  - [ ] Tapping share plays song immediately
  - [ ] Now Playing view shows "Shared by @username"
  - [ ] Song plays via existing Spotify integration
- **Priority**: Must

#### FR-12: Friend Activity (Currently Playing)
- **Type**: State-Driven
- **Statement**: While the user is on the Feed tab, the system shall display a sidebar or section showing what friends are currently listening to.
- **Acceptance Criteria**:
  - [ ] Shows friends currently playing music
  - [ ] Updates in near real-time (polling every 30s or Firestore listener)
  - [ ] Shows friend profile pic, track name, artist
  - [ ] Tapping plays that song
  - [ ] Max 5-10 friends shown
- **Priority**: Should
- **Notes**: Requires users to broadcast their currently playing track

### Notifications

#### FR-13: Push Notification for Song Share
- **Type**: Event-Driven
- **Statement**: When a user receives a song share, the system shall send a push notification if the app is not in foreground.
- **Acceptance Criteria**:
  - [ ] Push notification sent via Firebase Cloud Messaging
  - [ ] Notification shows sender name and track name
  - [ ] Tapping notification opens the share in-app
  - [ ] Notification respects user's notification preferences
- **Priority**: Should
- **Notes**: Requires FCM setup and Cloud Functions

#### FR-14: Push Notification for New Follower
- **Type**: Event-Driven
- **Statement**: When a user gains a new follower, the system shall send a push notification.
- **Acceptance Criteria**:
  - [ ] Push notification shows "@username started following you"
  - [ ] Tapping notification opens follower's profile
  - [ ] Notification respects user's preferences
- **Priority**: Could

#### FR-15: In-App Notification Badge
- **Type**: State-Driven
- **Statement**: While the user has unread shares, the system shall display a badge on the Feed tab icon.
- **Acceptance Criteria**:
  - [ ] Badge shows count of unread shares
  - [ ] Badge clears when feed is viewed
  - [ ] Badge updates in real-time
- **Priority**: Could

## Non-Functional Requirements

### NFR-1: Performance
- **Category**: Performance
- **Statement**: The system shall load the activity feed within 2 seconds on a typical network connection.
- **Acceptance Criteria**:
  - [ ] Feed loads in under 2 seconds
  - [ ] Pagination prevents loading too many items at once
  - [ ] Images lazy-load with placeholders
- **Priority**: Must

### NFR-2: Privacy
- **Category**: Security
- **Statement**: The system shall respect user privacy settings when displaying profile information and activity.
- **Acceptance Criteria**:
  - [ ] Private profiles only visible to followers
  - [ ] Currently playing only shared if user opts in
  - [ ] Block functionality prevents follows and shares
- **Priority**: Should

### NFR-3: Offline Resilience
- **Category**: Reliability
- **Statement**: The system shall cache the activity feed for offline viewing.
- **Acceptance Criteria**:
  - [ ] Feed viewable when offline (cached data)
  - [ ] Clear indication when showing cached data
  - [ ] Actions queued and retried when online
- **Priority**: Could

## Constraints

- **Firestore**: All data stored in Firestore; queries must be efficient
- **Spotify**: Song playback requires active Spotify connection
- **FCM**: Push notifications require Firebase Cloud Messaging setup
- **Existing Models**: Must use existing Friendship and SongShare models

## Assumptions

- Users have completed Spotify setup before using social features
- Users are authenticated via Google Sign-In
- Firestore indexes exist for friendship and share queries

## Edge Cases

- **User blocks another user**: Hide from search, prevent follows, filter shares
- **User unfollows while viewing their shares**: Shares remain in feed until refresh
- **Rapid follow/unfollow**: Debounce to prevent Firestore spam
- **Share to user who unfollowed**: Share still delivered (they can block if needed)
- **No Spotify connection**: Show share but disable playback, prompt to connect
- **User deletes account**: Remove their shares and friendships (already implemented in AuthManager)
