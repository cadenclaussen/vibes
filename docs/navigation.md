# Navigation Model

## Overview

Vibes uses a simple 3-tab navigation focused on music sharing between friends.

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
│   └── Search
└── Mixed Content Stream (scrollable)
    └── Cards sorted by relevance/recency
```

#### Feed Item Types

All items appear as tappable cards in a single scrollable stream:

| Type | Card Preview | Full Screen Detail |
|------|--------------|-------------------|
| **Song Share** | Album art, title, artist, "from [friend]", play button | Full player, lyrics, add to library, reply, artist info |
| **Concert** | Artist image, venue, date, price range | Full event details, lineup, venue map, buy tickets |
| **Friend Activity** | Avatar, "[Name] is now your friend" | Friend profile, their recent activity, shared interests |
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

Feed items are sorted by a weighted score combining:

**Base Priority** (content type weight):
1. Concerts in your area (highest)
2. New drops (releases within last 3 months)
3. Friend activity
4. Song shares
5. AI recommendations (lowest)

**Modifiers** (adjust final score):
- **Recency** - newer items boost score
- **Engagement** - unread/unplayed items boost score
- **Variety** - penalize if same type appeared recently (avoid 5 concerts in a row)

**Empty State**: "No activity yet - add friends and share songs!"

### Explore (Tab 1)
Discover new music through search and recommendations.

```
Explore
├── Search Bar
│   └── Search tracks, artists, albums, playlists
├── For You
│   └── Personalized recommendations from Spotify
├── Grow Your Playlist
│   ├── Playlist Selector (dropdown of user's playlists)
│   └── Recommended Tracks (based on selected playlist)
│       └── Track rows with Add button
└── (Search Results when searching)
    └── Tracks, artists, albums, playlists
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
2. App fetches recommendations based on playlist's tracks using Spotify/Apple Music API
3. Shows 10-20 recommended tracks not already in the playlist
4. Tapping "Add" adds track to playlist and removes it from recommendations
5. Can refresh recommendations with pull-to-refresh

**Data Source**: Spotify Recommendations API (seed_tracks from playlist) or Apple Music recommendations

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
├── Friends
│   ├── Follower count
│   ├── Following count
│   └── Add friend button
└── Settings (gear icon in nav bar)
    ├── Account (sign out, delete)
    ├── Spotify connection
    ├── Concert city
    └── About
```

## Core User Flow

```
1. Connect Spotify (Profile → Settings)
        ↓
2. Add Friends (Profile → Add)
        ↓
3. Browse Feed (scroll mixed content)
        ↓
4. Tap to Expand (full screen detail)
        ↓
5. Take Action (play, save, reply, buy tickets)
        ↓
6. Share with Friends (Feed → Send Song)
```

## Navigation Destinations

From any tab, users can navigate to:

| Destination | From | Trigger |
|-------------|------|---------|
| Song Detail (full screen) | Feed | Tap song share card |
| Concert Detail (full screen) | Feed | Tap concert card |
| Friend Profile (full screen) | Feed | Tap friend activity card |
| Album Detail (full screen) | Feed, Explore | Tap album/new release card |
| Artist Detail | Explore | Tap artist |
| Playlist Detail | Explore | Tap playlist |
| Settings | Profile | Gear icon |
| Edit Profile | Profile | Edit button |
| Friend Picker | Feed | Send Song action |
| Concert Settings | Settings | Concerts row |

### Full Screen Detail Views

Full screen views present as sheets that cover the entire screen. They include:
- Large visual header (artwork/image)
- Detailed content
- Primary action button(s)
- Close button (X) in top corner
- Swipe down to dismiss

## Data Sources

| Content | Source | Update Frequency |
|---------|--------|------------------|
| Shared songs | Firestore (messageThreads) | Real-time |
| Concerts | Ticketmaster API | On refresh |
| AI Recommendations | Spotify API + personalization | On refresh |
| Playlist Recommendations | Spotify API (seed_tracks) | On playlist select |
| New Releases | Spotify API (new-releases) | Daily |
| Friend activity | Firestore (friendships) | Real-time |
| Friend list | Firestore (friendships) | Real-time |
| User profile | Firestore (users) | Real-time |
| User playlists | Spotify/Apple Music API | On refresh |

## Authentication States

```
Not Logged In
└── AuthView (login/signup)

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
├── Concerts
│   ├── City setting
│   └── Change City button
├── Support
│   └── Replay Tutorial
└── About
    └── Version number
```
