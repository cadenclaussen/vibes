# Vibes - Product Requirements Document

## Overview

Vibes is a social music discovery and sharing iOS app built around 8 core features that create a social music experience. Users share songs, discover music through their network, create AI-powered playlists, and find concerts.

**App-Wide Interaction**: Long-press any song anywhere in the app to access quick actions (add to library, share to all/send to one, add to playlist).

## Core Features

| # | Feature | Description |
|---|---------|-------------|
| 1 | Music Collaboration | Share songs with people you follow and receive recommendations from your network |
| 2 | Music Discovery | Find new music through personalized recommendations and activity from people you follow |
| 3 | Trending | Stay current with new releases, popular songs, and concerts near you |
| 4 | Playlist Creation | AI-powered playlist generation and blends with people you follow |
| 5 | Gamification | Achievements and vibe-streaks to encourage engagement |
| 6 | Setup | Connect music services and configure the app |
| 7 | Stats | View your top artists, songs, genres, and listening history |
| 8 | Profile Management | Manage your identity, who you follow, and settings |

---

## 1. Music Collaboration

Share and receive music with your network through a follow-based social model (similar to Twitter/Instagram).

### Features

**Follow Model**
- Follow other users to see their shared songs in your feed
- No mutual approval required (asymmetric following)
- View count of people you follow on profile
- Discover users through suggestions

**Song Sharing**
- Two sharing options:
  - Share to all: broadcast to everyone who follows you
  - Send to one: pick a specific person from your following list
- When selecting one person, list is ranked by most frequent conversations
- Share with message/context ("this reminded me of you", "check this out")
- Receive notifications when someone shares a song with you

**Feed Integration**
- Shared songs appear in Feed with sender attribution
- "From [username]" context on song cards
- Reply to shares with your own song recommendation

### Inspiration
- Strava: Activity sharing with people you follow
- Letterboxd: Movie recommendations between users
- Twitter: Asymmetric follow model

---

## 2. Music Discovery

Find new music through multiple discovery paths tailored to your taste.

### Features

**Taste Profile**
- View your top genres, artists, and songs
- Data sourced from Spotify listening history
- Manual curation: users can adjust/remove items that don't reflect their taste
- LLM-enhanced processing to improve accuracy of taste profiles

**Personalized Recommendations**
- "For You" section with AI-curated suggestions
- Recommendations based on listening history and taste profile
- Ability to dislike/dismiss recommendations to improve future suggestions
- Explanation of why each song was recommended

**Following-Based Discovery**
- Find songs people you follow listen to that match your taste
- Blend recommendations: songs that work for both you and someone you follow
- See what's popular among people you follow

**Shazam Integration**
- Identify songs playing around you
- Add identified songs directly to library or playlists
- Share identified songs with people you follow

**Search (via Spotify API)**
- Search across artists, albums, playlists, and songs
- Results powered by Spotify's search API
- 30-second preview for any song (sourced from iTunes API)
  - If preview unavailable: button appears grayed out
  - Tapping grayed button offers option to open and play in Spotify
- Quick actions (long-press any song): add to library, share to all/send to one, add to playlist

---

## 3. Trending

Stay current with what's happening in music.

### Features

**New Releases**
- New albums and singles from artists you follow
- Trending new releases across the platform
- Release radar: upcoming releases to watch

**Popular Songs**
- Charts and trending tracks
- What's popular among people you follow
- Genre-specific trending lists

**Concerts Near You**
- Upcoming shows in your city and nearby cities
- Concerts from artists in your taste profile
- Price ranges and ticket availability
- Venue information and maps
- One-tap ticket purchase links (Ticketmaster)

---

## 4. Playlist Creation

AI-powered tools for building the perfect playlist.

### Features

**AI Playlist Generation**
- Create playlists based on mood/activity (workout, relaxing, working, party)
- Natural language prompts: "upbeat songs for a road trip"
- Generate playlists from a seed song or artist

