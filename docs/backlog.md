# Future Tasks Backlog

This file tracks tasks and features to be implemented in the future.

---

## Messaging Enhancements

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

## UI/UX Polish

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

## Backlog Statistics
- Total Future Tasks: 2
- Messaging Enhancements: 1
- UI/UX Polish: 1

---

## Recently Completed (moved from backlog)
- #18 Search/filter friends list - Completed in Task #84
- #7 Music taste compatibility scores - Completed in Task #86
- #12 Visual depth with shadows - Completed in Task #85
- #19 Group chats - Completed in Task #87
