import SwiftUI

struct ConcertRow: View {
    let rankedConcert: RankedConcert
    let onGetTickets: () -> Void

    private var concert: Concert {
        rankedConcert.concert
    }

    var body: some View {
        HStack(spacing: 12) {
            artistImage

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(concert.artistName)
                        .font(.headline)
                        .lineLimit(1)

                    if rankedConcert.isHomeCity {
                        HStack(spacing: 2) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text("Near You")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .clipShape(Capsule())
                    }
                }

                Text(concert.venueName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(concert.city)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(formattedDate)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if let price = concert.priceRange {
                    Text(price)
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            Button(action: onGetTickets) {
                Image(systemName: "ticket.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, rankedConcert.isHomeCity ? 8 : 0)
        .background(rankedConcert.isHomeCity ? Color.blue.opacity(0.08) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to get tickets")
    }

    private var artistImage: some View {
        Group {
            if let imageURL = concert.artistImageURL,
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
                Image(systemName: "music.mic")
                    .foregroundStyle(.secondary)
            }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: concert.date)
    }

    private var accessibilityLabel: String {
        var label = "\(concert.artistName) at \(concert.venueName), \(concert.city), \(formattedDate)"
        if rankedConcert.isHomeCity {
            label += ", in your home city"
        }
        return label
    }
}

#Preview {
    List {
        ConcertRow(
            rankedConcert: RankedConcert(
                concert: Concert(
                    id: "1",
                    artistName: "Drake",
                    artistImageURL: nil,
                    venueName: "Madison Square Garden",
                    venueAddress: "4 Pennsylvania Plaza",
                    city: "New York",
                    date: Date(),
                    priceRange: "USD 150 - 500",
                    ticketURL: "https://ticketmaster.com"
                ),
                artistRank: 1,
                isHomeCity: true
            ),
            onGetTickets: {}
        )

        ConcertRow(
            rankedConcert: RankedConcert(
                concert: Concert(
                    id: "2",
                    artistName: "Taylor Swift",
                    artistImageURL: nil,
                    venueName: "SoFi Stadium",
                    venueAddress: "1001 Stadium Dr",
                    city: "Los Angeles",
                    date: Date().addingTimeInterval(86400 * 7),
                    priceRange: nil,
                    ticketURL: "https://ticketmaster.com"
                ),
                artistRank: 2,
                isHomeCity: false
            ),
            onGetTickets: {}
        )
    }
}
