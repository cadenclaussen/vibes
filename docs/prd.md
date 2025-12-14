# Product Requirements Document

## Overview

### Product Name
vibes

### Version
1.0 - November 2025

### Author(s)
Product Team

## Executive Summary
vibes is a social music sharing app that connects friends through music. Built on Spotify's platform, vibes makes it easy to discover, share, and organize music with your social circle. With AI-powered playlist recommendations, users can find the perfect songs that fit multiple moods and contexts, then instantly share them with friends.

## Problem Statement
Music lovers struggle to share their favorite discoveries with friends in a meaningful way. Existing platforms like Spotify have limited social features - sharing is often one-directional and lacks context. Additionally, finding songs that work across multiple playlists is time-consuming and manual. Users need a dedicated space to build music-based connections and get intelligent help organizing their music across different moods and occasions.

## Goals & Objectives

### Primary Goals
- Create a social-first music sharing experience that strengthens connections between friends
- Simplify music discovery and sharing through intuitive friend-to-friend song recommendations
- Use AI to help users intelligently organize and discover music across multiple playlists
- Build on top of Spotify's ecosystem to leverage existing music libraries and playback

### Secondary Goals
- Create a visually appealing and polished user interface that delights users
- Design engaging animations and transitions that enhance the user experience
- Implement modern iOS design patterns and visual aesthetics
- **Note**: UI polish and visual appeal are important but should be prioritized after core functionality is complete and stable

## Target Users

### User Personas
- **The Music Curator**: Ages 18-28, constantly discovering new music, maintains multiple themed playlists, loves sharing finds with friends, wants their recommendations to be heard and appreciated
- **The Social Listener**: Ages 22-35, music is a way to connect with friends, values recommendations from trusted sources over algorithms, wants to know what friends are listening to
- **The Playlist Perfectionist**: Ages 25-40, spends hours organizing music into playlists for different moods/activities, struggles to find songs that fit multiple contexts, needs help managing large music library

## Requirements

### Functional Requirements

#### 1. Authentication & User Management
- Users can create accounts with email/password
- Users can sign in with Google (Google OAuth)
- Users can choose a unique username during onboarding
- Users can connect their Spotify account via OAuth
- Users can manage profile settings (username, display name, profile picture)
- Secure password reset and account recovery

- **Customizable Profiles ("Spaces"):**
  - Add favorite artists (top 5-10 with auto-sync from Spotify)
  - Add favorite songs/albums
  - Custom bio/about section (200 character limit)
  - Profile background/theme customization
  - Display favorite lyrics or song quotes
  - Music taste tags (genres, moods, vibes)
  - Auto-generated profile from listening history option
  - Pinned songs/playlists
  - Custom profile badges (achievements unlocked)

- **Privacy Controls:**
  - Public vs friends-only profile visibility
  - Real-time listening privacy toggle (show/hide "Now Playing" status)
  - When disabled, display as "Listening privately" to friends
  - Control who can see listening statistics
  - Control who can send friend requests (everyone, friends of friends, no one)
  - Block users from sending messages/songs

#### 2. Friend System
- Users can search for friends by username
- Users can send friend requests
- Users can accept or decline friend requests
- Users can view their friends list
- Users can remove friends
- Users can see friend activity/recently shared songs

- **Music Taste Compatibility:**
  - Calculate compatibility score between users (0-100%)
  - Based on shared artists, genres, and listening patterns
  - Display compatibility percentage on friend profiles
  - "You both love [Artist Name]" insights
  - Show top 5 shared artists between friends
  - Compatibility badge levels (Low <30%, Medium 30-70%, High >70%)

- **Friend Discovery & Suggestions:**
  - Suggest friends with similar music taste
  - "Users who listen to [Artist] you might like"
  - Find friends based on genre preferences
  - Mutual friend suggestions
  - Import from contacts with music compatibility shown
  - Leaderboard of most compatible friends

#### 3. Messaging & Song Sharing
- In-app messaging system for one-on-one conversations with friends
- Users can send text messages to friends
- Users can send songs within message threads
- Users can search for songs using Spotify's catalog (search triggers on return/submit)
- Search returns songs only (not artists or albums)
- Users can play 30-second previews of songs directly in-app
- Users can tap "Share" button on any song to open sharing options
- Share sheet displays options similar to TikTok:
  - **Send to Friends**: Shows list of friends to select (opens message thread)
  - **Top Friends**: Quick access to frequently shared-with friends
  - **Export to Messages**: Share via Apple Messages (iMessage/SMS)
