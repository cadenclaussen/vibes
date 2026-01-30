import SwiftUI

struct ArtistAlbumsSection: View {
    let albums: [UnifiedAlbum]
    let onAlbumTap: (UnifiedAlbum) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Albums")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(albums) { album in
                        AlbumThumbnail(album: album) {
                            onAlbumTap(album)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct AlbumThumbnail: View {
    let album: UnifiedAlbum
    let onTap: () -> Void

    private var releaseYear: String? {
        guard let date = album.releaseDate else { return nil }
        return String(date.prefix(4))
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: album.albumArtURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.tertiarySystemFill))
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundStyle(.tertiary)
                        }
                }
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(album.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let year = releaseYear {
                        Text(year)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 140, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ArtistAlbumsSection(
        albums: [
            UnifiedAlbum(id: "1", name: "Views", artistName: "Drake", releaseDate: "2016-04-29"),
            UnifiedAlbum(id: "2", name: "Scorpion", artistName: "Drake", releaseDate: "2018-06-29"),
            UnifiedAlbum(id: "3", name: "Certified Lover Boy", artistName: "Drake", releaseDate: "2021-09-03")
        ],
        onAlbumTap: { _ in }
    )
}
