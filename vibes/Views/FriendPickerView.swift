//
//  FriendPickerView.swift
//  vibes
//
//  Created by Claude Code on 12/19/25.
//

import SwiftUI
import FirebaseAuth

enum FriendPickerContent {
    case track(Track, previewUrl: String?)
    case playlist(Playlist)
}

struct FriendPickerView: View {
    let content: FriendPickerContent
    var onSent: ((FriendProfile) -> Void)?

    // Legacy initializer for tracks
    init(track: Track, previewUrl: String?, onSongSent: ((FriendProfile) -> Void)? = nil) {
        self.content = .track(track, previewUrl: previewUrl)
        self.onSent = onSongSent
    }

    // New initializer for playlists
    init(playlist: Playlist, onPlaylistSent: ((FriendProfile) -> Void)? = nil) {
        self.content = .playlist(playlist)
        self.onSent = onPlaylistSent
    }

    @StateObject private var viewModel = FriendsViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var isSending = false
    @State private var selectedFriends: Set<String> = []
    @State private var errorMessage: String?
    @State private var hasLoaded = false

    private var currentUserId: String? {
        AuthManager.shared.user?.uid
    }

    private var selectedCount: Int {
        selectedFriends.count
    }

    private var navigationTitle: String {
        switch content {
        case .track: return "Send Song"
        case .playlist: return "Send Playlist"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !hasLoaded || viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading friends...")
                    Spacer()
                } else if viewModel.friends.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Friends Yet")
                            .font(.headline)
                        Text("Add friends to share songs with them")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        Section {
                            contentPreviewRow
                        }
                        Section("Select Friends") {
                            ForEach(viewModel.friends) { friend in
                                friendSelectRow(friend)
                            }
                        }
                        if let error = errorMessage {
                            Section {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                }

                // Send button at bottom
                if hasLoaded && !viewModel.friends.isEmpty {
                    sendButton
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadFriends()
                hasLoaded = true
            }
        }
    }

