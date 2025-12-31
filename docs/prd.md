# Vibes Product Requirements Document

## Core Features

Vibes is built around 8 core features that together create a social music experience.

**App-Wide Interaction**: Long-press any song anywhere in the app to access quick actions (add to library, share to all/send to one, add to playlist).

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

### 1. Music Collaboration

Share and receive music with your network through a follow-based social model (similar to Twitter/Instagram).

#### Features

**Follow Model**
- Follow other users to see their shared songs in your feed
- No mutual approval required (asymmetric following)
- View count of people you follow on profile
- Discover users through suggestions

**Song Sharing**
- Two sharing options:
  - Share to all: broadcast to everyone you follow
  - Send to one: pick a specific person from your following list
- When selecting one person, list is ranked by most frequent conversations
- Request song recommendations from people you follow
- Share with message/context ("this reminded me of you", "check this out")
- Receive notifications when someone shares a song with you

**Feed Integration**
- Shared songs appear in Feed with sender attribution
- "From [username]" context on song cards
- Reply to shares with your own song recommendation
- Similar to Strava's activity sharing model

#### Inspiration
- Strava: Activity sharing with people you follow
- Letterboxd: Movie recommendations between users
- Twitter: Asymmetric follow model

---

### 2. Music Discovery

Find new music through multiple discovery paths tailored to your taste.

#### Features

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

### 3. Trending

Stay current with what's happening in music.

#### Features

**New Releases**
- New albums and singles from artists you follow
- Trending new releases across the platform
- Artist announcements (tour dates, social media activity)
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
- One-tap ticket purchase links

---

### 4. Playlist Creation

AI-powered tools for building the perfect playlist.

#### Features

**AI Playlist Generation**
- Create playlists based on mood/activity (workout, relaxing, working, party)
- Natural language prompts: "upbeat songs for a road trip"
- Generate playlists from a seed song or artist

**Grow Your Playlist**
- Select an existing playlist
- Get AI recommendations for songs that fit the playlist's vibe
- One-tap add to playlist
- Exclude songs already in the playlist

**Song Filtering**
- Filter your library by mood, tempo, energy level
- Find songs good for specific activities
- Create smart playlists based on audio features

**Blends**

A Blend is a collaborative playlist that mixes the music tastes of you and someone you follow. The AI analyzes both users' listening history, top artists, and favorite genres to find songs that bridge both tastes—tracks you'll both enjoy.

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

### 5. Gamification

Engagement mechanics to encourage regular use and social interaction.

#### Features

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

**Engagement Rewards**
- Points/XP for sharing, discovering, and engaging
- Leaderboards among people you follow
- Weekly/monthly challenges

---

### 6. Setup

Onboarding and configuration to get users connected and engaged.

#### Features

**Account Login**
- Sign in with Google (recommended, one-tap login)
- Sign in with email/password
- Create new account with email
- Password reset via email
- Session persistence (stay logged in)

**Music Service Connection**
- Connect Spotify account
- OAuth flow for secure authentication
- Display connection status prominently
- Easy disconnect/reconnect flow

**Gemini API Key (Required)**
- User must provide their own Gemini API key (free to create)
- Required for AI-powered features (playlist generation, recommendations)
- Key stored securely on device
- Validation check on entry
- Link to Google AI Studio where users can create a free API key
- Without key: AI features disabled, prompts to add key

**Concert City**
- Set home city for Ticketmaster concert discovery
- City search with autocomplete
- App searches concerts in your city and nearby cities within radius
- Used to show concerts in Feed and Trending
- Can be changed anytime in Settings

**Setup Progress Indicator**
- Visual progress bar showing setup completion
- Checklist of setup steps (connect Spotify, add Gemini API key, add profile photo, follow users)
- Call-to-action prompts until setup is complete
- Red/orange indicators for incomplete critical steps (Spotify, Gemini API key)