**Grow Your Playlist**
- Select an existing playlist
- Get AI recommendations for songs that fit the playlist's vibe
- One-tap add to playlist
- Exclude songs already in the playlist

**Blends**

A Blend is a collaborative playlist that mixes the music tastes of you and someone you follow. The AI analyzes both users' listening history, top artists, and favorite genres to find songs that bridge both tastes.

- Select someone you follow to create a Blend with
- AI generates a playlist of songs that match both taste profiles
- Blend includes a mix of:
  - Songs you both already like
  - New discoveries that fit both profiles
  - Artists similar to what you both listen to
- Share blend playlist with them
- Blends can be refreshed to get new songs
- Saved to your Spotify library as a playlist

---

## 5. Gamification

Engagement mechanics to encourage regular use and social interaction.

### Features

**Achievements**
- Unlock badges for milestones (first share, following 10 users, etc.)
- Genre exploration achievements
- Social achievements (collaboration streaks, popular shares)
- Display achievements on profile

**Vibe Streaks**
- Maintain daily streaks by sharing songs with people you follow
- Streak counters visible on profile
- Notifications to maintain streaks
- Streak recovery options (grace period or streak freeze)

**Streak Rewards**
- 7 days: Bronze flame icon
- 30 days: Silver flame icon
- 100 days: Gold flame icon
- 365 days: Special animated icon

---

## 6. Setup

Onboarding and configuration to get users connected and engaged.

### Features

**Account Login**
- Sign in with Google (sole auth method, one-tap login)
- Session persistence (stay logged in)

**Music Service Connection**
- Connect Spotify account (required for full features)
- OAuth flow with PKCE for secure authentication
- Display connection status prominently
- Easy disconnect/reconnect flow

**Gemini API Key (Required for AI Features)**
- User must provide their own Gemini API key (free to create)
- Required for AI-powered features (playlist generation, recommendations)
- Key stored securely in Keychain
- Validation check on entry
- Link to Google AI Studio for key creation
- Without key: AI features disabled, prompts to add key

**Concert City**
- Set home city for Ticketmaster concert discovery
- City search with autocomplete
- App searches concerts in your city and nearby cities within radius
- Can be changed anytime in Settings

**Setup Progress Indicator**
- Visual progress bar showing setup completion
- Checklist of setup steps (connect Spotify, add Gemini API key, add profile photo, follow users)
- Call-to-action prompts until setup is complete
- Red/orange indicators for incomplete critical steps (Spotify, Gemini API key)

**Setup Steps**
1. Sign in with Google
2. Complete tutorial (ends with Spotify connection prompt)
3. Connect Spotify
4. Set Gemini API key (free to create at Google AI Studio)
5. Set concert city for local events
6. Set profile photo and display name
7. Follow suggested users

**Tutorial (Swipeable Onboarding Cards)**

Shows immediately after account creation. Can be replayed from Settings.

| Card | Title | Content |
|------|-------|---------|
| 1 | Welcome to Vibes | Your social music experience. Discover, share, and connect through music. |
| 2 | Share Music | Share songs with everyone who follows you, or send directly to one person. Long-press any song for quick actions. |
| 3 | Discover | Search Spotify's catalog, get personalized recommendations, and see what people you follow are listening to. |
| 4 | Stay Current | Find concerts near you, see new releases, and never miss what's trending. |
| 5 | Create Playlists | Use AI to generate playlists for any mood. Create blends with people you follow. |
| 6 | Your Stats | See your top artists, songs, and genres. Track your listening over time. |
| 7 | Connect Spotify | Link your Spotify account to unlock all features. [Connect Spotify button] |

- Cards are swipeable left/right
- Progress dots at bottom
- Skip button available on cards 1-6
- Card 7 has "Connect Spotify" button and "Skip for now" option

---

## 7. Stats

View your listening statistics from Spotify.

### Features

