import SwiftUI

struct ArtistSearchResultRow: View {
    let artist: UnifiedArtist
    let isAlreadyAdded: Bool
    let canAdd: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            artistImage

            VStack(alignment: .leading, spacing: 2) {
                Text(artist.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if !artist.genres.isEmpty {
                    Text(artist.genres.prefix(3).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            addButton
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(artist.name)
        .accessibilityHint(accessibilityHint)
    }

    private var artistImage: some View {
        Group {
            if let imageURL = artist.imageURL,
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
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    private var imagePlaceholder: some View {
        Circle()
            .fill(Color(.systemGray4))
            .overlay {
                Image(systemName: "music.mic")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
    }

    @ViewBuilder
    private var addButton: some View {
        if isAlreadyAdded {
            Text("Added")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
        } else {
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canAdd ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
        }
    }

    private var accessibilityHint: String {
        if isAlreadyAdded {
            return "Already in your list"
        } else if !canAdd {
            return "Maximum artists reached"
        } else {
            return "Double tap to add to your list"
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ArtistSearchResultRow(
            artist: UnifiedArtist(
                id: "1",
                name: "Drake",
                imageURL: nil,
                genres: ["Hip-Hop", "Rap", "Pop"]
            ),
            isAlreadyAdded: false,
            canAdd: true,
            onAdd: {}
        )

        Divider()

        ArtistSearchResultRow(
            artist: UnifiedArtist(
                id: "2",
                name: "Taylor Swift",
                imageURL: nil,
                genres: ["Pop", "Country"]
            ),
            isAlreadyAdded: true,
            canAdd: true,
            onAdd: {}
        )

        Divider()

        ArtistSearchResultRow(
            artist: UnifiedArtist(
                id: "3",
                name: "Kendrick Lamar",
                imageURL: nil,
                genres: ["Hip-Hop"]
            ),
            isAlreadyAdded: false,
            canAdd: false,
            onAdd: {}
        )
    }
}
