import SwiftUI

struct ArtistHeaderView: View {
    let artist: UnifiedArtist

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Artist image with gradient
            GeometryReader { geometry in
                AsyncImage(url: URL(string: artist.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 300)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.6), .blue.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Image(systemName: "music.mic")
                                .font(.system(size: 80))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                }
            }
            .frame(height: 300)

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 150)
            .offset(y: 150)

            // Artist info
            VStack(alignment: .leading, spacing: 8) {
                Text(artist.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                if !artist.genres.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(artist.genres.prefix(4), id: \.self) { genre in
                                ArtistGenreChip(genre: genre)
                            }
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 8)
        }
    }
}

private struct ArtistGenreChip: View {
    let genre: String

    var body: some View {
        Text(genre.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }
}

#Preview {
    ArtistHeaderView(
        artist: UnifiedArtist(
            id: "1",
            name: "Drake",
            imageURL: nil,
            genres: ["hip-hop", "rap", "pop", "r&b"]
        )
    )
}
