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
        return page.items
    }

    func getPlaylistTracks(playlistId: String, limit: Int = 50) async throws -> [Track] {
        let urlString = "https://api.spotify.com/v1/playlists/\(playlistId)/tracks?limit=\(limit)"
        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
        }

        let response: PlaylistTracksResponse = try await makeRequest(url: url)
        return response.items.map { $0.track }
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

    // MARK: - Currently Playing

    func getCurrentlyPlaying() async throws -> CurrentlyPlaying? {
        let urlString = "https://api.spotify.com/v1/me/player/currently-playing"

        guard let url = URL(string: urlString) else {
            throw SpotifyError.invalidURL
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

    // MARK: - Helper Methods

    private func makeRequest<T: Decodable>(url: URL) async throws -> T {
        let request = try createAuthenticatedRequest(url: url)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.unknown(statusCode: 0, message: "Invalid response")
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

// MARK: - Additional Models for Playlist Tracks

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistTrackItem]
    let total: Int
    let limit: Int
    let offset: Int
}

struct PlaylistTrackItem: Codable {
    let addedAt: String
    let addedBy: PlaylistOwner
    let track: Track

    enum CodingKeys: String, CodingKey {
        case track
        case addedAt = "added_at"
        case addedBy = "added_by"
    }
}
