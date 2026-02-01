import SwiftUI

struct ArtistTopSongsView: View {
    let artist: UnifiedArtist

    @Environment(AppRouter.self) private var router
    @Environment(SpotifyRemoteService.self) private var spotifyRemote

    @State private var tracks: [UnifiedTrack] = []
    @State private var isLoading = true
    @State private var error: Error?

    private let spotifyService = SpotifyDataService.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                ProgressView("Loading songs...")
            } else if let error = error {
                ContentUnavailableView(
                    "Failed to Load Songs",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(tracks) { track in
                            SongRow(
                                track: track,
                                isPlaying: spotifyRemote.currentTrack?.id == track.id && spotifyRemote.isPlaying,
                                onShare: { router.presentShareSheet(for: track) },
                                onOpenInSpotify: {
                                    if let uri = track.spotifyUri {
                                        spotifyService.openInSpotify(uri: uri)
                                    }
                                }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { playTrack(track) }
                        }

                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }

            if !tracks.isEmpty {
                MiniPlayerView()
            }
        }
        .navigationTitle("Top Songs")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadTracks()
        }
    }

    private func loadTracks() async {
        do {
            tracks = try await spotifyService.getAllArtistTracks(artistId: artist.id, limit: 100)
        } catch {
            self.error = error
        }
        isLoading = false
    }

    private func playTrack(_ track: UnifiedTrack) {
        if spotifyRemote.currentTrack?.id == track.id {
            spotifyRemote.togglePlayPause()
        } else {
            spotifyRemote.playWithQueue(track, queue: tracks)
        }
    }
}

// Compact Apple Music-style row
private struct SongRow: View {
    let track: UnifiedTrack
    let isPlaying: Bool
    var onShare: (() -> Void)?
    var onOpenInSpotify: (() -> Void)?

    var body: some View {
        HStack(spacing: 10) {
            // Album art
            AsyncImage(url: URL(string: track.albumArtURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.15)
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                if isPlaying {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.black.opacity(0.4))
                    Image(systemName: "waveform")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .symbolEffect(.variableColor.iterative, isActive: true)
                }
            }

            // Song info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(track.name)
                        .font(.subheadline)
                        .foregroundStyle(isPlaying ? Color.accentColor : .primary)
                        .lineLimit(1)

                    if track.isExplicit {
                        Image(systemName: "e.square.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                    }
                }

                Text(track.albumName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            // Duration
            Text(track.formattedDuration)
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            // 3-dot menu
            Menu {
                Button {
                    onShare?()
                } label: {
                    Label("Send", systemImage: "paperplane")
                }

                Button {
                    onOpenInSpotify?()
                } label: {
                    Label("Open in Spotify", systemImage: "arrow.up.forward.app")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 8)
        .contextMenu {
            Button {
                onShare?()
            } label: {
                Label("Send", systemImage: "paperplane")
            }

            Button {
                onOpenInSpotify?()
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.forward.app")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ArtistTopSongsView(
            artist: UnifiedArtist(
                id: "3TVXtAsR1Inumwj472S9r4",
                name: "Drake",
                imageURL: nil,
                genres: ["hip-hop", "rap"]
            )
        )
    }
    .environment(AppRouter())
    .environment(SpotifyRemoteService.shared)
}
