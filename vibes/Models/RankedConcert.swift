import Foundation

struct RankedConcert: Codable, Identifiable, Hashable {
    var id: String { concert.id }
    var concert: Concert
    var artistRank: Int
    var isHomeCity: Bool

    init(concert: Concert, artistRank: Int, isHomeCity: Bool = false) {
        self.concert = concert
        self.artistRank = artistRank
        self.isHomeCity = isHomeCity
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RankedConcert, rhs: RankedConcert) -> Bool {
        lhs.id == rhs.id
    }
}
