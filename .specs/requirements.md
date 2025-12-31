# Vibes - Requirements Specification

Generated from `.specs/prd.md`

---

## 1. Authentication & Onboarding

### FR-1.1: Google Sign-In
- **Type**: Event-Driven
- **Statement**: When the user taps "Sign in with Google", the system shall initiate Google OAuth via Firebase Auth and create/authenticate the user account.
- **Acceptance Criteria**:
  - [ ] Google sign-in button displayed as sole auth option
  - [ ] OAuth flow opens in system browser/sheet
  - [ ] New users: account created in Firebase, redirected to tutorial
  - [ ] Returning users: redirected to Feed
  - [ ] Session persisted across app launches
  - [ ] Error states shown with retry option
- **Priority**: Must

### FR-1.2: Tutorial Flow
- **Type**: Event-Driven
- **Statement**: When a new user completes sign-in, the system shall present a 7-card swipeable tutorial introducing app features.
- **Acceptance Criteria**:
  - [ ] 7 cards displayed in sequence (Welcome, Share, Discover, Trending, Playlists, Stats, Connect Spotify)
  - [ ] Swipe left/right navigation between cards
  - [ ] Progress dots at bottom
  - [ ] Skip button on cards 1-6
  - [ ] Card 7: "Connect Spotify" and "Skip for now" buttons
  - [ ] Tutorial replayable from Settings
- **Priority**: Must

### FR-1.3: Spotify OAuth Connection
- **Type**: Event-Driven
- **Statement**: When the user taps "Connect Spotify", the system shall initiate Spotify OAuth with PKCE and store tokens securely in Keychain.
- **Acceptance Criteria**:
  - [ ] OAuth flow with required scopes (user-read-private, user-library-read, playlist-modify-public, etc.)
  - [ ] PKCE code verifier/challenge for security
  - [ ] Access and refresh tokens stored in Keychain
  - [ ] Automatic token refresh on expiry
  - [ ] Connection status visible in Profile and Settings
  - [ ] Disconnect option in Settings
- **Priority**: Must

### FR-1.4: Gemini API Key Setup
- **Type**: Event-Driven
- **Statement**: When the user enters a Gemini API key, the system shall validate the key and store it securely in Keychain.
- **Acceptance Criteria**:
  - [ ] Text field for API key entry in Settings
  - [ ] Link to Google AI Studio for key creation
  - [ ] Validation via test API call on submission
  - [ ] Error message for invalid keys
  - [ ] Key stored in Keychain (not UserDefaults)
  - [ ] Key status indicator (configured/not configured)
- **Priority**: Must

### FR-1.5: Concert City Configuration
- **Type**: Event-Driven
- **Statement**: When the user sets their concert city, the system shall store the location and use it for Ticketmaster concert queries.
- **Acceptance Criteria**:
  - [ ] City search with autocomplete
  - [ ] Selected city stored in user profile (Firestore)
  - [ ] Concerts filtered by city + nearby radius
  - [ ] City changeable anytime in Settings
- **Priority**: Should

### FR-1.6: Setup Progress Indicator
- **Type**: State-Driven
- **Statement**: While the user has incomplete setup steps, the system shall display a setup progress card on the Profile tab.
- **Acceptance Criteria**:
  - [ ] Progress checklist showing: Spotify, Gemini key, profile photo, concert city
  - [ ] Red/orange indicators for critical missing steps (Spotify, Gemini)
  - [ ] Tapping incomplete step navigates to that setup screen
  - [ ] Card hidden when all critical steps complete
- **Priority**: Should

### FR-1.7: Sign Out
- **Type**: Event-Driven
- **Statement**: When the user taps "Sign Out" in Settings, the system shall sign out of Firebase Auth, clear all tokens, and return to the auth screen.
- **Acceptance Criteria**:
  - [ ] Confirmation prompt before sign out
  - [ ] Firebase Auth sign out executed
  - [ ] Spotify tokens cleared from Keychain
  - [ ] Gemini API key cleared from Keychain
  - [ ] User returned to Google sign-in screen
