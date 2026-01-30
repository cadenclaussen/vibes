import SwiftUI

struct AlbumHeaderView: View {
    let album: UnifiedAlbum
    let trackCount: String
    let onArtistTap: (ArtistCredit) -> Void
    let onPlayAll: () -> Void
    let onShuffle: () -> Void

    private var releaseYear: String? {
        guard let date = album.releaseDate else { return nil }
        return String(date.prefix(4))
    }

    var body: some View {
        VStack(spacing: 16) {
            // Album artwork
            AsyncImage(url: URL(string: album.albumArtURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.tertiarySystemFill))
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 60))
                            .foregroundStyle(.tertiary)
                    }
            }
            .frame(width: 280, height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

            // Album info
            VStack(spacing: 8) {
                Text(album.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Artist links - each artist is separately tappable
                artistLinks

                HStack(spacing: 4) {
                    if let year = releaseYear {
                        Text(year)
                    }
                    Text("·")
                    Text(trackCount)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            // Action buttons
            HStack(spacing: 16) {
                Button(action: onPlayAll) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }

                Button(action: onShuffle) {
                    HStack(spacing: 6) {
                        Image(systemName: "shuffle")
                        Text("Shuffle")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding(.top)
    }

    @ViewBuilder
    private var artistLinks: some View {
        if album.artists.isEmpty {
            // Fallback for albums without artist data
            Text(album.artistName)
                .font(.headline)
                .foregroundStyle(.secondary)
        } else if album.artists.count == 1 {
            // Single artist
            Button {
                onArtistTap(album.artists[0])
            } label: {
                HStack(spacing: 4) {
                    Text(album.artists[0].name)
                        .font(.headline)
                        .foregroundStyle(.green)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.green.opacity(0.7))
                }
            }
        } else {
            // Multiple artists - show each separately
            HStack(spacing: 4) {
                ForEach(Array(album.artists.enumerated()), id: \.element.id) { index, artist in
                    Button {
                        onArtistTap(artist)
                    } label: {
                        Text(artist.name)
                            .font(.headline)
                            .foregroundStyle(.green)
                    }

                    if index < album.artists.count - 1 {
                        Text(",")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 40) {
            // Single artist
            AlbumHeaderView(
                album: UnifiedAlbum(
                    id: "1",
                    name: "Views",
                    artistName: "Drake",
                    artistId: "abc",
                    artists: [ArtistCredit(id: "abc", name: "Drake")],
                    releaseDate: "2016-04-29",
                    totalTracks: 20
                ),
                trackCount: "20 tracks",
                onArtistTap: { _ in },
                onPlayAll: {},
                onShuffle: {}
            )

            // Collab album
            AlbumHeaderView(
                album: UnifiedAlbum(
                    id: "2",
                    name: "Her Loss",
                    artistName: "Drake, 21 Savage",
                    artists: [
                        ArtistCredit(id: "drake", name: "Drake"),
                        ArtistCredit(id: "21savage", name: "21 Savage")
                    ],
                    releaseDate: "2022-11-04",
                    totalTracks: 16
                ),
                trackCount: "16 tracks",
                onArtistTap: { artist in print("Tapped: \(artist.name)") },
                onPlayAll: {},
                onShuffle: {}
            )
        }
    }
}
