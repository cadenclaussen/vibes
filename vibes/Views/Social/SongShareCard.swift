import SwiftUI

struct SongShareCard: View {
    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    @Environment(AppRouter.self) private var router
    let share: SongShare
    var onSenderTap: (() -> Void)?

    private let spotifyService = SpotifyDataService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: sender info and timestamp
            HStack(spacing: 8) {
                Button {
                    onSenderTap?()
                } label: {
                    HStack(spacing: 8) {
                        AsyncImage(url: URL(string: share.senderProfilePicture ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color(.tertiarySystemFill))
                                .overlay {
                                    Text(share.senderUsername.prefix(1).uppercased())
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                }
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())

                        Text("@\(share.senderUsername)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)

                Text("·")
                    .foregroundStyle(.tertiary)

                Text(share.timestamp.relativeTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            // Optional message
            if let message = share.message, !message.isEmpty {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            // Track card
            Button {
                playTrack()
            } label: {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: share.albumArtURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.tertiarySystemFill))
                            .overlay {
                                Image(systemName: "music.note")
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(share.trackName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(share.artistName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Play indicator
                    Image(systemName: isCurrentlyPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.accentColor)

                    // 3-dot menu
                    Menu {
                        Button {
                            router.presentShareSheet(for: asUnifiedTrack)
                        } label: {
                            Label("Send", systemImage: "paperplane")
                        }

                        Button {
                            spotifyService.openInSpotify(uri: "spotify:track:\(share.spotifyTrackId)")
                        } label: {
                            Label("Open in Spotify", systemImage: "arrow.up.forward.app")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button {
                    router.presentShareSheet(for: asUnifiedTrack)
                } label: {
                    Label("Send", systemImage: "paperplane")
                }

                Button {
                    spotifyService.openInSpotify(uri: "spotify:track:\(share.spotifyTrackId)")
                } label: {
                    Label("Open in Spotify", systemImage: "arrow.up.forward.app")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var isCurrentlyPlaying: Bool {
        spotifyRemote.currentTrack?.id == share.spotifyTrackId && spotifyRemote.isPlaying
    }

    private var asUnifiedTrack: UnifiedTrack {
        UnifiedTrack(
            id: share.spotifyTrackId,
            name: share.trackName,
            artistName: share.artistName,
            albumName: "",
            albumArtURL: share.albumArtURL,
            previewURL: share.previewURL,
            spotifyUri: "spotify:track:\(share.spotifyTrackId)"
        )
    }

    private func playTrack() {
        if isCurrentlyPlaying {
            spotifyRemote.togglePlayPause()
        } else {
            spotifyRemote.play(asUnifiedTrack)
        }
    }
}

// MARK: - Date Extension

private extension Date {
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    VStack(spacing: 0) {
        SongShareCard(
            share: SongShare(
                senderId: "1",
                senderUsername: "johnsmith",
                senderProfilePicture: nil,
                recipientId: "2",
                spotifyTrackId: "abc123",
                trackName: "Bohemian Rhapsody",
                artistName: "Queen",
                albumArtURL: "",
                message: "Check out this classic!",
                timestamp: Date().addingTimeInterval(-7200)
            )
        )

        Divider()

        SongShareCard(
            share: SongShare(
                senderId: "1",
                senderUsername: "musiclover",
                senderProfilePicture: nil,
                recipientId: "2",
                spotifyTrackId: "def456",
                trackName: "Blinding Lights",
                artistName: "The Weeknd",
                albumArtURL: "",
                message: nil,
                timestamp: Date().addingTimeInterval(-3600)
            )
        )
    }
    .environment(SpotifyRemoteService.shared)
    .environment(AppRouter())
}