- Top artists
- Top songs
- Top genres
- Time range toggle: all-time, past 6 months, past month
- Data pulled directly from Spotify API

---

## 8. Profile Management

User identity and account management.

### Features

**Profile Display**
- Profile photo
- Display name
- Username (@handle)
- Bio/status
- Following count
- Achievement badges
- Current streak

**Edit Profile**
- Update photo, name, bio
- Change username (with availability check)
- Privacy settings

**Social Management**
- View list of people you follow
- Unfollow users
- Block users

**Settings**
- Account (sign out, delete account)
- Spotify connection status and management
- Gemini API key (free to create)
- Concert city/location (searches nearby cities)
- Replay Tutorial
- About

---

## User Flows

### Share to All Flow

```
1. Long-press any song -> Quick actions menu
2. Tap "Share to All"
3. (Optional) Add a message (max 280 characters)
4. Tap "Share"
5. Song appears in the Feed of everyone who follows you
   - Shows as: "[Your name] shared a song"
   - Includes your message if added
```

### Send to One Flow

```
1. Long-press any song -> Quick actions menu
2. Tap "Send to One"
3. User Picker appears
   - Shows people you follow
   - Sorted by most frequent conversations
   - Search bar to filter
4. Select a person
5. (Optional) Add a message
6. Tap "Send"
7. Song appears in their Feed with "From [your name]"
8. Push notification sent to recipient
```

### Shazam Flow

```
1. Tap Shazam button in Feed Quick Actions Bar
2. Listening screen appears
   - Animated sound wave visualization
   - "Listening..." text
   - Cancel button
3. Song identified -> Song Detail appears
4. If not identified:
   - "Couldn't identify song" message
   - "Try Again" button
```

### AI Playlist Generation Flow

```
1. Navigate to Explore -> AI Playlist section
2. Input screen appears:
   - Text prompt field: "Describe your playlist..."
   - Example prompts shown
3. Tap "Generate"
4. Loading screen: "Creating your playlist..."
5. Playlist preview appears:
   - Generated playlist name
   - Track list with previews
   - "Regenerate" button for new results
   - "Save to Spotify" button
6. Saved playlist appears in your Spotify library
```

### Create Blend Flow

```
1. User Profile Detail -> "Create Blend" button
2. Loading screen: "Mixing your music tastes..."
3. Blend preview appears:
   - Blend name: "[Your name] + [Their name]"
   - Track list (20-30 songs)
   - Taste match percentage
5. Actions:
   - "Save to Spotify" - saves as collaborative playlist
   - "Share with [name]" - sends them the blend
   - "Refresh" - generate new songs
```

---

## Navigation Model

### Overview

3-tab navigation: **Feed** | **Explore** | **Profile**

```
+-------------------------------------------------------------+
|                         App                                 |
+-------------+---------------------+-------------------------+
|    Feed     |       Explore       |       Profile           |
|   (Tab 0)   |       (Tab 1)       |       (Tab 2)           |
+-------------+---------------------+-------------------------+
```

### Feed (Tab 0)

A unified scrollable feed mixing all content types. Tap any card to expand to full screen with details.

```
Feed
+-- Header ("Feed" + date)
+-- Quick Actions Bar (sticky)
|   +-- Send Song
|   +-- Shazam
|   +-- Search
+-- Mixed Content Stream (scrollable)
    +-- Cards sorted by relevance/recency
```

#### Feed Item Types

| Type | Card Preview | Full Screen Detail |
|------|--------------|-------------------|
| **Song Share** | Album art, title, artist, "from [username]", play button | Full player, add to library, reply, artist info |
| **Concert** | Artist image, venue, date, price range | Full event details, venue map, buy tickets |
| **New Follow** | Avatar, "You started following [Name]" | User profile, their recent shares |
| **New Release** | Album art, artist, "New album from [artist]" | Full album view, tracklist, play samples |
| **AI Recommendation** | Album art, "Based on your taste...", reason | Why we picked it, similar tracks, add to library |

