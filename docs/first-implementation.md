# First Implementation (MVP)

A focused first build to validate core features work before adding complexity.

## Goal

Get the essential loop working:
1. Connect music service
2. Discover something (concerts, AI recommendation)
3. Share it with a friend

## Scope

### In Scope
- Basic 3-tab navigation (Feed, Explore, Profile)
- Music service connection (Spotify + Apple Music)
- Concert discovery
- One AI feature (AI recommendations)
- Friend following + sharing

### Out of Scope (for now)
- AI Playlist Creation
- Friend Blends
- Achievements
- Vibe-Streaks
- Editable taste rankings
- Shazam integration

---

## Features

### 1. Music Service Connection
**Priority: Required**

Connect Spotify or Apple Music to enable personalized features.

```
Profile → Settings → Music Service
├── Connect Spotify
└── Connect Apple Music
```

- OAuth flow for Spotify
- MusicKit for Apple Music
- Store connection status
- Show "Connected" state with account info

### 2. Concert Discovery
**Priority: Core**

Find concerts near you.

```
Explore
└── Concerts Near You
    ├── [If no city] "Set your city" → city picker
    └── [If city set] List of upcoming concerts
        ├── Artist name
        ├── Venue
        ├── Date
        └── "Get Tickets" → Ticketmaster link
```

Implementation:
- City picker (text input or location permission)
- Ticketmaster API integration
- Simple list view of results
- Tap concert → open Ticketmaster in browser

### 3. AI Recommendations
**Priority: Core**

Get personalized song recommendations.

```
Explore
└── AI Discovery
    └── "For You" section
        ├── 5-10 recommended songs
        ├── Each shows: title, artist, album art
        └── Tap → 30-second preview or open in music service
```

Implementation:
- Fetch user's top artists/genres from music service
- Send to Gemini API with prompt
- Parse response into song list
- Display as scrollable cards
- Refresh button to get new recommendations

### 4. Friend Following
**Priority: Core**

Follow other users to see their activity.

```
Profile
└── Followers / Following
    ├── Search users
    ├── Follow button
    └── List of who you follow
```

Implementation:
- User search (by username)
- Follow/unfollow actions
- Store relationships in Firebase
- Basic following list view

### 5. Song Sharing
**Priority: Core**

Share a song with someone you follow.

```
Any song context menu
└── "Send to..." → Friend picker → Send

Feed
└── "Jordan shared a song with you" [song card]
    ├── Song info
    ├── Play preview
    └── Open in Spotify/Apple Music
```

Implementation:
- Context menu on any song (search results, recommendations, concerts)
- Friend picker (people you follow)
- Send creates a "share" record in Firebase
- Shares appear in recipient's Feed

### 6. Basic Feed
**Priority: Core**

See activity from people you follow.

```
Feed (Tab 0)
├── Quick Actions (simplified)
│   └── Send Song
└── Scrollable Feed
    ├── Songs shared with you
    └── What friends are listening to (if available from API)
```

Implementation:
- Query shares where you're the recipient
- Display as simple card list
- Pull to refresh

### 7. Basic Profile
**Priority: Core**

Your identity and settings access.

```
Profile (Tab 2)
├── Profile Header (photo, name, username)
├── [If not connected] Setup Card
├── Followers / Following counts
└── Settings (cog)
```

Implementation:
- Display user info from Firebase
- Connection status
- Link to settings

---

## Screens Summary

| Tab | Screens |
|-----|---------|
| Feed | Feed (shares + activity) |
| Explore | Explore (search, AI recs, concerts) |
| Profile | Profile, Settings, Following list |

---

## Data Models

```
User
├── id
├── username
├── displayName
├── profilePhotoURL
├── musicService: "spotify" | "appleMusic" | null
├── city (for concerts)
└── createdAt

Follow
├── followerId
├── followingId
└── createdAt

Share
├── id
├── senderId
├── recipientId
├── songId
├── songTitle
├── songArtist
├── songAlbumArt
├── songPreviewURL
├── createdAt
└── seen: boolean
```

---

## API Integrations

| Service | Purpose | Required |
|---------|---------|----------|
| Spotify API | Auth, user data, song info | Yes (if user chooses Spotify) |
| Apple MusicKit | Auth, user data, song info | Yes (if user chooses Apple Music) |
| Ticketmaster API | Concert listings | Yes |
| Gemini API | AI recommendations | Yes |
| Firebase | Auth, database, storage | Yes |

---

## Success Criteria

MVP is complete when a user can:

- [ ] Create account and sign in
- [ ] Connect Spotify or Apple Music
- [ ] See AI-recommended songs
- [ ] Set city and see nearby concerts
- [ ] Search for and follow another user
- [ ] Share a song with someone they follow
- [ ] See shared songs in their Feed

---

## What's Next (v2)

After MVP is validated:
1. AI Playlist Creation
2. Friend Blends
3. Editable taste rankings
4. Achievements & Vibe-Streaks
5. Shazam integration
6. Richer feed (trending, new releases)
