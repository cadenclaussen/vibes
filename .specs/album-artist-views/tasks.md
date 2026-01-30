# Album Detail & Artist Profile Implementation Tasks

## Phase 1: Kiro Specs
- [x] Task 1.1: Create prd.md
- [x] Task 1.2: Create requirements.md
- [x] Task 1.3: Create design.md
- [x] Task 1.4: Create tasks.md

## Phase 2: Album Detail Feature

### Task 2.1: Create AlbumDetailViewModel
**File**: vibes/ViewModels/AlbumDetailViewModel.swift
**Dependencies**: None
**Description**: Create ViewModel with album state, track loading, and playback methods

### Task 2.2: Create AlbumTrackRow
**File**: vibes/Views/Album/AlbumTrackRow.swift
**Dependencies**: None
**Description**: Track row with number, name, duration, explicit badge, context menu

### Task 2.3: Create AlbumHeaderView
**File**: vibes/Views/Album/AlbumHeaderView.swift
**Dependencies**: None
**Description**: Cover art, album name, tappable artist name, year, track count, Play/Shuffle buttons

### Task 2.4: Create AlbumDetailView
**File**: vibes/Views/Album/AlbumDetailView.swift
**Dependencies**: Task 2.1, 2.2, 2.3
**Description**: Compose header + track list + MiniPlayer

### Task 2.5: Update ContentView for Album
**File**: vibes/ContentView.swift
**Dependencies**: Task 2.4
**Description**: Replace AlbumDetailPlaceholder with AlbumDetailView in navigationDestination

## Phase 3: Artist Profile Feature

### Task 3.1: Create ArtistProfileViewModel
**File**: vibes/ViewModels/ArtistProfileViewModel.swift
**Dependencies**: None
**Description**: Create ViewModel that fetches top tracks and albums

### Task 3.2: Create ArtistHeaderView
**File**: vibes/Views/Artist/ArtistHeaderView.swift
**Dependencies**: None
**Description**: Large image with gradient overlay, artist name, genre chips

### Task 3.3: Create ArtistAlbumsSection
**File**: vibes/Views/Artist/ArtistAlbumsSection.swift
**Dependencies**: None
**Description**: Horizontal scrolling album thumbnails with tap navigation

### Task 3.4: Create ArtistProfileView
**File**: vibes/Views/Artist/ArtistProfileView.swift
**Dependencies**: Task 3.1, 3.2, 3.3
**Description**: Compose header + top songs + albums + MiniPlayer

### Task 3.5: Update ContentView for Artist
**File**: vibes/ContentView.swift
**Dependencies**: Task 3.4
**Description**: Replace ArtistDetailPlaceholder with ArtistProfileView in navigationDestination

## Phase 4: Cross-Navigation

### Task 4.1: Wire AlbumHeaderView artist tap
**Dependencies**: Task 2.3, Task 3.5
**Description**: Tapping artist name in AlbumHeaderView navigates to ArtistProfileView

### Task 4.2: Wire ArtistAlbumsSection album tap
**Dependencies**: Task 3.3, Task 2.5
**Description**: Tapping album in ArtistAlbumsSection navigates to AlbumDetailView

### Task 4.3: End-to-end testing
**Dependencies**: Task 4.1, 4.2
**Description**: Test full navigation flow: search -> album -> artist -> album -> back

## Dependency Graph

```
Phase 1 (Specs)
    ↓
Phase 2 (Album)          Phase 3 (Artist)
    ↓                         ↓
Task 2.5 ─────────────── Task 3.5
    ↓                         ↓
    └────── Phase 4 (Cross-Nav) ──────┘
```
