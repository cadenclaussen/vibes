import SwiftUI

struct RecentlyPlayedSection: View {
    let tracks: [RecentTrack]
    let onTrackTap: (UnifiedTrack) -> Void
    var onShare: ((UnifiedTrack) -> Void)?
    var onOpenInSpotify: ((UnifiedTrack) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Played")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            if tracks.isEmpty {
                Text("No recent listening history")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 0) {
                    ForEach(tracks) { recentTrack in
                        RecentTrackRow(recentTrack: recentTrack, onShare: onShare, onOpenInSpotify: onOpenInSpotify) {
                            onTrackTap(recentTrack.track)
                        }

                        if recentTrack.id != tracks.last?.id {
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
}

private struct RecentTrackRow: View {
    let recentTrack: RecentTrack
    var onShare: ((UnifiedTrack) -> Void)?
    var onOpenInSpotify: ((UnifiedTrack) -> Void)?
    let action: () -> Void

    @Environment(SpotifyRemoteService.self) private var spotifyRemote

    private var isPlaying: Bool {
        spotifyRemote.currentTrack?.id == recentTrack.track.id && spotifyRemote.isPlaying
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    AsyncImage(url: URL(string: recentTrack.track.albumArtURL ?? "")) { image in
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
                    Text(recentTrack.track.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(isPlaying ? Color.accentColor : .primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(recentTrack.track.artistName)
                            .foregroundStyle(.secondary)

                        Text("·")
                            .foregroundStyle(.tertiary)

                        Text(recentTrack.relativeTimeString)
                            .foregroundStyle(.tertiary)
                    }
                    .font(.caption)
                    .lineLimit(1)
                }

                Spacer()

                Menu {
                    Button {
                        onShare?(recentTrack.track)
                    } label: {
                        Label("Send", systemImage: "paperplane")
                    }

                    Button {
                        onOpenInSpotify?(recentTrack.track)
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
                onShare?(recentTrack.track)
            } label: {
                Label("Send", systemImage: "paperplane")
            }

            Button {
                onOpenInSpotify?(recentTrack.track)
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.forward.app")
            }
        }
    }
}

#Preview {
    RecentlyPlayedSection(
        tracks: [
            RecentTrack(
                id: "1",
                track: UnifiedTrack(id: "1", name: "One Dance", artistName: "Drake", albumName: "Views"),
                playedAt: Date().addingTimeInterval(-300)
            ),
            RecentTrack(
                id: "2",
                track: UnifiedTrack(id: "2", name: "Anti-Hero", artistName: "Taylor Swift", albumName: "Midnights"),
                playedAt: Date().addingTimeInterval(-3600)
            )
        ],
        onTrackTap: { _ in }
    )
}
