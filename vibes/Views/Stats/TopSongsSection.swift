import SwiftUI

struct TopSongsSection: View {
    let songs: [UnifiedTrack]
    let onSongTap: (UnifiedTrack) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Songs")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                    SongRow(song: song, rank: index + 1) {
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text("\(rank)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

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

                VStack(alignment: .leading, spacing: 2) {
                    Text(song.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(song.artistName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
