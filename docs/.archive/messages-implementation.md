# Messaging Implementation Plan

## Overview
This document outlines the step-by-step implementation plan for building the messaging system in the Friends tab. Tasks are organized in dependency order - complete earlier phases before moving to later ones.

## Phase 1: Backend & Database Setup

### 1.1 Firebase/Firestore Setup
- [ ] Create Firestore database (if not already set up)
- [ ] Enable Firebase Authentication integration
- [ ] Set up Firestore security rules for messages
- [ ] Create Cloud Functions for server-side operations (optional)
- [ ] Set up Firebase Cloud Messaging for push notifications

### 1.2 Database Schema
- [ ] Create `users` collection with fields:
  - userId, username, email, profilePictureUrl, spotifyId
  - privacySettings (nowPlayingVisible, etc.)

- [ ] Create `friendships` collection with fields:
  - friendshipId, userId1, userId2, status
  - vibestreak, lastInteractionDate, compatibilityScore
  - createdAt, updatedAt

- [ ] Create `messageThreads` collection with fields:
  - threadId, userId1, userId2
  - lastMessageTimestamp, lastMessagePreview
  - unreadCountUser1, unreadCountUser2
  - createdAt

- [ ] Create `messages` subcollection under each thread:
  - messageId, threadId, senderId, recipientId
  - messageType (text/song), textContent
  - spotifyTrackId, songTitle, songArtist, albumArtUrl, previewUrl
  - caption, rating, reactions[]
  - timestamp, read

- [ ] Create `interactions` collection for streak tracking:
  - interactionId, friendshipId, userId
  - interactionType, date (YYYY-MM-DD), timestamp

### 1.3 Firestore Security Rules
```
- [ ] Write security rules ensuring:
  - Users can only read their own threads
  - Users can only send messages to friends
  - Users can only update their own messages
  - Read receipts only update for recipients
```

## Phase 2: Core Data Layer (Swift)

### 2.1 Firebase Service Layer
- [ ] Create `FirebaseManager.swift` singleton
  - Initialize Firebase
  - Provide Firestore database reference
  - Handle authentication state

- [ ] Create `MessageService.swift`:
  - `fetchThreads(for userId:) -> [MessageThread]`
  - `observeThreads(for userId:, completion:)` (real-time)
  - `createThread(between user1:, and user2:) -> MessageThread`
  - `fetchMessages(for threadId:, limit:) -> [Message]`
  - `observeMessages(for threadId:, completion:)` (real-time)
  - `sendMessage(_ message:, to threadId:)`
  - `markMessagesAsRead(in threadId:, for userId:)`
  - `addReaction(_ emoji:, to messageId:, by userId:)`
  - `removeReaction(from messageId:, by userId:)`

- [ ] Create `FriendshipService.swift`:
  - `fetchFriendships(for userId:) -> [Friendship]`
  - `observeFriendships(for userId:, completion:)`
  - `updateVibestreak(for friendshipId:)`
  - `checkAndIncrementStreak(for friendshipId:, userId:)`

- [ ] Create `InteractionService.swift`:
  - `recordInteraction(friendshipId:, userId:, type:)`
  - `checkStreakEligibility(for friendshipId:, on date:) -> Bool`

### 2.2 Data Models (Swift Structs)
- [ ] Create `Models/MessageThread.swift`:
  ```swift
  struct MessageThread: Identifiable, Codable {
      let id: String
      let userId1: String
      let userId2: String
      var lastMessageTimestamp: Date
      var lastMessagePreview: String
      var unreadCount: Int
      let createdAt: Date
  }
  ```

- [ ] Create `Models/Message.swift`:
  ```swift
  struct Message: Identifiable, Codable {
      let id: String
      let threadId: String
      let senderId: String
      let recipientId: String
      let messageType: MessageType
      var textContent: String?
      var spotifyTrackId: String?
      var songTitle: String?
      var songArtist: String?
      var albumArtUrl: String?
      var previewUrl: String?
      var caption: String?
      var rating: Int?
      var reactions: [Reaction]
      let timestamp: Date
      var read: Bool
  }

  enum MessageType: String, Codable {
      case text
      case song
  }

  struct Reaction: Codable {
      let userId: String
      let emoji: String
      let timestamp: Date
  }
  ```

