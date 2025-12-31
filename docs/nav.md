# Navigation Architecture Options

## Core Use Cases to Support

| # | Use Case | Key Features |
|---|----------|--------------|
| 1 | Music Collaboration | Follow model, sharing, trending across users |
| 2 | Music Discovery | Personal taste, LLM enhancement, Shazam, friend discovery |
| 3 | Trending | New releases, popular songs, concerts |
| 4 | Playlist Creation | AI mood-based, filtering, friend blends |
| 5 | Gamification | Achievements, vibe-streaks |
| 6 | Setup | Music service connection with CTA until complete |
| 7 | Stats | Top artists, songs, genres, recently played |
| 8 | Profile | Account management, preferences |

---

## Option 1: Social Hub Model

**Tabs: Home, Feed, Explore, Profile (4 tabs)**

```
Home (Tab 0)
├── Greeting + streak status
├── Quick Actions
│   ├── Create Playlist
│   ├── Shazam
│   └── Send Song
├── Continue Where You Left Off
├── Today's Pick (AI recommendation)
└── Setup CTAs (if incomplete)

Feed (Tab 1)
├── Following Activity
│   ├── What people you follow are listening to
│   ├── Songs shared by people you follow
│   └── New playlists from following
├── Trending Section
│   ├── Popular songs across all users
│   └── Trending artists
└── Direct Messages / Shares

Explore (Tab 2)
├── Search Bar (always visible)
├── Your Taste
│   ├── Top Genres (editable/rankable)
│   ├── Top Artists (can dislike/hide)
│   └── Top Songs (can dislike/hide)
├── Discovery
│   ├── New Releases
│   ├── Concerts Near You
│   └── Friend Recommendations
└── AI Playlist Ideas
    ├── Mood-based creation
    └── Friend Blends

Profile (Tab 3)
├── Profile Header + Edit
├── Stats Dashboard
│   ├── Top Artists
│   ├── Top Songs
│   ├── Top Genres
│   └── Recently Played
├── Achievements & Badges
├── Vibe-Streaks
├── Followers / Following
└── Settings (via cog)
    ├── Music Service Setup
    ├── Account
    └── Preferences
```

### Upsides
- Clear separation: Social (Feed) vs Discovery (Explore)
- Home provides orientation and quick actions
- Stats live naturally with Profile (your identity)
- Trending integrated into social context

### Downsides
- 4 tabs might feel cluttered
- Feed vs Explore distinction could confuse some users
- Playlist creation split between Home (quick action) and Explore (AI)

### Use Case Coverage
| Use Case | Location | Quality |
|----------|----------|---------|
| Collaboration | Feed, Profile (following) | Strong |
| Discovery | Explore | Strong |
| Trending | Feed | Good |
| Playlist Creation | Explore, Home quick action | Split |
| Gamification | Profile | Strong |
| Setup | Settings, Home CTAs | Good |
| Stats | Profile | Strong |

---

## Option 2: Activity-Centric Model

**Tabs: Home, Discover, Create, Me (4 tabs)**

```
Home (Tab 0)
├── Following Activity Stream
│   ├── Real-time: "Alex is listening to..."
│   ├── Shares: "Jordan sent you a song"
│   └── Social actions
├── Trending Now
│   ├── Popular songs
│   ├── Trending artists
│   └── New releases
├── Streak Reminders
└── Setup CTAs (if incomplete)

Discover (Tab 1)
├── Search Bar
├── For You (AI-powered)
│   ├── Based on your taste
│   ├── Based on friends' taste
│   └── Mood recommendations
├── Your Taste (editable)
│   ├── Top Genres (rank them)
│   ├── Top Artists (dislike to hide)
│   └── Top Songs (dislike to hide)
├── Concerts Near You
└── Shazam Integration

Create (Tab 2)
├── AI Playlist Builder
│   ├── Mood selection
│   ├── Activity (workout, relax, focus)
│   └── Song filtering
├── Friend Blends
│   ├── Pick friends
│   └── Generate blend
├── Share to Following
│   ├── Song recommendation
│   └── Playlist share
└── Your Playlists

Me (Tab 3)
├── Profile Header
├── Stats
│   ├── Top Artists
│   ├── Top Songs
│   ├── Top Genres
│   └── Recently Played
├── Achievements
├── Vibe-Streaks Progress
├── Followers / Following
└── Settings (cog)
```

