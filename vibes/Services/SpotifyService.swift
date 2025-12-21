import Foundation
import Combine

@MainActor
class SpotifyService: ObservableObject {
    static let shared = SpotifyService()

    @Published var isAuthenticated = false
    @Published var userProfile: SpotifyUserProfile?

    private let keychainManager = KeychainManager.shared
    private var accessToken: String?

    // TODO: Replace with actual Spotify app credentials after registering in Spotify Developer Dashboard
    private let clientId = "ac84e0cce87749f3bce04a8ad3f5542e"
    private let clientSecret = "febfde684293434f969a9d0eda518394"
    private let redirectUri = "vibes://callback"

    private let scopes = [
        "user-read-private",
        "user-read-email",
        "playlist-read-private",
        "playlist-read-collaborative",
        "playlist-modify-public",
        "playlist-modify-private",
        "user-read-currently-playing",
        "user-read-playback-state",
        "user-top-read",
        "user-library-read",
        "user-read-recently-played"
    ].joined(separator: " ")

    private init() {
        checkAuthenticationStatus()
    }

    // MARK: - Authentication Status

    func checkAuthenticationStatus() {
        do {
            accessToken = try keychainManager.retrieveSpotifyAccessToken()

            if keychainManager.isTokenExpired() {
                Task {
                    try await refreshAccessToken()
                }
            } else {
                isAuthenticated = true
                Task {
                    await loadUserProfile()
                }
            }
        } catch {
            isAuthenticated = false
            accessToken = nil
        }
    }

    // MARK: - OAuth Flow

    func getAuthorizationURL() -> URL? {
        let encodedScopes = scopes.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://accounts.spotify.com/authorize?" +
            "client_id=\(clientId)" +
            "&response_type=code" +
            "&redirect_uri=\(redirectUri)" +
            "&scope=\(encodedScopes)"

        return URL(string: urlString)
    }

