# Messaging System Design

## Overview
The messaging system is the core social feature of vibes, enabling friends to share songs and text messages in one-on-one conversations. Each message thread tracks vibestreaks and provides a seamless experience for music discovery and social connection.

## Friends Tab Layout

### Top-Level Structure
```
┌─────────────────────────────────┐
│  Friends                    ⚙️  │
├─────────────────────────────────┤
│  📬 Notifications               │
│  ┌───────────────────────────┐ │
│  │ 3 new messages            │ │
│  │ New release: Artist Name  │ │
│  │ Friend request from @user │ │
│  └───────────────────────────┘ │
├─────────────────────────────────┤
│  🎵 Now Playing                 │
│  ┌───────────────────────────┐ │
│  │ @alice - Song Name        │ │
│  │ @bob - Another Song       │ │
│  └───────────────────────────┘ │
├─────────────────────────────────┤
│  💬 Friends                     │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 👤 Alice  🔥 15         │   │
│  │ "awesome track!"        │   │
│  │ 2m ago                  │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 👤 Bob    🔥 7          │   │
│  │ 🎵 Shared a song        │   │
│  │ 1h ago                  │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 👤 Charlie              │   │
│  │ No messages yet         │   │
│  │                         │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

### Notifications Section
**Purpose**: Quick access to important updates

**Content Types**:
1. Unread message count with preview
2. AI-discovered song recommendations
3. Friend requests (pending)
4. Vibestreak milestones (7 days, 30 days, etc.)
5. Achievement unlocks

**Behavior**:
- Collapsible/expandable section
- Tap notification → Navigate to relevant screen
- Badge shows total notification count
- Clears when viewed

### Now Playing Section
**Purpose**: See what friends are listening to in real-time

**Display**:
- Shows friends currently listening to music on Spotify
- Friend's username + currently playing song
- Album art thumbnail
- Tap to preview song or see details
- Updates in real-time (via Spotify API polling or webhooks)

**Privacy**:
- Only shows if friend has "Now Playing" visibility enabled
- Shows "Listening privately" for friends with privacy enabled

### Friends List
**Purpose**: Main list of all friends with message previews

**Each Friend Card Shows**:
- Profile picture
- Username
- Vibestreak count (🔥 icon + number)
- Last message preview (text or "🎵 Shared a song")
- Timestamp of last message
- Unread indicator (dot or count badge)

**Sorting**:
- Default: Most recent message first
- Alternative: Alphabetical (user preference)

**Tap Behavior**:
- Opens message thread with that friend

## Message Thread View

### Layout
```
┌─────────────────────────────────┐
│  ← @alice            🔥 15   ⋮  │
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────┐        │
│  │ Hey! Check this out │  You   │
│  │ 10:30 AM            │        │
│  └─────────────────────┘        │
│                                 │
│     ┌─────────────────────────┐ │
│     │ [Album Art]             │ │
│ Alice │ Song Name             │ │
│     │ Artist Name             │ │
│     │ ▶️  3:45                │ │
│     │ "this is fire 🔥"       │ │
│     │ 10:32 AM                │ │
│     └─────────────────────────┘ │
│                                 │
│  ┌─────────────────────┐        │
│  │ omg yes!!           │  You   │
│  │ 10:33 AM            │        │
│  └─────────────────────┘        │
│                                 │
│  [Vibestreak milestone: 15 🔥]  │
│                                 │
├─────────────────────────────────┤
│  [+]  Type a message...   [→]  │
└─────────────────────────────────┘
```

### Header
**Components**:
- Back button (←)
- Friend's username (@username)
- Current vibestreak count (🔥 number)
- Menu button (⋮) for:
  - View profile
  - Mute notifications
  - Clear chat history
  - Remove friend

### Message Types

#### Text Message
**Your messages** (right-aligned):
- Light background (or app accent color)
- Message text
- Timestamp below

**Friend's messages** (left-aligned):
- Darker background
- Friend's profile picture (small, left side)
- Message text
- Timestamp below

#### Song Message
**Components**:
- Album art (square, 80x80pt or similar)
- Song title (bold)
- Artist name (secondary text)
- Duration label
- Play button (▶️) - plays 30-second preview
- Optional caption below song card
- Optional star rating (if sender rated it)
- Timestamp

**Behavior**:
- Tap song card → Preview plays (if available)
- Playback controls appear: Play/Pause, progress bar
- Long press → Options menu:
  - Open in Spotify
  - Add to playlist
  - Share to another friend
  - React with emoji

**Visual Design**:
- Song cards slightly larger than text messages
- Clear visual distinction from text
- Reactions display below card

#### System Messages
**Vibestreak Milestones**:
- Centered, special styling
- "🔥 15 Day Vibestreak! Keep it going!"
- Subtle background color
- Celebration animation on first view

**Date Separators**:
- Centered gray text
- "Today", "Yesterday", or actual date
- Helps organize conversation history

### Message Input Area

**Components**:
1. **[+] Button** (left side):
   - Opens song search interface
   - Quick access to recently searched songs
   - Opens as modal or bottom sheet

2. **Text Input Field**:
   - Placeholder: "Type a message..."
   - Multi-line support
   - Auto-expands up to 4-5 lines

3. **Send Button [→]** (right side):
   - Disabled when input empty
   - Becomes prominent when text entered
   - Tap to send message

**Behavior**:
- Keyboard appears when tapping input field
- [+] button opens song search modal
- Selected song appears as preview above input
- Can add caption to song before sending
- Send button sends text OR song message

### Song Search Modal (Triggered from [+] Button)

```
┌─────────────────────────────────┐
│  Search Songs            ✕      │
├─────────────────────────────────┤
│  🔍 Search...          [Return] │
├─────────────────────────────────┤
│                                 │
│  Recently Searched              │
│  ┌─────────────────────────┐   │
│  │ [Album] Song - Artist   │   │
│  └─────────────────────────┘   │
│                                 │
│  Search Results                 │
│  ┌─────────────────────────┐   │
│  │ [Album] Song - Artist   │   │
│  │ ▶️ 3:45                 │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ [Album] Song - Artist   │   │
│  │ ▶️ 4:12                 │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

