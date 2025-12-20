# Implementation Plan

Refactoring vibes app to match the vision in `user-journeys.md`.

---

## Current State

**Tabs:** Search, Chats, Stats (placeholder), Profile

**What exists:**
- Search with Spotify song search, preview playback, share to friend, add to playlist
- Chats with DMs, song sharing, vibestreaks
- Stats tab is just a placeholder
- Profile with basic info, Spotify connection, friends list

---

## Target State

**Tabs:** Discover, Search, Chats, Profile

**Key changes:**
- New Discover tab as home/landing page
- Stats merged into Profile tab
- Enhanced UI across all tabs
- New features: recommendations, friend activity, reactions, badges

---

## Phase 1: Tab Structure & Profile Foundation

### 1.1 Remove Stats Tab, Merge into Profile

**Files to modify:**
- `vibes/ContentView.swift` - Remove Stats tab from TabView
- `vibes/Views/ProfileView.swift` - Add stats sections

**Steps:**
1. Remove `StatsTab` struct from ContentView.swift
2. Update TabView to only have 4 tabs: Discover, Search, Chats, Profile
3. Reorder tabs (Discover first as home)

### 1.2 Build Profile Stats Section

**New Spotify API methods needed in `SpotifyService.swift`:**
- `getTopArtists(timeRange:limit:)` - Uses `/me/top/artists`
- `getTopTracks(timeRange:limit:)` - Uses `/me/top/tracks`

**New models in `SpotifyModels.swift`:**
```swift
struct TopArtistsResponse: Codable {
    let items: [Artist]
    let total: Int
}

struct TopTracksResponse: Codable {
    let items: [Track]
    let total: Int
}
```

**Time ranges:** `short_term` (4 weeks), `medium_term` (6 months), `long_term` (all time)

**UI components for ProfileView:**
- Time period picker (segmented control)
- Top Artists grid (album art grid, 3x2 or scrollable)
- Top Songs list (with play counts if available)
- Listening stats summary (minutes listened estimate)

### 1.3 Add Recently Played Section

**Spotify API:** Already have `getRecentlyPlayed()` in SpotifyService

**UI:** Horizontal scroll of recent tracks with album art, tap to preview

### 1.4 Profile UI Refresh

**Sections in order:**
1. Profile header (photo, name, username, bio)
2. Spotify connection status
3. Time period picker
4. Listening stats summary
5. Top Artists
6. Top Songs
7. Recently Played
8. Friends list (moved lower)
9. Settings

---

## Phase 2: Discover Tab (New Home)

### 2.1 Create Discover Tab Shell

**New files:**
- `vibes/Views/DiscoverView.swift`
- `vibes/ViewModels/DiscoverViewModel.swift`

**Basic structure:**
```swift
struct DiscoverView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    NowPlayingSection()
                    NewReleasesSection()
                    ForYouSection()
                    TrendingSection()
                }
            }
            .navigationTitle("Discover")
        }
    }
}
```

### 2.2 Now Playing (Friends) Section

**Data needed:**
- Friends list
- Each friend's currently playing track (Spotify API)

**Spotify API:** `getCurrentlyPlaying()` - already exists, but need to call for each friend

**Challenge:** Can't get friends' Spotify data without their tokens. Options:
- Store friends' currently playing in Firestore (they update it)
- Poll when app is open, write to Firestore
- Show only friends who have shared recently instead

**Simpler approach:** Show "Recently Active" - friends who shared songs recently, with their last shared song.

### 2.3 New Releases Section

**Spotify API:** `getNewReleases(limit:)` - Add to SpotifyService
- Endpoint: `/browse/new-releases`

**UI:** Horizontal scroll of album cards with:
- Album art
- Album name
- Artist name
- Tap to view tracks / preview

### 2.4 For You (Recommendations) Section

**Spotify API:** `getRecommendations(seedTracks:seedArtists:limit:)` - Add to SpotifyService
- Endpoint: `/recommendations`
- Seeds: Use user's top tracks/artists as seeds

**UI:** Vertical list or carousel of recommended tracks
- "Because you like [Artist]" subtitle
- Album art, track name, artist
- Tap to preview, quick save/share buttons

### 2.5 Trending Among Friends

**Data source:** Firestore - aggregate songs shared by friends in last 7 days

**Query:**
- Get all messages of type "song" from friends in last 7 days
- Group by spotifyTrackId, count occurrences
- Sort by count descending

**UI:** List of trending songs with:
- Album art
- Track name, artist
- "Shared by [friend1], [friend2]..." or "3 friends shared this"

---

## Phase 3: Search Enhancements

### 3.1 Recent Searches

**Storage:** UserDefaults or local array
- Store last 10 search queries
- Show when search field is empty

**UI:**
- "Recent" header with "Clear" button
- List of recent search terms
- Tap to re-execute search

### 3.2 Search Filters/Segments

**Segments:** Songs | Artists | Albums | Playlists

**Spotify API updates:**
- Modify `searchTracks` to accept `type` parameter
- Support: `track`, `artist`, `album`, `playlist`

**UI:** Segmented control below search bar

### 3.3 Improved Results UI

**For Artists:**
- Artist image (circular)
- Artist name
- Follower count
- Tap to view top tracks

**For Albums:**
- Album art
- Album name
- Artist name
- Release year
- Tap to view tracks

**For Playlists:**
- Playlist image
- Playlist name
- Owner name
- Track count

---

## Phase 4: Chats Enhancements

### 4.1 Visual Refresh

**Message bubbles:**
- Softer corners
- Better spacing
- Improved typography
- Time stamps on tap/swipe

