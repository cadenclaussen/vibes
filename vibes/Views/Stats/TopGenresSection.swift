import SwiftUI

struct TopGenresSection: View {
    let genres: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Genres")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            if genres.isEmpty {
                Text("No genre data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(genres, id: \.self) { genre in
                            GenreChip(genre: genre)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

private struct GenreChip: View {
    let genre: String

    var body: some View {
        Text(genre.capitalized)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())
    }
}

#Preview {
    TopGenresSection(genres: ["hip-hop", "pop", "r&b", "rock", "indie"])
}