**Flow**:
1. User taps [+] button
2. Modal slides up from bottom
3. Shows recently searched songs
4. User types query, hits return
5. Search results appear (songs only)
6. User taps song → Preview option appears
7. User taps "Send" or "Add Caption"
8. If caption: Input field appears
9. User sends → Modal closes, song appears in thread

## Message Features

### Reactions
**Emoji Reactions**:
- ❤️ (Heart)
- 🔥 (Fire)
- 💀 (Skull - "dead" from laughter)
- 😍 (Heart Eyes)
- 🎵 (Music Note)

**Behavior**:
- Double-tap message/song → Quick react with ❤️
- Long press → Full reaction picker appears
- Reactions display below message
- Tap reaction → See who reacted
- Multiple users can react with same emoji (shows count)

### Vibestreaks
**How Streaks Work**:
- Increments when BOTH users send at least one message on the same day
- Resets if either user misses a day
- Streak count visible in thread header
- Milestone celebrations (7, 30, 100, 365 days)

**Visual Indicators**:
- 🔥 emoji + number in header
- Milestone system messages in thread
- Animation when milestone reached
- Push notification reminder to maintain streak

## Data Models

### MessageThread
```
{
  id: string
  userId1: string
  userId2: string
  lastMessageTimestamp: Date
  lastMessagePreview: string
  unreadCount: number (for current user)
  createdAt: Date
}
```

### Message
```
{
  id: string
  threadId: string
  senderId: string
  recipientId: string
  messageType: "text" | "song"

  // Text message fields
  textContent?: string

  // Song message fields
  spotifyTrackId?: string
  songTitle?: string
  songArtist?: string
  albumArtUrl?: string
  previewUrl?: string
  duration?: number
  caption?: string
  rating?: number (1-5)

  // Metadata
  timestamp: Date
  read: boolean
  reactions: [
    {
      userId: string
      emoji: string
      timestamp: Date
    }
  ]
}
```

### Interaction (for streak tracking)
```
{
  id: string
  friendshipId: string
  userId: string
  interactionType: "message" | "song"
  date: string (YYYY-MM-DD)
  timestamp: Date
}
```

## Technical Implementation

### Real-Time Updates
**Approach**: Firebase Firestore with real-time listeners

**Message Thread List**:
- Subscribe to user's threads collection
- Listener updates when:
  - New message arrives
  - Message read status changes
  - Friend sends message
- Update UI in real-time

**Message Thread**:
- Subscribe to specific thread's messages
- Listener updates when:
  - New message sent/received
  - Reactions added
  - Read receipts update
- Auto-scroll to bottom on new message

### Message Sending Flow
1. User composes message (text or selects song)
2. Create Message object
3. Write to Firestore messages collection
4. Update MessageThread with latest message info
5. Create Interaction record for streak tracking
6. Check if streak should increment
7. Send push notification to recipient
8. Update local UI optimistically

### Read Receipts (Simple Version)
- Mark message as read when thread is opened
- Update `read: true` on all unread messages
- Update `unreadCount` on MessageThread
- Clear badge/notification indicator

**Note**: Full read receipts (showing when friend read your message) is out of scope for v1.0

### Push Notifications
**Triggers**:
- Friend sends text message
- Friend sends song
- Vibestreak milestone reached
- Vibestreak at risk (12+ hours without interaction)

**Payload**:
- Friend's username
- Message preview (text) or "Shared a song"
- Tap → Opens app to that message thread

## Performance Considerations

### Message Pagination
- Load most recent 50 messages initially
- "Load more" button for older messages
- Infinite scroll (load 20 at a time)
- Cache loaded messages locally

### Image Loading
- Lazy load album art
- Cache album art URLs
- Use placeholders while loading
- SDWebImage or similar library

### Search Optimization
- Cache recent searches locally
- Debounce search input (though v1.0 uses return-triggered search)
- Limit to 20 results
- Cache search results briefly

## Error Handling

### Message Send Failures
- Show error state on message
- Retry button
- Queue failed messages for retry
- Clear error indicator on network recovery

### Preview Playback Failures
- Show "Preview unavailable" if null preview URL
- Display "Open in Spotify" button as fallback
- Handle network errors gracefully

### Connection Issues
- Show offline indicator
- Queue messages to send when online
- Indicate which messages are pending send
- Auto-retry when connection restored

## UI/UX Details

### Animations
- Message send: Slide in from right (yours) or left (theirs)
- Reaction: Pop/bounce animation
- Vibestreak milestone: Confetti or fire animation
- Song preview playing: Pulse animation on play button
- Typing indicator (future): Animated dots

### Accessibility
- VoiceOver support for all messages
- Dynamic type for message text
- High contrast mode support
- Haptic feedback on send, reactions, milestones

### Dark Mode
- Adjust message bubble colors
- Album art maintains original colors
- System messages use semantic colors
- Ensure sufficient contrast

## Future Enhancements (v2.0+)
- Read receipts ("Seen at 10:30 AM")
- Typing indicators
- Voice messages
- Song snippets/highlights (specific timestamp sharing)
- Group chats
- Message search within thread
- Pin important messages
- Delete messages
- Edit messages (text only)
- Forward messages to other friends
