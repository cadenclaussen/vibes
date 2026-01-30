import Foundation
import UIKit

enum SpotifyTimeRange: String {
    case shortTerm = "short_term"   // ~4 weeks
    case mediumTerm = "medium_term" // ~6 months
    case longTerm = "long_term"     // years
}

enum SpotifyDataError: LocalizedError {
    case notAuthenticated
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int, String?) // status code and optional body
    case decodingError(Error)
    case forbidden // 403 - missing scopes

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated with Spotify"
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let code, let body):
            if let body = body {
                return "Spotify error (\(code)): \(body)"
            }
            return "Invalid response from Spotify (status \(code))"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .forbidden:
            return "Missing Spotify permissions. Please reconnect your account."
        }
    }
}

class SpotifyDataService {
    static let shared = SpotifyDataService()
    private let baseURL = "https://api.spotify.com/v1"

    private init() {}

    func getTopArtists(limit: Int = 10, timeRange: SpotifyTimeRange = .shortTerm) async throws -> [UnifiedArtist] {
        let token = try await SpotifyAuthService.shared.getValidAccessToken()

        guard var components = URLComponents(string: "\(baseURL)/me/top/artists") else {
            throw SpotifyDataError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "time_range", value: timeRange.rawValue)
        ]

        guard let url = components.url else {
            throw SpotifyDataError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyDataError.invalidResponse(0, "Not an HTTP response")
            }

            if httpResponse.statusCode == 401 {
                throw SpotifyDataError.notAuthenticated
            }

            if httpResponse.statusCode == 403 {
                throw SpotifyDataError.forbidden
            }

            if httpResponse.statusCode != 200 {
                let body = String(data: data, encoding: .utf8)
                throw SpotifyDataError.invalidResponse(httpResponse.statusCode, body)
            }

