import SwiftUI

struct AlbumTrackRow: View {
    let track: UnifiedTrack
    let trackNumber: Int
    let onPlay: () -> Void
    let onSendToFriend: () -> Void
    let onAddToPlaylist: () -> Void
    let onOpenInSpotify: () -> Void

    @Environment(SpotifyRemoteService.self) private var spotifyRemote

    private var isCurrentlyPlaying: Bool {
        spotifyRemote.currentTrack?.id == track.id && spotifyRemote.isPlaying
    }

    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 12) {
                // Track number or playing indicator
                ZStack {
                    if isCurrentlyPlaying {
                        Image(systemName: "waveform")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .symbolEffect(.variableColor.iterative)
                    } else {
                        Text("\(trackNumber)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(track.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(isCurrentlyPlaying ? .green : .primary)
                            .lineLimit(1)

                        if track.isExplicit {
                            Text("E")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                    }

                    Text(track.artistName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(track.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .trailing)

                Menu {
                    Button {
                        onSendToFriend()
                    } label: {
                        Label("Send", systemImage: "paperplane")
                    }

                    Button {
                        onOpenInSpotify()
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
            .padding(.vertical, 10)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onSendToFriend()
            } label: {
                Label("Send", systemImage: "paperplane")
            }

            Button {
                onOpenInSpotify()
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.forward.app")
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        AlbumTrackRow(
            track: UnifiedTrack(
                id: "1",
                name: "Hotline Bling",
                artistName: "Drake",
                albumName: "Views",
                durationMs: 267000,
                isExplicit: true
            ),
            trackNumber: 1,
            onPlay: {},
            onSendToFriend: {},
            onAddToPlaylist: {},
            onOpenInSpotify: {}
        )

        AlbumTrackRow(
            track: UnifiedTrack(
                id: "2",
                name: "One Dance",
                artistName: "Drake",
                albumName: "Views",
                durationMs: 177000
            ),
            trackNumber: 2,
            onPlay: {},
            onSendToFriend: {},
            onAddToPlaylist: {},
            onOpenInSpotify: {}
        )
    }
    .environment(SpotifyRemoteService.shared)
}
