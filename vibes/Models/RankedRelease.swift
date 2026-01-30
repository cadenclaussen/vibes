import Foundation

struct RankedRelease: Codable, Identifiable, Hashable {
    var id: String { album.id }
    var album: UnifiedAlbum
    var artistRank: Int
    var isNew: Bool // released within last month

    init(album: UnifiedAlbum, artistRank: Int, isNew: Bool = false) {
        self.album = album
        self.artistRank = artistRank
        self.isNew = isNew
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RankedRelease, rhs: RankedRelease) -> Bool {
        lhs.id == rhs.id
    }
}