**Setup Steps**
1. Create account (Google or email/password)
2. Complete tutorial (ends with Spotify connection prompt)
3. Connect Spotify
4. Set Gemini API key (free to create at Google AI Studio)
5. Set concert city for local events
6. Set profile photo and display name
7. Follow suggested users

**Notifications**
- Prompt notifications for incomplete setup
- Badge on Profile tab until setup complete
- Contextual reminders when trying to use features requiring setup

**Tutorial (Swipeable Onboarding Cards)**

Shows immediately after account creation. Can be replayed from Settings.

| Card | Title | Content |
|------|-------|---------|
| 1 | Welcome to Vibes | Your social music experience. Discover, share, and connect through music. |
| 2 | Share Music | Share songs with everyone you follow, or send directly to one person. Long-press any song for quick actions. |
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

### 7. Stats

View your listening statistics from Spotify.

#### Features

- Top artists
- Top songs
- Top genres
- Time range toggle: all-time, past 6 months, past month
- Data pulled directly from Spotify API

---

### 8. Profile Management

User identity and account management.

#### Features

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
- Account settings (email, password, delete account)
- Spotify connection
- Gemini API key (free to create)
- Concert city/location (searches nearby cities)
- Replay Tutorial
- About

---

## User Flows

Detailed step-by-step flows for key features.

### Share to All Flow

When you share a song to all people you follow:

```
1. Long-press any song → Quick actions menu
2. Tap "Share to All"
3. (Optional) Add a message (max 280 characters)
4. Tap "Share"
5. Song appears in the Feed of everyone who follows you
   - Shows as: "[Your name] shared a song"
   - Includes your message if added
   - They can tap to open Song Detail
   - They can reply with their own song
```

### Send to One Flow

When you send a song directly to one person:

```
1. Long-press any song → Quick actions menu
2. Tap "Send to One"
3. User Picker appears
   - Shows people you follow
   - Sorted by most frequent conversations
   - Search bar to filter
4. Select a person
5. (Optional) Add a message
6. Tap "Send"
7. Song appears in their Feed with "From [your name]"
8. They receive a push notification: "[Your name] sent you a song"
```

### Receiving Songs Flow

When someone shares a song with you:

```
1. Push notification: "[Name] sent you a song" or "[Name] shared a song"
2. Tap notification → Opens Song Detail directly
   OR
3. Open app → Song appears in Feed
   - Card shows album art, song title, "from [username]"
   - Unread indicator (dot) until viewed
4. Tap card → Song Detail opens
5. Listen to preview, view actions
6. Optional: Tap "Reply with a song" to send one back
```

### Shazam Flow

When identifying a song:

```
1. Tap Shazam button in Feed Quick Actions Bar
2. Listening screen appears
   - Animated sound wave visualization
   - "Listening..." text
   - Cancel button
3. Song identified → Song Detail appears
   - Shows song info with "Identified with Shazam" badge
   - 30-second preview plays automatically
   - All standard quick actions available
4. If not identified:
   - "Couldn't identify song" message
   - "Try Again" button
   - "Cancel" button
```

### AI Playlist Generation Flow

When creating an AI-generated playlist:

```
1. Navigate to Explore → AI Playlist section
   OR Profile → Create Playlist
2. Input screen appears:
   - Text prompt field: "Describe your playlist..."
   - Example prompts shown:
     - "Upbeat songs for a morning run"
     - "Chill acoustic for studying"
     - "90s throwbacks for a road trip"
   - Optional: Mood sliders (energy, tempo, popularity)
   - Optional: Set playlist length (10, 20, 50 songs)
3. Tap "Generate"
4. Loading screen: "Creating your playlist..."
5. Playlist preview appears:
   - Generated playlist name
   - Track list with previews
   - "Regenerate" button for new results
   - "Edit" to remove specific tracks
   - "Save to Spotify" button
6. Saved playlist appears in your Spotify library
```

### User Discovery Flow

How to find people to follow:

```
1. Profile tab → "Find Users" button
   OR Feed empty state → "Find people to follow"
2. Discovery screen appears with sections:

   a. Search
      - Search bar at top
      - Search by username or display name
      - Results show: photo, name, @username
      - "Follow" button on each result

   b. Suggested Users
      - Based on mutual connections (people followed by people you follow)
      - Based on similar music taste (shared top artists/genres)
      - Each shows: photo, name, why suggested ("Followed by @user" or "Likes indie rock")

   c. Contacts (optional)
      - "Find contacts on Vibes" button
      - Requests contacts permission
      - Shows contacts who have Vibes accounts

3. Tap "Follow" on any user
4. They appear in your following list
5. Their shared songs now appear in your Feed
```

### Create Blend Flow

When creating a Blend with someone:

```
1. User Profile Detail → "Create Blend" button
   OR Explore → Blends section → "New Blend"
2. If from Explore, select a person you follow
3. Loading screen: "Mixing your music tastes..."
   - Shows both profile photos merging
4. Blend preview appears:
   - Blend name: "[Your name] + [Their name]"
   - Blend cover (merged profile photos or album art collage)
   - Track list (20-30 songs)
   - Taste match percentage (e.g., "72% match")
5. Actions:
   - "Save to Spotify" - saves as collaborative playlist
   - "Share with [name]" - sends them the blend
   - "Refresh" - generate new songs
6. Blend saved and shared
```

---

# Navigation Model

## Overview

Vibes uses a simple 3-tab navigation focused on music sharing with people you follow.

```
┌─────────────────────────────────────────────────────────┐
│                         App                             │
├─────────────┬─────────────────────┬─────────────────────┤
│    Feed     │       Explore       │       Profile       │
│   (Tab 0)   │       (Tab 1)       │       (Tab 2)       │
└─────────────┴─────────────────────┴─────────────────────┘
```

## Tab Structure

### Feed (Tab 0)
A unified scrollable feed mixing all content types. Tap any card to expand to full screen with details.

```
Feed
├── Header ("Feed" + date)
├── Quick Actions Bar (sticky)
│   ├── Send Song
│   ├── Shazam
│   └── Search
└── Mixed Content Stream (scrollable)
    └── Cards sorted by relevance/recency
```

#### Feed Item Types

All items appear as tappable cards in a single scrollable stream:

| Type | Card Preview | Full Screen Detail |
|------|--------------|-------------------|
| **Song Share** | Album art, title, artist, "from [username]", play button | Full player, lyrics, add to library, reply, artist info |
| **Concert** | Artist image, venue, date, price range | Full event details, lineup, venue map, buy tickets |
| **New Follow** | Avatar, "You started following [Name]" | User profile, their recent shares, shared interests |
| **New Release** | Album art, artist, "New album from [artist]" | Full album view, tracklist, play samples |
| **AI Recommendation** | Album art, "Based on your taste...", reason | Why we picked it, similar tracks, add to library |

#### Card Design