#### Content Sorting

Feed items are sorted by a weighted score:
1. **Recency** - newer items ranked higher
2. **Relevance** - items from frequently interacted users rank higher
3. **Engagement** - unread/unplayed items prioritized
4. **Variety** - don't show 5 concert cards in a row

**Empty State**: "No activity yet - follow users and share songs!"

### Explore (Tab 1)

Discover new music through search and recommendations.

```
Explore
+-- Search Bar (Spotify API)
|   +-- Search tracks, artists, albums, playlists via Spotify
+-- For You
|   +-- Personalized recommendations from Spotify
+-- Grow Your Playlist
|   +-- Playlist Selector (dropdown of user's playlists)
|   +-- Recommended Tracks (based on selected playlist)
+-- (Search Results when searching)
    +-- Tracks, artists, albums, playlists from Spotify
```

**Requires**: Spotify connection for recommendations

### Profile (Tab 2)

User identity and app settings.

```
Profile
+-- Header
|   +-- Profile photo
|   +-- Display name
|   +-- @username
|   +-- Edit Profile button
+-- Setup Card (if Spotify not connected)
|   +-- "Connect Spotify" CTA
+-- Following
|   +-- Following count
|   +-- Find users button
+-- Settings (gear icon in nav bar)
    +-- Account (sign out, delete)
    +-- Spotify connection
    +-- Gemini API key (free)
    +-- Concert city
    +-- Replay Tutorial
    +-- About
```

---

## Full Screen Detail Views

### Song Detail
- Album artwork header (large)
- Song title
- Artist name (tappable -> Artist Detail)
- Album name (tappable -> Album Detail)
- "From [username]" with timestamp (if shared by someone)
- Message from sender (if included)
- 30-second preview player
- Quick action buttons: Add to Library, Add to Playlist, Share, Open in Spotify
- "Reply with a song" button (for received shares)

### Artist Detail
- Artist image header
- Artist name
- Top songs (most popular tracks)
- Albums (sorted by release date, newest first)
- Singles (sorted by release date, newest first)
- Long-press any song for quick actions

### Album Detail
- Album artwork header (large)
- Album name, artist (tappable), release year
- Track count and total duration
- Track list with track numbers
- "Play on Spotify" button
- "Add to Library" button

### Playlist Detail
- Playlist cover image header
- Playlist name, creator, track count, duration
- Description (if available)
- Track list with album art thumbnails
- "Play on Spotify" button

### Concert Detail
- Artist image header
- Artist name (tappable -> Artist Detail)
- Event date and time
- Venue name and address (tappable -> opens Maps)
- Price range
- Ticket availability status
- "Buy Tickets" button (opens Ticketmaster)
- Additional performers/openers (if any)

