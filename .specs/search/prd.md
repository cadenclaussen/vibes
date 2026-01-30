# Search Feature PRD

## Problem

Users have no way to find specific songs, artists, or albums within the app. They must leave the app to search in Spotify, breaking the experience.

## Solution

A search feature in the Explore tab that lets users find and preview music directly in the app.

## User Stories

1. As a user, I want to search for songs so I can find music I'm thinking of
2. As a user, I want to search for artists so I can explore their catalog
3. As a user, I want to preview songs (30 seconds) before adding them
4. As a user, I want to open search results in Spotify for full playback

## Scope

### In Scope
- Search songs, artists, albums
- Display search results in categorized sections
- 30-second audio preview for songs
- Tap to open in Spotify
- Recent searches (last 10)
- Clear search / cancel

### Out of Scope
- Playlist search (Spotify API limitations for other users' playlists)
- Full song playback (requires Spotify Premium SDK)
- Offline search
- Voice search
- Filters (genre, year, etc.)

## Success Metrics

- Users can find and preview music without leaving the app
- Search is responsive (results appear within 1 second of typing pause)
