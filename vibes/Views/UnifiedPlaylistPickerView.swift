//
//  UnifiedPlaylistPickerView.swift
//  vibes
//
//  Playlist picker that works with both Apple Music and Spotify.
//

import SwiftUI

struct UnifiedPlaylistPickerView: View {
    let track: UnifiedTrack
    let onAdded: () -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject var musicServiceManager = MusicServiceManager.shared

    @State private var playlists: [UnifiedPlaylist] = []
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
            if let urlString = track.album.imageUrl, let url = URL(string: urlString) {
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
                Text(track.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(track.artists.map { $0.name }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding()
        .cardStyle()
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
            Text("Create a playlist in \(musicServiceManager.serviceName) first")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private var playlistList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(playlists) { playlist in
                    UnifiedPlaylistRowView(
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
            let service = musicServiceManager.currentService
            playlists = try await service.getUserPlaylists(limit: 50, offset: 0)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func addToPlaylist(_ playlist: UnifiedPlaylist) async {
        isAdding = true
        addedToPlaylistId = playlist.id

        do {
            let service = musicServiceManager.currentService
            let trackUri = service.getTrackUri(for: track)
            try await service.addTrackToPlaylist(playlistId: playlist.id, trackUri: trackUri)
            HapticService.success()

            LocalAchievementStats.shared.songsAddedToPlaylists += 1
            LocalAchievementStats.shared.checkTimeBasedAchievements()
            LocalAchievementStats.shared.checkResurrection(trackId: track.originalId)
            LocalAchievementStats.shared.checkLocalAchievements()

            isAdding = false
            try? await Task.sleep(nanoseconds: 500_000_000)
            onAdded()
            dismiss()
        } catch {
            HapticService.error()
            isAdding = false
            addedToPlaylistId = nil
            errorMessage = "Failed to add: \(error.localizedDescription)"
        }
    }
}

struct UnifiedPlaylistRowView: View {
    let playlist: UnifiedPlaylist
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

                    Text("\(playlist.trackCount) songs")
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
        if let imageUrl = playlist.imageUrl, let url = URL(string: imageUrl) {
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

#Preview {
    UnifiedPlaylistPickerView(
        track: UnifiedTrack(
            id: "1",
            originalId: "1",
            serviceType: .spotify,
            name: "Test Song",
            artists: [UnifiedArtist(
                id: "1",
                originalId: "1",
                serviceType: .spotify,
                name: "Test Artist",
                imageUrl: nil,
                genres: nil,
                followerCount: nil,
                externalUrl: nil,
                uri: nil
            )],
            album: UnifiedAlbum(
                id: "1",
                originalId: "1",
                serviceType: .spotify,
                name: "Test Album",
                imageUrl: nil,
                releaseDate: "2024",
                trackCount: 10,
                externalUrl: nil,
                uri: nil
            ),
            durationMs: 180000,
            isExplicit: false,
            previewUrl: nil,
            externalUrl: nil,
            uri: nil
        ),
        onAdded: {}
    )
}
