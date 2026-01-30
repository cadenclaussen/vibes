import SwiftUI

struct SongSearchRow: View {
    let track: UnifiedTrack
    let onPlay: () -> Void
    let onTap: () -> Void

    @Environment(AudioPreviewManager.self) private var audioManager

    private var isCurrentlyPlaying: Bool {
        audioManager.currentTrack?.id == track.id && audioManager.isPlaying
    }

    private var hasPreview: Bool {
        track.previewURL != nil
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
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

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(track.artistName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if hasPreview {
                    Button {
                        onPlay()
                    } label: {
                        Image(systemName: isCurrentlyPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(isCurrentlyPlaying ? .green : .primary)
                    }
                    .buttonStyle(.plain)
                }

                Text(track.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
            onTap: {}
        )
    }
    .environment(AudioPreviewManager.shared)
}
