import SwiftUI

struct PlaylistPickerView: View {
    let trackUri: String
    let trackName: String
    let artistName: String
    let albumArtUrl: String?
    let onAdded: () -> Void

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var spotifyService = SpotifyService.shared

    @State private var playlists: [Playlist] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isAdding = false
    @State private var addedToPlaylistId: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                trackHeader
                Divider()
                playlistContent
            }
            .navigationTitle("Add to Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadPlaylists()
        }
    }

    private var trackHeader: some View {
        HStack(spacing: 12) {
            if let urlString = albumArtUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        albumPlaceholder
                    }
                }
                .frame(width: 50, height: 50)
                .cornerRadius(6)
            } else {
                albumPlaceholder
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(trackName)
                    .font(.headline)
                    .lineLimit(1)
                Text(artistName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    private var albumPlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "music.note")
                    .foregroundColor(.secondary)
            }
    }

    @ViewBuilder
    private var playlistContent: some View {
        if isLoading {
            loadingView
        } else if let error = errorMessage {
            errorView(message: error)
        } else if playlists.isEmpty {
            emptyView
        } else {
            playlistList
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
            Text("Loading playlists...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Failed to Load")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                Task { await loadPlaylists() }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Playlists")
                .font(.headline)
            Text("Create a playlist on Spotify first")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private var playlistList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(playlists) { playlist in
                    PlaylistRowView(
                        playlist: playlist,
                        isAdding: isAdding && addedToPlaylistId == playlist.id,
                        wasAdded: !isAdding && addedToPlaylistId == playlist.id
                    ) {
                        Task { await addToPlaylist(playlist) }
                    }
                    Divider()
                        .padding(.leading, 72)
                }
            }
        }
    }

    private func loadPlaylists() async {
        isLoading = true
        errorMessage = nil

        do {
            playlists = try await spotifyService.getUserPlaylists()
            // Filter to only show user's own playlists (can't add to others' playlists)
            if let userId = spotifyService.userProfile?.id {
                playlists = playlists.filter { $0.owner.id == userId }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func addToPlaylist(_ playlist: Playlist) async {
        isAdding = true
        addedToPlaylistId = playlist.id

        do {
            try await spotifyService.addTrackToPlaylist(playlistId: playlist.id, trackUri: trackUri)
            isAdding = false
            // Brief delay to show success state before dismissing
            try? await Task.sleep(nanoseconds: 500_000_000)
            onAdded()
            dismiss()
        } catch {
            isAdding = false
            addedToPlaylistId = nil
            errorMessage = "Failed to add: \(error.localizedDescription)"
        }
    }
}

struct PlaylistRowView: View {
    let playlist: Playlist
    let isAdding: Bool
    let wasAdded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                playlistImage

                VStack(alignment: .leading, spacing: 4) {
                    Text(playlist.name)
                        .font(.body)
                        .lineLimit(1)

                    Text("\(playlist.tracks.total) songs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isAdding {
                    ProgressView()
                } else if wasAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isAdding || wasAdded)
    }

    @ViewBuilder
    private var playlistImage: some View {
        if let imageUrl = playlist.images?.first?.url, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    playlistPlaceholder
                }
            }
            .frame(width: 48, height: 48)
            .cornerRadius(4)
        } else {
            playlistPlaceholder
                .frame(width: 48, height: 48)
                .cornerRadius(4)
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
}
