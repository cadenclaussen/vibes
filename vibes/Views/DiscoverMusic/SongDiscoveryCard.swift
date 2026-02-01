import SwiftUI

struct SongDiscoveryCard: View {
    let track: UnifiedTrack
    let onDismiss: () -> Void
    var onAddToPlaylist: (() -> Void)?
    var onOpenInSpotify: (() -> Void)?
    var onSendToFriend: (() -> Void)?

    @Environment(\.openURL) private var openURL
    @Environment(SpotifyRemoteService.self) private var spotifyRemote

    private var isPlaying: Bool {
        spotifyRemote.currentTrack?.id == track.id && spotifyRemote.isPlaying
    }

    var body: some View {
        HStack(spacing: 12) {
            albumArt

            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.headline)
                    .foregroundStyle(isPlaying ? Color.accentColor : .primary)
                    .lineLimit(1)

                Text(track.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(track.albumName)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()

            moreMenu

            dismissButton
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(track.name) by \(track.artistName)")
        .accessibilityHint("Tap X to dismiss, or long press for more options")
        .accessibilityAction(named: "Add to Playlist") {
            onAddToPlaylist?()
        }
        .accessibilityAction(named: "Open in Spotify") {
            openInSpotify()
        }
        .accessibilityAction(named: "Send to Friend") {
            onSendToFriend?()
        }
        .contextMenu {
            Button {
                onSendToFriend?()
            } label: {
                Label("Send", systemImage: "paperplane")
            }

            Button {
                openInSpotify()
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.forward.app")
            }

            Divider()

            Button(role: .destructive) {
                onDismiss()
            } label: {
                Label("Not Interested", systemImage: "xmark")
            }
        }
    }

    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            onAddToPlaylist?()
        } label: {
            Label("Add to Playlist", systemImage: "plus.circle")
        }

        Button {
            openInSpotify()
        } label: {
            Label("Open in Spotify", systemImage: "arrow.up.right")
        }

        Button {
            onSendToFriend?()
        } label: {
            Label("Send to Friend", systemImage: "paperplane")
        }

        Divider()

        Button(role: .destructive) {
            onDismiss()
        } label: {
            Label("Not Interested", systemImage: "xmark")
        }
    }

    private func openInSpotify() {
        if let action = onOpenInSpotify {
            action()
            return
        }

        // default behavior: open spotify uri or web url
        if let uri = track.spotifyUri,
           let url = URL(string: uri) {
            openURL(url)
        } else {
            // fallback to web
            let webURL = URL(string: "https://open.spotify.com/track/\(track.id)")!
            openURL(webURL)
        }
    }

    private var albumArt: some View {
        ZStack {
            Group {
                if let urlString = track.albumArtURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            albumPlaceholder
                        case .empty:
                            ProgressView()
                        @unknown default:
                            albumPlaceholder
                        }
                    }
                } else {
                    albumPlaceholder
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if isPlaying {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.black.opacity(0.4))
                    .frame(width: 64, height: 64)
                Image(systemName: "waveform")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .symbolEffect(.variableColor.iterative, isActive: true)
            }
        }
    }

    private var albumPlaceholder: some View {
        ZStack {
            Color(.tertiarySystemBackground)
            Image(systemName: "music.note")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }

    private var moreMenu: some View {
        Menu {
            Button {
                onSendToFriend?()
            } label: {
                Label("Send", systemImage: "paperplane")
            }

            Button {
                openInSpotify()
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.forward.app")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
    }

    private var dismissButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss song")
    }
}

#Preview {
    VStack(spacing: 16) {
        SongDiscoveryCard(
            track: UnifiedTrack(
                id: "1",
                name: "Sample Song",
                artistName: "Sample Artist",
                albumName: "Sample Album"
            ),
            onDismiss: {}
        )

        SongDiscoveryCard(
            track: UnifiedTrack(
                id: "2",
                name: "Another Song with a Very Long Title That Should Truncate",
                artistName: "Another Artist",
                albumName: "Another Album"
            ),
            onDismiss: {}
        )
    }
    .padding()
    .environment(SpotifyRemoteService.shared)
}