### Upsides
- Create tab emphasizes playlist/sharing actions
- Clear mental model: Browse (Home), Find (Discover), Make (Create), Self (Me)
- Social activity prominent on Home
- Discovery focused purely on finding music

### Downsides
- Create tab might feel empty if user rarely creates
- "Me" is less inviting than "Profile"
- Social split between Home (activity) and Me (followers)

### Use Case Coverage
| Use Case | Location | Quality |
|----------|----------|---------|
| Collaboration | Home, Create, Me | Split across tabs |
| Discovery | Discover | Strong |
| Trending | Home | Good |
| Playlist Creation | Create | Very Strong |
| Gamification | Me | Strong |
| Setup | Settings | Standard |
| Stats | Me | Strong |

---

## Option 3: Minimalist Model

**Tabs: Feed, Explore, Profile (3 tabs)**

```
Feed (Tab 0)
├── Quick Actions (horizontal row, top, always visible)
│   ├── Create Playlist
│   ├── Send Song
│   └── Shazam
├── Streak Reminders (if any active)
├── [If not connected] "Connect to see what friends are playing" banner
└── Scrollable Feed (Instagram-style, infinite scroll)
    ├── "Alex is listening to..." [song card]
    ├── "New release from [Artist]" [album card]
    ├── "Jordan shared a song with you" [song card]
    ├── Trending song [song card]
    ├── "Sarah added to playlist" [playlist card]
    ├── New release [album card]
    ├── Friend listening [song card]
    └── ... mixed content, infinite scroll

Explore (Tab 1)
├── Search Bar (always works)
├── Your Taste (editable, drives discovery)
│   ├── Top Genres (rankable, hide/dislike)
│   ├── Top Artists (rankable, hide/dislike)
│   └── Top Songs (rankable, hide/dislike)
│   └── [If not connected] Grayed, "Connect to see your taste"
├── AI Discovery
│   ├── Based on you
│   ├── Based on friends
│   └── Mood-based
│   └── [If not connected] Grayed, "Connect to unlock"
├── Concerts Near You
│   └── [If no city set] "Set your city" prompt → city picker
├── Friend Discovery (always works)
│   ├── Songs your friends like
│   └── Friend blends
└── AI Playlist Creation
    ├── Mood picker
    ├── Activity picker
    └── Friend blend builder
    └── [If not connected] Grayed, "Connect to create"

Profile (Tab 2)
├── Profile Header
├── [If not connected] Setup Card
│   ├── "Connect to unlock your music identity"
│   ├── [ ] Connect Spotify
│   └── [ ] Connect Apple Music
├── Music Identity (display-only, for you and followers)
│   ├── Top Artist (singular - your "main")
│   ├── Recently Played (dynamic, what you're into now)
│   └── Listening Time (hours this week/month)
├── Your Playlists
├── Achievements
├── Vibe-Streaks
├── Followers / Following
└── Settings (cog) [red badge if not connected]
    ├── Account
    ├── Music Service (Spotify/Apple Music)
    ├── AI Features
    │   ├── Enable AI recommendations (on by default)
    │   └── Gemini API key (optional, for power users)
    ├── Concerts
    │   ├── Your city/location
    │   └── Ticketmaster API key (optional, for more results)
    ├── Notifications
    └── Privacy
```

### Setup Strategy

Setup is aggressive but rewarding. Users feel incomplete until connected.

**Primary Setup (Music Service):**
| Feature | Without Connection |
|---------|-------------------|
| Search | Works |
| Friend Discovery | Works |
| Your Taste | Grayed, "Connect to see" |
| AI Discovery | Grayed, "Connect to unlock" |
| AI Playlist Creation | Grayed, "Connect to create" |
| Music Identity stats | Empty, shows prompt |

**Visual Indicators:**
- Red badge on Settings cog until connected
- Setup Card on Profile
- Grayed features with clear unlock prompts

**First Launch:**
1. Onboarding modal pushes connection (skippable)
2. If skipped, every tab shows what they're missing
3. Tapping grayed feature → connection prompt

**On Connection:**
1. "Connected!" achievement unlocked (first achievement)
2. Immediate load of personalized content
3. Setup Card disappears, red badges clear
4. Celebration moment

**Secondary Setup (AI & Concerts):**