- [ ] Create `Models/Friendship.swift`:
  ```swift
  struct Friendship: Identifiable, Codable {
      let id: String
      let userId1: String
      let userId2: String
      var status: FriendshipStatus
      var vibestreak: Int
      var lastInteractionDate: String?
      var compatibilityScore: Double?
      let createdAt: Date
  }

  enum FriendshipStatus: String, Codable {
      case pending
      case accepted
  }
  ```

- [ ] Create `Models/Interaction.swift`:
  ```swift
  struct Interaction: Identifiable, Codable {
      let id: String
      let friendshipId: String
      let userId: String
      let interactionType: String
      let date: String // YYYY-MM-DD
      let timestamp: Date
  }
  ```

## Phase 3: ViewModels (MVVM Pattern)

### 3.1 FriendsViewModel
- [ ] Create `ViewModels/FriendsViewModel.swift`:
  ```swift
  class FriendsViewModel: ObservableObject {
      @Published var messageThreads: [MessageThread] = []
      @Published var friendships: [Friendship] = []
      @Published var isLoading = false
      @Published var errorMessage: String?

      private let messageService: MessageService
      private let friendshipService: FriendshipService

      func loadThreads()
      func observeThreads()
      func getOtherUserId(in thread:) -> String
      func getVibestreak(for thread:) -> Int
  }
  ```

### 3.2 MessageThreadViewModel
- [ ] Create `ViewModels/MessageThreadViewModel.swift`:
  ```swift
  class MessageThreadViewModel: ObservableObject {
      @Published var messages: [Message] = []
      @Published var friendship: Friendship?
      @Published var isLoading = false
      @Published var isSending = false
      @Published var errorMessage: String?

      let threadId: String
      let otherUserId: String

      private let messageService: MessageService
      private let friendshipService: FriendshipService
      private let interactionService: InteractionService

      func loadMessages()
      func observeMessages()
      func sendTextMessage(_ text: String)
      func sendSongMessage(_ track: SpotifyTrack, caption: String?)
      func markMessagesAsRead()
      func addReaction(_ emoji: String, to message: Message)
      func loadMoreMessages()
  }
  ```

### 3.3 SongSearchViewModel
- [ ] Create `ViewModels/SongSearchViewModel.swift`:
  ```swift
  class SongSearchViewModel: ObservableObject {
      @Published var searchResults: [SpotifyTrack] = []
      @Published var recentSearches: [SpotifyTrack] = []
      @Published var isSearching = false
      @Published var errorMessage: String?

      private let spotifyService: SpotifyService

      func search(query: String)
      func loadRecentSearches()
      func saveRecentSearch(_ track: SpotifyTrack)
  }
  ```

## Phase 4: UI Components - Basic Structure

### 4.1 Friends Tab View
- [ ] Create `Views/FriendsView.swift`:
  - Main container view
  - Navigation structure
  - Tab bar integration

- [ ] Add sections:
  - [ ] Placeholder for Notifications section
  - [ ] Placeholder for Now Playing section
  - [ ] Friends list (main focus)

### 4.2 Friends List
- [ ] Create `Views/Components/FriendThreadRow.swift`:
  - Display friend's profile picture
  - Username
  - Vibestreak indicator (🔥 + number)
  - Last message preview
  - Timestamp
  - Unread indicator

- [ ] In `FriendsView.swift`:
  - [ ] Add List with ForEach over threads
  - [ ] Tap gesture to navigate to MessageThreadView
  - [ ] Pull to refresh
  - [ ] Loading state
  - [ ] Empty state (no friends yet)

### 4.3 Message Thread View - Basic
- [ ] Create `Views/MessageThreadView.swift`:
  - [ ] Navigation bar with back button, username, vibestreak
  - [ ] ScrollView for messages
  - [ ] Message input area at bottom