- **Priority**: Must

### FR-1.8: Delete Account
- **Type**: Event-Driven
- **Statement**: When the user taps "Delete Account" in Settings, the system shall permanently delete their account and all associated data.
- **Acceptance Criteria**:
  - [ ] Confirmation prompt with warning
  - [ ] Re-authentication required (Google sign-in)
  - [ ] User document deleted from Firestore
  - [ ] Related data deleted (friendships, messages, shares)
  - [ ] Firebase Auth account deleted
  - [ ] All tokens cleared
  - [ ] User returned to auth screen
- **Priority**: Must

---

## 2. Music Collaboration

### FR-2.1: Follow User
- **Type**: Event-Driven
- **Statement**: When the user taps "Follow" on another user's profile, the system shall create a follow relationship and add that user's shared content to the follower's feed.
- **Acceptance Criteria**:
  - [ ] Follow button on User Profile Detail view
  - [ ] Friendship document created in Firestore (status: "accepted", asymmetric)
  - [ ] No approval required from followed user
  - [ ] Following count updates immediately on both profiles
  - [ ] Followed user's song shares appear in follower's Feed
- **Priority**: Must

### FR-2.2: Unfollow User
- **Type**: Event-Driven
- **Statement**: When the user taps "Unfollow" on a followed user's profile, the system shall remove the follow relationship.
- **Acceptance Criteria**:
  - [ ] Unfollow button shown for followed users
  - [ ] Confirmation prompt before unfollowing
  - [ ] Friendship document deleted from Firestore
  - [ ] Content from unfollowed user removed from Feed
  - [ ] Following count decremented
- **Priority**: Must

### FR-2.3: Song Context Menu
- **Type**: Event-Driven
- **Statement**: When the user long-presses any song anywhere in the app, the system shall display a context menu with quick actions.
- **Acceptance Criteria**:
  - [ ] Long-press gesture recognized on all song UI elements
  - [ ] Haptic feedback on menu appearance
  - [ ] Menu options: Add to Library, Share to All, Send to One, Add to Playlist
  - [ ] Menu dismissible by tapping outside
  - [ ] Actions execute immediately with success feedback
- **Priority**: Must

### FR-2.4: Share Song to All
- **Type**: Event-Driven
- **Statement**: When the user selects "Share to All" from the context menu, the system shall broadcast the song to the feed of all users who follow them.
- **Acceptance Criteria**:
  - [ ] Optional message field (max 280 characters)
  - [ ] Song share document created in Firestore
  - [ ] Share appears in followers' feeds with sender attribution
  - [ ] Shows as "[username] shared a song" with optional message
  - [ ] Success toast confirmation
- **Priority**: Must

### FR-2.5: Send Song to One
- **Type**: Event-Driven
- **Statement**: When the user selects "Send to One" from the context menu, the system shall display a user picker and send the song directly to the selected user.
- **Acceptance Criteria**:
  - [ ] User picker shows people the user follows
  - [ ] List sorted by most frequent conversations
  - [ ] Search bar to filter users
  - [ ] Optional message field
  - [ ] Song appears in recipient's feed with "From [username]"
  - [ ] Push notification sent to recipient
  - [ ] Message thread created/updated in Firestore
- **Priority**: Must

### FR-2.6: Reply to Song Share
- **Type**: Event-Driven
- **Statement**: When the user taps "Reply with a song" on a received song share, the system shall open a song picker to send a song back to the original sender.
- **Acceptance Criteria**:
  - [ ] "Reply with a song" button on Song Detail for received shares
  - [ ] Opens Spotify search to find song
  - [ ] Selected song sent directly to original sender
  - [ ] Creates conversation thread
- **Priority**: Should

---

## 3. Music Discovery

### FR-3.1: Spotify Search
- **Type**: Event-Driven
- **Statement**: When the user enters a search query in Explore, the system shall query Spotify API and display results for tracks, artists, albums, and playlists.
- **Acceptance Criteria**:
  - [ ] Search bar at top of Explore tab
  - [ ] Debounced search (300ms after typing stops)
  - [ ] Results categorized: Tracks, Artists, Albums, Playlists
  - [ ] Tap result opens appropriate detail view
  - [ ] Long-press track for context menu
  - [ ] Empty state for no results