| Feature | Default | Power User |
|---------|---------|------------|
| AI Discovery | Works with app backend | Add Gemini API key for unlimited |
| AI Playlists | Works with app backend | Add Gemini API key for unlimited |
| Concerts | Prompt for city on first tap | Add Ticketmaster key for more results |

These features "just work" - no setup required for most users. Power users can add their own API keys in Settings for enhanced functionality.

### Design Rationale

**Explore's "Your Taste"** = A tool. Editable inputs that drive discovery algorithms.

**Profile's "Music Identity"** = A display. Quick snapshot of who you are musically.

This avoids redundancy: full taste breakdown lives in Explore where it's actionable. Profile shows identity stats that are more interesting to followers and change more often.

### Upsides
- Very clean, only 3 tabs
- Less decision fatigue
- No redundant stats between tabs
- Profile stays fresh (Recently Played changes often)
- Clear purpose per tab: Social (Feed), Find (Explore), Me (Profile)
- Setup is impossible to ignore but rewarding to complete

### Downsides
- Feed could get crowded
- Explore does a lot (search + discovery + creation)
- Less prominent playlist creation

### Use Case Coverage
| Use Case | Location | Quality |
|----------|----------|---------|
| Collaboration | Feed, Profile | Good |
| Discovery | Explore | Strong |
| Trending | Feed | Strong |
| Playlist Creation | Explore | Good |
| Gamification | Profile | Strong |
| Setup | Feature gating, progress card, badges, first achievement | Strong |
| Stats | Explore (editable), Profile (identity) | Strong |

---

## Option 4: Instagram/TikTok Social Model

**Tabs: Home, Discover, Inbox, Profile (4 tabs)**

```
Home (Tab 0)
├── Following Feed (primary content)
│   ├── Song shares from following
│   ├── "Currently listening" updates
│   ├── Playlist updates
│   └── Achievements unlocked
├── Trending Section
│   ├── Top songs across platform
│   └── Rising artists
├── For You
│   ├── AI recommendations
│   └── Today's pick
└── Setup banner (if incomplete)

Discover (Tab 1)
├── Search Bar
├── Browse Categories
│   ├── New Releases
│   ├── Concerts
│   ├── By Mood
│   └── By Genre
├── Your Taste Profile
│   ├── Top Genres (editable)
│   ├── Top Artists (editable)
│   └── Top Songs (editable)
├── Shazam
└── Friend-based Discovery
    ├── What friends like
    └── Create blend

Inbox (Tab 2)
├── Direct Shares
│   ├── Songs sent to you
│   ├── Playlist shares
│   └── Song requests
├── Create Actions
│   ├── AI Playlist Builder
│   ├── Friend Blend
│   └── Share Song
├── Vibe-Streak Threads
└── Notifications

Profile (Tab 3)
├── Profile Header
├── Stats
├── Your Playlists
├── Achievements
├── Vibe-Streaks Overview
├── Followers / Following
└── Settings
```

### Upsides
- Very social-first, emphasizes follow model
- Inbox consolidates all direct interactions
- Clear separation: passive (Home), active (Discover), social (Inbox), self (Profile)
- Familiar to Instagram/TikTok users

### Downsides
- Inbox might feel empty without DMs
- Playlist creation buried in Inbox
- Stats less prominent (in Profile)

### Use Case Coverage
| Use Case | Location | Quality |
|----------|----------|---------|
| Collaboration | Home, Inbox | Very Strong |
| Discovery | Discover | Strong |
| Trending | Home | Strong |
| Playlist Creation | Inbox | Okay (hidden) |
| Gamification | Profile, Home feed | Good |
| Setup | Settings, Home banner | Good |
| Stats | Profile | Standard |

---

## Option 5: Content-First Model

**Tabs: For You, Search, Library, Profile (4 tabs)**

```
For You (Tab 0)
├── AI Recommendations
│   ├── Based on taste
│   ├── Based on mood
│   └── Based on time of day
├── Following Activity
│   ├── What friends listen to
│   ├── Shared songs
│   └── Trending in network
├── Trending
│   ├── Popular songs
│   ├── New releases
│   └── Concerts
├── Streak Reminders
└── Setup CTAs

Search (Tab 1)
├── Search Bar
├── Recent Searches
├── Shazam Button
├── Browse by Genre
├── Browse by Mood
└── Results
    ├── Artists
    ├── Albums
    ├── Songs (30s preview)
    └── Playlists

Library (Tab 2)
├── Your Playlists
│   ├── Created
│   └── Saved
├── Create New
│   ├── AI Playlist Builder
│   └── Friend Blend
├── Your Taste (editable)
│   ├── Top Genres
│   ├── Top Artists
│   └── Top Songs
└── Recently Played

Profile (Tab 3)
├── Profile Header
├── Stats Dashboard
├── Achievements
├── Vibe-Streaks
├── Followers / Following
├── Share to Following
└── Settings
```