- Users can add captions/messages when sharing songs
- Users can optionally rate songs they send (1-5 stars or similar rating system)
- Users can view message history with each friend (text + songs)
- Users can play shared songs as 30-second previews in-app
- Users can open full songs in Spotify app via deep link
- Users can save shared songs to their Spotify playlists
- Message threads show both text messages and song shares chronologically

- **Quick Reactions:**
  - React to songs with emoji reactions (❤️, 🔥, 💀, 😍, 🎵)
  - Custom vibes-branded stickers ("SLAY", "BANGER", "VIBE")
  - Animated reactions (confetti, flames, hearts)
  - Tap reaction to see who reacted
  - Reactions visible in message thread
  - Quick double-tap to react with default emoji (like Instagram)
  - Low-friction alternative to text responses

#### 4. AI Playlist Recommendations & Discovery
- AI analyzes song characteristics (genre, mood, tempo, energy, etc.)
- AI suggests which user playlists a song would fit into
- AI can find songs that work across multiple specified playlists
- AI can analyze an existing playlist and recommend new songs to add
  - Analyzes the playlist's overall vibe, mood, and characteristics
  - Suggests 5-10 songs that would fit well with the playlist
  - Provides explanations for why each song matches the playlist
  - Users can preview suggested songs before adding
- AI discovers new song releases that match user's music taste
  - Analyzes user's listening habits, playlists, and shared songs
  - Notifies users of new releases that fit their style
  - Shows these recommendations in the notifications section at the top of the Friends tab
  - Users can listen, share, or add to playlists
- Users can accept or reject AI suggestions
- AI learns from user feedback to improve recommendations
- AI provides explanations for why songs match certain playlists

#### 5. Spotify Integration
- Full integration with Spotify Web API
- Access to user's Spotify playlists
- Playback of 30-second song previews in-app using Spotify's preview URLs
- Deep linking to Spotify app for full track playback
- Sync with user's Spotify library
- Add songs to Spotify playlists directly from vibes
- AVPlayer used for in-app preview playback (no Spotify SDK required for v1.0)

#### 6. Social Engagement & Vibestreaks
- Each friendship has a "vibestreak" counter
- Vibestreak increases when both users interact on the same day
- Valid interactions include: sending songs, sending text messages, any communication in the thread
- Streak increments by 1 for each consecutive day both users engage
- Streak resets if either user fails to engage for a day
- Users can view current streak count with each friend (displayed in message thread)
- Visual indicators celebrate milestone streaks (7 days, 30 days, 100 days, etc.)
- Push notifications remind users to maintain streaks with friends
- Leaderboard or stats showing longest streaks

#### 7. Statistics & Friendly Competition
- **Personal Stats Dashboard:**
  - Total listening time (daily, weekly, monthly, all-time)
  - Top artists with listening time breakdown
  - Top songs with play counts
  - Top genres with percentage distribution
  - Songs shared vs received counts
  - Active vibestreaks count
  - Music diversity score (variety of artists/genres)

- **Friend Comparisons:**
  - Compare listening time with friends (weekly/monthly)
  - Compare top artists overlap ("You both love [Artist]")
  - Music compatibility score (percentage match)
  - Who sent more songs this week/month
  - Friendly leaderboards for listening time
  - Genre taste comparison charts

- **Competition Features:**
  - Weekly listening time leaderboard among friends
  - Artist listening time challenges ("Who can listen to [Artist] more this week?")
  - Most songs shared leaderboard
  - Badges and achievements:
    - "Night Owl" (most late-night listening)
    - "Early Bird" (most morning listening)
    - "Genre Explorer" (listened to 10+ genres)
    - "Loyal Fan" (100+ hours with one artist)
    - "Social Butterfly" (shared songs with 10+ friends)

- **Weekly/Monthly Recaps:**
  - Spotify Wrapped-style summaries
  - Top 5 songs of the week/month
  - Most listened artist
  - Total listening time
  - Top friend interactions
  - Shareable graphics for social media
  - Year-end "vibes Wrapped" feature

### Non-Functional Requirements

1. **Performance**:
   - App launch time under 2 seconds
   - Search results return within 1 second
   - AI recommendations generate within 3 seconds
   - Smooth scrolling at 60fps

2. **Security**:
   - All user data encrypted at rest and in transit
   - Secure OAuth implementation for Spotify
   - Password hashing with industry-standard algorithms (bcrypt/Argon2)
   - Rate limiting on API endpoints to prevent abuse
   - Secure token storage for authentication

