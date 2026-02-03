import Foundation

struct FollowedArtist: Codable, Identifiable, Hashable {
    var id: String { artistId }
    let artistId: String
    let artistName: String
    let artistImageURL: String?
    let followedAt: Date

    init(artistId: String, artistName: String, artistImageURL: String?, followedAt: Date = Date()) {
        self.artistId = artistId
        self.artistName = artistName
        self.artistImageURL = artistImageURL
        self.followedAt = followedAt
    }

    init(from artist: UnifiedArtist) {
        self.artistId = artist.id
        self.artistName = artist.name
        self.artistImageURL = artist.imageURL
        self.followedAt = Date()
    }

    func toRankedArtist(rank: Int) -> RankedArtist {
        let artist = UnifiedArtist(
            id: artistId,
            name: artistName,
            imageURL: artistImageURL
        )
        return RankedArtist(artist: artist, rank: rank)
    }

    func toUnifiedArtist() -> UnifiedArtist {
        UnifiedArtist(
            id: artistId,
            name: artistName,
            imageURL: artistImageURL
        )
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(artistId)
    }

    static func == (lhs: FollowedArtist, rhs: FollowedArtist) -> Bool {
        lhs.artistId == rhs.artistId
    }
}
