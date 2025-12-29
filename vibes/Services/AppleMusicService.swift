import Foundation
import MusicKit
import Combine

@MainActor
class AppleMusicService: ObservableObject, MusicStreamingService {
    static let shared = AppleMusicService()

    var serviceType: MusicServiceType { .appleMusic }

    @Published var isAuthenticated: Bool = false
    @Published var userProfile: UnifiedUserProfile?

    private var authorizationStatus: MusicAuthorization.Status = .notDetermined

    private init() {
        // Don't do anything in init - check status lazily when needed
    }

    // MARK: - Authentication

    func authenticate() async throws {
        let status = await MusicAuthorization.request()
        authorizationStatus = status
        isAuthenticated = status == .authorized

        if !isAuthenticated {
            throw MusicServiceError.authenticationFailed("Apple Music access was denied")
        }

        try await loadUserProfile()
    }

    func signOut() {
        isAuthenticated = false
        userProfile = nil
    }

    func checkAuthenticationStatus() {
        authorizationStatus = MusicAuthorization.currentStatus
        isAuthenticated = authorizationStatus == .authorized
    }

    // MARK: - User Profile

    func loadUserProfile() async throws {
        userProfile = UnifiedUserProfile(
            id: "apple_user",
            displayName: "Apple Music",
            email: nil,
            imageUrl: nil,
            serviceType: .appleMusic,
            followerCount: nil,
            country: nil
        )
    }

    // MARK: - Search

    func searchTracks(query: String, limit: Int) async throws -> [UnifiedTrack] {
        var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
        request.limit = limit

        let response = try await performMusicKitRequest { try await request.response() }
        return response.songs.map { $0.toUnified() }
    }

