# Profile Enhancements - Design

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────┐
│                     ProfileView                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Profile Header                      │    │
│  │  ┌──────┐                                       │    │
│  │  │ Edit │  (own profile only)                   │    │
│  │  └──────┘                                       │    │
│  │     ┌─────────┐                                 │    │
│  │     │  Photo  │                                 │    │
│  │     └─────────┘                                 │    │
│  │    Display Name                                 │    │
│  │     @username                                   │    │
│  │   "Bio text here..."                           │    │
│  │                                                 │    │
│  │    1 Followers    1 Following                  │    │
│  │                                                 │    │
│  │  ┌────────┐ ┌─────┐ ┌──────┐ ┌─────┐          │    │
│  │  │Hip Hop │ │ R&B │ │ Trap │ │ Pop │          │    │
│  │  └────────┘ └─────┘ └──────┘ └─────┘          │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │              StatsPreviewCard                    │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                  EditProfileView (Sheet)                 │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Cancel              Edit Profile           Save │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│              ┌─────────────┐                            │
│              │    Photo    │  ← Tap to change           │
│              │   (camera)  │                            │
│              └─────────────┘                            │
│              Change Photo                               │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │ Display Name                                     │    │
│  │ ┌─────────────────────────────────────────────┐ │    │
│  │ │ Caden Claussen                          50  │ │    │
│  │ └─────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │ Bio                                              │    │
│  │ ┌─────────────────────────────────────────────┐ │    │
│  │ │ Music lover, hip hop enthusiast         160 │ │    │
│  │ │                                              │ │    │
│  │ └─────────────────────────────────────────────┘ │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
User taps Edit → EditProfileView presented
                         │
                         ▼
              ┌──────────────────┐
              │  Form Fields     │
              │  - displayName   │
              │  - bio           │
              │  - newImage      │
              └────────┬─────────┘
                       │ Save tapped
                       ▼
              ┌──────────────────┐
              │  Validate        │
              │  - name not empty│
              │  - lengths ok    │
              └────────┬─────────┘
                       │
        ┌──────────────┴──────────────┐
        │ Has new image?              │
        ▼                             ▼
┌───────────────┐            ┌───────────────┐
│ Upload to     │            │ Skip upload   │
│ Firebase      │            │               │
│ Storage       │            │               │
└───────┬───────┘            └───────┬───────┘
        │                            │
        └──────────────┬─────────────┘
                       ▼
              ┌──────────────────┐
              │ Update Firestore │
              │ UserProfile      │
              └────────┬─────────┘
                       │
                       ▼
              ┌──────────────────┐
              │ Dismiss sheet    │
              │ Refresh profile  │
              └──────────────────┘
```

## UI Components

### ProfileHeaderView (Updated)

The existing profile header in ContentView will be extracted and enhanced:

```swift
struct ProfileHeaderView: View {
    let profile: UserProfile
    let isOwnProfile: Bool
    let genres: [String]
    let isLoadingGenres: Bool
    var onEditTapped: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            // Edit button (own profile only)
            // Profile picture
            // Display name
            // Username
            // Bio (if present)
            // Follower/Following counts
            // Genre chips
        }
    }
}
```

### EditProfileView

New sheet view for editing profile:

```swift
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager

    @State private var displayName: String
    @State private var bio: String
    @State private var selectedImage: UIImage?
    @State private var showPhotoPicker = false
    @State private var isSaving = false
    @State private var error: Error?

    // Form with photo picker trigger, text fields, character counts
}
```

### GenreChipsView

Reusable component for displaying genres:

```swift
struct GenreChipsView: View {
    let genres: [String]
    let isLoading: Bool

    var body: some View {
        // Horizontal scroll of pill-shaped chips
        // Shimmer placeholders when loading
    }
}
```

## Firebase Storage

### Image Upload Path

```
users/{userId}/profile.jpg
```

### Storage Rules

```javascript
match /users/{userId}/{allPaths=**} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

## Data Model Updates

### UserProfile (existing model)

The `bio` field already exists in the UserProfile model. No model changes needed.

```swift
struct UserProfile: Codable, Identifiable {
    var id: String { uid }
    let uid: String
    let email: String
    var username: String
    var displayName: String
    var bio: String?                    // Already exists
    var profilePictureURL: String?      // Already exists
    var spotifyLinked: Bool?
    var geminiKeyConfigured: Bool?
    var createdAt: Date?
    var updatedAt: Date?
}
```

## Services

### ProfileService (new)

```swift
@Observable
@MainActor
final class ProfileService {
    static let shared = ProfileService()

    func uploadProfilePicture(_ image: UIImage, userId: String) async throws -> String
    func updateProfile(displayName: String, bio: String?, imageURL: String?) async throws
}
```

### SpotifyDataService (existing)

Already has `extractTopGenres(from artists:)` method that returns `[String]`.

## State Management

### ProfileViewModel (new or extend existing)

```swift
@Observable
@MainActor
final class ProfileViewModel {
    var topGenres: [String] = []
    var isLoadingGenres = false
    var showEditSheet = false

    func loadGenres() async
}
```
