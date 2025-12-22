import Foundation

// MARK: - Authentication Models

struct SpotifyToken: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String

    var expirationDate: Date {
        Date().addingTimeInterval(TimeInterval(expiresIn))
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

// MARK: - User Profile Models

struct SpotifyUserProfile: Codable {
    let id: String
    let displayName: String?
    let email: String?
    let images: [SpotifyImage]?
    let followers: Followers?
    let country: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case images
        case followers
        case country
    }
}

struct SpotifyImage: Codable, Hashable {
    let url: String
    let height: Int?
    let width: Int?
}

struct Followers: Codable, Hashable {
    let total: Int
}

// MARK: - Track Models

struct Track: Codable, Identifiable {
    let id: String
    let name: String
    let artists: [Artist]
    let album: Album
    let durationMs: Int
    let explicit: Bool
    let popularity: Int
    var previewUrl: String?  // Mutable to allow iTunes fallback
    let uri: String
    let externalUrls: ExternalUrls

    enum CodingKeys: String, CodingKey {
        case id, name, artists, album, explicit, popularity, uri
        case durationMs = "duration_ms"
        case previewUrl = "preview_url"
        case externalUrls = "external_urls"
    }
}

struct Artist: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let uri: String
    let externalUrls: ExternalUrls?
    let images: [SpotifyImage]?
    let genres: [String]?
    let followers: Followers?
    let popularity: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, uri, images, genres, followers, popularity
        case externalUrls = "external_urls"
    }
}

struct Album: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let images: [SpotifyImage]
    let releaseDate: String
    let totalTracks: Int
    let uri: String

    enum CodingKeys: String, CodingKey {
        case id, name, images, uri
        case releaseDate = "release_date"
        case totalTracks = "total_tracks"
    }
}

struct ExternalUrls: Codable, Hashable {
    let spotify: String
}

// MARK: - Playlist Models

struct Playlist: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String?
    let images: [SpotifyImage]?
    let owner: PlaylistOwner
    let tracks: PlaylistTracksInfo
    let isPublic: Bool?
    let collaborative: Bool?
    let uri: String
    let externalUrls: ExternalUrls?

    enum CodingKeys: String, CodingKey {
        case id, name, description, images, owner, tracks, collaborative, uri
        case isPublic = "public"
        case externalUrls = "external_urls"
    }
}

struct PlaylistOwner: Codable, Hashable {
    let id: String
    let displayName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}

struct PlaylistTracksInfo: Codable, Hashable {
    let total: Int
}

struct PlaylistPage: Codable {
    let items: [Playlist?]
    let total: Int
    let limit: Int
    let offset: Int
    let next: String?
}

// MARK: - Search Models

enum SearchType: String, CaseIterable {
    case track = "track"
    case artist = "artist"
    case album = "album"
    case playlist = "playlist"

    var displayName: String {
        switch self {
        case .track: return "Songs"
        case .artist: return "Artists"
        case .album: return "Albums"
        case .playlist: return "Playlists"
        }
    }
}

struct UnifiedSearchResult: Codable {
    let tracks: TrackPage?
    let artists: ArtistPage?
    let albums: AlbumSearchPage?
    let playlists: PlaylistSearchPage?
}

struct TrackSearchResult: Codable {
    let tracks: TrackPage
}

struct TrackPage: Codable {
    let items: [Track]
    let total: Int
    let limit: Int
    let offset: Int
    let next: String?
    let previous: String?
}

struct ArtistPage: Codable {
    let items: [Artist]
    let total: Int
    let limit: Int
    let offset: Int
}

struct AlbumSearchPage: Codable {
    let items: [Album]
    let total: Int
    let limit: Int
    let offset: Int
}

struct PlaylistSearchPage: Codable {
    let items: [Playlist?]
    let total: Int
    let limit: Int
    let offset: Int
}

// MARK: - Album Tracks Models

struct AlbumTracksResponse: Codable {
    let items: [SimplifiedTrack]
    let total: Int
    let limit: Int
    let offset: Int
}

struct SimplifiedTrack: Codable, Identifiable {
    let id: String
    let name: String
    let artists: [Artist]
    let durationMs: Int
    let explicit: Bool
    let previewUrl: String?
    let trackNumber: Int
    let uri: String

    enum CodingKeys: String, CodingKey {
        case id, name, artists, explicit, uri
        case durationMs = "duration_ms"
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
    }
}

// MARK: - Playlist Tracks Models

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistTrackItem]
    let total: Int
    let limit: Int
    let offset: Int
}

struct PlaylistTrackItem: Codable {
    let track: Track?
    let addedAt: String?

    enum CodingKeys: String, CodingKey {
        case track
        case addedAt = "added_at"
    }
}

// MARK: - Artist Top Tracks Models

struct ArtistTopTracksResponse: Codable {
    let tracks: [Track]
}

struct ArtistAlbumsResponse: Codable {
    let items: [Album]
    let total: Int
    let limit: Int
    let offset: Int
}

// MARK: - Currently Playing Models

struct CurrentlyPlaying: Codable {
    let item: Track?
    let isPlaying: Bool
    let progressMs: Int?
    let timestamp: Int

    enum CodingKeys: String, CodingKey {
        case item
        case isPlaying = "is_playing"
        case progressMs = "progress_ms"
        case timestamp
    }
}

// MARK: - Recently Played Models

struct RecentlyPlayedResponse: Codable {
    let items: [PlayHistory]
}

struct PlayHistory: Codable {
    let track: Track
    let playedAt: String

    enum CodingKeys: String, CodingKey {
        case track
        case playedAt = "played_at"
    }
}

// MARK: - Error Models

enum SpotifyError: LocalizedError {
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case rateLimitExceeded
    case serverError
    case decodingError
    case unknown(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .unauthorized:
            return "Unauthorized - Invalid or expired token"
        case .forbidden:
            return "Forbidden - Bad OAuth request"
        case .notFound:
            return "Resource not found"
        case .rateLimitExceeded:
            return "Rate limit exceeded - Too many requests"
        case .serverError:
            return "Spotify server error"
        case .decodingError:
            return "Failed to decode response"
        case .unknown(let statusCode, let message):
            return "Error \(statusCode): \(message)"
        }
    }
}

struct SpotifyErrorResponse: Codable {
    let error: ErrorDetail

    struct ErrorDetail: Codable {
        let status: Int
        let message: String
    }
}

// MARK: - Top Items Models

struct TopArtistsResponse: Codable {
    let items: [Artist]
    let total: Int
    let limit: Int
    let offset: Int
}

struct TopTracksResponse: Codable {
    let items: [Track]
    let total: Int
    let limit: Int
    let offset: Int
}

// MARK: - New Releases Models

struct NewReleasesResponse: Codable {
    let albums: AlbumPage
}

struct AlbumPage: Codable {
    let items: [Album]
    let total: Int
    let limit: Int
    let offset: Int
}

// MARK: - Recommendations Models

struct RecommendationsResponse: Codable {
    let tracks: [Track]
    let seeds: [RecommendationSeed]
}

struct RecommendationSeed: Codable {
    let id: String
    let type: String
    let initialPoolSize: Int?
    let afterFilteringSize: Int?
    let afterRelinkingSize: Int?

    enum CodingKeys: String, CodingKey {
        case id, type
        case initialPoolSize = "initialPoolSize"
        case afterFilteringSize = "afterFilteringSize"
        case afterRelinkingSize = "afterRelinkingSize"
    }
}