### User Profile Detail
- Profile photo header
- Display name and @username
- Bio (if set)
- Following count
- Follow/Unfollow button
- Their recent shares (songs they've shared to all)
- "Create Blend" button

---

## Authentication Flow

```
User Sign-In Flow:
+------------------+
|  Launch App      |
+--------+---------+
         |
         v
+------------------+     +------------------+
| Google Sign-In   |---->|  Create Account  |
| (Firebase Auth)  |     |  with Firebase   |
+--------+---------+     +------------------+
         |
         v
+------------------+
|   Tutorial       |
|   (7 cards)      |
+--------+---------+
         |
         v
+------------------+     +------------------+
|  Spotify OAuth   |---->|   Link Spotify   |
|   (Required)     |     |    to Account    |
+--------+---------+     +------------------+
         |
         v
+------------------+
|   vibes Home     |
+------------------+
```

### Authentication States

```
Not Logged In
+-- AuthView (Google sign-in only)
        |
    Tutorial (swipeable cards, ends with Spotify prompt)

Logged In, No Spotify
+-- All tabs accessible
+-- Explore shows "Connect Spotify" prompt
+-- Profile shows Setup Card

Logged In, Spotify Connected
+-- Full functionality
```

---

## Data Sources

| Content | Source | Update Frequency |
|---------|--------|------------------|
| Shared songs | Firestore (real-time) | Real-time |
| Concerts | Ticketmaster API | On refresh |
| AI Recommendations | Gemini API + Spotify API | On refresh |
| AI Playlists | Gemini API | On generation |
| Playlist Recommendations | Spotify API (seed_tracks) | On playlist select |
| New Releases | Spotify API (new-releases) | Daily |
| Search results | Spotify API | On search |
| Following activity | Firestore | Real-time |
| User profile | Firestore | Real-time |
| User playlists | Spotify API | On refresh |
| Audio previews | iTunes API | On demand |

---

## Technical Stack

### Core
- **Language**: Swift with SwiftUI
- **Architecture**: MVVM
- **Minimum iOS**: 17.0+

### Backend
- **Authentication**: Firebase Auth (Google Sign-In only)
- **Database**: Firebase Firestore (real-time)
- **Storage**: Firebase Storage (profile photos)
- **Push Notifications**: Firebase Cloud Messaging
- **Cloud Functions**: Firebase Functions (vibestreaks, notifications)

### APIs
- **Music Service**: Spotify Web API (OAuth with PKCE)
- **AI Features**: Google Gemini API (user-provided key)
- **Concerts**: Ticketmaster Discovery API
- **Audio Previews**: iTunes Search API (no key required)

### Security
- All tokens stored in iOS Keychain
- PKCE for Spotify OAuth
- Firebase Security Rules for data isolation
- No client secrets in app code

---

## Firestore Collections

```
users/{userId}
  - uid, email, username, displayName, bio
  - profilePictureURL, spotifyId, spotifyLinked
  - favoriteArtists, favoriteSongs, musicTasteTags
  - createdAt, updatedAt, fcmToken
  - privacySettings: { profileVisibility, showNowPlaying, ... }

friendships/{friendshipId}
  - userId, friendId, status ("pending" | "accepted")
  - vibestreak, lastInteractionDate
  - compatibilityScore, sharedArtists
  - createdAt, acceptedAt

messageThreads/{threadId}
  - userId1, userId2
  - lastMessageTimestamp, lastMessageContent, lastMessageType
  - unreadCountUser1, unreadCountUser2

messages/{messageId}
  - threadId, senderId, recipientId
  - messageType ("text" | "song"), content, caption
  - reactions, timestamp, read

nowPlaying/{userId}
  - spotifyTrackId, trackName, artistName, albumArt
  - isPlaying, timestamp, progressMs, durationMs

notifications/{notificationId}
  - userId, notificationType, relatedId
  - content, title, imageURL, timestamp, read

listeningStats/{userId}__{date}
  - totalListeningTimeMs, topArtists, topSongs, topGenres

achievements/{userId}__{achievementType}
  - unlockedAt, progress, metadata
```

---

## Spotify OAuth Scopes

Required scopes for all features:

```
user-read-private      - Read user's subscription details
user-read-email        - Read user's email address
user-library-read      - Access user's saved tracks/albums
user-library-modify    - Save/remove tracks from library
playlist-read-private  - Access user's private playlists
playlist-modify-public - Create/edit public playlists
playlist-modify-private - Create/edit private playlists
user-top-read          - Access user's top artists and tracks
```

---

## Settings Structure

```
Settings
+-- Account
|   +-- Sign Out
|   +-- Delete Account
+-- Music Service
|   +-- Spotify status
|   +-- Connect/Manage button
+-- Gemini API (free)
|   +-- API key status
|   +-- Add/Update key button (links to Google AI Studio)
+-- Concerts
|   +-- City setting (searches nearby cities)
|   +-- Change City button
+-- Support
|   +-- Replay Tutorial
+-- About
    +-- Version number
```
