import SwiftUI

struct ConcertFeedCard: View {
    let concert: Concert

    @Environment(AppRouter.self) private var router

    var body: some View {
        Button {
            router.navigateToConcertDiscovery()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header with type indicator
                HStack(spacing: 8) {
                    Image(systemName: "ticket.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.purple.gradient)
                        .clipShape(Circle())

                    Text("Upcoming Concert")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                // Concert content
                HStack(spacing: 12) {
                    // Artist image
                    AsyncImage(url: URL(string: concert.artistImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.purple.opacity(0.2))
                            .overlay {
                                Image(systemName: "music.mic")
                                    .foregroundStyle(.purple.opacity(0.5))
                            }
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(concert.artistName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(concert.venueName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.caption2)
                            Text(concert.city)
                                .font(.caption)

                            Text("·")
                                .foregroundStyle(.tertiary)

                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(formattedDate)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                // Price range if available
                if let priceRange = concert.priceRange {
                    Text(priceRange)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Concert: \(concert.artistName) at \(concert.venueName) on \(formattedDate)")
        .accessibilityHint("Double tap to see more concerts")
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: concert.date)
    }
}

#Preview {
    ConcertFeedCard(
        concert: Concert(
            id: "1",
            artistName: "Taylor Swift",
            artistImageURL: nil,
            venueName: "Madison Square Garden",
            venueAddress: "4 Pennsylvania Plaza",
            city: "New York",
            date: Date().addingTimeInterval(86400 * 30),
            priceRange: "USD 150 - 500",
            ticketURL: "https://ticketmaster.com"
        )
    )
    .environment(AppRouter())
    .padding()
    .background(Color(.secondarySystemBackground))
}
