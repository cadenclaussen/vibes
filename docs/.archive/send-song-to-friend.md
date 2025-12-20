# Send Song to Friend - Implementation Plan

## Overview

Enable users to send songs from search results to friends, with the song appearing in their DM conversation and being playable directly from the message.

## Current State

### What Already Exists

1. **Message Model** (`vibes/Models/Message.swift`)
   - Already supports `MessageType.song`
   - Has all needed fields: `spotifyTrackId`, `songTitle`, `songArtist`, `albumArtUrl`, `previewUrl`, `duration`, `caption`

2. **MessageThreadViewModel** (`vibes/ViewModels/MessageThreadViewModel.swift:101-132`)
   - Already has `sendSongMessage()` method that creates and sends song messages

3. **SongMessageBubbleView** (`vibes/Views/MessageThreadView.swift:129-197`)
   - Displays song messages with album art, title, artist, duration
   - Has play button but it's non-functional (just an icon)

4. **AudioPlayerService** (`vibes/Services/AudioPlayerService.swift`)
   - Singleton that handles audio playback
   - Used by SearchView for song previews

5. **SearchView** (`vibes/Views/SearchView.swift`)
   - Shows search results with `TrackRow` component
   - Tap plays the preview via AudioPlayerService

## Implementation Steps

### Step 1: Add Send Button to TrackRow

**File**: `vibes/Views/SearchView.swift`

Add a "send" button to each track row that opens a friend picker sheet.

```swift
// In TrackRow, add a send button next to the play indicator
Button {
    // Set the track to send and show friend picker
    onSendTapped(track)
} label: {
    Image(systemName: "paperplane")
        .foregroundColor(.blue)
}

// Add callback to TrackRow
let onSendTapped: (Track) -> Void
```

**Changes needed**:
- Add `onSendTapped` callback parameter to `TrackRow`
- Add send button UI element
- Pass callback from `SearchView` to each `TrackRow`

### Step 2: Create FriendPickerView

**New File**: `vibes/Views/FriendPickerView.swift`

A sheet that displays the user's friends list for selection.

```swift
struct FriendPickerView: View {
    @StateObject private var viewModel = FriendsViewModel()
    let track: Track
    let previewUrl: String?
    let onFriendSelected: (FriendProfile) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(viewModel.friends) { friend in
                Button {
                    onFriendSelected(friend)
                    dismiss()
                } label: {
                    // Friend row with name and username
                }
            }
            .navigationTitle("Send to Friend")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task {
            await viewModel.loadFriends()
        }
    }
}
```

### Step 3: Add State and Sheet to SearchView

**File**: `vibes/Views/SearchView.swift`

Add state for the selected track and friend picker sheet.

```swift
@State private var trackToSend: Track?
@State private var showingFriendPicker = false

// In body, add sheet:
.sheet(isPresented: $showingFriendPicker) {
    if let track = trackToSend {
        FriendPickerView(
            track: track,
            previewUrl: viewModel.getPreviewUrl(for: track),
            onFriendSelected: { friend in
                sendSongToFriend(track: track, friend: friend)
            }
        )
    }
}
```

### Step 4: Implement sendSongToFriend

**File**: `vibes/Views/SearchView.swift` or new `vibes/ViewModels/SongSharingService.swift`

Create a service/method to send the song message.

```swift
func sendSongToFriend(track: Track, friend: FriendProfile) {
    guard let currentUserId = AuthManager.shared.user?.uid else { return }

    Task {
        do {
            // Get or create thread
            let threadId = try await FirestoreService.shared.getOrCreateThread(
                userId1: currentUserId,
                userId2: friend.id
            )

            // Create song message
            let message = Message(
                threadId: threadId,
                senderId: currentUserId,
                recipientId: friend.id,
                messageType: .song,
                spotifyTrackId: track.id,
                songTitle: track.name,
                songArtist: track.artists.map { $0.name }.joined(separator: ", "),
                albumArtUrl: track.album.images.first?.url,
                previewUrl: viewModel.getPreviewUrl(for: track),
                duration: track.durationMs / 1000,
                timestamp: Date(),
                read: false
            )

            try await FirestoreService.shared.sendMessage(message)
            // Show success toast
        } catch {
            // Show error
        }
    }
}
```

