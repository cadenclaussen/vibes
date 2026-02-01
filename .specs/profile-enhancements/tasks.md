# Profile Enhancements - Implementation Tasks

## Phase 1: Infrastructure

### Task 1.1: Add Firebase Storage dependency
- Add FirebaseStorage to Package.swift if not present
- Verify import works
- **Files**: Package.swift (if needed)
- **Estimate**: 5 min

### Task 1.2: Create ProfileService
- Create ProfileService.swift with singleton pattern
- Add uploadProfilePicture() method with image resizing
- Add updateProfile() method for Firestore updates
- **Files**: vibes/Services/ProfileService.swift (new)
- **Depends on**: 1.1

### Task 1.3: Create ProfileViewModel
- Create ProfileViewModel.swift
- Add topGenres, isLoadingGenres state
- Add loadGenres() method using SpotifyDataService
- Add showEditSheet binding
- **Files**: vibes/ViewModels/ProfileViewModel.swift (new)
- **Depends on**: None

## Phase 2: Edit Profile UI

### Task 2.1: Create EditProfileView
- Create sheet view with Cancel/Save toolbar
- Add profile picture tap target with PhotosPicker
- Add displayName TextField with character count
- Add bio TextField (multiline) with character count
- Add loading state during save
- Add error handling with alert
- **Files**: vibes/Views/Profile/EditProfileView.swift (new)
- **Depends on**: 1.2

### Task 2.2: Image resizing utility
- Create UIImage extension for resizing to max dimension
- Resize to 400x400 before upload
- Convert to JPEG with 0.8 compression
- **Files**: vibes/Extensions/UIImage+Resize.swift (new)
- **Depends on**: None

### Task 2.3: Wire up EditProfileView to ProfileService
- Connect Save button to ProfileService.updateProfile()
- Handle image upload if new image selected
- Validate displayName not empty
- Dismiss on success, show error on failure
- **Files**: vibes/Views/Profile/EditProfileView.swift
- **Depends on**: 2.1, 2.2, 1.2

## Phase 3: Genre Chips

### Task 3.1: Create GenreChipsView
- Create horizontal ScrollView with genre pills
- Style pills with accent color background, white text
- Add loading state with shimmer placeholders
- Handle empty state (hide section)
- **Files**: vibes/Views/Profile/GenreChipsView.swift (new)
- **Depends on**: None

### Task 3.2: Load genres in ProfileViewModel
- Call SpotifyDataService.extractTopGenres() with top artists
- Limit to 5 genres
- Handle errors silently (just show no genres)
- **Files**: vibes/ViewModels/ProfileViewModel.swift
- **Depends on**: 1.3

## Phase 4: Profile Integration

### Task 4.1: Update ProfileView with bio display
- Add bio Text below username (if bio exists)
- Style with secondary color, center alignment
- **Files**: vibes/ContentView.swift (ProfileView section)
- **Depends on**: None

### Task 4.2: Add Edit button to ProfileView
- Add Edit button in toolbar or near profile picture
- Only show on own profile (not when viewing others)
- Present EditProfileView sheet on tap
- **Files**: vibes/ContentView.swift (ProfileView section)
- **Depends on**: 2.3

### Task 4.3: Add GenreChipsView to ProfileView
- Add GenreChipsView below follower counts
- Connect to ProfileViewModel.topGenres
- Load genres on appear
- **Files**: vibes/ContentView.swift (ProfileView section)
- **Depends on**: 3.1, 3.2

### Task 4.4: Add genres to UserProfileView (other users)
- Show genres on other users' profiles too
- Load genres based on their top artists (if public)
- Note: May need to skip if we don't have their Spotify data
- **Files**: vibes/Views/Social/UserProfileView.swift
- **Depends on**: 3.1

## Phase 5: Polish & Testing

### Task 5.1: Firebase Storage rules
- Update storage rules to allow user profile uploads
- Test upload permissions
- **Files**: Firebase Console (manual)
- **Depends on**: 1.2

### Task 5.2: Build and test
- Test edit profile flow end-to-end
- Test image upload and display
- Test genre loading
- Test bio display
- Verify persistence after app restart
- **Depends on**: All above

## Dependency Graph

```
1.1 ─────┐
         │
         ▼
1.2 ───────────────┐
         │         │
         ▼         │
2.1 ───► 2.3 ◄─────┤
         ▲         │
2.2 ─────┘         │
                   │
1.3 ───► 3.2       │
         │         │
         ▼         │
3.1 ───► 4.3       │
                   │
4.1 (independent)  │
                   │
4.2 ◄──────────────┘
         │
4.4 ◄────┘

5.1, 5.2 (final)
```

## File Summary

### New Files
- vibes/Services/ProfileService.swift
- vibes/ViewModels/ProfileViewModel.swift
- vibes/Views/Profile/EditProfileView.swift
- vibes/Views/Profile/GenreChipsView.swift
- vibes/Extensions/UIImage+Resize.swift

### Modified Files
- vibes/ContentView.swift (ProfileView section)
- vibes/Views/Social/UserProfileView.swift
