# Vibes - Product Requirements Document

## Overview

Vibes is a social music app for iOS. The MVP focuses on user discovery - finding and connecting with other people on the app.

## Core Feature: User Discovery

Browse and search for other users on the platform.

### Features

**User List**
- View a scrollable list of all users on the app
- Each user row shows:
  - Profile photo
  - Display name
  - @username
- Tap a user to view their profile detail

**User Search**
- Search bar at the top of the user list
- Filter users by display name or username
- Real-time filtering as you type
- Clear button to reset search

**User Profile Detail**
- Profile photo (large)
- Display name
- @username
- Bio (if set)

---

## Future Features

The following features are planned for future releases:

### Follow/Unfollow (Future)
- Follow other users to connect with them
- Unfollow users
- See follower/following counts on profiles
- Following feed with activity from followed users

### Music Features (Future)
- Spotify integration
- Song sharing
- Music discovery
- Concert discovery
- AI recommendations

---

## Navigation Model

### Overview

3-tab navigation: **People** | **Explore** | **Profile**

### People (Tab 0)

Browse and search users on the app.

```
People
+-- Search Bar
+-- User List (scrollable)
    +-- User rows (photo, name, username)
    +-- Tap -> User Profile Detail
```

### Explore (Tab 1)

Placeholder for future music discovery features.

```
Explore
+-- Coming Soon placeholder
```

### Profile (Tab 2)

Your profile and settings.

```
Profile
+-- Profile Header
|   +-- Your photo
|   +-- Display name
|   +-- @username
|   +-- Edit Profile button
+-- Settings (gear icon)
    +-- Account (sign out)
    +-- About
```

---

## Authentication Flow

```
Launch App
    |
    v
Google Sign-In (Firebase Auth)
    |
    v
Main App (People tab)
```

---

## Data Sources

| Content | Source |
|---------|--------|
| User list | Firestore |
| User profiles | Firestore |
| User search | Firestore query |

---

## Technical Stack

### Core
- **Language**: Swift with SwiftUI
- **Architecture**: MVVM
- **Minimum iOS**: 17.0+

### Backend
- **Authentication**: Firebase Auth (Google Sign-In)
- **Database**: Firebase Firestore

### Security
- Firebase Security Rules for data isolation

---

## Firestore Collections

```
users/{userId}
  - uid, email, username, displayName, bio
  - profilePictureURL
  - createdAt, updatedAt
```

---

## Settings Structure

```
Settings
+-- Account
|   +-- Sign Out
+-- About
    +-- Version number
```
