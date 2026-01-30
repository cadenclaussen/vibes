import SwiftUI

struct AlbumSearchRow: View {
    let album: UnifiedAlbum
    let onTap: () -> Void

    private var releaseYear: String? {
        guard let date = album.releaseDate else { return nil }
        return String(date.prefix(4))
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: album.albumArtURL ?? "")) { image in
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
                    Text(album.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(album.artistName)
                        if let year = releaseYear {
                            Text("·")
                            Text(year)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
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
        AlbumSearchRow(
            album: UnifiedAlbum(
                id: "1",
                name: "Views",
                artistName: "Drake",
                releaseDate: "2016-04-29"
            ),
            onTap: {}
        )
    }
}
