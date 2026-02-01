import SwiftUI

struct SongSearchRow: View {
    let track: UnifiedTrack
    let onPlay: () -> Void
    let onOpenInSpotify: () -> Void

    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    @Environment(AppRouter.self) private var router

    private var isCurrentlyPlaying: Bool {
        spotifyRemote.currentTrack?.id == track.id && spotifyRemote.isPlaying
    }

    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 12) {
                ZStack {
                    AsyncImage(url: URL(string: track.albumArtURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.tertiarySystemFill))
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    if isCurrentlyPlaying {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.black.opacity(0.4))
                            .frame(width: 48, height: 48)
                        Image(systemName: "waveform")
                            .font(.body)
                            .foregroundStyle(.white)
                            .symbolEffect(.variableColor.iterative, isActive: true)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(isCurrentlyPlaying ? Color.accentColor : .primary)
                        .lineLimit(1)

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
                        router.presentShareSheet(for: track)
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
            .padding(.vertical, 8)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                router.presentShareSheet(for: track)
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
    VStack {
        SongSearchRow(
            track: UnifiedTrack(
                id: "1",
                name: "One Dance",
                artistName: "Drake",
                albumName: "Views",
                previewURL: "https://example.com/preview.mp3",
                durationMs: 177000
            ),
            onPlay: {},
            onOpenInSpotify: {}
        )
    }
    .environment(SpotifyRemoteService.shared)
    .environment(AppRouter())
}