### Upsides
- Spotify-familiar pattern
- Library emphasizes your content ownership
- Search is dedicated (fast access)
- For You is personalized landing

### Downsides
- Social activity split between For You and Profile
- Library may feel redundant with Profile stats
- Less novel/differentiated

### Use Case Coverage
| Use Case | Location | Quality |
|----------|----------|---------|
| Collaboration | For You, Profile | Good |
| Discovery | For You, Search | Strong |
| Trending | For You | Strong |
| Playlist Creation | Library | Strong |
| Gamification | Profile | Strong |
| Setup | Settings, For You CTAs | Good |
| Stats | Library, Profile | Split |

---

## Comparison Matrix

| Aspect | Option 1 | Option 2 | Option 3 | Option 4 | Option 5 |
|--------|----------|----------|----------|----------|----------|
| **Tab Count** | 4 | 4 | 3 | 4 | 4 |
| **Social Emphasis** | Medium | Low | Medium | Very High | Medium |
| **Discovery Emphasis** | High | High | High | High | High |
| **Playlist Creation** | Split | Strong | Good | Hidden | Strong |
| **Simplicity** | Medium | Medium | High | Medium | Medium |
| **Novelty** | Medium | Medium | Low | High | Low |
| **Learning Curve** | Low | Medium | Very Low | Medium | Very Low |

---

## Recommendation

### For Social-First App: Option 4 (Instagram Model)

If the primary differentiator is the follow/social model, Option 4 makes social the hero. The Feed-style Home and dedicated Inbox mirror patterns users know from Instagram/TikTok.

**Best for:** Apps where "what are my friends listening to" is the #1 question.

### For Discovery-First App: Option 3 (Minimalist)

If discovery and personal taste are the heroes, Option 3 keeps things clean while giving Explore room to breathe. Everything else folds into Feed and Profile naturally.

**Best for:** Apps where finding new music you'll love is the #1 goal.

### For Creation-First App: Option 2 (Activity-Centric)

If playlist creation and sharing are core actions, a dedicated Create tab makes those features first-class citizens instead of buried features.

**Best for:** Apps where "make something and share it" is the #1 action.

---

## Key Design Decisions Needed

1. **What's the primary value prop?**
   - Social: "See what friends listen to" → Option 4
   - Discovery: "Find music you'll love" → Option 3
   - Creation: "Make perfect playlists" → Option 2

2. **How prominent should following/followers be?**
   - Very prominent (like Twitter) → Option 4
   - Moderate (like Spotify) → Options 1, 3, 5
   - Secondary feature → Option 2

3. **Where does playlist creation live?**
   - Own tab (prominent) → Option 2
   - Inside Explore/Discover → Options 1, 3, 5
   - Inside Inbox/Social → Option 4

4. **Where do stats live?**
   - Profile only → Options 1, 3, 4
   - Dedicated Library section → Options 2, 5

5. **Setup CTAs: Aggressive or subtle?**
   - Banner on every tab until complete → More aggressive
   - Home/Settings only → More subtle
   - Red badge on Profile until complete → Middle ground

---

## Setup Flow Considerations

Regardless of navigation model, the setup flow should:

1. **Surface prominently** until music service connected
   - Red dot badge on Settings/Profile
   - Banner on Home tab
   - Blocking modal on first launch

2. **Guide completion**
   - Checklist: "Connect Spotify" / "Connect Apple Music"
   - Show benefits: "Connect to unlock AI recommendations, stats, and more"

3. **Make it skippable** but not invisible
   - User can browse but gets reminded
   - Core features grayed out until connected

4. **Celebrate completion**
   - Achievement unlocked: "Connected!"
   - Immediately show personalized content

---

## Next Steps

1. Choose primary value proposition (Social vs Discovery vs Creation)
2. Select navigation model
3. Detail out each screen
4. Design setup flow
5. Plan gamification integration