    // Wraps MusicKit calls to provide better error messages for common issues
    private func performMusicKitRequest<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch {
            let errorString = String(describing: error)
            if errorString.contains("developerToken") || errorString.contains("developer token") {
                throw MusicServiceError.authenticationFailed(
                    "MusicKit not configured. Enable MusicKit for your App ID in the Apple Developer portal and regenerate your provisioning profile."
                )
            }
            throw error
        }
    }

    func searchArtists(query: String, limit: Int) async throws -> [UnifiedArtist] {
        var request = MusicCatalogSearchRequest(term: query, types: [MusicKit.Artist.self])
        request.limit = limit

        let response = try await performMusicKitRequest { try await request.response() }
        return response.artists.map { $0.toUnified() }
    }

    func searchAlbums(query: String, limit: Int) async throws -> [UnifiedAlbum] {
        var request = MusicCatalogSearchRequest(term: query, types: [MusicKit.Album.self])
        request.limit = limit

        let response = try await performMusicKitRequest { try await request.response() }
        return response.albums.map { $0.toUnified() }
    }

    func searchPlaylists(query: String, limit: Int) async throws -> [UnifiedPlaylist] {
        var request = MusicCatalogSearchRequest(term: query, types: [MusicKit.Playlist.self])
        request.limit = limit

        let response = try await performMusicKitRequest { try await request.response() }
        return response.playlists.map { $0.toUnified() }
    }

    // MARK: - User Library Data

    func getTopArtists(timeRange: MusicTimeRange, limit: Int) async throws -> [UnifiedArtist] {
        let recentlyPlayed = try await getRecentlyPlayed(limit: 50)

        var artistCounts: [String: (artist: UnifiedArtist, count: Int)] = [:]
        for history in recentlyPlayed {
            if let artist = history.track.artists.first {
                if let existing = artistCounts[artist.id] {
                    artistCounts[artist.id] = (artist, existing.count + 1)
                } else {
                    artistCounts[artist.id] = (artist, 1)
                }
            }
        }

        let sortedArtists = artistCounts.values
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0.artist }

        return Array(sortedArtists)
    }

    func getTopTracks(timeRange: MusicTimeRange, limit: Int) async throws -> [UnifiedTrack] {
        let recentlyPlayed = try await getRecentlyPlayed(limit: 50)

        var trackCounts: [String: (track: UnifiedTrack, count: Int)] = [:]
        for history in recentlyPlayed {
            if let existing = trackCounts[history.track.id] {
                trackCounts[history.track.id] = (history.track, existing.count + 1)
            } else {
                trackCounts[history.track.id] = (history.track, 1)
            }
        }

        let sortedTracks = trackCounts.values
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0.track }

        return Array(sortedTracks)
    }

    func getRecentlyPlayed(limit: Int) async throws -> [UnifiedPlayHistory] {
        var request = MusicRecentlyPlayedRequest<Song>()
        request.limit = limit

        let response = try await performMusicKitRequest { try await request.response() }
        let dateFormatter = ISO8601DateFormatter()

        return response.items.map { song in
            UnifiedPlayHistory(
                track: song.toUnified(),
                playedAt: dateFormatter.string(from: Date())
            )
        }
    }

    // MARK: - Currently Playing (Not supported)

    func getCurrentlyPlaying() async throws -> UnifiedCurrentlyPlaying? {
        return nil
    }

    // MARK: - Artist Details

    func getArtistTopTracks(artistId: String) async throws -> [UnifiedTrack] {
        let originalId = extractOriginalId(from: artistId)
        let id = MusicItemID(originalId)

        var request = MusicCatalogResourceRequest<MusicKit.Artist>(matching: \.id, equalTo: id)
        request.properties = [.topSongs]

        let response = try await performMusicKitRequest { try await request.response() }

        guard let artist = response.items.first,
              let topSongs = artist.topSongs else {
            return []
        }

        return topSongs.map { $0.toUnified() }
    }

    func getArtistAlbums(artistId: String, limit: Int) async throws -> [UnifiedAlbum] {
        let originalId = extractOriginalId(from: artistId)
        let id = MusicItemID(originalId)

        var request = MusicCatalogResourceRequest<MusicKit.Artist>(matching: \.id, equalTo: id)
        request.properties = [.albums]

        let response = try await performMusicKitRequest { try await request.response() }

        guard let artist = response.items.first,
              let albums = artist.albums else {
            return []
        }

        return Array(albums.prefix(limit).map { $0.toUnified() })
    }

    // MARK: - Album Details

    func getAlbumTracks(albumId: String, limit: Int) async throws -> [UnifiedSimplifiedTrack] {
        let originalId = extractOriginalId(from: albumId)
        let id = MusicItemID(originalId)

        var request = MusicCatalogResourceRequest<MusicKit.Album>(matching: \.id, equalTo: id)
        request.properties = [.tracks]

        let response = try await performMusicKitRequest { try await request.response() }

        guard let album = response.items.first,
              let tracks = album.tracks else {
            return []
        }

        return Array(tracks.prefix(limit).enumerated().map { index, track in
            trackToUnifiedSimplified(track, trackNumber: index + 1)
        })
    }

    // MARK: - Playlists

    func getUserPlaylists(limit: Int, offset: Int) async throws -> [UnifiedPlaylist] {
        var request = MusicLibraryRequest<MusicKit.Playlist>()
        request.limit = limit

        let response = try await performMusicKitRequest { try await request.response() }
        return response.items.map { $0.toUnified() }
    }

    func getPlaylistTracks(playlistId: String, limit: Int) async throws -> [UnifiedTrack] {
        let originalId = extractOriginalId(from: playlistId)
        let id = MusicItemID(originalId)

        var request = MusicCatalogResourceRequest<MusicKit.Playlist>(matching: \.id, equalTo: id)
        request.properties = [.tracks]

        let response = try await performMusicKitRequest { try await request.response() }

        guard let playlist = response.items.first,
              let tracks = playlist.tracks else {
            return []
        }

        return Array(tracks.prefix(limit).map { trackToUnified($0) })
    }

    func createPlaylist(name: String, description: String) async throws -> String {
        let library = MusicLibrary.shared
        let playlist = try await performMusicKitRequest {
            try await library.createPlaylist(name: name, description: description)
        }
        return "apple_\(playlist.id.rawValue)"
    }

    func addTrackToPlaylist(playlistId: String, trackUri: String) async throws {
        try await addTracksToPlaylist(playlistId: playlistId, trackUris: [trackUri])
    }

    func addTracksToPlaylist(playlistId: String, trackUris: [String]) async throws {
        let originalPlaylistId = extractOriginalId(from: playlistId)

        let request = MusicLibraryRequest<MusicKit.Playlist>()
        let response = try await performMusicKitRequest { try await request.response() }

        guard let playlist = response.items.first(where: { $0.id.rawValue == originalPlaylistId }) else {
            throw MusicServiceError.notFound
        }

        let library = MusicLibrary.shared

        for uri in trackUris {
            let trackId = extractOriginalId(from: uri)
            let songId = MusicItemID(trackId)

            var songRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: songId)
            let songResponse = try await performMusicKitRequest { try await songRequest.response() }
            if let song = songResponse.items.first {
                try await performMusicKitRequest { try await library.add(song, to: playlist) }
            }
        }
    }

    // MARK: - Deep Linking

    func getTrackUri(for track: UnifiedTrack) -> String {
        return track.originalId
    }

    // MARK: - Helper Methods

    private func extractOriginalId(from id: String) -> String {
        if id.hasPrefix("apple_") {
            return String(id.dropFirst(6))
        }
        return id
    }

    private func trackToUnified(_ track: MusicKit.Track) -> UnifiedTrack {
        let artistId = UUID().uuidString

        return UnifiedTrack(
            id: "apple_\(track.id.rawValue)",
            originalId: track.id.rawValue,
            serviceType: .appleMusic,
            name: track.title,
            artists: [UnifiedArtist(
                id: "apple_\(artistId)",
                originalId: artistId,
                serviceType: .appleMusic,
                name: track.artistName,
                imageUrl: nil,
                genres: nil,
                followerCount: nil,
                externalUrl: nil,
                uri: nil
            )],
            album: UnifiedAlbum(
                id: "apple_",
                originalId: "",
                serviceType: .appleMusic,
                name: track.albumTitle ?? "",
                imageUrl: track.artwork?.url(width: 300, height: 300)?.absoluteString,
                releaseDate: "",
                trackCount: 0,
                externalUrl: nil,
                uri: nil
            ),
            durationMs: Int((track.duration ?? 0) * 1000),
            isExplicit: track.contentRating == .explicit,
            previewUrl: nil,
            externalUrl: nil,
            uri: track.id.rawValue
        )
    }

    private func trackToUnifiedSimplified(_ track: MusicKit.Track, trackNumber: Int) -> UnifiedSimplifiedTrack {
        let artistId = UUID().uuidString

        return UnifiedSimplifiedTrack(
            id: "apple_\(track.id.rawValue)",
            originalId: track.id.rawValue,
            serviceType: .appleMusic,
            name: track.title,
            artists: [UnifiedArtist(
                id: "apple_\(artistId)",
                originalId: artistId,
                serviceType: .appleMusic,
                name: track.artistName,
                imageUrl: nil,
                genres: nil,
                followerCount: nil,
                externalUrl: nil,
                uri: nil
            )],
            durationMs: Int((track.duration ?? 0) * 1000),
            isExplicit: track.contentRating == .explicit,
            previewUrl: nil,
            trackNumber: trackNumber,
            uri: track.id.rawValue
        )
    }
}

