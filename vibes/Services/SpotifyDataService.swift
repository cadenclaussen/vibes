import Foundation

enum SpotifyTimeRange: String {
    case shortTerm = "short_term"   // ~4 weeks
    case mediumTerm = "medium_term" // ~6 months
    case longTerm = "long_term"     // years
}

enum SpotifyDataError: LocalizedError {
    case notAuthenticated
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated with Spotify"
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Spotify"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
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
                throw SpotifyDataError.invalidResponse
            }

            if httpResponse.statusCode == 401 {
                throw SpotifyDataError.notAuthenticated
            }

            if httpResponse.statusCode == 403 {
                throw SpotifyDataError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                throw SpotifyDataError.invalidResponse
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
                throw SpotifyDataError.invalidResponse
            }

            if httpResponse.statusCode == 401 {
                throw SpotifyDataError.notAuthenticated
            }

            if httpResponse.statusCode != 200 {
                throw SpotifyDataError.invalidResponse
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
