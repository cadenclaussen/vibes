import Foundation
import Combine
import UIKit

@MainActor
class SpotifyServiceAdapter: ObservableObject, MusicStreamingService {
    static let shared = SpotifyServiceAdapter()

    private let spotifyService = SpotifyService.shared
    private let itunesService = iTunesService.shared

    var serviceType: MusicServiceType { .spotify }

    @Published var isAuthenticated: Bool = false
    @Published var userProfile: UnifiedUserProfile?

    private var cancellables = Set<AnyCancellable>()

    private init() {
        spotifyService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isAuthenticated = value
            }
            .store(in: &cancellables)

        spotifyService.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.userProfile = profile?.toUnified()
            }
            .store(in: &cancellables)
    }

    // MARK: - Authentication

    func authenticate() async throws {
        guard let url = spotifyService.getAuthorizationURL() else {
            throw MusicServiceError.authenticationFailed("Could not create authorization URL")
        }
        await UIApplication.shared.open(url)
    }

    func signOut() {
        spotifyService.signOut()
    }

    func checkAuthenticationStatus() {
        spotifyService.checkAuthenticationStatus()
    }

    // MARK: - Handle OAuth Callback

    func handleAuthorizationCallback(url: URL) async throws {
        try await spotifyService.handleAuthorizationCallback(url: url)
    }

    // MARK: - User Profile

    func loadUserProfile() async throws {
        await spotifyService.loadUserProfile()
    }

    // MARK: - Search

    func searchTracks(query: String, limit: Int) async throws -> [UnifiedTrack] {
        let tracks = try await spotifyService.searchTracks(query: query, limit: limit)
        var unifiedTracks = tracks.map { $0.toUnified() }
        await enrichWithiTunesPreviews(&unifiedTracks)
        return unifiedTracks
    }

    func searchArtists(query: String, limit: Int) async throws -> [UnifiedArtist] {
        let artists = try await spotifyService.searchArtists(query: query, limit: limit)
        return artists.map { $0.toUnified() }
    }

    func searchAlbums(query: String, limit: Int) async throws -> [UnifiedAlbum] {
        let albums = try await spotifyService.searchAlbums(query: query, limit: limit)
        return albums.map { $0.toUnified() }
    }

    func searchPlaylists(query: String, limit: Int) async throws -> [UnifiedPlaylist] {
        let playlists = try await spotifyService.searchPlaylists(query: query, limit: limit)
        return playlists.map { $0.toUnified() }
    }

    // MARK: - User Library Data

    func getTopArtists(timeRange: MusicTimeRange, limit: Int) async throws -> [UnifiedArtist] {
        let artists = try await spotifyService.getTopArtists(timeRange: timeRange.rawValue, limit: limit)
        return artists.map { $0.toUnified() }
    }

    func getTopTracks(timeRange: MusicTimeRange, limit: Int) async throws -> [UnifiedTrack] {
        let tracks = try await spotifyService.getTopTracks(timeRange: timeRange.rawValue, limit: limit)
        var unifiedTracks = tracks.map { $0.toUnified() }
        await enrichWithiTunesPreviews(&unifiedTracks)
        return unifiedTracks
    }

    func getRecentlyPlayed(limit: Int) async throws -> [UnifiedPlayHistory] {
        let history = try await spotifyService.getRecentlyPlayed(limit: limit)
        return history.map { $0.toUnified() }
    }

    // MARK: - Currently Playing

    func getCurrentlyPlaying() async throws -> UnifiedCurrentlyPlaying? {
        guard let currentlyPlaying = try await spotifyService.getCurrentlyPlaying() else {
            return nil
        }
        return currentlyPlaying.toUnified()
    }

    // MARK: - Artist Details

    func getArtistTopTracks(artistId: String) async throws -> [UnifiedTrack] {
        let originalId = extractOriginalId(from: artistId)
        let tracks = try await spotifyService.getArtistTopTracks(artistId: originalId)
        var unifiedTracks = tracks.map { $0.toUnified() }
        await enrichWithiTunesPreviews(&unifiedTracks)
        return unifiedTracks
    }

    func getArtistAlbums(artistId: String, limit: Int) async throws -> [UnifiedAlbum] {
        let originalId = extractOriginalId(from: artistId)
        let albums = try await spotifyService.getArtistAlbums(artistId: originalId, limit: limit)
        return albums.map { $0.toUnified() }
    }

    // MARK: - Album Details

    func getAlbumTracks(albumId: String, limit: Int) async throws -> [UnifiedSimplifiedTrack] {
        let originalId = extractOriginalId(from: albumId)
        let tracks = try await spotifyService.getAlbumTracks(albumId: originalId, limit: limit)
        return tracks.map { $0.toUnified() }
    }

    // MARK: - Playlists

    func getUserPlaylists(limit: Int, offset: Int) async throws -> [UnifiedPlaylist] {
        let playlists = try await spotifyService.getUserPlaylists(limit: limit, offset: offset)
        return playlists.map { $0.toUnified() }
    }

    func getPlaylistTracks(playlistId: String, limit: Int) async throws -> [UnifiedTrack] {
        let originalId = extractOriginalId(from: playlistId)
        let tracks = try await spotifyService.getPlaylistTracks(playlistId: originalId, limit: limit)
        var unifiedTracks = tracks.map { $0.toUnified() }
        await enrichWithiTunesPreviews(&unifiedTracks)
        return unifiedTracks
    }

    func createPlaylist(name: String, description: String) async throws -> String {
        guard let userId = spotifyService.userProfile?.id else {
            throw MusicServiceError.notAuthenticated
        }
        let playlistId = try await spotifyService.createPlaylist(userId: userId, name: name, description: description)
        return "spotify_\(playlistId)"
    }

    func addTrackToPlaylist(playlistId: String, trackUri: String) async throws {
        let originalPlaylistId = extractOriginalId(from: playlistId)
        let originalTrackUri = trackUri.hasPrefix("spotify:") ? trackUri : "spotify:track:\(extractOriginalId(from: trackUri))"
        try await spotifyService.addTrackToPlaylist(playlistId: originalPlaylistId, trackUri: originalTrackUri)
    }

    func addTracksToPlaylist(playlistId: String, trackUris: [String]) async throws {
        let originalPlaylistId = extractOriginalId(from: playlistId)
        let originalTrackUris = trackUris.map { uri -> String in
            if uri.hasPrefix("spotify:") {
                return uri
            } else {
                return "spotify:track:\(extractOriginalId(from: uri))"
            }
        }
        try await spotifyService.addTracksToPlaylist(playlistId: originalPlaylistId, trackUris: originalTrackUris)
    }

    // MARK: - Deep Linking

    func getTrackUri(for track: UnifiedTrack) -> String {
        if let uri = track.uri, uri.hasPrefix("spotify:") {
            return uri
        }
        return "spotify:track:\(track.originalId)"
    }

    // MARK: - OAuth URL Handling

    func getAuthorizationURL() -> URL? {
        return spotifyService.getAuthorizationURL()
    }

    // MARK: - Helper Methods

    private func extractOriginalId(from id: String) -> String {
        if id.hasPrefix("spotify_") {
            return String(id.dropFirst(8))
        }
        return id
    }

    private func enrichWithiTunesPreviews(_ tracks: inout [UnifiedTrack]) async {
        for i in tracks.indices {
            if tracks[i].previewUrl == nil {
                if let previewUrl = await itunesService.searchPreview(
                    trackName: tracks[i].name,
                    artistName: tracks[i].primaryArtistName
                ) {
                    tracks[i].previewUrl = previewUrl
                }
            }
        }
    }
}