- **Priority**: Must

### FR-3.2: For You Recommendations
- **Type**: State-Driven
- **Statement**: While Spotify is connected, the system shall display personalized recommendations in the "For You" section of Explore.
- **Acceptance Criteria**:
  - [ ] "For You" section visible in Explore
  - [ ] Recommendations from Spotify Recommendations API
  - [ ] Each recommendation shows "why" explanation
  - [ ] Dismiss/dislike button to improve future suggestions
  - [ ] Pull-to-refresh for new recommendations
- **Priority**: Should

### FR-3.3: Song Preview Playback
- **Type**: Event-Driven
- **Statement**: When the user taps play on a song, the system shall play a 30-second preview from iTunes API.
- **Acceptance Criteria**:
  - [ ] Play button on song cards and detail views
  - [ ] 30-second preview audio from iTunes Search API
  - [ ] Progress bar during playback
  - [ ] Only one preview plays at a time (stops previous)
  - [ ] If preview unavailable: grayed button, "Open in Spotify" option
- **Priority**: Must

### FR-3.4: Shazam Song Identification
- **Type**: Event-Driven
- **Statement**: When the user taps the Shazam button, the system shall listen for audio and identify the playing song.
- **Acceptance Criteria**:
  - [ ] Shazam button in Feed Quick Actions Bar
  - [ ] Microphone permission requested on first use
  - [ ] Animated listening indicator
  - [ ] On success: Song Detail opens with identified song
  - [ ] On failure: "Couldn't identify" with "Try Again" option
- **Priority**: Could

### FR-3.5: Grow Your Playlist
- **Type**: Event-Driven
- **Statement**: When the user selects a playlist in "Grow Your Playlist", the system shall generate AI recommendations for songs that fit the playlist's vibe.
- **Acceptance Criteria**:
  - [ ] Playlist dropdown showing user's Spotify playlists
  - [ ] 10-20 recommended tracks displayed
  - [ ] Recommendations exclude songs already in playlist
  - [ ] "Add" button adds track to playlist via Spotify API
  - [ ] Added tracks removed from recommendation list
  - [ ] Pull-to-refresh for new recommendations
- **Priority**: Should
- **Notes**: Requires Gemini API key

---

## 4. Feed

### FR-4.1: Unified Feed Display
- **Type**: Ubiquitous
- **Statement**: The system shall display a unified scrollable feed containing song shares, concerts, new follows, new releases, and AI recommendations.
- **Acceptance Criteria**:
  - [ ] Single scrollable list with mixed content types
  - [ ] Each card type visually distinguishable
  - [ ] Pull-to-refresh updates content
  - [ ] Infinite scroll / pagination
  - [ ] Empty state: "No activity yet - follow users and share songs!"
- **Priority**: Must

### FR-4.2: Feed Content Sorting
- **Type**: Ubiquitous
- **Statement**: The system shall sort feed items by weighted score considering recency, relevance, engagement, and variety.
- **Acceptance Criteria**:
  - [ ] Newer items ranked higher
  - [ ] Items from frequently interacted users rank higher
  - [ ] Unread/unplayed items prioritized
  - [ ] Variety maintained (no 5 same-type cards in a row)
- **Priority**: Should

### FR-4.3: Quick Actions Bar
- **Type**: Ubiquitous
- **Statement**: The system shall display a sticky Quick Actions Bar at the top of Feed with Send Song, Shazam, and Search buttons.
- **Acceptance Criteria**:
  - [ ] Bar stays visible while scrolling
  - [ ] Send Song: opens song search for sharing
  - [ ] Shazam: initiates song identification
  - [ ] Search: focuses Explore tab search bar
- **Priority**: Must

