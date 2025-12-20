# Spotify API Integration Guide

This guide explains how to integrate Spotify's Web API into the vibes app for music discovery, playlist management, and real-time listening data.

## Table of Contents

1. [Authentication](#authentication)
2. [User Profile](#user-profile)
3. [Search](#search)
4. [Playlists](#playlists)
5. [Currently Playing](#currently-playing)
6. [Tracks](#tracks)
7. [Artists](#artists)
8. [Error Handling](#error-handling)
9. [Rate Limiting](#rate-limiting)

---

## Authentication

Spotify uses OAuth 2.0 for authentication. There are several authorization flows available.

### Authorization Code Flow (Recommended for iOS)

This is the most secure flow for mobile apps with a backend.

**Step 1: Register Your App**
1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Note your Client ID and Client Secret
4. Add redirect URI (e.g., `vibes://callback`)

**Step 2: Authorization URL**

```swift
let clientId = "YOUR_CLIENT_ID"
let redirectUri = "vibes://callback"
let scopes = "user-read-private user-read-email playlist-read-private user-read-currently-playing user-read-playback-state"

let authURL = "https://accounts.spotify.com/authorize?" +
    "client_id=\(clientId)" +
    "&response_type=code" +
    "&redirect_uri=\(redirectUri)" +
    "&scope=\(scopes.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
```

**Step 3: Exchange Code for Token**

After user authorizes, Spotify redirects to your redirect URI with a code parameter:

```swift
func exchangeCodeForToken(code: String) async throws -> SpotifyToken {
    let tokenURL = "https://accounts.spotify.com/api/token"

    var request = URLRequest(url: URL(string: tokenURL)!)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let credentials = "\(clientId):\(clientSecret)"
    let base64Credentials = credentials.data(using: .utf8)!.base64EncodedString()
    request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

    let body = "grant_type=authorization_code&code=\(code)&redirect_uri=\(redirectUri)"
    request.httpBody = body.data(using: .utf8)

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(SpotifyToken.self, from: data)
}

struct SpotifyToken: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String
    let scope: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}
```

**Step 4: Refresh Token**

Access tokens expire after 1 hour. Use the refresh token to get a new access token:

```swift
func refreshAccessToken(refreshToken: String) async throws -> SpotifyToken {
    let tokenURL = "https://accounts.spotify.com/api/token"

    var request = URLRequest(url: URL(string: tokenURL)!)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let credentials = "\(clientId):\(clientSecret)"
    let base64Credentials = credentials.data(using: .utf8)!.base64EncodedString()
    request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

    let body = "grant_type=refresh_token&refresh_token=\(refreshToken)"
    request.httpBody = body.data(using: .utf8)

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(SpotifyToken.self, from: data)
}
```

### Required Scopes

Common scopes for vibes app:
- `user-read-private` - Read user profile data
- `user-read-email` - Read user email
- `playlist-read-private` - Read private playlists
- `playlist-read-collaborative` - Read collaborative playlists
- `user-read-currently-playing` - Read currently playing track
- `user-read-playback-state` - Read playback state
- `user-top-read` - Read top artists and tracks
- `user-library-read` - Read saved tracks and albums

---

## User Profile

Get the current user's profile information.

**Endpoint:** `GET https://api.spotify.com/v1/me`

**Required Scope:** `user-read-private`, `user-read-email`

```swift
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

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}

struct Followers: Codable {
    let total: Int
}

func getCurrentUserProfile(accessToken: String) async throws -> SpotifyUserProfile {
    let url = URL(string: "https://api.spotify.com/v1/me")!

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(SpotifyUserProfile.self, from: data)
}
```

---

## Search

Search for tracks, albums, artists, playlists, and more.

**Endpoint:** `GET https://api.spotify.com/v1/search`

**Query Parameters:**
- `q` - Search query (required)
- `type` - Comma-separated list of item types: `track`, `artist`, `album`, `playlist`
- `limit` - Maximum number of results (default: 20, max: 50)
- `offset` - Offset for pagination (default: 0)
- `market` - ISO 3166-1 alpha-2 country code

### Search for Tracks

```swift
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

struct Track: Codable {
    let id: String
    let name: String
    let artists: [Artist]
    let album: Album
    let durationMs: Int
    let explicit: Bool
    let popularity: Int
    let previewUrl: String?
    let uri: String
    let externalUrls: ExternalUrls

    enum CodingKeys: String, CodingKey {
        case id, name, artists, album, explicit, popularity, uri
        case durationMs = "duration_ms"
        case previewUrl = "preview_url"
        case externalUrls = "external_urls"
    }
}

struct Artist: Codable {
    let id: String
    let name: String
    let uri: String
    let externalUrls: ExternalUrls?

    enum CodingKeys: String, CodingKey {
        case id, name, uri
        case externalUrls = "external_urls"
    }
}

struct Album: Codable {
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

struct ExternalUrls: Codable {
    let spotify: String
}

func searchTracks(query: String, accessToken: String, limit: Int = 20) async throws -> [Track] {
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=track&limit=\(limit)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(TrackSearchResult.self, from: data)
    return result.tracks.items
}
```

### Search for Artists

```swift
struct ArtistSearchResult: Codable {
    let artists: ArtistPage
}

struct ArtistPage: Codable {
    let items: [ArtistDetail]
}

struct ArtistDetail: Codable {
    let id: String
    let name: String
    let genres: [String]
    let images: [SpotifyImage]
    let popularity: Int
    let followers: Followers
    let uri: String
}

func searchArtists(query: String, accessToken: String, limit: Int = 20) async throws -> [ArtistDetail] {
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=artist&limit=\(limit)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(ArtistSearchResult.self, from: data)
    return result.artists.items
}
```

---

## Playlists

Retrieve and manage user playlists.

### Get Current User's Playlists

**Endpoint:** `GET https://api.spotify.com/v1/me/playlists`

**Required Scope:** `playlist-read-private`, `playlist-read-collaborative`

```swift
struct PlaylistPage: Codable {
    let items: [Playlist]
    let total: Int
    let limit: Int
    let offset: Int
    let next: String?
}

struct Playlist: Codable {
    let id: String
    let name: String
    let description: String?
    let images: [SpotifyImage]
    let owner: PlaylistOwner
    let tracks: PlaylistTracksInfo
    let isPublic: Bool?
    let collaborative: Bool
    let uri: String
    let externalUrls: ExternalUrls

    enum CodingKeys: String, CodingKey {
        case id, name, description, images, owner, tracks, collaborative, uri
        case isPublic = "public"
        case externalUrls = "external_urls"
    }
}

struct PlaylistOwner: Codable {
    let id: String
    let displayName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}

struct PlaylistTracksInfo: Codable {
    let total: Int
}

func getCurrentUserPlaylists(accessToken: String, limit: Int = 50, offset: Int = 0) async throws -> [Playlist] {
    let urlString = "https://api.spotify.com/v1/me/playlists?limit=\(limit)&offset=\(offset)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(PlaylistPage.self, from: data)
    return result.items
}
```

### Get Playlist Items (Tracks)

**Endpoint:** `GET https://api.spotify.com/v1/playlists/{playlist_id}/tracks`

```swift
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

func getPlaylistTracks(playlistId: String, accessToken: String, limit: Int = 50) async throws -> [Track] {
    let urlString = "https://api.spotify.com/v1/playlists/\(playlistId)/tracks?limit=\(limit)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(PlaylistTracksResponse.self, from: data)
    return result.items.map { $0.track }
}
```

---

## Currently Playing

Get the user's currently playing track or the last played track.

**Endpoint:** `GET https://api.spotify.com/v1/me/player/currently-playing`

**Required Scope:** `user-read-currently-playing`

```swift
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

func getCurrentlyPlaying(accessToken: String) async throws -> CurrentlyPlaying? {
    let urlString = "https://api.spotify.com/v1/me/player/currently-playing"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await URLSession.shared.data(for: request)

    // 204 No Content means nothing is currently playing
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
        return nil
    }

    return try JSONDecoder().decode(CurrentlyPlaying.self, from: data)
}
```

### Get Recently Played Tracks

**Endpoint:** `GET https://api.spotify.com/v1/me/player/recently-played`

**Required Scope:** `user-read-recently-played`

```swift
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

func getRecentlyPlayed(accessToken: String, limit: Int = 20) async throws -> [PlayHistory] {
    let urlString = "https://api.spotify.com/v1/me/player/recently-played?limit=\(limit)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(RecentlyPlayedResponse.self, from: data)
    return result.items
}
```

---

## Tracks

### Get Track

Get detailed information about a specific track.

**Endpoint:** `GET https://api.spotify.com/v1/tracks/{id}`

```swift
func getTrack(trackId: String, accessToken: String) async throws -> Track {
    let urlString = "https://api.spotify.com/v1/tracks/\(trackId)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(Track.self, from: data)
}
```

### Get Multiple Tracks

**Endpoint:** `GET https://api.spotify.com/v1/tracks?ids={ids}`

```swift
struct TracksResponse: Codable {
    let tracks: [Track]
}

func getTracks(trackIds: [String], accessToken: String) async throws -> [Track] {
    let idsString = trackIds.joined(separator: ",")
    let urlString = "https://api.spotify.com/v1/tracks?ids=\(idsString)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(TracksResponse.self, from: data)
    return result.tracks
}
```

### Get Audio Features

Get audio features for a track (tempo, key, danceability, energy, etc.).

**Endpoint:** `GET https://api.spotify.com/v1/audio-features/{id}`

```swift
struct AudioFeatures: Codable {
    let id: String
    let danceability: Double
    let energy: Double
    let key: Int
    let loudness: Double
    let mode: Int
    let speechiness: Double
    let acousticness: Double
    let instrumentalness: Double
    let liveness: Double
    let valence: Double
    let tempo: Double
    let durationMs: Int
    let timeSignature: Int

    enum CodingKeys: String, CodingKey {
        case id, danceability, energy, key, loudness, mode, speechiness
        case acousticness, instrumentalness, liveness, valence, tempo
        case durationMs = "duration_ms"
        case timeSignature = "time_signature"
    }
}

func getAudioFeatures(trackId: String, accessToken: String) async throws -> AudioFeatures {
    let urlString = "https://api.spotify.com/v1/audio-features/\(trackId)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(AudioFeatures.self, from: data)
}
```

---

## Artists

### Get Artist

**Endpoint:** `GET https://api.spotify.com/v1/artists/{id}`

```swift
func getArtist(artistId: String, accessToken: String) async throws -> ArtistDetail {
    let urlString = "https://api.spotify.com/v1/artists/\(artistId)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(ArtistDetail.self, from: data)
}
```

### Get Artist's Top Tracks

**Endpoint:** `GET https://api.spotify.com/v1/artists/{id}/top-tracks`

```swift
struct ArtistTopTracksResponse: Codable {
    let tracks: [Track]
}

func getArtistTopTracks(artistId: String, market: String = "US", accessToken: String) async throws -> [Track] {
    let urlString = "https://api.spotify.com/v1/artists/\(artistId)/top-tracks?market=\(market)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(ArtistTopTracksResponse.self, from: data)
    return result.tracks
}
```

### Get User's Top Artists

**Endpoint:** `GET https://api.spotify.com/v1/me/top/artists`

**Required Scope:** `user-top-read`

```swift
struct TopArtistsResponse: Codable {
    let items: [ArtistDetail]
}

func getUserTopArtists(accessToken: String, timeRange: String = "medium_term", limit: Int = 20) async throws -> [ArtistDetail] {
    // timeRange: short_term (~4 weeks), medium_term (~6 months), long_term (years)
    let urlString = "https://api.spotify.com/v1/me/top/artists?time_range=\(timeRange)&limit=\(limit)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(TopArtistsResponse.self, from: data)
    return result.items
}
```

### Get User's Top Tracks

**Endpoint:** `GET https://api.spotify.com/v1/me/top/tracks`

**Required Scope:** `user-top-read`

```swift
struct TopTracksResponse: Codable {
    let items: [Track]
}

func getUserTopTracks(accessToken: String, timeRange: String = "medium_term", limit: Int = 20) async throws -> [Track] {
    let urlString = "https://api.spotify.com/v1/me/top/tracks?time_range=\(timeRange)&limit=\(limit)"

    guard let url = URL(string: urlString) else {
        throw SpotifyError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(TopTracksResponse.self, from: data)
    return result.items
}
```

---

## Error Handling

Spotify API returns standard HTTP status codes and error responses.

```swift
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

func handleSpotifyError(data: Data?, response: URLResponse?) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        return
    }

    switch httpResponse.statusCode {
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
        if let data = data,
           let errorResponse = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data) {
            throw SpotifyError.unknown(statusCode: errorResponse.error.status, message: errorResponse.error.message)
        }
        throw SpotifyError.unknown(statusCode: httpResponse.statusCode, message: "Unknown error")
    }
}
```

---

## Rate Limiting

Spotify enforces rate limits to prevent abuse:

- **Rate limit:** Varies by endpoint, typically around 180 requests per minute
- **Response header:** `Retry-After` header indicates seconds to wait before retrying
- **Status code:** 429 (Too Many Requests)

**Best Practices:**
1. Cache responses when possible
2. Implement exponential backoff for retries
3. Monitor rate limit headers
4. Batch requests when available (e.g., get multiple tracks at once)

```swift
func makeSpotifyRequest<T: Decodable>(
    url: URL,
    accessToken: String,
    retries: Int = 3
) async throws -> T {
    var currentRetry = 0

    while currentRetry < retries {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.unknown(statusCode: 0, message: "Invalid response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)

        case 429:
            // Rate limited
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
            let waitTime = Double(retryAfter ?? "1") ?? 1.0
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            currentRetry += 1

        case 401:
            // Token expired - refresh and retry
            throw SpotifyError.unauthorized

        default:
            try handleSpotifyError(data: data, response: response)
        }
    }

    throw SpotifyError.rateLimitExceeded
}
```

---

## Additional Resources

- [Spotify Web API Reference](https://developer.spotify.com/documentation/web-api)
- [Spotify iOS SDK](https://developer.spotify.com/documentation/ios)
- [Authorization Guide](https://developer.spotify.com/documentation/web-api/concepts/authorization)
- [API Rate Limits](https://developer.spotify.com/documentation/web-api/concepts/rate-limits)

## Next Steps

1. Register app in Spotify Developer Dashboard
2. Implement OAuth flow in vibes app
3. Create SpotifyService class to encapsulate API calls
4. Store tokens securely in Keychain
5. Implement token refresh logic
6. Add error handling and retry logic
7. Cache API responses to reduce requests
8. Test rate limiting behavior
