import SwiftUI

struct TopSongsSection: View {
    let songs: [UnifiedTrack]
    let onSongTap: (UnifiedTrack) -> Void
    var onShare: ((UnifiedTrack) -> Void)?
    var onOpenInSpotify: ((UnifiedTrack) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Songs")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                    SongRow(song: song, rank: index + 1, onShare: onShare, onOpenInSpotify: onOpenInSpotify) {
                        onSongTap(song)
                    }

                    if index < songs.count - 1 {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

private struct SongRow: View {
    let song: UnifiedTrack
    let rank: Int
    var onShare: ((UnifiedTrack) -> Void)?
    var onOpenInSpotify: ((UnifiedTrack) -> Void)?
    let action: () -> Void

    @Environment(SpotifyRemoteService.self) private var spotifyRemote

    private var isPlaying: Bool {
        spotifyRemote.currentTrack?.id == song.id && spotifyRemote.isPlaying
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text("\(rank)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isPlaying ? Color.accentColor : .secondary)
                    .frame(width: 20)

                ZStack {
                    AsyncImage(url: URL(string: song.albumArtURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.tertiarySystemFill))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                    if isPlaying {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.black.opacity(0.4))
                            .frame(width: 40, height: 40)
                        Image(systemName: "waveform")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .symbolEffect(.variableColor.iterative, isActive: true)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(song.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(isPlaying ? Color.accentColor : .primary)
                        .lineLimit(1)

                    Text(song.artistName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Menu {
                    Button {
                        onShare?(song)
                    } label: {
                        Label("Send", systemImage: "paperplane")
                    }

                    Button {
                        onOpenInSpotify?(song)
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
            .padding(.horizontal)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onShare?(song)
            } label: {
                Label("Send", systemImage: "paperplane")
            }

            Button {
                onOpenInSpotify?(song)
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.forward.app")
            }
        }
    }
}

#Preview {
    TopSongsSection(
        songs: [
            UnifiedTrack(id: "1", name: "One Dance", artistName: "Drake", albumName: "Views"),
            UnifiedTrack(id: "2", name: "Anti-Hero", artistName: "Taylor Swift", albumName: "Midnights"),
            UnifiedTrack(id: "3", name: "Blinding Lights", artistName: "The Weeknd", albumName: "After Hours")
        ],
        onSongTap: { _ in }
    )
}
