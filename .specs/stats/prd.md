# Stats Feature PRD

## Problem

Users connect their Spotify account but have no way to see their listening data within the app. They must leave the app and use Spotify Wrapped or third-party tools to understand their music taste.

## Solution

A Stats screen showing the user's listening habits pulled from Spotify:
- Top Artists
- Top Songs
- Top Genres
- Recently Played

## User Stories

1. As a user, I want to see my top artists so I know who I listen to most
2. As a user, I want to see my top songs so I can rediscover favorites
3. As a user, I want to see my top genres so I understand my music taste
4. As a user, I want to see recently played tracks so I can find songs I heard recently

## Scope

### In Scope
- Top 10 artists (configurable time range)
- Top 10 songs (configurable time range)
- Top 5 genres (derived from top artists)
- Last 20 recently played tracks
- Time range selector: 4 weeks, 6 months, all time
- Tap artist/song to open in Spotify

### Out of Scope
- Listening history beyond Spotify's API limits
- Comparisons with friends
- Historical trends over time
- Apple Music support (Spotify only for MVP)

## Success Metrics

- Users view Stats within first session after connecting Spotify
- Users return to Stats screen on subsequent sessions
