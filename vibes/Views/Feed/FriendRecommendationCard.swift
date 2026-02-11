import SwiftUI

struct FriendRecommendationCard: View {
    let track: UnifiedTrack
    let friendUsernames: [String]

    @Environment(AppRouter.self) private var router
    @Environment(SpotifyRemoteService.self) private var spotifyRemote

    private var isPlaying: Bool {
        spotifyRemote.currentTrack?.id == track.id && spotifyRemote.isPlaying
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "heart.circle.fill")
                    .foregroundStyle(.pink)
                Text("Friends are loving")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.pink)
            }

            // Song row
            HStack(spacing: 12) {
                // Album art with play overlay
                Button {
                    playTrack()
                } label: {
                    ZStack {
                        AsyncImage(url: URL(string: track.albumArtURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.2))
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        // Playing indicator
                        if isPlaying {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.black.opacity(0.4))
                            Image(systemName: "waveform")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .symbolEffect(.variableColor.iterative, options: .repeating)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Track info
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(isPlaying ? Color.accentColor : .primary)

                    Text(track.artistName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    // Friends who shared
                    Text(friendsText)
                        .font(.caption2)
                        .foregroundStyle(.pink)
                        .lineLimit(1)
                }

                Spacer()

                // Actions menu
                Menu {
                    Button {
                        router.presentShareSheet(for: track)
                    } label: {
                        Label("Send", systemImage: "paperplane")
                    }

                    Button {
                        if let uri = track.spotifyUri {
                            SpotifyDataService.shared.openInSpotify(uri: uri)
                        }
                    } label: {
                        Label("Open in Spotify", systemImage: "arrow.up.right")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            Button {
                router.presentShareSheet(for: track)
            } label: {
                Label("Send", systemImage: "paperplane")
            }

            Button {
                if let uri = track.spotifyUri {
                    SpotifyDataService.shared.openInSpotify(uri: uri)
                }
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.right")
            }
        }
    }

    private var friendsText: String {
        switch friendUsernames.count {
        case 1:
            return "@\(friendUsernames[0]) shared this"
        case 2:
            return "@\(friendUsernames[0]) and @\(friendUsernames[1]) shared this"
        default:
            let othersCount = friendUsernames.count - 1
            return "@\(friendUsernames[0]) and \(othersCount) others shared this"
        }
    }

    private func playTrack() {
        if spotifyRemote.currentTrack?.id == track.id {
            spotifyRemote.togglePlayPause()
        } else {
            spotifyRemote.play(track)
        }
    }
}

#Preview {
    FriendRecommendationCard(
        track: UnifiedTrack(
            id: "1",
            name: "Blinding Lights",
            artistName: "The Weeknd",
            albumName: "After Hours",
            albumArtURL: nil,
            spotifyUri: "spotify:track:1",
            durationMs: 200000
        ),
        friendUsernames: ["alice", "bob", "charlie"]
    )
    .padding()
    .environment(AppRouter())
    .environment(SpotifyRemoteService.shared)
}