            let decoded = try JSONDecoder().decode(SpotifyTopArtistsResponse.self, from: data)
            return decoded.items.map { $0.toUnifiedArtist() }
        } catch let error as SpotifyDataError {
            throw error
        } catch let error as DecodingError {
            throw SpotifyDataError.decodingError(error)
        } catch {
            throw SpotifyDataError.networkError(error)
        }
    }

    func getArtistAlbums(artistId: String, limit: Int = 50) async throws -> [UnifiedAlbum] {
        let token = try await SpotifyAuthService.shared.getValidAccessToken()

        guard var components = URLComponents(string: "\(baseURL)/artists/\(artistId)/albums") else {
            throw SpotifyDataError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "include_groups", value: "album,single"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "market", value: "US")
        ]

        guard let url = components.url else {
            throw SpotifyDataError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyDataError.invalidResponse(0, "Not an HTTP response")
            }

            if httpResponse.statusCode == 401 {
                throw SpotifyDataError.notAuthenticated
            }

            if httpResponse.statusCode == 403 {
                throw SpotifyDataError.forbidden
            }

            if httpResponse.statusCode != 200 {
                let body = String(data: data, encoding: .utf8)
                throw SpotifyDataError.invalidResponse(httpResponse.statusCode, body)
            }

            let decoded = try JSONDecoder().decode(SpotifyArtistAlbumsResponse.self, from: data)
            return decoded.items.map { $0.toUnifiedAlbum() }
        } catch let error as SpotifyDataError {
            throw error
        } catch let error as DecodingError {
            throw SpotifyDataError.decodingError(error)
        } catch {
            throw SpotifyDataError.networkError(error)
        }
    }

    func getReleasesForArtists(
        artists: [RankedArtist],
        recentDays: Int = 30
    ) async throws -> [RankedRelease] {
        var allReleases: [RankedRelease] = []
        var seenIds = Set<String>()
        let calendar = Calendar.current
        let now = Date()
        let recentCutoff = calendar.date(byAdding: .day, value: -recentDays, to: now)!

        for artist in artists {
            do {
                let albums = try await getArtistAlbums(artistId: artist.artist.id, limit: 50)

                for album in albums {
                    if seenIds.contains(album.id) { continue }

                    guard let releaseDateStr = album.releaseDate,
                          let releaseDate = parseReleaseDate(releaseDateStr) else {
                        continue
                    }

                    // include recent (within last N days) or upcoming
                    let isRecent = releaseDate >= recentCutoff && releaseDate <= now
                    let isUpcoming = releaseDate > now

                    if isRecent || isUpcoming {
                        seenIds.insert(album.id)
                        let rankedRelease = RankedRelease(
                            album: album,
                            artistRank: artist.rank,
                            isNew: isRecent
                        )
                        allReleases.append(rankedRelease)
                    }
                }
            } catch {
                // skip failed artist, continue with others
                continue
            }
        }

        // sort by artist rank first, then by release date (newest first) within each artist
        allReleases.sort { lhs, rhs in
            if lhs.artistRank != rhs.artistRank {
                return lhs.artistRank < rhs.artistRank
            }
            let lhsDate = lhs.album.releaseDate ?? ""
            let rhsDate = rhs.album.releaseDate ?? ""
            return lhsDate > rhsDate
        }

        return allReleases
    }

    private func parseReleaseDate(_ dateString: String) -> Date? {
        // Spotify returns dates in formats: "2024-01-15", "2024-01", or "2024"
        let formatters: [DateFormatter] = [
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM"
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy"
                return f
            }()
        ]

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }

    func searchArtists(query: String, limit: Int = 10) async throws -> [UnifiedArtist] {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return []
        }

        let token = try await SpotifyAuthService.shared.getValidAccessToken()

        guard var components = URLComponents(string: "\(baseURL)/search") else {
            throw SpotifyDataError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "artist"),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        guard let url = components.url else {
            throw SpotifyDataError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyDataError.invalidResponse(0, "Not an HTTP response")
            }

            if httpResponse.statusCode == 401 {
                throw SpotifyDataError.notAuthenticated
            }

            if httpResponse.statusCode == 403 {
                throw SpotifyDataError.forbidden
            }

            if httpResponse.statusCode != 200 {
                let body = String(data: data, encoding: .utf8)
                throw SpotifyDataError.invalidResponse(httpResponse.statusCode, body)
            }

            let decoded = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
            return decoded.artists.items.map { $0.toUnifiedArtist() }
        } catch let error as SpotifyDataError {
            throw error
        } catch let error as DecodingError {
            throw SpotifyDataError.decodingError(error)
        } catch {
            throw SpotifyDataError.networkError(error)
        }
    }

    func getTopTracks(limit: Int = 5, timeRange: SpotifyTimeRange = .mediumTerm) async throws -> [UnifiedTrack] {
        let token = try await SpotifyAuthService.shared.getValidAccessToken()

        guard var components = URLComponents(string: "\(baseURL)/me/top/tracks") else {
            throw SpotifyDataError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "time_range", value: timeRange.rawValue)
        ]

        guard let url = components.url else {
            throw SpotifyDataError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyDataError.invalidResponse(0, "Not an HTTP response")
            }

            if httpResponse.statusCode == 401 {
                throw SpotifyDataError.notAuthenticated
            }

            if httpResponse.statusCode == 403 {
                throw SpotifyDataError.forbidden
            }

            if httpResponse.statusCode != 200 {
                let body = String(data: data, encoding: .utf8)
                throw SpotifyDataError.invalidResponse(httpResponse.statusCode, body)
            }

            let decoded = try JSONDecoder().decode(SpotifyTopTracksResponse.self, from: data)
            return decoded.items.map { $0.toUnifiedTrack() }
        } catch let error as SpotifyDataError {
            throw error
        } catch let error as DecodingError {
            throw SpotifyDataError.decodingError(error)
        } catch {
            throw SpotifyDataError.networkError(error)
        }
    }

    func getArtistTopTracks(artistId: String) async throws -> [UnifiedTrack] {
        let token = try await SpotifyAuthService.shared.getValidAccessToken()

        guard var components = URLComponents(string: "\(baseURL)/artists/\(artistId)/top-tracks") else {
            throw SpotifyDataError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "market", value: "US")
        ]

        guard let url = components.url else {
            throw SpotifyDataError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyDataError.invalidResponse(0, "Not an HTTP response")
            }

            if httpResponse.statusCode == 401 {
                throw SpotifyDataError.notAuthenticated
            }

            if httpResponse.statusCode == 403 {
                throw SpotifyDataError.forbidden
            }

            if httpResponse.statusCode != 200 {
                let body = String(data: data, encoding: .utf8)
                throw SpotifyDataError.invalidResponse(httpResponse.statusCode, body)
            }

            let decoded = try JSONDecoder().decode(SpotifyArtistTopTracksResponse.self, from: data)
            return decoded.tracks.map { $0.toUnifiedTrack() }
        } catch let error as SpotifyDataError {
            throw error
        } catch let error as DecodingError {
            throw SpotifyDataError.decodingError(error)
        } catch {
            throw SpotifyDataError.networkError(error)
        }
    }

    func getAlbumTracks(albumId: String) async throws -> [UnifiedTrack] {
        let token = try await SpotifyAuthService.shared.getValidAccessToken()

        guard let url = URL(string: "\(baseURL)/albums/\(albumId)") else {
            throw SpotifyDataError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyDataError.invalidResponse(0, "Not an HTTP response")
            }

            if httpResponse.statusCode == 401 {
                throw SpotifyDataError.notAuthenticated
            }

            if httpResponse.statusCode != 200 {
                let body = String(data: data, encoding: .utf8)
                throw SpotifyDataError.invalidResponse(httpResponse.statusCode, body)
            }

            let decoded = try JSONDecoder().decode(SpotifyAlbumFullResponse.self, from: data)
            return decoded.tracks.items.map { $0.toUnifiedTrack(albumName: decoded.name, albumId: decoded.id, albumArtURL: decoded.images?.first?.url) }
        } catch let error as SpotifyDataError {
            throw error
        } catch let error as DecodingError {
            throw SpotifyDataError.decodingError(error)
        } catch {
            throw SpotifyDataError.networkError(error)
        }
    }

    func discoverTracks(limit: Int = 10, maxPopularity: Int = 100) async throws -> [UnifiedTrack] {
        // Get user's top artists
        let topArtists = try await getTopArtists(limit: 5, timeRange: .mediumTerm)

        if topArtists.isEmpty {
            throw SpotifyDataError.invalidResponse(0, "No top artists found")
        }

        // Get user's top tracks to filter them out
        let userTopTracks = try await getTopTracks(limit: 50, timeRange: .mediumTerm)
        var excludedTrackIds = Set(userTopTracks.map { $0.id })

        var allTracks: [UnifiedTrack] = []

        // If looking for obscure tracks, dig into album catalogs
        // Trigger deep cuts for anything past "Mainstream"
        let wantDeepCuts = maxPopularity < 95

        if wantDeepCuts {
            // Also exclude each artist's top tracks (the popular ones)
            for artist in topArtists.prefix(3) {
                do {
                    // Get and exclude artist's popular tracks
                    let artistTopTracks = try await getArtistTopTracks(artistId: artist.id)
                    for track in artistTopTracks {
                        excludedTrackIds.insert(track.id)
                    }

                    // Get albums and dig for deep cuts
                    let albums = try await getArtistAlbums(artistId: artist.id, limit: 20)
                    // Pick random albums, preferring older ones for deeper cuts
                    for album in albums.shuffled().prefix(4) {
                        let albumTracks = try await getAlbumTracks(albumId: album.id)
                        allTracks.append(contentsOf: albumTracks)
                    }
                } catch {
                    continue
                }
            }
        } else {
            // For mainstream, use top tracks (faster)
            for artist in topArtists {
                do {
                    let artistTracks = try await getArtistTopTracks(artistId: artist.id)
                    allTracks.append(contentsOf: artistTracks)
                } catch {
                    continue
                }
            }
        }

        // Filter out tracks user already knows AND artist's popular tracks
        allTracks = allTracks.filter { !excludedTrackIds.contains($0.id) }

        // Filter by popularity (only for tracks that have popularity data)
        if maxPopularity < 100 {
            allTracks = allTracks.filter { track in
                guard let popularity = track.popularity else {
                    return true // Album tracks without popularity are kept
                }
                return popularity <= maxPopularity
            }
        }

        // Shuffle and return requested amount
        allTracks.shuffle()
        return Array(allTracks.prefix(limit))
    }

    func getRecentlyPlayed(limit: Int = 20) async throws -> [RecentTrack] {
        let token = try await SpotifyAuthService.shared.getValidAccessToken()

        guard var components = URLComponents(string: "\(baseURL)/me/player/recently-played") else {
            throw SpotifyDataError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "limit", value: String(min(limit, 50)))
        ]

        guard let url = components.url else {
            throw SpotifyDataError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyDataError.invalidResponse(0, "Not an HTTP response")
            }

            if httpResponse.statusCode == 401 {
                throw SpotifyDataError.notAuthenticated
            }

            if httpResponse.statusCode == 403 {
                throw SpotifyDataError.forbidden
            }

            if httpResponse.statusCode != 200 {
                let body = String(data: data, encoding: .utf8)
                throw SpotifyDataError.invalidResponse(httpResponse.statusCode, body)
            }

            let decoded = try JSONDecoder().decode(SpotifyRecentlyPlayedResponse.self, from: data)
            return decoded.items.compactMap { item -> RecentTrack? in
                guard let date = ISO8601DateFormatter().date(from: item.playedAt) else {
                    return nil
                }
                return RecentTrack(
                    id: "\(item.track.id)_\(item.playedAt)",
                    track: item.track.toUnifiedTrack(),
                    playedAt: date
                )
            }
        } catch let error as SpotifyDataError {
            throw error
        } catch let error as DecodingError {
            throw SpotifyDataError.decodingError(error)
        } catch {
            throw SpotifyDataError.networkError(error)
        }
    }

    func extractTopGenres(from artists: [UnifiedArtist], count: Int = 5) -> [String] {
        var genreCounts: [String: Int] = [:]

        for artist in artists {
            for genre in artist.genres {
                genreCounts[genre, default: 0] += 1
            }
        }

        let sorted = genreCounts.sorted { $0.value > $1.value }
        return Array(sorted.prefix(count).map { $0.key })
    }

    func openInSpotify(uri: String) {
        guard let url = URL(string: uri) else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let webURL = spotifyWebURL(from: uri) {
            UIApplication.shared.open(webURL)
        }
    }

    private func spotifyWebURL(from uri: String) -> URL? {
        // Convert spotify:track:123 to https://open.spotify.com/track/123
        let components = uri.split(separator: ":")
        guard components.count == 3,
              components[0] == "spotify" else {
            return nil
        }
        let type = String(components[1])
        let id = String(components[2])
        return URL(string: "https://open.spotify.com/\(type)/\(id)")
    }
}

