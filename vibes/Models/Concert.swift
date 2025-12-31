import Foundation

struct Concert: Codable, Identifiable, Hashable {
    var id: String
    var artistName: String
    var artistImageURL: String?
    var venueName: String
    var venueAddress: String
    var city: String
    var date: Date
    var priceRange: String?
    var ticketURL: String
    var additionalArtists: [String]

    init(
        id: String,
        artistName: String,
        artistImageURL: String? = nil,
        venueName: String,
        venueAddress: String,
        city: String,
        date: Date,
        priceRange: String? = nil,
        ticketURL: String,
        additionalArtists: [String] = []
    ) {
        self.id = id
        self.artistName = artistName
        self.artistImageURL = artistImageURL
        self.venueName = venueName
        self.venueAddress = venueAddress
        self.city = city
        self.date = date
        self.priceRange = priceRange
        self.ticketURL = ticketURL
        self.additionalArtists = additionalArtists
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Concert, rhs: Concert) -> Bool {
        lhs.id == rhs.id
    }
}