3. **Scalability**:
   - Support for 100K users in initial launch
   - Database architecture that can scale horizontally
   - Efficient caching for Spotify API calls to stay within rate limits
   - Asynchronous processing for AI recommendations

4. **Accessibility**:
   - VoiceOver support for iOS
   - Dynamic type support
   - Sufficient color contrast (WCAG AA standards)
   - Haptic feedback for key interactions

5. **Design & Aesthetics** (Secondary Priority):
   - Modern, clean interface following iOS Human Interface Guidelines
   - Smooth animations and transitions (120fps on ProMotion displays)
   - Cohesive color scheme and visual identity
   - Custom iconography and illustrations
   - Delightful micro-interactions (streak celebrations, achievement unlocks)
   - Glassmorphism or modern iOS design trends
   - Dark mode support
   - **Implementation Timeline**: Polish UI after core features are functional and tested

### Out of Scope (v1.0)
- **iOS Widgets** (home screen and lock screen widgets - moved to v2.0)
- **Full music streaming/playback** (v1.0 uses 30-second previews only; full playback via Spotify app deep link)
- **Spotify iOS SDK integration** (using preview URLs and AVPlayer instead for v1.0)
- Group chats (only one-on-one messaging in v1.0)
- Public profiles or social feed beyond friends
- Creating custom playlists within vibes (users manage playlists in Spotify)
- Support for music platforms other than Spotify
- Desktop/web versions (iOS only for v1.0)
- In-app purchases or monetization
- Read receipts or typing indicators
- Voice messages or video messages
- Real-time search (search triggers on return/submit only)

## User Experience

### Key User Flows

#### 1. Onboarding Flow
- Download app → Create account → Choose username → Connect Spotify account → Find/add friends → Receive tutorial on sending first song

#### 2. Sending a Song Flow
- Type song query in search field → Press return/submit to trigger search → Results appear (songs only) → Tap song to play 30-second preview (optional) → Tap "Share" button → Share sheet appears with options:
  - Select "Send to Friends" → Choose friend or "Top Friends" → Opens message thread → Song appears in thread with optional caption/rating → Send
  - OR select "Export to Messages" → Opens iOS share sheet → Share via iMessage/SMS with Spotify link
  - OR tap "Open in Spotify" → Deep link to Spotify app for full playback

#### 3. Messaging Flow
- Go to Friends tab → Tap friend from friends list → Opens message thread → View conversation history (text + songs) → Type text message OR tap + to search/send song → Message appears in thread → Vibestreak increments if both users engaged today

#### 4. Notifications Flow
- Open Friends tab → See notifications section at top showing recent messages, new song recommendations, friend requests, and milestones
  - Tap message notification → Opens message thread with that friend
  - Tap song recommendation → Preview song → Share with friends or add to playlist

#### 5. AI Playlist Discovery Flow
- Have a song in mind → Tap "Find Playlists" → AI analyzes song → Shows matching playlists with match scores → User selects playlists → Song added to selected playlists in Spotify

#### 6. Cross-Playlist Discovery Flow
- Select multiple playlists → Request AI to find songs that fit all selected playlists → Review AI suggestions with explanations → Add songs to playlists

#### 7. AI Playlist Enhancement Flow
- Select a playlist → Tap "Get Recommendations" → AI analyzes playlist characteristics → Shows 5-10 recommended songs with explanations → Preview songs → Select songs to add → Songs added to playlist in Spotify

#### 8. Friend Discovery Flow
- Tap "Add Friends" → Search by username or sync contacts → Send friend requests → Wait for acceptance → Start sharing music

#### 9. Vibestreak Maintenance Flow
- Receive notification "Keep your streak alive with [Friend Name]" → Open app → Send song or message to maintain streak → View updated streak count with celebration animation → Share milestone achievements

#### 10. Stats & Competition Flow
- Open Stats tab → View personal listening stats → Tap "Compare with Friends" → Select friend → See side-by-side comparison → View leaderboards → Share weekly recap to social media

#### 11. Profile Customization Flow
- Open Profile tab → Tap "Edit Space" → Add favorite artists (auto-sync or manual) → Add bio and lyrics → Choose background theme → Add music taste tags → Save → Profile updates for friends to see

### Wireframes/Mockups
- Tab-based navigation with 4 main tabs: Search, Friends, Stats, Profile

- **Search tab**:
  - Song search with Spotify catalog (search triggers on return/submit)
  - Search returns songs only (not artists or albums)
  - Tap song to play 30-second preview in-app
  - Each song shows: album art, title, artist, duration
  - Share button opens TikTok-style share sheet
  - "Open in Spotify" button for full track playback
  - Recently searched songs displayed below search field