// MARK: - Spotify API Response Models

private struct SpotifyTopArtistsResponse: Decodable {
    let items: [SpotifyArtist]
}

private struct SpotifySearchResponse: Decodable {
    let artists: SpotifyArtistsPaging
}

private struct SpotifyArtistsPaging: Decodable {
    let items: [SpotifyArtist]
}

private struct SpotifyRecentlyPlayedResponse: Decodable {
    let items: [SpotifyPlayHistoryItem]
}

private struct SpotifyPlayHistoryItem: Decodable {
    let track: SpotifyTrack
    let playedAt: String

    enum CodingKeys: String, CodingKey {
        case track
        case playedAt = "played_at"
    }
}

private struct SpotifyArtist: Decodable {
    let id: String
    let name: String
    let images: [SpotifyImage]
    let genres: [String]
    let popularity: Int
    let uri: String

    func toUnifiedArtist() -> UnifiedArtist {
        let imageURL = images.first?.url
        return UnifiedArtist(
            id: id,
            name: name,
            imageURL: imageURL,
            genres: genres,
            popularity: popularity,
            spotifyUri: uri
        )
    }
}

private struct SpotifyImage: Decodable {
    let url: String
    let height: Int?
    let width: Int?
}

private struct SpotifyArtistAlbumsResponse: Decodable {
    let items: [SpotifyAlbum]
}

