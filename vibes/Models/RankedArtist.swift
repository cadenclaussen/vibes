import Foundation

struct RankedArtist: Codable, Identifiable, Hashable {
    var id: String { artist.id }
    var artist: UnifiedArtist
    var rank: Int

    init(artist: UnifiedArtist, rank: Int) {
        self.artist = artist
        self.rank = rank
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RankedArtist, rhs: RankedArtist) -> Bool {
        lhs.id == rhs.id
    }
}