### Step 5: Make SongMessageBubbleView Playable

**File**: `vibes/Views/MessageThreadView.swift`

Connect the play button to AudioPlayerService.

```swift
struct SongMessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    @ObservedObject var audioPlayer = AudioPlayerService.shared

    private var isPlaying: Bool {
        audioPlayer.currentTrackId == message.spotifyTrackId && audioPlayer.isPlaying
    }

    var body: some View {
        // ... existing layout ...

        // Replace static play button with functional one
        Button {
            if let previewUrl = message.previewUrl {
                audioPlayer.playUrl(previewUrl, trackId: message.spotifyTrackId ?? message.id ?? "")
            }
        } label: {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.title2)
                .foregroundColor(message.previewUrl != nil ? .blue : .gray)
        }
        .disabled(message.previewUrl == nil)
    }
}
```

Add progress bar and playing state visualization similar to TrackRow.

### Step 6: Show Song Preview in Friends List (Optional Enhancement)

**File**: `vibes/Views/FriendsView.swift`

Show the last message (including song info) under each friend's name.

```swift
private func friendRow(_ friend: FriendProfile) -> some View {
    HStack(spacing: 12) {
        // ... existing avatar ...

        VStack(alignment: .leading, spacing: 2) {
            Text(friend.displayName)
                .font(.headline)

            // Last message preview
            if let lastMessage = viewModel.lastMessages[friend.id] {
                if lastMessage.messageType == .song {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note")
                            .font(.caption)
                        Text(lastMessage.songTitle ?? "Song")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                } else {
                    Text(lastMessage.textContent ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        // ...
    }
}
```

This requires adding `lastMessages: [String: Message]` to FriendsViewModel and fetching the last message for each friend.

## File Changes Summary

| File | Changes |
|------|---------|
| `vibes/Views/SearchView.swift` | Add send button to TrackRow, state for friend picker sheet, sendSongToFriend method |
| `vibes/Views/FriendPickerView.swift` | **NEW** - Friend selection sheet for sending songs |
| `vibes/Views/MessageThreadView.swift` | Make SongMessageBubbleView play button functional with AudioPlayerService |
| `vibes/Views/FriendsView.swift` | (Optional) Show last message preview including songs |
| `vibes/ViewModels/FriendsViewModel.swift` | (Optional) Add lastMessages dictionary and fetch logic |

## UI/UX Flow

1. User searches for a song in Search tab
2. User taps send button (paperplane icon) on a track
3. Friend picker sheet appears showing user's friends
4. User taps a friend to select them
5. Song is sent as a message to that friend's DM thread
6. Success feedback shown (toast or confirmation)
7. Friend sees song message in their DM with user
8. Friend can tap play button to hear 30-second preview

## Testing Checklist

- [ ] Send button appears on search results
- [ ] Friend picker shows all friends
- [ ] Song message appears in DM thread after sending
- [ ] Play button works in song message bubble
- [ ] Progress bar shows during playback
- [ ] Pause/resume works correctly
- [ ] Message shows for both sender and recipient
- [ ] Handle case when no preview URL available
- [ ] Error handling for send failures

## Considerations

1. **No preview available**: Some tracks don't have preview URLs. Show disabled play button with tooltip/alert.

2. **Thread creation**: If no existing DM thread with friend, one needs to be created first. The `getOrCreateThread` method handles this.

3. **Real-time updates**: Firestore listeners should pick up the new message automatically on both ends.

4. **Audio session**: AudioPlayerService already handles audio session configuration.

5. **iTunes fallback**: The existing SearchViewModel fetches iTunes previews as fallback. May need to pass this to the song message or handle it differently for received messages.
