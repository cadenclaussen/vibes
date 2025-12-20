//
//  FriendPickerView.swift
//  vibes
//
//  Created by Claude Code on 12/19/25.
//

import SwiftUI
import FirebaseAuth

struct FriendPickerView: View {
    let track: Track
    let previewUrl: String?
    var onSongSent: ((FriendProfile) -> Void)?

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
                            trackPreviewRow
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
            .navigationTitle("Send Song")
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

    private var trackPreviewRow: some View {
        HStack(spacing: 12) {
            albumArtView
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
    }

    private var albumArtView: some View {
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

    private var albumPlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "music.note")
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
        }
        .disabled(isSending)
    }

    private func toggleSelection(_ friend: FriendProfile) {
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

                    let message = Message(
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
                        reactions: nil,
                        timestamp: Date(),
                        read: false
                    )

                    try await FirestoreService.shared.sendMessage(message)
                    successCount += 1
                    lastSentFriend = friend
                } catch {
                    print("Failed to send to \(friend.username): \(error)")
                }
            }

            if successCount == 0 {
                errorMessage = "Failed to send song"
                isSending = false
            } else {
                // Brief delay to show completion
                try? await Task.sleep(nanoseconds: 200_000_000)
                dismiss()

                // Only navigate to conversation if sent to exactly one friend
                if selectedFriendProfiles.count == 1, let friend = lastSentFriend {
                    onSongSent?(friend)
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
            artists: [Artist(id: "1", name: "Test Artist", uri: "spotify:artist:1", externalUrls: nil)],
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
