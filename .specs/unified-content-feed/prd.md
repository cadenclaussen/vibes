# Unified Content Feed - Product Requirements

## Summary
Transform the feed page from a stack of static navigation widgets into a dynamic, content-driven stream. The feed will display contextual cards (upcoming concerts, new releases, song recommendations) interleaved with social content (song shares from friends), creating a unified scrollable experience similar to modern social media feeds.

## Problem Statement
The current feed page displays 5 static widget buttons at the top (Setup, Find People, Concerts, Releases, Discover Music) before showing any actual content. This creates a poor user experience:
- Users must scroll past navigation buttons to see social content
- The widgets feel like a menu, not a feed
- Discovery features are hidden behind generic "go to" buttons rather than showing actual content
- The layout doesn't feel dynamic or personalized

## Goals
- Convert static discovery widgets into dynamic, contextual content cards
- Create a unified feed mixing social shares with personalized discovery content
- Show actual content (real concerts, real releases, real recommendations) instead of navigation buttons
- Maintain quick access to discovery features by making cards tappable to navigate to full feature views
- Hide Setup card automatically once all setup steps are complete
- Keep Find People card visible at the top for social growth
- Allow users to follow artists to personalize their feed with relevant concerts, releases, and recommendations

## Non-Goals
- Building a full algorithmic recommendation engine (use existing services)
- Real-time push notifications for new content
- Infinite scroll with pagination (can be added later)
- User preferences for card types or frequency
- Analytics/tracking of card interactions

## Target Users
- Existing Vibes app users who want a more engaging, content-rich feed experience
- Users who follow artists and want to discover concerts/releases organically
- Social users who share and receive song recommendations from friends

## Scope

### Included
1. **Feed Card Types:**
   - Song Share Card (existing, from friends)
   - Concert Feed Card (upcoming shows from followed artists)
   - New Release Feed Card (albums/singles from followed artists)
   - Song Recommendation Card (AI/algorithmic suggestions)

2. **Card Behavior:**
   - Each card type has distinct visual design
   - Tapping a card navigates to the relevant feature view
   - Cards are interleaved in the feed stream

3. **Top Section:**
   - Setup Card: Visible until all 3 setup items complete, then hidden
   - Find People Card: Always visible at top

4. **Feed Logic:**
   - Fetch and merge content from multiple sources
   - Interleave card types naturally in the stream
   - Pull-to-refresh to reload all content

5. **Artist Following:**
   - Follow button on all artist profile views
   - Following an artist adds their concerts and releases to your feed
   - Followed artists improve music recommendation accuracy
   - Followed artists stored in Firestore for persistence
   - Feed content prioritizes followed artists over Spotify top artists

### Excluded
- Customizable feed preferences
- Card dismissal/hiding
- Push notifications for new cards
- Offline caching of feed content