```
┌─────────────────────────────────────┐
│ ┌──────┐                            │
│ │      │  Title                     │
│ │ Art  │  Subtitle                  │
│ │      │  Context (from X, 2h ago)  │
│ └──────┘                     [▶]    │
└─────────────────────────────────────┘
         ↓ tap anywhere
┌─────────────────────────────────────┐
│                                     │
│         FULL SCREEN DETAIL          │
│                                     │
│  • Large artwork/image              │
│  • Full info                        │
│  • Action buttons                   │
│  • Related content                  │
│                                     │
│              [X] Close              │
└─────────────────────────────────────┘
```

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
├── Search Bar (Spotify API)
│   └── Search tracks, artists, albums, playlists via Spotify
├── For You
│   └── Personalized recommendations from Spotify
├── Grow Your Playlist
│   ├── Playlist Selector (dropdown of user's playlists)
│   └── Recommended Tracks (based on selected playlist)
│       └── Track rows with Add button
└── (Search Results when searching)
    └── Tracks, artists, albums, playlists from Spotify
```

**Requires**: Spotify connection for recommendations

#### Grow Your Playlist

AI-powered feature that recommends tracks based on an existing playlist's content.

```
┌─────────────────────────────────────┐
│ Grow Your Playlist                  │
│ Based on what's in this playlist    │
├─────────────────────────────────────┤
│ ▼ Select a playlist...              │
│   ┌───────────────────────────────┐ │
│   │ My Playlist 1                 │ │
│   │ Workout Mix                   │ │
│   │ Chill Vibes                   │ │
│   └───────────────────────────────┘ │
└─────────────────────────────────────┘
         ↓ after selection
┌─────────────────────────────────────┐
│ Grow Your Playlist                  │
│ Based on "Workout Mix"              │
├─────────────────────────────────────┤
│ ┌──────┐                            │
│ │ Art  │ Song Title           [Add] │
│ └──────┘ Artist • Album             │
│ ─────────────────────────────────── │
│ ┌──────┐                            │
│ │ Art  │ Song Title           [Add] │
│ └──────┘ Artist • Album             │
│ ─────────────────────────────────── │
│           ...more tracks...         │
└─────────────────────────────────────┘
```

**UI Components**:
| Component | Description |
|-----------|-------------|
| Header | "Grow Your Playlist" title with subtitle "Based on what's in this playlist" |
| Playlist Dropdown | User's playlists, sorted by recently modified |
| Track Row | Album art (50x50), song title (bold), artist • album, Add button |
| Add Button | Green button, adds track to selected playlist |
| Success Toast | "Added to [playlist name]" confirmation |

**Behavior**:
1. User taps playlist dropdown to select a playlist
2. App fetches recommendations based on playlist's tracks using Spotify API
3. Shows 10-20 recommended tracks not already in the playlist
4. Tapping "Add" adds track to playlist and removes it from recommendations
5. Can refresh recommendations with pull-to-refresh

**Data Source**: Spotify Recommendations API (seed_tracks from playlist)

### Profile (Tab 2)
User identity and app settings.

```
Profile
├── Header
│   ├── Profile photo
│   ├── Display name
│   ├── @username
│   └── Edit Profile button
├── Setup Card (if Spotify not connected)
│   └── "Connect Spotify" CTA
├── Following
│   ├── Following count
│   └── Find users button
└── Settings (gear icon in nav bar)
    ├── Account (sign out, delete)
    ├── Spotify connection
    ├── Gemini API key (free)
    ├── Concert city (searches nearby cities)
    ├── Replay Tutorial
    └── About
```

## Core User Flow

```
1. Connect Spotify (Profile → Settings)
        ↓
2. Follow Users (Profile → Find Users)
        ↓
3. Browse Feed (scroll mixed content)
        ↓
4. Tap to Expand (full screen detail)
        ↓
5. Take Action (play, save, reply, buy tickets)
        ↓
6. Share Song (Feed → Send Song)
```

## Navigation Destinations

From any tab, users can navigate to:

| Destination | From | Trigger |
|-------------|------|---------|
| Song Detail (full screen) | Feed | Tap song share card |
| Concert Detail (full screen) | Feed | Tap concert card |
| User Profile (full screen) | Feed | Tap new follow card |
| Album Detail (full screen) | Feed, Explore | Tap album/new release card |
| Artist Detail | Explore | Tap artist |
| Playlist Detail | Explore | Tap playlist |
| Settings | Profile | Gear icon |
| Edit Profile | Profile | Edit button |
| User Picker | Feed | Send Song action |
| Concert Settings | Settings | Concerts row |

### Full Screen Detail Views

Full screen views present as sheets that cover the entire screen. They include:
- Large visual header (artwork/image)
- Detailed content
- Primary action button(s)
- Close button (X) in top corner
- Swipe down to dismiss

#### Artist Detail

When tapping on an artist anywhere in the app:
- Artist image header
- Artist name
- Top songs (most popular tracks)
- Albums (sorted by release date, newest first)
- Singles (sorted by release date, newest first)
- Long-press any song for quick actions

#### Album Detail

When tapping on an album anywhere in the app:
- Album artwork header (large)
- Album name
- Artist name (tappable → Artist Detail)
- Release year
- Track count and total duration
- Track list with track numbers
  - Each track shows: number, title, duration, explicit badge if applicable
  - Tap track to play preview
  - Long-press track for quick actions
- "Play on Spotify" button (opens Spotify app)
- "Add to Library" button

#### Playlist Detail

When tapping on a playlist anywhere in the app:
- Playlist cover image header
- Playlist name
- Creator name (if not user's own playlist)
- Track count and total duration
- Description (if available)
- Track list
  - Each track shows: album art thumbnail, title, artist, duration
  - Tap track to play preview
  - Long-press track for quick actions
- "Play on Spotify" button
- "Add to Library" button (for playlists you don't own)

#### Concert Detail

When tapping on a concert anywhere in the app:
- Artist image header
- Artist name (tappable → Artist Detail)
- Event date and time
- Venue name
- Venue address (tappable → opens Maps)
- Price range (e.g., "$45 - $120")
- Ticket availability status (Available, Limited, Sold Out)
- "Buy Tickets" button (opens Ticketmaster)
- "Add to Calendar" button
- Additional performers/openers (if any)
- Venue info section:
  - Venue photo (if available)
  - Capacity
  - Venue type (arena, club, theater, etc.)

#### Song Detail

When tapping on a shared song in the Feed:
- Album artwork header (large)
- Song title
- Artist name (tappable → Artist Detail)
- Album name (tappable → Album Detail)
- "From [username]" with timestamp (if shared by someone)
- Message from sender (if included)
- 30-second preview player
  - Play/pause button
  - Progress bar
  - If no preview: "Open in Spotify" button
- Quick action buttons:
  - Add to Library
  - Add to Playlist
  - Share / Send to One
  - Open in Spotify
- "Reply with a song" button (opens song picker to send back)

#### User Profile Detail

When tapping on a user anywhere in the app:
- Profile photo header
- Display name
- @username
- Bio (if set)
- Following count
- Follow/Unfollow button
- Their recent shares (songs they've shared to all)
- "Create Blend" button (generates playlist for both of you)

## Data Sources

| Content | Source | Update Frequency |
|---------|--------|------------------|
| Shared songs | Firestore (messageThreads) | Real-time |
| Concerts | Ticketmaster API | On refresh |
| AI Recommendations | Gemini API + Spotify API | On refresh |
| AI Playlists | Gemini API | On generation |
| Playlist Recommendations | Spotify API (seed_tracks) | On playlist select |
| New Releases | Spotify API (new-releases) | Daily |
| Search results | Spotify API | On search |
| Following activity | Firestore (following) | Real-time |
| Following list | Firestore (following) | Real-time |
| User profile | Firestore (users) | Real-time |
| User playlists | Spotify API | On refresh |

## Authentication States

```
Not Logged In
└── AuthView (Google sign-in or email/password)
        ↓
    Tutorial (swipeable cards, ends with Spotify prompt)

Logged In, No Spotify
└── All tabs accessible
└── Explore shows "Connect Spotify" prompt
└── Profile shows Setup Card

Logged In, Spotify Connected
└── Full functionality
```

## Settings Structure

```
Settings
├── Account
│   ├── Sign Out
│   └── Delete Account
├── Music Service
│   ├── Spotify status
│   └── Connect/Manage button
├── Gemini API (free)
│   ├── API key status
│   └── Add/Update key button (links to Google AI Studio)
├── Concerts
│   ├── City setting (searches nearby cities)
│   └── Change City button
├── Support
│   └── Replay Tutorial
└── About
    └── Version number
```
