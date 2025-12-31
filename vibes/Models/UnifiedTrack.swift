import Foundation

struct UnifiedTrack: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var artistName: String
    var artistId: String?
    var albumName: String
    var albumId: String?
    var albumArtURL: String?
    var previewURL: String?
    var spotifyUri: String?
    var durationMs: Int?
    var isExplicit: Bool
    var popularity: Int?

    init(
        id: String,
        name: String,
        artistName: String,
        artistId: String? = nil,
        albumName: String,
        albumId: String? = nil,
        albumArtURL: String? = nil,
        previewURL: String? = nil,
        spotifyUri: String? = nil,
        durationMs: Int? = nil,
        isExplicit: Bool = false,
        popularity: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.artistName = artistName
        self.artistId = artistId
        self.albumName = albumName
        self.albumId = albumId
        self.albumArtURL = albumArtURL
        self.previewURL = previewURL
        self.spotifyUri = spotifyUri
        self.durationMs = durationMs
        self.isExplicit = isExplicit
        self.popularity = popularity
    }

    var formattedDuration: String {
        guard let ms = durationMs else { return "--:--" }
        let seconds = ms / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UnifiedTrack, rhs: UnifiedTrack) -> Bool {
        lhs.id == rhs.id
    }
}

struct UnifiedAlbum: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var artistName: String
    var artistId: String?
    var albumArtURL: String?
    var releaseDate: String?
    var totalTracks: Int?
    var spotifyUri: String?

    init(
        id: String,
        name: String,
        artistName: String,
        artistId: String? = nil,
        albumArtURL: String? = nil,
        releaseDate: String? = nil,
        totalTracks: Int? = nil,
        spotifyUri: String? = nil
    ) {
        self.id = id
        self.name = name
        self.artistName = artistName
        self.artistId = artistId
        self.albumArtURL = albumArtURL
        self.releaseDate = releaseDate
        self.totalTracks = totalTracks
        self.spotifyUri = spotifyUri
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UnifiedAlbum, rhs: UnifiedAlbum) -> Bool {
        lhs.id == rhs.id
    }
}

struct UnifiedArtist: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var imageURL: String?
    var genres: [String]
    var popularity: Int?
    var spotifyUri: String?

    init(
        id: String,
        name: String,
        imageURL: String? = nil,
        genres: [String] = [],
        popularity: Int? = nil,
        spotifyUri: String? = nil
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.genres = genres
        self.popularity = popularity
        self.spotifyUri = spotifyUri
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UnifiedArtist, rhs: UnifiedArtist) -> Bool {
        lhs.id == rhs.id
    }
}

struct UnifiedPlaylist: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var description: String?
    var imageURL: String?
    var ownerName: String
    var trackCount: Int
    var isPublic: Bool
    var spotifyUri: String?

    init(
        id: String,
        name: String,
        description: String? = nil,
        imageURL: String? = nil,
        ownerName: String,
        trackCount: Int = 0,
        isPublic: Bool = true,
        spotifyUri: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.ownerName = ownerName
        self.trackCount = trackCount
        self.isPublic = isPublic
        self.spotifyUri = spotifyUri
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UnifiedPlaylist, rhs: UnifiedPlaylist) -> Bool {
        lhs.id == rhs.id
    }
}