- **Friends tab**:
  - **Notifications section at top**:
    - Recent messages from friends
    - New song releases that might fit your style (AI-powered)
    - Friend requests and vibestreak milestones
    - Achievement unlocks
  - Friend list with vibestreak counts and profile pictures
  - Real-time "Now Playing" section showing what friends are listening to
  - Tapping a friend opens message thread with text + songs
  - Quick add friend button

- **Stats tab**:
  - Personal listening statistics
  - Friend comparison leaderboards
  - Weekly/monthly recaps
  - Badges and achievements display
  - Shareable graphics
  - Competition challenges

- **Profile tab**:
  - User's customizable "Space" (profile)
  - Favorite artists, songs, albums
  - Custom bio and lyrics
  - Settings and account management
  - Privacy settings

## Technical Considerations

### Dependencies
- **Spotify Web API**: Core dependency for music catalog, authentication, playlist access, listening history, currently playing, 30-second preview URLs
- **AVPlayer/AVFoundation**: For in-app 30-second preview playback (no Spotify iOS SDK required)
- **Backend/Database**: Firebase, Supabase, or custom backend for user data, friendships, song shares, stats, achievements
- **AI/ML Service**: OpenAI API, custom model, or music intelligence API (e.g., Spotify's own audio features)
- **Authentication**: OAuth 2.0 for Spotify and Google sign-in, Firebase Auth or similar for user accounts
- **Push Notifications**: APNs for iOS notifications when friends send songs, vibestreak reminders, achievements
- **Networking**: URLSession or Alamofire for API calls
- **SwiftUI**: For main app UI
- **CloudKit/Firebase**: For real-time sync of listening activity across devices
- **Image Processing**: For generating shareable recap graphics

### Constraints
- **Spotify API Rate Limits**: Must implement caching and efficient API usage
- **Spotify Terms of Service**: Cannot download or store audio files, must comply with usage restrictions
- **iOS Platform**: Requires iOS development expertise (Swift/SwiftUI)
- **AI Costs**: Token costs for AI API calls may require optimization
- **Music Availability**: Song availability varies by region in Spotify's catalog

### Technical Approach

#### Architecture
- **iOS App**: Native SwiftUI application
- **Backend**: RESTful API or GraphQL for user management, friendships, sharing
- **Database**: Relational database (PostgreSQL) or NoSQL (Firestore) for user data, relationships, share history
- **Caching Layer**: Redis or in-memory cache for Spotify API responses

#### Spotify Integration
- OAuth 2.0 flow for user authorization
- Store access tokens securely in iOS Keychain
- Implement token refresh logic
- Use Spotify Web API endpoints for:
  - Search (`/search?type=track`) - songs only
  - Track details (`/tracks/{id}`) - get 30-second preview URLs
  - User playlists (`/me/playlists`)
  - Audio features (`/audio-features/{id}`)
  - Add to playlist (`/playlists/{id}/tracks`)
  - New releases (`/browse/new-releases`)
  - Recently played (`/me/player/recently-played`)
  - Currently playing (`/me/player/currently-playing`)
  - Top artists and tracks (`/me/top/artists`, `/me/top/tracks`)
  - User listening history for statistics
- Song Playback:
  - Extract `preview_url` from track objects (30-second MP3 URLs)
  - Use AVPlayer to stream preview URLs in-app
  - Handle cases where `preview_url` is null (not all tracks have previews)
  - Deep link format: `spotify:track:{id}` for opening in Spotify app

#### AI Implementation
- Fetch song audio features from Spotify (danceability, energy, valence, tempo, etc.)
- Analyze user's playlist characteristics to build playlist "profiles"
- Use similarity algorithms or LLM with embeddings to match songs to playlists
- For playlist enhancement:
  - Analyze all songs in a playlist to determine overall characteristics
  - Search Spotify catalog for songs with similar audio features
  - Rank and filter recommendations based on fit score
  - Generate 5-10 top recommendations with explanations
- For new release discovery:
  - Build user taste profile from their playlists, listening history, and shared songs
  - Monitor Spotify's new releases API for recent additions
  - Match new releases against user taste profile
  - Push notifications to Notifications tab when good matches are found
  - Include explanation for why the release fits their taste
- Provide reasoning for matches (e.g., "High energy and upbeat, matches your Workout playlist")
- Store AI feedback to improve future recommendations

#### Data Models
- **User**: id, username, email, spotifyId, profilePicture, bio, favoriteArtists (array), favoriteSongs (array), musicTasteTags (array), profileTheme, customLyrics, privacySettings, createdAt
- **Friendship**: userId, friendId, status (pending/accepted), vibestreak (integer), lastInteractionDate, compatibilityScore (percentage), createdAt
- **Message**: id, senderId, recipientId, messageType (text/song), content (text or spotifyTrackId), caption, rating (1-5, optional for songs), timestamp, read
- **MessageThread**: id, userId1, userId2, lastMessageTimestamp, unreadCount
- **Notification**: id, userId, notificationType (message/songRecommendation/friendRequest/vibestreakMilestone/achievement), relatedId (messageId/trackId/friendshipId), content, timestamp, read
- **PlaylistProfile**: userId, spotifyPlaylistId, characteristics (JSON), updatedAt
- **Interaction**: id, friendshipId, userId, interactionType (song/message), timestamp (for streak tracking)
- **ListeningStats**: userId, date, totalListeningTime, topArtists (JSON), topSongs (JSON), topGenres (JSON), songsSent, songsReceived
- **Achievement**: id, userId, achievementType (nightOwl/earlyBird/genreExplorer/loyalFan/socialButterfly), unlockedAt, progress
- **Competition**: id, competitionType (weeklyListening/artistChallenge), participants (array of userIds), startDate, endDate, leaderboard (JSON)
- **WeeklyRecap**: id, userId, weekStart, topSongs (array), topArtist, totalListeningTime, topFriendInteractions, shareableGraphic (URL)

## Launch Plan

### Milestones
- **Phase 1: MVP Development** - Core features (auth, friends, basic sharing)
- **Phase 2: Spotify Integration** - Full Spotify API integration and testing
- **Phase 3: AI Features** - Implement AI playlist recommendations
- **Phase 4: Beta Testing** - Invite-only beta with 100-500 users
- **Phase 5: Public Launch** - App Store release

### Rollout Strategy
- Closed beta with friends and family (50 users)
- Expanded beta with music enthusiasts (500 users)
- Collect feedback and iterate
- Soft launch to App Store
- Marketing push to music communities (Reddit, Twitter, TikTok)
- Consider partnerships with music influencers

## Open Questions
- [ ] Should we support Apple Music in addition to Spotify in future versions?
- [ ] How do we handle songs without preview URLs (display message, disable play button)?
- [ ] What AI model/service provides best balance of cost and quality for playlist matching?
- [ ] Should friend requests be mutual or can users follow without acceptance?
- [ ] Do we need content moderation for messages sent with songs?
- [ ] Should there be daily/weekly limits on songs sent to prevent spam?
- [ ] How do we handle users in different Spotify regions (catalog differences)?
- [ ] Should we build our own music recommendation algorithm or use existing services?
- [ ] Should we cache preview URLs or fetch them fresh each time?

## Future Enhancements (v2.0+)

### Planned Features for Future Releases

#### iOS Widgets (High Priority for v2.0)
- **Vibestreak Widget:**
  - Shows active vibestreaks with top friends
  - Compact, medium, and large sizes
  - Tap to open message thread with friend
  - Visual streak flame indicators

- **Now Playing Widget:**
  - Display what friends are currently listening to
  - Scrollable list of active listeners
  - Tap friend to see full song details
  - Quick share button

- **Stats Widget:**
  - Weekly listening time
  - Top artist of the week
  - Songs shared count
  - Compact size for lock screen

- **Quick Share Widget:**
  - Recently played songs
  - One-tap share to top friends
  - Quick access to search

- **Lock Screen Widgets (iOS 16+):**
  - Circular vibestreak counter
  - Rectangular friend activity
  - Inline stats display
  - Customizable colors/styles

#### Other Future Features
- Group chats and group listening sessions
- Apple Music support
- Desktop/web versions
- Advanced AI features (mood-based recommendations, AI DJ)
- In-app purchases and premium features
- Voice/video messages
- Read receipts and typing indicators
- Story/Status feature (24-hour song stories)
- Song challenges and weekly themes

## Appendix

### References
- [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api)
- [Spotify Audio Features](https://developer.spotify.com/documentation/web-api/reference/get-audio-features)
- [OAuth 2.0 Authorization Guide](https://developer.spotify.com/documentation/general/guides/authorization/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Changelog
| Date | Version | Changes | Author |
|------|---------|---------|--------|
| Nov 2025 | 1.0 | Initial draft with core features defined | Product Team |
| Nov 2025 | 1.1 | Updated playback approach to use 30-second previews with AVPlayer; search triggers on return/submit only; search limited to songs only | Product Team |