- [ ] Create `Views/Components/MessageBubble.swift`:
  - [ ] Text message layout (left/right alignment)
  - [ ] Timestamp
  - [ ] Read indicator (simple version)
  - [ ] Different styling for sent vs received

### 4.4 Message Input
- [ ] Create `Views/Components/MessageInputView.swift`:
  - [ ] Text field with placeholder
  - [ ] [+] button (left)
  - [ ] Send button [→] (right)
  - [ ] Handle keyboard appearance
  - [ ] Auto-expand text field (up to 4-5 lines)
  - [ ] Enable/disable send button based on input

## Phase 5: Core Messaging Functionality

### 5.1 Sending Text Messages
- [ ] Wire up MessageInputView to MessageThreadViewModel
- [ ] Implement send action:
  - Create Message object
  - Call messageService.sendMessage()
  - Record interaction for streak tracking
  - Clear input field
  - Optimistic UI update

- [ ] Handle send errors:
  - Show error state
  - Retry option
  - Queue for later retry

### 5.2 Receiving Messages
- [ ] Set up real-time listener in MessageThreadViewModel
- [ ] Update UI when new message arrives
- [ ] Auto-scroll to bottom on new message
- [ ] Play sound/haptic feedback (optional)

### 5.3 Read Receipts (Simple)
- [ ] Mark messages as read when thread is opened
- [ ] Update unread count in thread list
- [ ] Clear badge indicators

### 5.4 Message Display
- [ ] Display messages in chronological order
- [ ] Show sender profile picture for received messages
- [ ] Proper spacing and alignment
- [ ] Date separators (Today, Yesterday, dates)

## Phase 6: Song Messages

### 6.1 Song Search Modal
- [ ] Create `Views/SongSearchView.swift`:
  - Search field with return-triggered search
  - Recently searched songs section
  - Search results list

- [ ] Create `Views/Components/SongResultRow.swift`:
  - Album art thumbnail
  - Song title, artist
  - Duration
  - Preview play button
  - Tap to select

### 6.2 Song Message Sending
- [ ] Add [+] button tap action in MessageInputView
- [ ] Present SongSearchView as sheet/modal
- [ ] User searches and selects song
- [ ] Show selected song preview above input
- [ ] Optional caption input
- [ ] Send song message to thread
- [ ] Record interaction for streak

### 6.3 Song Message Display
- [ ] Create `Views/Components/SongMessageBubble.swift`:
  - Album art (80x80pt)
  - Song title, artist
  - Duration label
  - Preview play button
  - Caption (if present)
  - Timestamp

- [ ] Update MessageBubble to handle both types:
  - if messageType == .text → TextMessageBubble
  - if messageType == .song → SongMessageBubble

### 6.4 Song Preview Playback
- [ ] Create `Services/AudioPlayerService.swift`:
  - AVPlayer for streaming preview URLs
  - Play/pause controls
  - Current playback position
  - Handle null preview URLs

- [ ] Add playback controls to SongMessageBubble:
  - Play/Pause button
  - Progress bar (optional for v1.0)
  - Handle playback state changes

- [ ] Handle "Open in Spotify" button:
  - Deep link: `spotify:track:{id}`
  - Open URL in Spotify app

## Phase 7: Vibestreaks

### 7.1 Streak Calculation Logic
- [ ] Implement in FriendshipService:
  ```swift
  func calculateStreak(friendshipId: String) async -> Int
  func checkBothUsersInteractedToday(friendshipId: String) -> Bool
  func incrementStreak(friendshipId: String)
  func resetStreak(friendshipId: String)
  ```

- [ ] Create scheduled check (Cloud Function or local):
  - Run daily at midnight
  - Check all active friendships
  - Increment streaks where both users interacted
  - Reset streaks where interaction missed

### 7.2 Streak Display
- [ ] Show current streak in MessageThreadView header
- [ ] Show streak in FriendThreadRow
- [ ] Update in real-time when messages sent