// MARK: - MusicKit to Unified Model Conversions

extension Song {
    func toUnified() -> UnifiedTrack {
        let artistId = artistURL?.absoluteString.components(separatedBy: "/").last ?? UUID().uuidString

        return UnifiedTrack(
            id: "apple_\(id.rawValue)",
            originalId: id.rawValue,
            serviceType: .appleMusic,
            name: title,
            artists: [UnifiedArtist(
                id: "apple_\(artistId)",
                originalId: artistId,
                serviceType: .appleMusic,
                name: artistName,
                imageUrl: nil,
                genres: nil,
                followerCount: nil,
                externalUrl: artistURL?.absoluteString,
                uri: nil
            )],
            album: UnifiedAlbum(
                id: "apple_\(albums?.first?.id.rawValue ?? "")",
                originalId: albums?.first?.id.rawValue ?? "",
                serviceType: .appleMusic,
                name: albumTitle ?? "",
                imageUrl: artwork?.url(width: 300, height: 300)?.absoluteString,
                releaseDate: releaseDate?.formatted(.iso8601) ?? "",
                trackCount: 0,
                externalUrl: nil,
                uri: nil
            ),
            durationMs: Int((duration ?? 0) * 1000),
            isExplicit: contentRating == .explicit,
            previewUrl: previewAssets?.first?.url?.absoluteString,
            externalUrl: url?.absoluteString,
            uri: id.rawValue
        )
    }
}

extension MusicKit.Artist {
    func toUnified() -> UnifiedArtist {
        UnifiedArtist(
            id: "apple_\(id.rawValue)",
            originalId: id.rawValue,
            serviceType: .appleMusic,
            name: name,
            imageUrl: artwork?.url(width: 300, height: 300)?.absoluteString,
            genres: nil,
            followerCount: nil,
            externalUrl: url?.absoluteString,
            uri: id.rawValue
        )
    }
}

extension MusicKit.Album {
    func toUnified() -> UnifiedAlbum {
        UnifiedAlbum(
            id: "apple_\(id.rawValue)",
            originalId: id.rawValue,
            serviceType: .appleMusic,
            name: title,
            imageUrl: artwork?.url(width: 300, height: 300)?.absoluteString,
            releaseDate: releaseDate?.formatted(.iso8601) ?? "",
            trackCount: trackCount,
            externalUrl: url?.absoluteString,
            uri: id.rawValue
        )
    }
}

extension MusicKit.Playlist {
    func toUnified() -> UnifiedPlaylist {
        UnifiedPlaylist(
            id: "apple_\(id.rawValue)",
            originalId: id.rawValue,
            serviceType: .appleMusic,
            name: name,
            description: standardDescription,
            imageUrl: artwork?.url(width: 300, height: 300)?.absoluteString,
            ownerName: curatorName ?? "Apple Music",
            trackCount: 0,
            isPublic: nil,
            isCollaborative: nil,
            externalUrl: url?.absoluteString,
            uri: id.rawValue
        )
    }
}
