import SwiftUI

struct ReleaseRow: View {
    let rankedRelease: RankedRelease
    let onOpenSpotify: () -> Void

    private var album: UnifiedAlbum {
        rankedRelease.album
    }

    var body: some View {
        HStack(spacing: 12) {
            albumArt

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(album.name)
                        .font(.headline)
                        .lineLimit(1)

                    if rankedRelease.isNew {
                        HStack(spacing: 2) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                            Text("New")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .clipShape(Capsule())
                    }
                }

                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if let releaseDate = album.releaseDate {
                        Text(formattedDate(releaseDate))
                    }
                    if let trackCount = album.totalTracks {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("\(trackCount) tracks")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onOpenSpotify) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.green)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, rankedRelease.isNew ? 8 : 0)
        .background(rankedRelease.isNew ? Color.green.opacity(0.08) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to open in Spotify")
    }

    private var albumArt: some View {
        Group {
            if let imageURL = album.albumArtURL,
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
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemGray4))
            .overlay {
                Image(systemName: "music.note")
                    .foregroundStyle(.secondary)
            }
    }

    private func formattedDate(_ dateString: String) -> String {
        // try full date format first
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }

        // try year-month format
        inputFormatter.dateFormat = "yyyy-MM"
        outputFormatter.dateFormat = "MMM yyyy"

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }

        // fallback to raw string
        return dateString
    }

    private var accessibilityLabel: String {
        var label = "\(album.name) by \(album.artistName)"
        if let releaseDate = album.releaseDate {
            label += ", released \(formattedDate(releaseDate))"
        }
        if rankedRelease.isNew {
            label += ", new release"
        }
        return label
    }
}

#Preview {
    List {
        ReleaseRow(
            rankedRelease: RankedRelease(
                album: UnifiedAlbum(
                    id: "1",
                    name: "Certified Lover Boy",
                    artistName: "Drake",
                    albumArtURL: nil,
                    releaseDate: "2024-12-15",
                    totalTracks: 21
                ),
                artistRank: 1,
                isNew: true
            ),
            onOpenSpotify: {}
        )

        ReleaseRow(
            rankedRelease: RankedRelease(
                album: UnifiedAlbum(
                    id: "2",
                    name: "Midnights",
                    artistName: "Taylor Swift",
                    albumArtURL: nil,
                    releaseDate: "2024-11-20",
                    totalTracks: 13
                ),
                artistRank: 2,
                isNew: false
            ),
            onOpenSpotify: {}
        )
    }
}
