import SwiftUI

struct PlaylistRecommendationsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PlaylistRecommendationsViewModel()
    @ObservedObject private var audioPlayer = AudioPlayerService.shared

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.selectedPlaylist == nil {
                    playlistSelectionView
                } else {
                    recommendationsView
                }
            }
            .navigationTitle(viewModel.selectedPlaylist == nil ? "Select Playlist" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                if viewModel.selectedPlaylist != nil {
                    ToolbarItem(placement: .principal) {
                        Button {
                            viewModel.deselectPlaylist()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.caption.weight(.semibold))
                                Text(viewModel.selectedPlaylist?.name ?? "")
                                    .font(.headline)
                                    .lineLimit(1)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
        .task {
            await viewModel.loadPlaylists()
        }
    }

    // MARK: - Playlist Selection

    private var playlistSelectionView: some View {
        Group {
            if viewModel.isLoadingPlaylists {
                loadingView("Loading playlists...")
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if viewModel.playlists.isEmpty {
                emptyPlaylistsView
            } else {
                playlistList
            }
        }
    }

    private var playlistList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.playlists) { playlist in
                    Button {
                        Task {
                            await viewModel.selectPlaylist(playlist)
                        }
                    } label: {
                        PlaylistSelectionRow(playlist: playlist)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 72)
                }
            }
        }
    }

    private var emptyPlaylistsView: some View {
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

    // MARK: - Recommendations

    private var recommendationsView: some View {
        Group {
            if viewModel.isLoadingRecommendations && viewModel.recommendations.isEmpty {
                loadingView("Analyzing playlist...")
            } else if let error = viewModel.errorMessage, viewModel.recommendations.isEmpty {
                errorView(error)
            } else {
                recommendationsList
            }
        }
    }

    private var recommendationsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.addedCount > 0 {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(viewModel.addedCount) song\(viewModel.addedCount == 1 ? "" : "s") added")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                ForEach(viewModel.recommendations) { rec in
                    RecommendationCard(
                        recommendation: rec,
                        isAdding: viewModel.isAddingSongId == rec.id,
                        isPlaying: isPlaying(rec),
                        onPlay: { playPreview(rec) },
                        onAdd: {
                            Task { await viewModel.addSong(rec) }
                        },
                        onDismiss: { viewModel.dismissSong(rec) }
                    )
                }

                if viewModel.isLoadingRecommendations && !viewModel.recommendations.isEmpty {
                    HStack {
                        ProgressView()
                        Text("Finding more songs...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }

                if viewModel.recommendations.isEmpty && !viewModel.isLoadingRecommendations {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("All caught up!")
                            .font(.headline)
                        Text("Check back later for more recommendations")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 40)
                }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Helpers

    private func loadingView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                Task {
                    if viewModel.selectedPlaylist != nil {
                        await viewModel.selectPlaylist(viewModel.selectedPlaylist!)
                    } else {
                        await viewModel.loadPlaylists()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }

    private func isPlaying(_ rec: PlaylistRecommendation) -> Bool {
        audioPlayer.currentTrackId == rec.track.id && audioPlayer.isPlaying
    }

    private func playPreview(_ rec: PlaylistRecommendation) {
        guard let previewUrl = rec.previewUrl else { return }

        if audioPlayer.currentTrackId == rec.track.id {
            audioPlayer.togglePlayPause()
        } else {
            audioPlayer.playUrl(previewUrl, trackId: rec.track.id)
        }
    }
}

// MARK: - Subviews

struct PlaylistSelectionRow: View {
    let playlist: Playlist

    var body: some View {
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
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var playlistImage: some View {
        if let imageUrl = playlist.images?.first?.url, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    playlistPlaceholder
                }
            }
            .frame(width: 48, height: 48)
            .cornerRadius(4)
        } else {
            playlistPlaceholder.frame(width: 48, height: 48).cornerRadius(4)
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

struct RecommendationCard: View {
    let recommendation: PlaylistRecommendation
    let isAdding: Bool
    let isPlaying: Bool
    let onPlay: () -> Void
    let onAdd: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                albumArt
                trackInfo
                Spacer()
                playButton
            }

            Text(recommendation.recommendation.reason)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack(spacing: 16) {
                Spacer()
                dismissButton
                addButton
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var albumArt: some View {
        if let imageUrl = recommendation.track.album.images.first?.url,
           let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    albumPlaceholder
                }
            }
            .frame(width: 56, height: 56)
            .cornerRadius(8)
        } else {
            albumPlaceholder.frame(width: 56, height: 56).cornerRadius(8)
        }
    }

    private var albumPlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "music.note")
                    .foregroundColor(.secondary)
            }
    }

    private var trackInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recommendation.track.name)
                .font(.headline)
                .lineLimit(1)
            Text(recommendation.track.artists.first?.name ?? "Unknown Artist")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }

    private var playButton: some View {
        Button(action: onPlay) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.green)
        }
    }

    private var dismissButton: some View {
        Button(action: onDismiss) {
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                Text("Skip")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemFill))
            .cornerRadius(20)
        }
        .disabled(isAdding)
    }

    private var addButton: some View {
        Button(action: onAdd) {
            HStack(spacing: 4) {
                if isAdding {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark")
                }
                Text("Add")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.green)
            .cornerRadius(20)
        }
        .disabled(isAdding)
    }
}