**Song bubbles:**
- Larger album art
- More prominent play button
- Progress bar while playing
- Cleaner layout

### 4.2 Song Reactions

**Reaction types:** 🔥 ❤️ 💯 😐 (fire, heart, 100, meh)

**Data model update in `Message.swift`:**
```swift
var reactions: [String: String]?  // Already exists: [userId: emoji]
```

**UI:**
- Long press on song message to show reaction picker
- Reactions display below song bubble
- Tap existing reaction to add same one

### 4.3 Group Chats

**New models:**
```swift
struct GroupChat: Codable, Identifiable {
    var id: String?
    var name: String
    var memberIds: [String]
    var createdBy: String
    var createdAt: Date
    var lastMessageTimestamp: Date
    var lastMessageContent: String
}
```

**Firestore structure:**
- `groupChats` collection
- `groupChats/{groupId}/messages` subcollection

**UI:**
- "New Group" button in Chats tab
- Group name and member picker
- Group chat view similar to DM view
- Member avatars in header

### 4.4 Playlist Sharing

**Message type:** Add `.playlist` to MessageType enum

**New fields in Message:**
```swift
var playlistId: String?
var playlistName: String?
var playlistImageUrl: String?
var playlistTrackCount: Int?
```

**UI:**
- Playlist card in chat
- Tap to expand and see tracks
- "Add all to library" button

---

## Phase 5: Polish & Gamification

### 5.1 Vibestreak Rewards

**Streak tiers:**
| Days | Icon | Color |
|------|------|-------|
| 1-6 | flame | gray |
| 7-29 | flame | bronze |
| 30-99 | flame | silver |
| 100-364 | flame | gold |
| 365+ | flame.fill | animated |

**UI:** Update streak display in Chats list and message thread header

### 5.2 Music Personality Card

**Algorithm:**
- Analyze top genres from top artists
- Determine primary and secondary genre preferences
- Generate personality label

**Examples:**
- "Indie Explorer" - mostly indie with variety
- "Hip-Hop Head" - primarily hip-hop/rap
- "Genre Fluid" - no dominant genre
- "Throwback Fan" - older release dates

**UI:**
- Card in Profile tab
- Shareable image generation
- Share to chat or export

### 5.3 Achievements/Badges

**Badge types:**
| Badge | Criteria |
|-------|----------|
| Early Adopter | Joined in first year |
| Streak Starter | First 7-day streak |
| Streak Master | 100-day streak |
| Tastemaker | 10 songs you shared were saved by friends |
| Explorer | Listened to 10+ genres |
| Socialite | 10+ friends added |
| Completionist | Listened to full album |

**Storage:** Firestore user document with `badges: [String]` array

**UI:** Badge grid in Profile, earn notifications

### 5.4 Onboarding Flow

**Screens:**
1. Welcome + value prop
2. Sign up / Sign in
3. Connect Spotify (required)
4. Find friends (contacts or search)
5. Quick tutorial (swipe through tabs)
6. Land on Discover

**Implementation:**
- `OnboardingView.swift` with paged flow
- Track onboarding completion in UserDefaults
- Show only for new users

---

## File Structure (New/Modified)

```
vibes/
├── Views/
│   ├── DiscoverView.swift (NEW)
│   ├── ProfileView.swift (MODIFIED - add stats)
│   ├── SearchView.swift (MODIFIED - filters, recent)
│   ├── ChatsView.swift (MODIFIED - groups)
│   ├── MessageThreadView.swift (MODIFIED - reactions)
│   ├── OnboardingView.swift (NEW)
│   └── Components/
│       ├── TopArtistsGrid.swift (NEW)
│       ├── TopSongsList.swift (NEW)
│       ├── RecentlyPlayedRow.swift (NEW)
│       ├── NewReleaseCard.swift (NEW)
│       ├── RecommendationCard.swift (NEW)
│       ├── TrendingSongRow.swift (NEW)
│       ├── ReactionPicker.swift (NEW)
│       └── MusicPersonalityCard.swift (NEW)
├── ViewModels/
│   ├── DiscoverViewModel.swift (NEW)
│   └── ProfileViewModel.swift (NEW or MODIFIED)
├── Services/
│   └── SpotifyService.swift (MODIFIED - new endpoints)
├── Models/
│   ├── SpotifyModels.swift (MODIFIED - new response types)
│   ├── Message.swift (MODIFIED - playlist type)
│   └── GroupChat.swift (NEW)
└── ContentView.swift (MODIFIED - tab order)
```

---

## API Additions to SpotifyService

```swift
// Top items
func getTopArtists(timeRange: String, limit: Int) async throws -> [Artist]
func getTopTracks(timeRange: String, limit: Int) async throws -> [Track]

// Discovery
func getNewReleases(limit: Int) async throws -> [Album]
func getRecommendations(seedTracks: [String], seedArtists: [String], limit: Int) async throws -> [Track]

// Search enhancements
func search(query: String, types: [String], limit: Int) async throws -> SearchResults
```

---

## Priority Order

1. **Phase 1** - Foundation, quick wins, simplifies tab bar
2. **Phase 2** - Core differentiator, makes app feel complete
3. **Phase 4.2** - Reactions are high engagement, low effort
4. **Phase 3** - Search improvements are nice-to-have
5. **Phase 4.3-4.4** - Group chats and playlist sharing are larger efforts
6. **Phase 5** - Polish after core features work

---

## Notes

- All Spotify API calls need proper scopes - check current scopes cover new endpoints
- Consider rate limiting on Discover tab (lots of API calls)
- Cache aggressively - top artists/tracks don't change often
- Test with users who have limited Spotify history