private struct SpotifyAlbum: Decodable {
    let id: String
    let name: String
    let artists: [SpotifyAlbumArtist]
    let images: [SpotifyImage]
    let releaseDate: String?
    let totalTracks: Int?
    let uri: String

    enum CodingKeys: String, CodingKey {
        case id, name, artists, images, uri
        case releaseDate = "release_date"
        case totalTracks = "total_tracks"
    }

    func toUnifiedAlbum() -> UnifiedAlbum {
        let imageURL = images.first?.url
        let artistName = artists.first?.name ?? "Unknown Artist"
        let artistId = artists.first?.id

        return UnifiedAlbum(
            id: id,
            name: name,
            artistName: artistName,
            artistId: artistId,
            albumArtURL: imageURL,
            releaseDate: releaseDate,
            totalTracks: totalTracks,
            spotifyUri: uri
        )
    }
}

private struct SpotifyAlbumArtist: Decodable {
    let id: String
    let name: String
}

// MARK: - Track Response Models

private struct SpotifyTopTracksResponse: Decodable {
    let items: [SpotifyTrack]
}

private struct SpotifyArtistTopTracksResponse: Decodable {
    let tracks: [SpotifyTrack]
}

private struct SpotifyTrack: Decodable {
    let id: String
    let name: String
    let artists: [SpotifyTrackArtist]
    let album: SpotifyTrackAlbum
    let previewUrl: String?
    let uri: String
    let durationMs: Int?
    let explicit: Bool?
    let popularity: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, artists, album, uri, explicit, popularity
        case previewUrl = "preview_url"
        case durationMs = "duration_ms"
    }

    func toUnifiedTrack() -> UnifiedTrack {
        let artistName = artists.first?.name ?? "Unknown Artist"
        let artistId = artists.first?.id
        let albumArtURL = album.safeImages.first?.url

        return UnifiedTrack(
            id: id,
            name: name,
            artistName: artistName,
            artistId: artistId,
            albumName: album.name,
            albumId: album.id,
            albumArtURL: albumArtURL,
            previewURL: previewUrl,
            spotifyUri: uri,
            durationMs: durationMs,
            isExplicit: explicit ?? false,
            popularity: popularity
        )
    }
}

