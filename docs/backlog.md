# Future Tasks Backlog

This file tracks tasks and features to be implemented in the future.

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

### 6. Music taste compatibility scores
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

### 7. AI-powered new music recommendations
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

## Authentication Enhancements

### 8. Forgot password functionality
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

### 9. Delete account functionality
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
- Total Future Tasks: 9
- Profile Enhancements: 2
- Friends Tab Enhancements: 5
- Authentication Enhancements: 2