    func handleAuthorizationCallback(url: URL) async throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw SpotifyError.unknown(statusCode: 0, message: "Failed to extract authorization code")
        }

        try await exchangeCodeForToken(code: code)
    }

    private func exchangeCodeForToken(code: String) async throws {
        let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let credentials = "\(clientId):\(clientSecret)"
        let base64Credentials = credentials.data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        let body = "grant_type=authorization_code&code=\(code)&redirect_uri=\(redirectUri)"
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.unknown(statusCode: 0, message: "Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data) {
                throw SpotifyError.unknown(statusCode: errorResponse.error.status, message: errorResponse.error.message)
            }
            throw SpotifyError.unknown(statusCode: httpResponse.statusCode, message: "Token exchange failed")
        }

        let token = try JSONDecoder().decode(SpotifyToken.self, from: data)
        try saveToken(token)

        accessToken = token.accessToken
        isAuthenticated = true

        await loadUserProfile()
    }

    // MARK: - Token Management

    private func saveToken(_ token: SpotifyToken) throws {
        try keychainManager.saveSpotifyAccessToken(token.accessToken)
        if let refreshToken = token.refreshToken {
            try keychainManager.saveSpotifyRefreshToken(refreshToken)
        }
        try keychainManager.saveTokenExpiration(token.expirationDate)
    }

    func refreshAccessToken() async throws {
        guard let refreshToken = try? keychainManager.retrieveSpotifyRefreshToken() else {
            throw SpotifyError.unauthorized
        }

        let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let credentials = "\(clientId):\(clientSecret)"
        let base64Credentials = credentials.data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        let body = "grant_type=refresh_token&refresh_token=\(refreshToken)"
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.unknown(statusCode: 0, message: "Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            throw SpotifyError.unauthorized
        }

        let token = try JSONDecoder().decode(SpotifyToken.self, from: data)
        try saveToken(token)

        accessToken = token.accessToken
        isAuthenticated = true
    }

    // MARK: - Sign Out

    func signOut() {
        try? keychainManager.deleteSpotifyTokens()
        accessToken = nil
        isAuthenticated = false
        userProfile = nil
    }

    // MARK: - User Profile

    func loadUserProfile() async {
        do {
            userProfile = try await getCurrentUserProfile()
        } catch {
            print("Failed to load user profile: \(error)")
        }
    }

    private func getCurrentUserProfile() async throws -> SpotifyUserProfile {
        let url = URL(string: "https://api.spotify.com/v1/me")!
        return try await makeRequest(url: url)
    }

    // MARK: - Playlists

    func getUserPlaylists(limit: Int = 50, offset: Int = 0) async throws -> [Playlist] {
        let urlString = "https://api.spotify.com/v1/me/playlists?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let page: PlaylistPage = try await makeRequest(url: url)
        return page.items.compactMap { $0 }
    }

    func getPlaylistTracks(playlistId: String, limit: Int = 50) async throws -> [Track] {
        let urlString = "https://api.spotify.com/v1/playlists/\(playlistId)/tracks?limit=\(limit)"
        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: PlaylistTracksResponse = try await makeRequest(url: url)
        return response.items.compactMap { $0.track }
    }

    func addTrackToPlaylist(playlistId: String, trackUri: String) async throws {
        let urlString = "https://api.spotify.com/v1/playlists/\(playlistId)/tracks"
        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        // Check if token is expired before making request
        if keychainManager.isTokenExpired() {
            try await refreshAccessToken()
        }

        var request = try createAuthenticatedRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["uris": [trackUri]]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.unknown(statusCode: 0, message: "Invalid response")
        }

        // 201 Created is success for adding tracks
        if httpResponse.statusCode == 401 {
            try await refreshAccessToken()
            try await addTrackToPlaylist(playlistId: playlistId, trackUri: trackUri)
            return
        }

        guard httpResponse.statusCode == 201 else {
            try handleHTTPError(response: httpResponse, data: data)
            return
        }
    }

    func addTracksToPlaylist(playlistId: String, trackUris: [String]) async throws {
        let urlString = "https://api.spotify.com/v1/playlists/\(playlistId)/tracks"
        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        if keychainManager.isTokenExpired() {
            try await refreshAccessToken()
        }

        var request = try createAuthenticatedRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["uris": trackUris]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.unknown(statusCode: 0, message: "Invalid response")
        }

        if httpResponse.statusCode == 401 {
            try await refreshAccessToken()
            try await addTracksToPlaylist(playlistId: playlistId, trackUris: trackUris)
            return
        }

        guard httpResponse.statusCode == 201 else {
            try handleHTTPError(response: httpResponse, data: data)
            return
        }
    }

    func createPlaylist(userId: String, name: String, description: String = "") async throws -> String {
        let urlString = "https://api.spotify.com/v1/users/\(userId)/playlists"
        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        if keychainManager.isTokenExpired() {
            try await refreshAccessToken()
        }

        var request = try createAuthenticatedRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": name,
            "description": description,
            "public": false
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.unknown(statusCode: 0, message: "Invalid response")
        }

        if httpResponse.statusCode == 401 {
            try await refreshAccessToken()
            return try await createPlaylist(userId: userId, name: name, description: description)
        }

        guard httpResponse.statusCode == 201 else {
            try handleHTTPError(response: httpResponse, data: data)
            throw SpotifyError.unknown(statusCode: httpResponse.statusCode, message: "Failed to create playlist")
        }

        struct CreatePlaylistResponse: Codable {
            let id: String
        }

        let playlistResponse = try JSONDecoder().decode(CreatePlaylistResponse.self, from: data)
        return playlistResponse.id
    }

    // MARK: - Search

    func searchTracks(query: String, limit: Int = 20) async throws -> [Track] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=track&limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let result: TrackSearchResult = try await makeRequest(url: url)
        return result.tracks.items
    }

    func search(query: String, type: SearchType, limit: Int = 20) async throws -> UnifiedSearchResult {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=\(type.rawValue)&limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        return try await makeRequest(url: url)
    }

    func searchArtists(query: String, limit: Int = 20) async throws -> [Artist] {
        let result = try await search(query: query, type: .artist, limit: limit)
        return result.artists?.items ?? []
    }

    func searchAlbums(query: String, limit: Int = 20) async throws -> [Album] {
        let result = try await search(query: query, type: .album, limit: limit)
        return result.albums?.items ?? []
    }

    func searchPlaylists(query: String, limit: Int = 20) async throws -> [Playlist] {
        let result = try await search(query: query, type: .playlist, limit: limit)
        return result.playlists?.items.compactMap { $0 } ?? []
    }

    // MARK: - Album Tracks

    func getAlbumTracks(albumId: String, limit: Int = 50) async throws -> [SimplifiedTrack] {
        let urlString = "https://api.spotify.com/v1/albums/\(albumId)/tracks?limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: AlbumTracksResponse = try await makeRequest(url: url)
        return response.items
    }

    // MARK: - Artist Details

    func getArtistTopTracks(artistId: String) async throws -> [Track] {
        let urlString = "https://api.spotify.com/v1/artists/\(artistId)/top-tracks"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: ArtistTopTracksResponse = try await makeRequest(url: url)
        return response.tracks
    }

    func getArtistAlbums(artistId: String, limit: Int = 10) async throws -> [Album] {
        let urlString = "https://api.spotify.com/v1/artists/\(artistId)/albums?include_groups=album,single&limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: ArtistAlbumsResponse = try await makeRequest(url: url)
        return response.items
    }

    // MARK: - Currently Playing

    func getCurrentlyPlaying() async throws -> CurrentlyPlaying? {
        try await getCurrentlyPlayingInternal(isRetry: false)
    }

    private func getCurrentlyPlayingInternal(isRetry: Bool) async throws -> CurrentlyPlaying? {
        let urlString = "https://api.spotify.com/v1/me/player/currently-playing"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        // Check if token is expired before making request
        if keychainManager.isTokenExpired() && !isRetry {
            try await refreshAccessToken()
        }

        var request = try createAuthenticatedRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.unknown(statusCode: 0, message: "Invalid response")
        }

        if httpResponse.statusCode == 204 {
            return nil
        }

        // If unauthorized and not already a retry, refresh token and try again
        if httpResponse.statusCode == 401 && !isRetry {
            do {
                try await refreshAccessToken()
                return try await getCurrentlyPlayingInternal(isRetry: true)
            } catch {
                signOut()
                throw SpotifyError.unauthorized
            }
        }

        try handleHTTPError(response: httpResponse, data: data)

        return try JSONDecoder().decode(CurrentlyPlaying.self, from: data)
    }

    // MARK: - Recently Played

    func getRecentlyPlayed(limit: Int = 20) async throws -> [PlayHistory] {
        let urlString = "https://api.spotify.com/v1/me/player/recently-played?limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: RecentlyPlayedResponse = try await makeRequest(url: url)
        return response.items
    }

    // MARK: - Top Items

    func getTopArtists(timeRange: String = "medium_term", limit: Int = 20) async throws -> [Artist] {
        let urlString = "https://api.spotify.com/v1/me/top/artists?time_range=\(timeRange)&limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: TopArtistsResponse = try await makeRequest(url: url)
        return response.items
    }

    func getTopTracks(timeRange: String = "medium_term", limit: Int = 20) async throws -> [Track] {
        let urlString = "https://api.spotify.com/v1/me/top/tracks?time_range=\(timeRange)&limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: TopTracksResponse = try await makeRequest(url: url)
        return response.items
    }

    // MARK: - New Releases

    func getNewReleases(limit: Int = 20) async throws -> [Album] {
        let urlString = "https://api.spotify.com/v1/browse/new-releases?limit=\(limit)"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: NewReleasesResponse = try await makeRequest(url: url)
        return response.albums.items
    }

    // MARK: - Recommendations

    func getRecommendations(seedTracks: [String] = [], seedArtists: [String] = [], limit: Int = 20) async throws -> [Track] {
        var queryItems: [String] = ["limit=\(limit)"]

        if !seedTracks.isEmpty {
            let trackIds = seedTracks.prefix(5).joined(separator: ",")
            queryItems.append("seed_tracks=\(trackIds)")
        }

        if !seedArtists.isEmpty {
            let artistIds = seedArtists.prefix(5).joined(separator: ",")
            queryItems.append("seed_artists=\(artistIds)")
        }

        // Need at least one seed
        if seedTracks.isEmpty && seedArtists.isEmpty {
            return []
        }

        let urlString = "https://api.spotify.com/v1/recommendations?\(queryItems.joined(separator: "&"))"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: RecommendationsResponse = try await makeRequest(url: url)
        return response.tracks
    }

    // MARK: - Helper Methods

    private func makeRequest<T: Decodable>(url: URL, isRetry: Bool = false) async throws -> T {
        // Check if token is expired before making request
        if keychainManager.isTokenExpired() && !isRetry {
            try await refreshAccessToken()
        }

        let request = try createAuthenticatedRequest(url: url)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.unknown(statusCode: 0, message: "Invalid response")
        }

        // If unauthorized and not already a retry, refresh token and try again
        if httpResponse.statusCode == 401 && !isRetry {
            do {
                try await refreshAccessToken()
                return try await makeRequest(url: url, isRetry: true)
            } catch {
                // Refresh failed, clear auth state
                signOut()
                throw SpotifyError.unauthorized
            }
        }

        try handleHTTPError(response: httpResponse, data: data)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw SpotifyError.decodingError
        }
    }

    private func createAuthenticatedRequest(url: URL) throws -> URLRequest {
        guard let token = accessToken else {
            throw SpotifyError.unauthorized
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func handleHTTPError(response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw SpotifyError.unauthorized
        case 403:
            throw SpotifyError.forbidden
        case 404:
            throw SpotifyError.notFound
        case 429:
            throw SpotifyError.rateLimitExceeded
        case 500...599:
            throw SpotifyError.serverError
        default:
            if let errorResponse = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data) {
                throw SpotifyError.unknown(statusCode: errorResponse.error.status, message: errorResponse.error.message)
            }
            throw SpotifyError.unknown(statusCode: response.statusCode, message: "Unknown error")
        }
    }
}
