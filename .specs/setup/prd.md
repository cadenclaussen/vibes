# Setup Feature - Product Requirements

## Summary

A setup feature that guides users through connecting three required services to unlock the full Vibes experience. A persistent setup card appears at the top of the Feed tab until all three items are configured.

## Problem Statement

Users need to connect multiple external services before they can use core app features. Without clear guidance, users may:
- Not understand which services are required
- Abandon setup partway through
- Miss features because they never connected a service
- Be confused about why certain features are disabled

The setup flow must make it clear what's required, why it matters, and provide frictionless connection for each service.

## Goals

- Guide users through connecting all three required services
- Show clear visual progress (red = incomplete, green = complete)
- Provide instructions for obtaining each required credential
- Allow users to edit previously entered values
- Persist setup card in Feed until all steps complete

## Non-Goals

- Account creation (handled by Google Sign-In before setup)
- Tutorial content (separate onboarding flow)
- Profile customization (optional, not part of required setup)
- Following users (optional, not part of required setup)

## Target Users

New users who have just created a Vibes account via Google Sign-In and need to connect services to unlock features.

## Scope

### Required Setup Steps

| Step | Name | What User Enters | Required For |
|------|------|------------------|--------------|
| 1 | **Connect Spotify** | OAuth authorization | All music features (Feed, Explore, Stats) |
| 2 | **Gemini API Key** | API key string | AI playlist generation, recommendations |
| 3 | **Ticketmaster** | API key + city name | Concert discovery near user |

### Navigation Flow

```
Feed Tab
    |
    v
[Setup Card] (at top of feed, visible until all complete)
    |
    | tap
    v
SetupChecklistView (push navigation)
    |
    +-- [Spotify Button] (red/green)
    |       |
    |       | tap
    |       v
    |   SpotifySetupView (push navigation)
    |       - Instructions for connecting Spotify
    |       - "Connect with Spotify" button (OAuth)
    |
    +-- [Gemini Button] (red/green)
    |       |
    |       | tap
    |       v
    |   GeminiSetupView (push navigation)
    |       - Instructions for getting API key
    |       - Link to Google AI Studio
    |       - Text field for API key
    |       - Save button
    |
    +-- [Ticketmaster Button] (red/green)
            |
            | tap
            v
        TicketmasterSetupView (push navigation)
            - Instructions for getting API key
            - Link to Ticketmaster Developer Portal
            - Text field for API key
            - Text field for city name
            - Save button
```

### Component Details

#### SetupCard

- **Location**: Top of Feed tab, above all feed content
- **Visibility**: Always visible (even when all steps complete)
- **Appearance**: Card with progress indicator (e.g., "1/3 complete" or "Setup Complete")
- **Action**: Tap to push-navigate to SetupChecklistView

#### SetupChecklistView

- **Navigation**: Push from Feed via SetupCard
- **Layout**: Three large buttons stacked vertically
- **Button States**:
  - **Red**: Step not completed
  - **Green**: Step completed
- **Behavior**:
  - Tap any button (red or green) to push-navigate to that step's setup view
  - Green buttons allow editing previously entered values

#### SpotifySetupView

- **Navigation**: Push from SetupChecklistView
- **Content**:
  - Header: "Connect Spotify"
  - Instructions explaining why Spotify is needed
  - "Connect with Spotify" button that triggers OAuth flow
- **On Success**: Mark step complete, pop back to checklist

#### GeminiSetupView

- **Navigation**: Push from SetupChecklistView
- **Content**:
  - Header: "Gemini API Key"
  - Instructions: How to get a free API key
  - Link: Opens Google AI Studio in browser
  - Text field: Paste API key
  - Save button: Validates and saves key
- **Validation**: Test API key before accepting
- **On Success**: Mark step complete, pop back to checklist

#### TicketmasterSetupView

- **Navigation**: Push from SetupChecklistView
- **Content**:
  - Header: "Ticketmaster"
  - Instructions: How to get API key from Ticketmaster Developer Portal
  - Link: Opens Ticketmaster Developer Portal in browser
  - Text field 1: API key
  - Text field 2: City name (with autocomplete if possible)
  - Save button: Validates and saves both values
- **Validation**: Test API key before accepting
- **On Success**: Mark step complete, pop back to checklist

### Data Storage

| Item | Storage Location |
|------|------------------|
| Spotify tokens | iOS Keychain |
| Gemini API key | iOS Keychain |
| Ticketmaster API key | iOS Keychain |
| City name | UserDefaults |
| Setup completion status | UserDefaults + Firestore |

### Visual States

```
Button States:

[Red Button]          [Green Button]
+----------------+    +----------------+
|  (!) Spotify   |    |  (check) Spotify |
|   Not Connected|    |     Connected    |
+----------------+    +----------------+
```

