import SwiftUI

struct RecommendationFeedCard: View {
    let track: UnifiedTrack
    let reason: String

    @Environment(AppRouter.self) private var router
    @Environment(SpotifyRemoteService.self) private var spotifyRemote

    private let spotifyService = SpotifyDataService.shared

    var body: some View {
        Button {
            router.navigateToDiscoverMusic()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header with type indicator
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.orange.gradient)
                        .clipShape(Circle())

                    Text("Recommended for You")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                // Track content
                HStack(spacing: 12) {
                    // Album art with play button overlay
                    ZStack {
                        AsyncImage(url: URL(string: track.albumArtURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.orange.opacity(0.2))
                                .overlay {
                                    Image(systemName: "music.note")
                                        .foregroundStyle(.orange.opacity(0.5))
                                }
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        // Playing indicator or play button
                        if isPlaying {
                            PlayingWaveform()
                                .frame(width: 24, height: 24)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(track.name)
                            .font(.headline)
                            .foregroundColor(isPlaying ? .accentColor : .primary)
                            .lineLimit(1)

                        Text(track.artistName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        Text(reason)
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Play button
                    Button {
                        playTrack()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.orange)
                    }
                    .buttonStyle(.plain)

                    // More menu
                    Menu {
                        Button {
                            router.presentShareSheet(for: track)
                        } label: {
                            Label("Send", systemImage: "paperplane")
                        }

                        Button {
                            if let uri = track.spotifyUri {
                                spotifyService.openInSpotify(uri: uri)
                            }
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
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                router.presentShareSheet(for: track)
            } label: {
                Label("Send", systemImage: "paperplane")
            }

            Button {
                if let uri = track.spotifyUri {
                    spotifyService.openInSpotify(uri: uri)
                }
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.forward.app")
            }
        }
        .accessibilityLabel("Recommended song: \(track.name) by \(track.artistName)")
        .accessibilityHint("Double tap to discover more music")
    }

    private var isPlaying: Bool {
        spotifyRemote.currentTrack?.id == track.id && spotifyRemote.isPlaying
    }

    private func playTrack() {
        if isPlaying {
            spotifyRemote.togglePlayPause()
        } else {
            spotifyRemote.play(track)
        }
    }
}

// MARK: - Playing Waveform Animation

private struct PlayingWaveform: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(Color.white)
                    .frame(width: 3)
                    .frame(height: animating ? 16 : 8)
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .padding(4)
        .background(Color.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onAppear { animating = true }
    }
}

#Preview {
    RecommendationFeedCard(
        track: UnifiedTrack(
            id: "1",
            name: "Anti-Hero",
            artistName: "Taylor Swift",
            albumName: "Midnights",
            albumArtURL: nil,
            spotifyUri: "spotify:track:123"
        ),
        reason: "Based on your listening"
    )
    .environment(AppRouter())
    .environment(SpotifyRemoteService.shared)
    .padding()
    .background(Color(.secondarySystemBackground))
}
