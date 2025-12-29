import Foundation
import SwiftUI

// MARK: - Service Type

enum MusicServiceType: String, Codable, CaseIterable {
    case spotify
    case appleMusic

    var displayName: String {
        switch self {
        case .spotify: return "Spotify"
        case .appleMusic: return "Apple Music"
        }
    }

    var iconName: String {
        switch self {
        case .spotify: return "music.note"
        case .appleMusic: return "applelogo"
        }
    }

    var brandColor: Color {
        switch self {
        case .spotify: return Color(red: 0.12, green: 0.84, blue: 0.38)
        case .appleMusic: return Color(red: 0.98, green: 0.34, blue: 0.42)
        }
    }
}

// MARK: - Time Range

enum MusicTimeRange: String, CaseIterable {
    case shortTerm = "short_term"
    case mediumTerm = "medium_term"
    case longTerm = "long_term"

    var displayName: String {
        switch self {
        case .shortTerm: return "4 Weeks"
        case .mediumTerm: return "6 Months"
        case .longTerm: return "All Time"
        }
    }
}

// MARK: - Protocol for Unified Items

protocol UnifiedMusicItem: Identifiable, Hashable, Codable {
    var id: String { get }
    var name: String { get }
    var serviceType: MusicServiceType { get }
    var originalId: String { get }
}

// MARK: - Unified Track

struct UnifiedTrack: UnifiedMusicItem {
    let id: String
    let originalId: String
    let serviceType: MusicServiceType
    let name: String
    let artists: [UnifiedArtist]
    let album: UnifiedAlbum
    let durationMs: Int
    let isExplicit: Bool
    var previewUrl: String?
    let externalUrl: String?
    let uri: String?

    var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }

    var primaryArtistName: String {
        artists.first?.name ?? ""
    }

    var primaryArtist: UnifiedArtist? {
        artists.first
    }

    var formattedDuration: String {
        let minutes = durationMs / 60000
        let seconds = (durationMs % 60000) / 1000
        return String(format: "%d:%02d", minutes, seconds)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UnifiedTrack, rhs: UnifiedTrack) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Unified Artist

struct UnifiedArtist: UnifiedMusicItem {
    let id: String
    let originalId: String
    let serviceType: MusicServiceType
    let name: String
    let imageUrl: String?
    let genres: [String]?
    let followerCount: Int?
    let externalUrl: String?
    let uri: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UnifiedArtist, rhs: UnifiedArtist) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Unified Album

struct UnifiedAlbum: UnifiedMusicItem {
    let id: String
    let originalId: String
    let serviceType: MusicServiceType
    let name: String
    let imageUrl: String?
    let releaseDate: String
    let trackCount: Int
    let externalUrl: String?
    let uri: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UnifiedAlbum, rhs: UnifiedAlbum) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Unified Playlist

struct UnifiedPlaylist: UnifiedMusicItem {
    let id: String
    let originalId: String
    let serviceType: MusicServiceType
    let name: String
    let description: String?
    let imageUrl: String?
    let ownerName: String
    let trackCount: Int
    let isPublic: Bool?
    let isCollaborative: Bool?
    let externalUrl: String?
    let uri: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UnifiedPlaylist, rhs: UnifiedPlaylist) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Unified User Profile

struct UnifiedUserProfile: Codable, Identifiable {
    let id: String
    let displayName: String?
    let email: String?
    let imageUrl: String?
    let serviceType: MusicServiceType
    let followerCount: Int?
    let country: String?
}

// MARK: - Unified Currently Playing

struct UnifiedCurrentlyPlaying: Codable {
    let track: UnifiedTrack?
    let isPlaying: Bool
    let progressMs: Int?
    let timestamp: Int
}

// MARK: - Unified Play History

struct UnifiedPlayHistory: Codable, Identifiable {
    var id: String { "\(track.id)_\(playedAt)" }
    let track: UnifiedTrack
    let playedAt: String
}

// MARK: - Unified Simplified Track (for album tracks)

struct UnifiedSimplifiedTrack: Identifiable, Codable, Hashable {
    let id: String
    let originalId: String
    let serviceType: MusicServiceType
    let name: String
    let artists: [UnifiedArtist]
    let durationMs: Int
    let isExplicit: Bool
    var previewUrl: String?
    let trackNumber: Int
    let uri: String?

    var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }

    var formattedDuration: String {
        let minutes = durationMs / 60000
        let seconds = (durationMs % 60000) / 1000
        return String(format: "%d:%02d", minutes, seconds)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UnifiedSimplifiedTrack, rhs: UnifiedSimplifiedTrack) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Music Service Error

enum MusicServiceError: LocalizedError {
    case notAuthenticated
    case authenticationFailed(String)
    case networkError(Error)
    case invalidURL
    case notFound
    case rateLimitExceeded
    case serverError
    case decodingError
    case featureNotSupported(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated. Please sign in."
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        case .notFound:
            return "Resource not found"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .serverError:
            return "Server error. Please try again later."
        case .decodingError:
            return "Failed to process response"
        case .featureNotSupported(let feature):
            return "\(feature) is not supported by this music service"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Search Type (shared)

enum UnifiedSearchType: String, CaseIterable {
    case track
    case artist
    case album
    case playlist

    var displayName: String {
        switch self {
        case .track: return "Songs"
        case .artist: return "Artists"
        case .album: return "Albums"
        case .playlist: return "Playlists"
        }
    }
}