### 7.3 Milestone Celebrations
- [ ] Detect milestones (7, 30, 100 days)
- [ ] Insert system message in thread
- [ ] Show celebration animation
- [ ] Send push notification for milestone

## Phase 8: Reactions

### 8.1 Reaction UI
- [ ] Add double-tap gesture to message bubbles:
  - Quick react with ❤️

- [ ] Add long-press gesture to message bubbles:
  - Show reaction picker (❤️ 🔥 💀 😍 🎵)
  - User selects emoji

- [ ] Display reactions below message:
  - Show emoji + count if multiple users
  - Tap to see who reacted

### 8.2 Reaction Functionality
- [ ] Implement addReaction in MessageService
- [ ] Implement removeReaction (tap existing reaction)
- [ ] Real-time updates when reactions added
- [ ] Animation when reaction added (bounce/pop)

## Phase 9: Additional Features

### 9.1 Notifications Section
- [ ] Create `Views/Components/NotificationsSection.swift`:
  - Collapsible header
  - List of notifications
  - Tap to navigate to relevant screen

- [ ] Notification types:
  - Unread message count
  - Friend requests
  - Vibestreak milestones
  - AI song recommendations (placeholder)

### 9.2 Now Playing Section
- [ ] Create `Views/Components/NowPlayingSection.swift`:
  - Fetch currently playing from Spotify API
  - Show friends listening right now
  - Album art, song title, artist
  - Tap to preview song

- [ ] Real-time updates:
  - Poll Spotify API every 30-60 seconds
  - Or use webhooks if available

- [ ] Privacy handling:
  - Check friend's nowPlayingVisible setting
  - Show "Listening privately" if disabled

### 9.3 Thread Menu Options
- [ ] Add menu button (⋮) in MessageThreadView header
- [ ] Options:
  - View friend's profile
  - Mute notifications
  - Clear chat history (confirmation alert)
  - Remove friend (confirmation alert)

### 9.4 Message Pagination
- [ ] Load initial 50 messages
- [ ] Add "Load more" button at top
- [ ] Or implement infinite scroll
- [ ] Cache loaded messages locally

## Phase 10: Push Notifications

### 10.1 Setup
- [ ] Configure APNs in Apple Developer portal
- [ ] Add Push Notifications capability in Xcode
- [ ] Set up Firebase Cloud Messaging
- [ ] Request notification permission from user

### 10.2 Notification Triggers
- [ ] Friend sends message → Push notification
- [ ] Friend sends song → Push notification
- [ ] Vibestreak milestone → Push notification
- [ ] Streak at risk (12+ hours) → Reminder notification

### 10.3 Notification Handling
- [ ] Tap notification → Open app to specific thread
- [ ] Update badge count on app icon
- [ ] Clear notifications when thread viewed

## Phase 11: Polish & Optimization

### 11.1 Performance
- [ ] Optimize Firestore queries (indexes)
- [ ] Implement message caching
- [ ] Lazy load album art images
- [ ] Debounce text input if needed
- [ ] Pagination for large message histories

### 11.2 Error Handling
- [ ] Network error states
- [ ] Retry failed message sends
- [ ] Handle null preview URLs gracefully
- [ ] Offline mode indicators
- [ ] Queue messages when offline

### 11.3 Loading States
- [ ] Skeleton screens for friends list
- [ ] Loading indicators for messages
- [ ] Shimmer effects for images loading

### 11.4 Animations
- [ ] Message send/receive animations
- [ ] Reaction pop animations
- [ ] Vibestreak milestone confetti/fire
- [ ] Smooth scrolling
- [ ] Keyboard animations

### 11.5 Accessibility
- [ ] VoiceOver labels for all UI elements
- [ ] Dynamic Type support
- [ ] Sufficient color contrast
- [ ] Haptic feedback on key actions

### 11.6 Dark Mode
- [ ] Test all views in dark mode
- [ ] Adjust message bubble colors
- [ ] Ensure album art looks good
- [ ] System message styling

