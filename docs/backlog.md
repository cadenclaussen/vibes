# Future Tasks Backlog

This file tracks tasks and features to be implemented in the future.

---

## Friends Tab Enhancements

### 18. Search/filter friends list
- **Type**: Feature
- **Description**: Add a search bar to filter friends by name or username
- **Context**: As friend lists grow, users need a quick way to find specific friends
- **Requirements**:
  - Add search bar at top of friends list
  - Filter friends in real-time as user types
  - Search by display name and username
  - Show "No results" state when no matches
  - Clear button to reset search
  - Keep search bar visible while scrolling (sticky header)

### 6. Swipe-to-reveal message timestamps
- **Type**: Feature
- **Description**: Add swipe gesture to reveal timestamps for all messages in the conversation
- **Context**: Keep message view clean by hiding timestamps by default, show them when user swipes left
- **Requirements**:
  - Add left swipe gesture on message list view
  - Show timestamps for all messages when swiping left
  - Messages should stay in place, only timestamps appear/disappear
  - Timestamps should disappear when user releases swipe
  - Format timestamps with short time style (e.g., "3:45 PM")
  - Position timestamps next to messages (right-aligned for sent messages, left-aligned for received)

### 7. Music taste compatibility scores
- **Type**: Feature
- **Description**: Calculate and display music compatibility percentage between users
- **Context**: Helps users discover friends with similar music taste and provides conversation starters
- **Requirements**:
  - Analyze shared artists, genres, and listening patterns
  - Calculate compatibility score (0-100%)
  - Display percentage on friend profiles
  - Show "You both love [Artist Name]" insights
  - List top 5 shared artists between friends
  - Compatibility badge levels (Low <30%, Medium 30-70%, High >70%)
  - Update scores periodically based on listening habits
  - Include compatibility in friend discovery/suggestions

### 9. AI-powered new music recommendations
- **Type**: Feature
- **Description**: Personalized new music suggestions in notifications section based on listening habits
- **Context**: AI feature that analyzes user taste to recommend new releases they might enjoy
- **Requirements**:
  - Integrate AI/ML service (OpenAI API or music intelligence API)
  - Analyze user's listening history and preferences
  - Fetch new releases from Spotify
  - Match new releases to user taste profile
  - Display recommendations in notifications section
  - Include explanation for why song was recommended
  - Allow users to preview, save, or share recommendations
  - Mark recommendations as viewed/dismissed
  - Update recommendations weekly

---

## UI/UX Polish

### 12. Add visual depth with shadows and elevation
- **Type**: Feature
- **Description**: Apply consistent shadows to cards and components for visual hierarchy
- **Context**: Subtle shadows create depth and help separate UI elements
- **Requirements**:
  - Add shadow to all card components (.shadow(radius: 2, y: 1))
  - Apply consistent corner radius (12pt) across all cards
  - Add shadows to floating buttons (send, add friend)
  - Increase shadow on interactive elements during press state
  - Use semantic colors for backgrounds to work in dark mode
  - Add elevation to navigation bar/tab bar with subtle shadow
  - Ensure shadows are subtle and don't overwhelm the design
  - Test shadow appearance in both light and dark mode

### 13. Add pull-to-refresh on friends list
- **Type**: Feature
- **Description**: Implement pull-to-refresh gesture to reload friends list and message threads
- **Context**: Allows users to manually refresh content and see latest updates
- **Requirements**:
  - Add .refreshable modifier to friends list ScrollView
  - Fetch latest message threads on pull-to-refresh
  - Update friend online status on refresh
  - Add haptic feedback when refresh completes
  - Show activity indicator during refresh
  - Handle errors gracefully if refresh fails
  - Debounce refresh to prevent excessive API calls
  - Auto-refresh should still work in background

---

## Messaging Enhancements

### 19. Group chats
- **Type**: Feature
- **Description**: Add group messaging functionality to allow multiple friends to chat together
- **Context**: Users want to create group conversations for sharing music with multiple friends at once
- **Requirements**:
  - Create GroupThread model with name, participants, and unread counts
  - Add "New Group" button to create groups
  - Multi-select friends to add to group (minimum 2)
  - Name the group during creation
  - Show group conversations in Chats tab alongside DMs
  - Display sender names on messages in group chats
  - Group settings: edit name, view members, leave group
  - Creator can add/remove members
  - Track read status per user in group
  - Support both text and song messages in groups
  - Requires Firestore composite index for participantIds + lastMessageTimestamp

---

## Backlog Statistics
- Total Future Tasks: 8
- Friends Tab Enhancements: 4
- UI/UX Polish: 3
- Messaging Enhancements: 1
