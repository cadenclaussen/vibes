# Profile Enhancements - Product Requirements

## Summary

Enhance the Profile page with editable user information (display name, bio, profile picture) and display top genres based on listening data. This makes profiles feel personal and complete.

## Problem Statement

The current Profile page is sparse - it only shows the user's name, username, follower counts, and a stats preview. Users can't personalize their profile or express their music identity. Other users viewing a profile don't get a sense of who the person is or what music they're into.

## Goals

- Allow users to edit their display name and add a bio
- Allow users to change their profile picture
- Display top genres as visual chips/tags
- Make profiles feel personal and expressive

## Non-Goals

- Profile themes/custom colors (future)
- Banner images (future)
- Profile music (playing a song on your profile)
- Privacy settings for profile visibility

## Target Users

All Vibes users who want to personalize their profile and express their music taste.

## User Stories

1. As a user, I want to edit my display name so I can change how I appear to others
2. As a user, I want to add a bio so I can tell others about myself and my music taste
3. As a user, I want to change my profile picture so I can personalize my appearance
4. As a user, I want to see my top genres displayed so others know what music I'm into
5. As a visitor, I want to see someone's bio and genres so I can decide if I want to follow them

## Scope

### In Scope
- Edit Profile sheet with form fields
- Display name editing (max 50 characters)
- Bio editing (max 160 characters)
- Profile picture selection from photo library
- Profile picture upload to Firebase Storage
- Top genres display (up to 5 genres as chips)
- Genre extraction from Spotify listening data

### Out of Scope
- Camera capture for profile picture
- Image cropping/editing
- Genre customization (manual add/remove)
- Profile picture removal (only replace)

## Success Metrics

- Users can successfully update their profile
- Profile changes persist across sessions
- Genres display accurately based on listening data
- Profile picture uploads complete within 5 seconds
