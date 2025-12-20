# Future Tasks Backlog

This file tracks tasks and features to be implemented in the future.

---

## Search Tab Enhancements

### 17. Tap-to-play song previews
- **Type**: Feature
- **Description**: Play 30-second song previews when tapping on search results
- **Context**: Spotify provides previewUrl on tracks for 30-second audio snippets
- **Documentation**: See docs/song-preview-implementation.md for full implementation guide
- **Requirements**:
  - Create AudioPlayerService singleton using AVPlayer
  - Update TrackRow to handle tap and show play/pause state
  - Show visual indicator for currently playing track
  - Handle tracks with no preview available
  - Add progress bar and sound wave animation
  - Optional: Add mini now-playing bar at bottom of search view

---

## Profile Enhancements

### 1. Add profile picture upload capability
- **Type**: Feature
- **Description**: Add the ability to change the profile picture in the profile section
- **Context**: Currently shows placeholder person icon, need ability to upload/change photo
- **Requirements**:
  - Photo picker integration
  - Image upload to Firebase Storage
  - Update profile picture URL in Firestore
  - Display uploaded image in ProfileView
  - Handle image compression/sizing

### 2. Predefined genre selection
- **Type**: Feature
- **Description**: Instead of adding favorite genres with free text input, have a set list of music genres that you can pick from
- **Context**: Free text input allows typos and inconsistencies, predefined list ensures data quality
- **Requirements**:
  - Define comprehensive list of music genres
  - Replace text input with selection UI (checkboxes, chips, or multi-select)
  - Allow multiple genre selection
  - Update ProfileEditView to use genre picker
  - Consider genre categorization (Rock, Pop, Hip-Hop, Electronic, etc.)

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

### 3. Messaging functionality
- **Type**: Feature
- **Description**: Add one-on-one messaging with friends where users can send text and songs
- **Context**: Core social feature for communication and song sharing between friends
- **Requirements**:
  - Create MessageThread and Message data models
  - Implement messaging service (send text/songs, fetch conversations)
  - Create MessageThreadView with chronological message history
  - Support text messages and song shares in same thread
  - Real-time message updates (Firebase listeners or polling)
  - Message input field with send button
  - Song attachment button to search and share songs
  - Unread message indicators
  - Tap friend in FriendsView to open message thread

### 4. Vibestreaks tracking
- **Type**: Feature
- **Description**: Daily engagement tracking between friends with streak counters and milestones
- **Context**: Gamification feature to encourage daily music sharing between friends
- **Requirements**:
  - Track daily interactions between friend pairs
  - Calculate streak count (consecutive days both users engaged)
  - Display streak count next to friends in friend list
  - Visual streak indicators (fire emoji, badges)
  - Milestone celebrations (7, 30, 100 days)
  - Push notifications to maintain streaks
  - Leaderboard of longest streaks
  - Reset streak logic when day is missed

### 5. Real-time Now Playing
- **Type**: Feature
- **Description**: Show what friends are currently listening to on Spotify in real-time
- **Context**: Enables music discovery through seeing friends' current listening activity
- **Requirements**:
  - Integrate Spotify Web API "currently playing" endpoint
  - Create "Now Playing" section at top of friends list
  - Poll or subscribe to friends' listening status
  - Display song name, artist, and album art
  - Show "Listening to..." status with live indicator
  - Respect privacy settings (users can hide their activity)
  - Tap to view song details or share
  - Empty state when no friends are listening

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

### 7. Send messages with Return/Enter key
- **Type**: Feature
- **Description**: Allow users to send messages by pressing Return/Enter instead of clicking the send button
- **Context**: Improves messaging UX by enabling faster message sending with keyboard
- **Requirements**:
  - Add onSubmit handler to TextField in message input
  - Trigger send action when Return/Enter is pressed
  - Keep send button as alternative method
  - Prevent sending empty messages
  - Consider shift+Enter for new line (if multiline support added)
  - Maintain consistent behavior across iOS versions

### 8. Music taste compatibility scores
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

### 10. Add haptic feedback throughout the app
- **Type**: Feature
- **Description**: Implement haptic feedback for key user interactions to improve tactile experience
- **Context**: Subtle haptics make the app feel more responsive and polished
- **Requirements**:
  - Add light haptic on button taps (send message, friend request, edit profile)
  - Add notification haptic for success actions (message sent, friend added)
  - Add warning haptic for error states
  - Add selection haptic for tab switches
  - Add impact haptic for pull-to-refresh completion
  - Add success haptic for streak milestones
  - Use UIImpactFeedbackGenerator with appropriate styles (.light, .medium, .heavy)
  - Ensure haptics don't fire too frequently (debounce if needed)

### 11. Add smooth animations and transitions
- **Type**: Feature
- **Description**: Implement fluid animations for UI state changes and transitions
- **Context**: Animations make the app feel modern and help users understand state changes
- **Requirements**:
  - Add .animation(.spring()) to state-driven UI changes
  - Implement slide-in animation for new messages
  - Add fade transitions between views
  - Animate profile picture updates with scale effect
  - Add bounce animation for reactions
  - Implement smooth keyboard dismiss animations
  - Add tab switch animations with scale effect
  - Animate button states (pressed, disabled) with opacity/scale
  - Use .transition() for view appearance/disappearance
  - Keep animations subtle and quick (0.2-0.4s duration)

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

### 14. Show last seen and online status for friends
- **Type**: Feature
- **Description**: Display real-time online status and last active timestamp for friends
- **Context**: Helps users know when friends are available to chat
- **Requirements**:
  - Track user online/offline status in Firestore
  - Update status when app enters foreground/background
  - Display green dot indicator for online friends
  - Show "Active now" for online users
  - Show "Active 5m ago", "Active 1h ago" for recent activity
  - Show "Last seen [date]" for longer absence
  - Update status in real-time with Firestore listeners
  - Add privacy setting to hide online status
  - Show typing indicator when friend is typing (future)
  - Handle offline gracefully (don't show stale data)

---

## Authentication Enhancements

### 15. Forgot password functionality
- **Type**: Feature
- **Description**: Add forgot password/password reset flow for users who can't access their account
- **Context**: Essential authentication feature to help users regain access to their accounts
- **Requirements**:
  - Add "Forgot Password?" link on login screen
  - Create password reset view with email input
  - Integrate Firebase Auth password reset email
  - Show confirmation message after email sent
  - Handle error cases (user not found, invalid email)
  - Add clear instructions for checking email
  - Consider adding password reset link expiration notice
  - Return to login screen after successful reset

### 16. Delete account functionality
- **Type**: Feature
- **Description**: Allow users to permanently delete their account and all associated data
- **Context**: Required for privacy compliance (GDPR, CCPA) and user autonomy
- **Requirements**:
  - Add "Delete Account" option in profile settings
  - Create confirmation dialog with warning about permanent deletion
  - Require password re-authentication before deletion
  - Delete user data from Firestore (profile, friends, messages, etc.)
  - Delete Firebase Auth account
  - Delete uploaded media from Firebase Storage
  - Remove user from friends' friend lists
  - Show clear warning about data loss and irreversibility
  - Provide grace period option (30 days before permanent deletion)
  - Log user out and return to login screen after deletion
  - Send confirmation email about account deletion

---

## Backlog Statistics
- Total Future Tasks: 18
- Search Tab Enhancements: 1
- Profile Enhancements: 2
- Friends Tab Enhancements: 8
- UI/UX Polish: 5
- Authentication Enhancements: 2