    private var sendButton: some View {
        Button {
            sendToSelectedFriends()
        } label: {
            HStack {
                if isSending {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(selectedCount == 0 ? "Select Friends" : "Send to \(selectedCount) Friend\(selectedCount == 1 ? "" : "s")")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedCount > 0 && !isSending ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(selectedCount == 0 || isSending)
        .padding()
    }

    @ViewBuilder
    private var contentPreviewRow: some View {
        switch content {
        case .track(let track, _):
            HStack(spacing: 12) {
                trackArtView(track: track)
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(track.artists.map { $0.name }.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 4)

        case .playlist(let playlist):
            HStack(spacing: 12) {
                playlistArtView(playlist: playlist)
                VStack(alignment: .leading, spacing: 4) {
                    Text(playlist.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text("\(playlist.tracks.total) tracks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func trackArtView(track: Track) -> some View {
        Group {
            if let imageUrl = track.album.images.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        albumPlaceholder
                    @unknown default:
                        albumPlaceholder
                    }
                }
            } else {
                albumPlaceholder
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(6)
    }

    private func playlistArtView(playlist: Playlist) -> some View {
        Group {
            if let imageUrl = playlist.images?.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        playlistPlaceholder
                    @unknown default:
                        playlistPlaceholder
                    }
                }
            } else {
                playlistPlaceholder
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(6)
    }

    private var albumPlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "music.note")
                    .foregroundColor(.secondary)
            }
    }

    private var playlistPlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "music.note.list")
                    .foregroundColor(.secondary)
            }
    }

    private func friendSelectRow(_ friend: FriendProfile) -> some View {
        Button {
            toggleSelection(friend)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color(.tertiaryLabel))

                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("@\(friend.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: selectedFriends.contains(friend.id) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(selectedFriends.contains(friend.id) ? .blue : .secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isSending)
    }

    private func toggleSelection(_ friend: FriendProfile) {
        HapticService.selectionChanged()
        if selectedFriends.contains(friend.id) {
            selectedFriends.remove(friend.id)
        } else {
            selectedFriends.insert(friend.id)
        }
    }

    private func sendToSelectedFriends() {
        guard let currentUserId = currentUserId else {
            errorMessage = "Not logged in"
            return
        }

        let selectedFriendProfiles = viewModel.friends.filter { selectedFriends.contains($0.id) }
        guard !selectedFriendProfiles.isEmpty else { return }

        isSending = true
        errorMessage = nil

        Task {
            var successCount = 0
            var lastSentFriend: FriendProfile?

            for friend in selectedFriendProfiles {
                do {
                    let threadId = try await FirestoreService.shared.getOrCreateThread(
                        userId1: currentUserId,
                        userId2: friend.id
                    )

                    let message: Message
                    switch content {
                    case .track(let track, let previewUrl):
                        message = Message(
                            id: nil,
                            threadId: threadId,
                            senderId: currentUserId,
                            recipientId: friend.id,
                            messageType: .song,
                            textContent: nil,
                            spotifyTrackId: track.id,
                            songTitle: track.name,
                            songArtist: track.artists.map { $0.name }.joined(separator: ", "),
                            albumArtUrl: track.album.images.first?.url,
                            previewUrl: previewUrl,
                            duration: track.durationMs / 1000,
                            caption: nil,
                            rating: nil,
                            playlistId: nil,
                            playlistName: nil,
                            playlistImageUrl: nil,
                            playlistTrackCount: nil,
                            playlistOwnerName: nil,
                            reactions: nil,
                            timestamp: Date(),
                            read: false
                        )

                    case .playlist(let playlist):
                        message = Message(
                            id: nil,
                            threadId: threadId,
                            senderId: currentUserId,
                            recipientId: friend.id,
                            messageType: .playlist,
                            textContent: nil,
                            spotifyTrackId: nil,
                            songTitle: nil,
                            songArtist: nil,
                            albumArtUrl: nil,
                            previewUrl: nil,
                            duration: nil,
                            caption: nil,
                            rating: nil,
                            playlistId: playlist.id,
                            playlistName: playlist.name,
                            playlistImageUrl: playlist.images?.first?.url,
                            playlistTrackCount: playlist.tracks.total,
                            playlistOwnerName: playlist.owner.displayName,
                            reactions: nil,
                            timestamp: Date(),
                            read: false
                        )
                    }

                    try await FirestoreService.shared.sendMessage(message)
                    successCount += 1
                    lastSentFriend = friend

                    // Track for achievements
                    if case .track(let track, _) = content {
                        // Track song message sent for each recipient
                        LocalAchievementStats.shared.songMessagesSent += 1
                        LocalAchievementStats.shared.messagesSent += 1
                        LocalAchievementStats.shared.trackConversation(with: friend.id)

                        // Only track these once per send action
                        if successCount == 1 {
                            let artistName = track.artists.first?.name ?? ""
                            LocalAchievementStats.shared.trackArtistShared(artistName)
                            LocalAchievementStats.shared.trackSongSharedOnFriday()
                            LocalAchievementStats.shared.checkTimeBasedAchievements()
                        }
                    }
                } catch {
                    print("Failed to send to \(friend.username): \(error)")
                }
            }

            let itemName: String
            switch content {
            case .track: itemName = "song"
            case .playlist: itemName = "playlist"
            }

            if successCount == 0 {
                HapticService.error()
                errorMessage = "Failed to send \(itemName)"
                isSending = false
            } else {
                HapticService.success()
                // Brief delay to show completion
                try? await Task.sleep(nanoseconds: 200_000_000)
                dismiss()

                // Only navigate to conversation if sent to exactly one friend
                if selectedFriendProfiles.count == 1, let friend = lastSentFriend {
                    onSent?(friend)
                }
            }
        }
    }
}

#Preview {
    FriendPickerView(
        track: Track(
            id: "123",
            name: "Test Song",
            artists: [Artist(id: "1", name: "Test Artist", uri: "spotify:artist:1", externalUrls: nil, images: nil, genres: nil, followers: nil, popularity: nil)],
            album: Album(
                id: "1",
                name: "Test Album",
                images: [],
                releaseDate: "2024-01-01",
                totalTracks: 10,
                uri: "spotify:album:1"
            ),
            durationMs: 180000,
            explicit: false,
            popularity: 50,
            previewUrl: nil,
            uri: "spotify:track:123",
            externalUrls: ExternalUrls(spotify: "https://open.spotify.com/track/123")
        ),
        previewUrl: nil
    )
}
