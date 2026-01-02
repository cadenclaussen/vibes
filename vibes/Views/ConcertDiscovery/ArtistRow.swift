import SwiftUI

struct ArtistRow: View {
    let rankedArtist: RankedArtist
    let displayRank: Int
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("\(displayRank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .center)

            artistImage

            VStack(alignment: .leading, spacing: 2) {
                Text(rankedArtist.artist.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if !rankedArtist.artist.genres.isEmpty {
                    Text(rankedArtist.artist.genres.prefix(2).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(rankedArtist.artist.name), ranked number \(displayRank)")
        .accessibilityHint("Swipe left to remove, or use edit mode to reorder")
    }

    private var artistImage: some View {
        Group {
            if let imageURL = rankedArtist.artist.imageURL,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        imagePlaceholder
                    case .empty:
                        ProgressView()
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(width: 50, height: 50)
        .clipShape(Circle())
    }

    private var imagePlaceholder: some View {
        Circle()
            .fill(Color(.systemGray4))
            .overlay {
                Image(systemName: "music.mic")
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview {
    List {
        ArtistRow(
            rankedArtist: RankedArtist(
                artist: UnifiedArtist(
                    id: "1",
                    name: "Drake",
                    imageURL: nil,
                    genres: ["Hip-Hop", "Rap"],
                    popularity: 95
                ),
                rank: 1
            ),
            displayRank: 1,
            onRemove: {}
        )

        ArtistRow(
            rankedArtist: RankedArtist(
                artist: UnifiedArtist(
                    id: "2",
                    name: "Taylor Swift",
                    imageURL: nil,
                    genres: ["Pop"],
                    popularity: 98
                ),
                rank: 2
            ),
            displayRank: 2,
            onRemove: {}
        )
    }
}