### FR-4.4: Feed Card Expansion
- **Type**: Event-Driven
- **Statement**: When the user taps a feed card, the system shall present a full-screen detail view.
- **Acceptance Criteria**:
  - [ ] Tap any card opens full-screen sheet
  - [ ] Song cards -> Song Detail
  - [ ] Concert cards -> Concert Detail
  - [ ] User cards -> User Profile Detail
  - [ ] Album cards -> Album Detail
  - [ ] Swipe down or X button to dismiss
- **Priority**: Must

---

## 5. Concerts

### FR-5.1: Concert Discovery
- **Type**: State-Driven
- **Statement**: While a concert city is configured, the system shall fetch and display upcoming concerts from Ticketmaster API in the Feed.
- **Acceptance Criteria**:
  - [ ] Concerts appear as cards in Feed
  - [ ] Filtered by user's configured city + nearby radius
  - [ ] Shows: artist, venue, date, price range
  - [ ] Concerts from artists in user's taste profile prioritized
- **Priority**: Should

### FR-5.2: Concert Detail View
- **Type**: Event-Driven
- **Statement**: When the user taps a concert card, the system shall display full concert details.
- **Acceptance Criteria**:
  - [ ] Artist image and name (tappable -> Artist Detail)
  - [ ] Event date and time
  - [ ] Venue name and address (tappable -> opens Apple Maps)
  - [ ] Price range and ticket availability
  - [ ] "Buy Tickets" button opens Ticketmaster
  - [ ] Additional performers/openers listed
- **Priority**: Should

---

## 6. Playlist Creation

### FR-6.1: AI Playlist Generation
- **Type**: Event-Driven
- **Statement**: When the user submits a natural language prompt, the system shall use Gemini API to generate a playlist matching the description.
- **Acceptance Criteria**:
  - [ ] Text input for prompt (e.g., "upbeat songs for a road trip")
  - [ ] Example prompts shown for inspiration
  - [ ] Loading state during generation
  - [ ] Preview with generated name and track list
  - [ ] "Regenerate" button for new results
  - [ ] "Save to Spotify" creates playlist in user's library
- **Priority**: Should
- **Notes**: Requires Gemini API key

### FR-6.2: Create Blend
- **Type**: Event-Driven
- **Statement**: When the user taps "Create Blend" on a followed user's profile, the system shall generate a playlist combining both users' music tastes.
- **Acceptance Criteria**:
  - [ ] "Create Blend" button on User Profile Detail
  - [ ] Loading: "Mixing your music tastes..."
  - [ ] Preview shows: blend name, 20-30 tracks, taste match percentage
  - [ ] Mix includes: mutual favorites, new discoveries, similar artists
  - [ ] "Save to Spotify" creates collaborative playlist
  - [ ] "Share" sends blend to the other user
  - [ ] "Refresh" generates new songs
- **Priority**: Could
- **Notes**: Requires Gemini API key

---

## 7. Detail Views

### FR-7.1: Song Detail View
- **Type**: Event-Driven
- **Statement**: When the user opens a song, the system shall display full song details with preview player and actions.
- **Acceptance Criteria**:
  - [ ] Large album artwork
  - [ ] Song title, artist (tappable), album (tappable)
  - [ ] "From [username]" with timestamp if shared
  - [ ] Sender's message if included
  - [ ] 30-second preview player with progress bar
  - [ ] Actions: Add to Library, Add to Playlist, Share, Open in Spotify
  - [ ] "Reply with a song" for received shares
- **Priority**: Must

### FR-7.2: Artist Detail View
- **Type**: Event-Driven
- **Statement**: When the user taps an artist name, the system shall display artist profile with top songs and discography.
- **Acceptance Criteria**:
  - [ ] Artist image header
  - [ ] Artist name
  - [ ] Top songs section (most popular)
  - [ ] Albums section (sorted by release date, newest first)
  - [ ] Singles section (sorted by release date, newest first)
  - [ ] Long-press any song for context menu
- **Priority**: Must

