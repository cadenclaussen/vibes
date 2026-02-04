import SwiftUI

struct ReleaseFeedCard: View {
    let album: UnifiedAlbum

    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header - taps to releases discovery
            Button {
                router.navigateToReleasesDiscovery()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.green.gradient)
                        .clipShape(Circle())

                    Text("New Release")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)

            // Album content - taps to album detail
            Button {
                router.navigateToAlbumDetail(album)
            } label: {
                HStack(spacing: 12) {
                    // Album art
                    AsyncImage(url: URL(string: album.albumArtURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.green.opacity(0.2))
                            .overlay {
                                Image(systemName: "music.note")
                                    .foregroundStyle(.green.opacity(0.5))
                            }
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(album.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(album.artistName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            if let releaseDate = album.releaseDate {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                Text(formatReleaseDate(releaseDate))
                                    .font(.caption)
                            }

                            if let trackCount = album.totalTracks {
                                if album.releaseDate != nil {
                                    Text("·")
                                        .foregroundStyle(.tertiary)
                                }
                                Text("\(trackCount) tracks")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.systemBackground))
        .accessibilityLabel("New release: \(album.name) by \(album.artistName)")
        .accessibilityHint("Double tap to view album")
    }

    private func formatReleaseDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .none
            return outputFormatter.string(from: date)
        }

        inputFormatter.dateFormat = "yyyy"
        if inputFormatter.date(from: dateString) != nil {
            return dateString
        }

        return dateString
    }
}

#Preview {
    ReleaseFeedCard(
        album: UnifiedAlbum(
            id: "1",
            name: "Midnights",
            artistName: "Taylor Swift",
            artistId: "123",
            albumArtURL: nil,
            releaseDate: "2024-01-15",
            totalTracks: 13
        )
    )
    .environment(AppRouter())
    .padding()
    .background(Color(.secondarySystemBackground))
}
