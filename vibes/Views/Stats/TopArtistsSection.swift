import SwiftUI

struct TopArtistsSection: View {
    let artists: [UnifiedArtist]
    let onArtistTap: (UnifiedArtist) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Artists")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(artists.enumerated()), id: \.element.id) { index, artist in
                        ArtistCard(artist: artist, rank: index + 1) {
                            onArtistTap(artist)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct ArtistCard: View {
    let artist: UnifiedArtist
    let rank: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: artist.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.tertiarySystemFill))
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())

                    Text("\(rank)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .offset(x: -2, y: -2)
                }

                Text(artist.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TopArtistsSection(
        artists: [
            UnifiedArtist(id: "1", name: "Drake", genres: ["hip-hop"]),
            UnifiedArtist(id: "2", name: "Taylor Swift", genres: ["pop"]),
            UnifiedArtist(id: "3", name: "The Weeknd", genres: ["r&b"])
        ],
        onArtistTap: { _ in }
    )
}