### FR-7.3: Album Detail View
- **Type**: Event-Driven
- **Statement**: When the user taps an album, the system shall display album details with full tracklist.
- **Acceptance Criteria**:
  - [ ] Large album artwork
  - [ ] Album name, artist (tappable), release year
  - [ ] Track count and total duration
  - [ ] Numbered tracklist
  - [ ] Tap track to play preview
  - [ ] Long-press track for context menu
  - [ ] "Play on Spotify" and "Add to Library" buttons
- **Priority**: Must

### FR-7.4: Playlist Detail View
- **Type**: Event-Driven
- **Statement**: When the user taps a playlist, the system shall display playlist details with full tracklist.
- **Acceptance Criteria**:
  - [ ] Playlist cover image
  - [ ] Playlist name, creator, track count, duration
  - [ ] Description if available
  - [ ] Tracklist with album art thumbnails
  - [ ] Tap track to play preview
  - [ ] Long-press track for context menu
  - [ ] "Play on Spotify" button
- **Priority**: Must

### FR-7.5: User Profile Detail View
- **Type**: Event-Driven
- **Statement**: When the user taps another user, the system shall display their profile with recent shares and actions.
- **Acceptance Criteria**:
  - [ ] Profile photo, display name, @username
  - [ ] Bio if set
  - [ ] Following count
  - [ ] Follow/Unfollow button
  - [ ] Recent shares (songs they've shared to all)
  - [ ] "Create Blend" button
- **Priority**: Must

---

## 8. Profile & Settings

### FR-8.1: Profile Display
- **Type**: Ubiquitous
- **Statement**: The system shall display the user's profile with photo, name, username, bio, following count, achievements, and streak.
- **Acceptance Criteria**:
  - [ ] Profile photo (or placeholder)
  - [ ] Display name and @username
  - [ ] Bio text
  - [ ] Following count (tappable to view list)
  - [ ] Achievement badges
  - [ ] Current vibe streak counter
- **Priority**: Must

### FR-8.2: Edit Profile
- **Type**: Event-Driven
- **Statement**: When the user taps "Edit Profile", the system shall allow updating profile photo, display name, username, and bio.
- **Acceptance Criteria**:
  - [ ] Photo picker for profile photo
  - [ ] Photo uploaded to Firebase Storage
  - [ ] Text fields for display name and bio
  - [ ] Username field with availability check
  - [ ] Save/Cancel buttons
  - [ ] Changes reflected immediately after save
- **Priority**: Must

### FR-8.3: View Following List
- **Type**: Event-Driven
- **Statement**: When the user taps their following count, the system shall display a list of users they follow.
- **Acceptance Criteria**:
  - [ ] List of followed users with photo and name
  - [ ] Tap user to open their profile detail
  - [ ] Unfollow button per user
  - [ ] Search/filter functionality
- **Priority**: Must

### FR-8.4: Find Users
- **Type**: Event-Driven
- **Statement**: When the user taps "Find Users", the system shall display user discovery with search and suggestions.
- **Acceptance Criteria**:
  - [ ] Search bar for username/display name
  - [ ] Suggested users based on mutual follows
  - [ ] Suggested users based on similar music taste
  - [ ] Follow button on each result
- **Priority**: Should

### FR-8.5: Block User
- **Type**: Event-Driven
- **Statement**: When the user blocks another user, the system shall prevent all interaction between them.
- **Acceptance Criteria**:
  - [ ] Block option in user profile menu
  - [ ] Confirmation prompt
  - [ ] Blocked user cannot see blocker's profile or shares
  - [ ] Blocker cannot see blocked user's content
  - [ ] Existing follows removed
  - [ ] Unblock option in Settings
- **Priority**: Should

---

## 9. Gamification

### FR-9.1: Achievements
- **Type**: Event-Driven
- **Statement**: When the user completes a milestone, the system shall unlock and display the corresponding achievement badge.
- **Acceptance Criteria**:
  - [ ] Achievements for: first share, 10 follows, genre exploration, etc.
  - [ ] Badge notification on unlock
  - [ ] Badges displayed on profile
  - [ ] Achievement list viewable in profile/stats
- **Priority**: Could

### FR-9.2: Vibe Streaks
- **Type**: State-Driven
- **Statement**: While the user shares songs daily, the system shall maintain and display their streak count.
- **Acceptance Criteria**:
  - [ ] Streak counter on profile
  - [ ] Streak incremented when user shares song each day
  - [ ] Streak reset if no share for 24+ hours
  - [ ] Streak icons: 7d bronze, 30d silver, 100d gold, 365d animated
  - [ ] Notification reminder before streak breaks
  - [ ] Grace period or streak freeze option
- **Priority**: Could

---

## 10. Stats

### FR-10.1: Listening Stats Display
- **Type**: State-Driven
- **Statement**: While Spotify is connected, the system shall display the user's top artists, songs, and genres.
- **Acceptance Criteria**:
  - [ ] Stats section accessible from Profile
  - [ ] Top artists with images
  - [ ] Top songs with album art
  - [ ] Top genres
  - [ ] Time range toggle: all-time, 6 months, 1 month
  - [ ] Data from Spotify API (user-top-read scope)
- **Priority**: Should

---

## Non-Functional Requirements

### NFR-1: Feed Load Performance
- **Category**: Performance
- **Statement**: The system shall load the initial feed within 2 seconds on a typical network connection.
- **Acceptance Criteria**:
  - [ ] Skeleton/loading state displayed immediately
  - [ ] First 10 items visible within 2 seconds
  - [ ] Subsequent pagination loads within 1 second
- **Priority**: Must

### NFR-2: Search Response Time
- **Category**: Performance
- **Statement**: The system shall display search results within 500ms of the user stopping typing.
- **Acceptance Criteria**:
  - [ ] 300ms debounce before API call
  - [ ] Results displayed within 500ms of API call
  - [ ] Loading indicator during search
- **Priority**: Should

### NFR-3: Token Security
- **Category**: Security
- **Statement**: The system shall store all authentication tokens and API keys in iOS Keychain.
- **Acceptance Criteria**:
  - [ ] Spotify tokens in Keychain
  - [ ] Gemini API key in Keychain
  - [ ] No tokens in UserDefaults or plaintext
  - [ ] Tokens cleared on sign out
- **Priority**: Must

### NFR-4: OAuth Security
- **Category**: Security
- **Statement**: The system shall use PKCE for Spotify OAuth authentication.
- **Acceptance Criteria**:
  - [ ] PKCE code verifier and challenge generated
  - [ ] State parameter for CSRF protection
  - [ ] Tokens exchanged via secure callback
- **Priority**: Must

### NFR-5: Offline Handling
- **Category**: Usability
- **Statement**: When network is unavailable, the system shall display cached content and show offline indicator.
- **Acceptance Criteria**:
  - [ ] Cached feed items displayed offline
  - [ ] Offline indicator visible in UI
  - [ ] Actions queued for retry when online
  - [ ] Clear error messages for failed operations
- **Priority**: Should

### NFR-6: VoiceOver Accessibility
- **Category**: Accessibility
- **Statement**: The system shall support VoiceOver with appropriate labels for all interactive elements.
- **Acceptance Criteria**:
  - [ ] All buttons have accessibility labels
  - [ ] Images have accessibility descriptions
  - [ ] Custom controls are accessible
  - [ ] Navigation order is logical
- **Priority**: Should

### NFR-7: Dynamic Type
- **Category**: Accessibility
- **Statement**: The system shall scale text appropriately when Dynamic Type is enabled.
- **Acceptance Criteria**:
  - [ ] Text uses semantic styles (.headline, .body, etc.)
  - [ ] Layout adapts to larger text sizes
  - [ ] No text truncation at larger sizes
- **Priority**: Should

### NFR-8: Error Recovery
- **Category**: Reliability
- **Statement**: If an API call fails, the system shall display an error message and provide retry option.
- **Acceptance Criteria**:
  - [ ] User-friendly error messages (not technical)
  - [ ] Retry button for failed operations
  - [ ] Automatic retry with exponential backoff for transient failures
  - [ ] Graceful degradation for non-critical features
- **Priority**: Must

### NFR-9: Dark Mode Support
- **Category**: Usability
- **Statement**: The system shall support both light and dark appearance modes.
- **Acceptance Criteria**:
  - [ ] UI adapts to system appearance setting
  - [ ] All colors use semantic/dynamic colors
  - [ ] Images and icons appropriate for both modes
- **Priority**: Must

---

## Developer Setup Requirements

### FR-DEV-1: Spotify Developer App
- **Type**: Ubiquitous
- **Statement**: The system shall require a Spotify Developer App with Client ID for OAuth.
- **Acceptance Criteria**:
  - [ ] App created at developer.spotify.com/dashboard
  - [ ] Redirect URI configured: `vibes://spotify-callback`
  - [ ] Client ID stored in configuration file (not hardcoded)
  - [ ] Required scopes documented
- **Priority**: Must

### FR-DEV-2: Firebase Project
- **Type**: Ubiquitous
- **Statement**: The system shall require a Firebase project with Auth, Firestore, and Storage configured.
- **Acceptance Criteria**:
  - [ ] Firebase project created
  - [ ] iOS app registered with bundle ID
  - [ ] GoogleService-Info.plist added to project
  - [ ] Google Sign-In provider enabled
  - [ ] Firestore database created
  - [ ] Security rules configured
- **Priority**: Must

### FR-DEV-3: Ticketmaster API
- **Type**: Ubiquitous
- **Statement**: The system shall require a Ticketmaster API key for concert discovery.
- **Acceptance Criteria**:
  - [ ] App created at developer.ticketmaster.com
  - [ ] API key stored in configuration file
  - [ ] Rate limits documented (5000/day free tier)
- **Priority**: Should

### FR-DEV-4: Configuration File
- **Type**: Ubiquitous
- **Statement**: The system shall load API credentials from a secure configuration file excluded from source control.
- **Acceptance Criteria**:
  - [ ] Configuration file (Secrets.plist or Config.xcconfig)
  - [ ] File in .gitignore
  - [ ] Template file provided (Secrets.example.plist)
  - [ ] Build fails with clear error if file missing
- **Priority**: Must

---

## Constraints

### Technical
- iOS 17.0+ required (SwiftUI features)
- Spotify account required for music features (free tier sufficient)
- Gemini API key required for AI features (user-provided, free tier)
- Network connection required for real-time features

### Business
- Users provide their own Gemini API key (app remains free)
- No full music playback (30-second previews only, licensing)
- Concerts limited to Ticketmaster coverage areas

---

## Assumptions

- Users have a Spotify account (free or premium)
- Users willing to create free Gemini API key for AI features
- Users have reliable network for primary use
- Ticketmaster API provides sufficient concert coverage
- iTunes API provides preview URLs for most tracks

---

## Edge Cases

### No Spotify Connected
- Feed shows only non-music content (follows)
- Explore shows "Connect Spotify" prompt
- Search disabled with explanation
- Setup card prominent in Profile

### No Gemini API Key
- AI features disabled (playlist generation, blends, AI recommendations)
- Prompt to add key when user tries AI feature
- Non-AI features work normally
- "For You" uses Spotify recommendations instead

### No Followers/Following
- Feed shows empty state with "Find people to follow" CTA
- Suggested users section prominent
- Share options still work (for future followers)

### Preview Unavailable
- Play button grayed out
- Tapping shows "Open in Spotify" option
- Other song actions still available

### Shazam Fails
- "Couldn't identify song" message
- "Try Again" and "Cancel" options
- Suggest quieter environment

### Network Offline
- Show cached content
- Offline indicator in UI
- Queue actions for later
- Disable features requiring network

### API Rate Limits
- Implement exponential backoff
- Show "Try again later" for user-initiated actions
- Background operations silently retry

### Token Expiry
- Automatic refresh for Spotify tokens
- Re-prompt for Google auth if refresh fails
- Gemini key doesn't expire (but may be revoked)