## Phase 12: Testing

### 12.1 Unit Tests
- [ ] Test MessageService CRUD operations
- [ ] Test streak calculation logic
- [ ] Test message send/receive flow
- [ ] Test reaction add/remove

### 12.2 Integration Tests
- [ ] Test real-time listeners
- [ ] Test Firebase queries
- [ ] Test push notification delivery

### 12.3 UI Tests
- [ ] Test navigation flows
- [ ] Test message sending
- [ ] Test song search and send
- [ ] Test reactions

### 12.4 Manual Testing
- [ ] Test with 2+ real accounts
- [ ] Test vibestreaks over multiple days
- [ ] Test edge cases (null preview URLs, long messages)
- [ ] Test on different device sizes
- [ ] Test with poor network conditions

## Phase 13: Launch Preparation

### 13.1 Security Review
- [ ] Review Firestore security rules
- [ ] Ensure user data privacy
- [ ] Validate input sanitization
- [ ] Check for potential abuse vectors

### 13.2 Performance Review
- [ ] Monitor Firestore read/write counts
- [ ] Optimize expensive queries
- [ ] Check app size and memory usage
- [ ] Test with many messages (1000+)

### 13.3 Final Polish
- [ ] Fix any UI bugs
- [ ] Smooth out animations
- [ ] Final copywriting review
- [ ] Test all error states

## Implementation Tips

### Development Order
1. Start with Phase 1-2 (backend + data layer)
2. Build basic UI in Phase 4 (without all features)
3. Implement text messaging first (Phase 5)
4. Add song messages (Phase 6)
5. Layer in vibestreaks and reactions (Phase 7-8)
6. Polish and optimize (Phase 11-13)

### Testing Strategy
- Test with Firebase Emulator during development
- Use real Firebase for integration testing
- Test with multiple test accounts
- Keep a checklist of all flows to manually test

### Code Organization
```
vibes/
├── Models/
│   ├── Message.swift
│   ├── MessageThread.swift
│   ├── Friendship.swift
│   └── Interaction.swift
├── Services/
│   ├── FirebaseManager.swift
│   ├── MessageService.swift
│   ├── FriendshipService.swift
│   ├── InteractionService.swift
│   ├── SpotifyService.swift
│   └── AudioPlayerService.swift
├── ViewModels/
│   ├── FriendsViewModel.swift
│   ├── MessageThreadViewModel.swift
│   └── SongSearchViewModel.swift
├── Views/
│   ├── FriendsView.swift
│   ├── MessageThreadView.swift
│   ├── SongSearchView.swift
│   └── Components/
│       ├── FriendThreadRow.swift
│       ├── MessageBubble.swift
│       ├── SongMessageBubble.swift
│       ├── MessageInputView.swift
│       ├── NotificationsSection.swift
│       └── NowPlayingSection.swift
└── Utilities/
    ├── DateFormatters.swift
    ├── Constants.swift
    └── Extensions.swift
```

## Estimated Timeline (Solo Developer)

- **Phase 1-2 (Backend & Data Layer)**: 3-5 days
- **Phase 3 (ViewModels)**: 2-3 days
- **Phase 4 (Basic UI)**: 3-4 days
- **Phase 5 (Text Messaging)**: 3-5 days
- **Phase 6 (Song Messages)**: 4-6 days
- **Phase 7 (Vibestreaks)**: 2-3 days
- **Phase 8 (Reactions)**: 2-3 days
- **Phase 9 (Additional Features)**: 4-6 days
- **Phase 10 (Push Notifications)**: 2-3 days
- **Phase 11 (Polish)**: 3-5 days
- **Phase 12 (Testing)**: 3-5 days
- **Phase 13 (Launch Prep)**: 2-3 days

**Total: 6-8 weeks** for full messaging implementation

This timeline assumes:
- Working 4-6 hours/day
- Some prior iOS/SwiftUI experience
- Firebase familiarity
- Normal debugging time included
