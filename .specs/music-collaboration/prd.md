# Music Collaboration - Product Requirements

## Summary

Social music sharing feature using a follow model (Twitter/Instagram style). Users can follow each other, share songs directly, and see what friends are listening to in real-time.

## Problem Statement

The app currently has strong music discovery and playback features, but no social layer. Users discover great music but have no way to share it with friends or see what their friends are enjoying. Music is inherently social - people want to share songs that resonate with them and discover music through trusted friends rather than algorithms alone.

## Goals

- Enable users to follow/unfollow other users
- Allow direct song sharing between users
- Show real-time friend activity (currently playing)
- Create a feed of shared songs from followed users
- Make sharing feel effortless (one-tap from Now Playing or Search)

## Non-Goals

- Group chats or messaging threads (future feature)
- Collaborative playlists (future feature)
- Public trending/viral content across all users (future feature)
- Song requests from friends (future feature)
- Reactions or comments on shares (future feature)

## Target Users

- Music enthusiasts who want to share discoveries with friends
- Users who trust friend recommendations over algorithm suggestions
- Social users who enjoy seeing what their circle is listening to

## Scope

### Phase 1: Following System
- User search and discovery
- Follow/unfollow functionality
- Followers/following lists on profile
- Follow suggestions based on existing connections

### Phase 2: Song Sharing
- Share button on Now Playing view
- Share from search results (long-press context menu)
- Select recipient(s) from following list
- Optional message with share

### Phase 3: Activity Feed
- Feed of shares from followed users
- Tap to play shared song
- Show who shared and when
- Friend activity sidebar (currently playing)

### Phase 4: Notifications
- Push notification when someone shares a song with you
- Notification when someone follows you
- In-app notification badge
