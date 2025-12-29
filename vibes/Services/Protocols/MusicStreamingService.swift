import Foundation
import Combine

// MARK: - Music Streaming Service Protocol

@MainActor
protocol MusicStreamingService: ObservableObject {
    // MARK: - Service Identity
    var serviceType: MusicServiceType { get }

    // MARK: - Authentication State
    var isAuthenticated: Bool { get }
    var userProfile: UnifiedUserProfile? { get }

    // MARK: - Authentication Methods
    func authenticate() async throws
    func signOut()
    func checkAuthenticationStatus()

    // MARK: - User Profile
    func loadUserProfile() async throws

    // MARK: - Search
    func searchTracks(query: String, limit: Int) async throws -> [UnifiedTrack]
    func searchArtists(query: String, limit: Int) async throws -> [UnifiedArtist]
    func searchAlbums(query: String, limit: Int) async throws -> [UnifiedAlbum]
    func searchPlaylists(query: String, limit: Int) async throws -> [UnifiedPlaylist]

    // MARK: - User Library Data
    func getTopArtists(timeRange: MusicTimeRange, limit: Int) async throws -> [UnifiedArtist]
    func getTopTracks(timeRange: MusicTimeRange, limit: Int) async throws -> [UnifiedTrack]
    func getRecentlyPlayed(limit: Int) async throws -> [UnifiedPlayHistory]

    // MARK: - Currently Playing (optional - Apple Music doesn't support)
    func getCurrentlyPlaying() async throws -> UnifiedCurrentlyPlaying?

    // MARK: - Artist Details
    func getArtistTopTracks(artistId: String) async throws -> [UnifiedTrack]
    func getArtistAlbums(artistId: String, limit: Int) async throws -> [UnifiedAlbum]

    // MARK: - Album Details
    func getAlbumTracks(albumId: String, limit: Int) async throws -> [UnifiedSimplifiedTrack]

    // MARK: - Playlists
    func getUserPlaylists(limit: Int, offset: Int) async throws -> [UnifiedPlaylist]
    func getPlaylistTracks(playlistId: String, limit: Int) async throws -> [UnifiedTrack]
    func createPlaylist(name: String, description: String) async throws -> String
    func addTrackToPlaylist(playlistId: String, trackUri: String) async throws
    func addTracksToPlaylist(playlistId: String, trackUris: [String]) async throws

    // MARK: - Deep Linking
    func getExternalUrl(for track: UnifiedTrack) -> URL?
    func getExternalUrl(for artist: UnifiedArtist) -> URL?
    func getExternalUrl(for album: UnifiedAlbum) -> URL?
    func getExternalUrl(for playlist: UnifiedPlaylist) -> URL?
    func getTrackUri(for track: UnifiedTrack) -> String
}

// MARK: - Default Implementations

extension MusicStreamingService {
    func getExternalUrl(for track: UnifiedTrack) -> URL? {
        guard let urlString = track.externalUrl else { return nil }
        return URL(string: urlString)
    }

    func getExternalUrl(for artist: UnifiedArtist) -> URL? {
        guard let urlString = artist.externalUrl else { return nil }
        return URL(string: urlString)
    }

    func getExternalUrl(for album: UnifiedAlbum) -> URL? {
        guard let urlString = album.externalUrl else { return nil }
        return URL(string: urlString)
    }

    func getExternalUrl(for playlist: UnifiedPlaylist) -> URL? {
        guard let urlString = playlist.externalUrl else { return nil }
        return URL(string: urlString)
    }

    func getTrackUri(for track: UnifiedTrack) -> String {
        return track.uri ?? track.originalId
    }
}

// MARK: - Service Capabilities

struct MusicServiceCapabilities {
    let supportsCurrentlyPlaying: Bool
    let supportsTopItems: Bool
    let supportsRecentlyPlayed: Bool
    let supportsPlaylistCreation: Bool
    let requiresSubscription: Bool

    static let spotify = MusicServiceCapabilities(
        supportsCurrentlyPlaying: true,
        supportsTopItems: true,
        supportsRecentlyPlayed: true,
        supportsPlaylistCreation: true,
        requiresSubscription: false
    )

    static let appleMusic = MusicServiceCapabilities(
        supportsCurrentlyPlaying: false,
        supportsTopItems: false,  // derived from recently played
        supportsRecentlyPlayed: true,
        supportsPlaylistCreation: true,
        requiresSubscription: true
    )
}