private struct SpotifyTrackArtist: Decodable {
    let id: String
    let name: String
}

private struct SpotifyTrackAlbum: Decodable {
    let id: String
    let name: String
    let images: [SpotifyImage]?

    var safeImages: [SpotifyImage] {
        images ?? []
    }
}

// MARK: - Album Full Response (for deep cuts discovery)

private struct SpotifyAlbumFullResponse: Decodable {
    let id: String
    let name: String
    let images: [SpotifyImage]?
    let tracks: SpotifyAlbumTracksPage
}

private struct SpotifyAlbumTracksPage: Decodable {
    let items: [SpotifySimplifiedTrack]
}

private struct SpotifySimplifiedTrack: Decodable {
    let id: String
    let name: String
    let artists: [SpotifyTrackArtist]
    let previewUrl: String?
    let uri: String
    let durationMs: Int?
    let explicit: Bool?
    let trackNumber: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, artists, uri, explicit
        case previewUrl = "preview_url"
        case durationMs = "duration_ms"
        case trackNumber = "track_number"
    }

    func toUnifiedTrack(albumName: String, albumId: String, albumArtURL: String?) -> UnifiedTrack {
        let artistName = artists.first?.name ?? "Unknown Artist"
        let artistId = artists.first?.id

        return UnifiedTrack(
            id: id,
            name: name,
            artistName: artistName,
            artistId: artistId,
            albumName: albumName,
            albumId: albumId,
            albumArtURL: albumArtURL,
            previewURL: previewUrl,
            spotifyUri: uri,
            durationMs: durationMs,
            isExplicit: explicit ?? false,
            popularity: nil // Album tracks don't include popularity, but they're deep cuts
        )
    }
}
