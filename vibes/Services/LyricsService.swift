import Foundation

enum LyricsError: LocalizedError {
    case notFound
    case networkError(Error)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Lyrics not found"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from lyrics service"
        }
    }
}

actor LyricsService {
    static let shared = LyricsService()

    private var cache: [String: SyncedLyrics] = [:]
    private let baseURL = "https://lrclib.net/api"

    private init() {}

    func getLyrics(trackName: String, artistName: String, albumName: String? = nil, duration: TimeInterval? = nil) async throws -> SyncedLyrics {
        let cacheKey = "\(artistName)-\(trackName)".lowercased()

        if let cached = cache[cacheKey] {
            return cached
        }

        let lyrics = try await fetchLyrics(
            trackName: trackName,
            artistName: artistName,
            albumName: albumName,
            duration: duration
        )

        cache[cacheKey] = lyrics
        return lyrics
    }

    private func fetchLyrics(trackName: String, artistName: String, albumName: String?, duration: TimeInterval?) async throws -> SyncedLyrics {
        var components = URLComponents(string: "\(baseURL)/get")!

        var queryItems = [
            URLQueryItem(name: "track_name", value: trackName),
            URLQueryItem(name: "artist_name", value: artistName)
        ]

        if let album = albumName {
            queryItems.append(URLQueryItem(name: "album_name", value: album))
        }

        if let dur = duration {
            queryItems.append(URLQueryItem(name: "duration", value: String(Int(dur))))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw LyricsError.invalidResponse
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw LyricsError.invalidResponse
            }

            if httpResponse.statusCode == 404 {
                throw LyricsError.notFound
            }

            if httpResponse.statusCode != 200 {
                throw LyricsError.invalidResponse
            }

            let lrcResponse = try JSONDecoder().decode(LRCLibResponse.self, from: data)

            // Prefer synced lyrics, fallback to plain lyrics
            if let syncedLyrics = lrcResponse.syncedLyrics, !syncedLyrics.isEmpty {
                return SyncedLyrics.parse(lrc: syncedLyrics)
            } else if let plainLyrics = lrcResponse.plainLyrics, !plainLyrics.isEmpty {
                // Convert plain lyrics to unsynced format (no timestamps)
                return parsePlainLyrics(plainLyrics)
            }

            throw LyricsError.notFound
        } catch let error as LyricsError {
            throw error
        } catch {
            throw LyricsError.networkError(error)
        }
    }

    private func parsePlainLyrics(_ text: String) -> SyncedLyrics {
        // For plain lyrics without timestamps, create lines with 0 start time
        // This means they won't auto-scroll but will still display
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .enumerated()
            .map { LyricLine(text: $1, startTime: 0) }

        return SyncedLyrics(lines: lines)
    }

    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - API Response

private struct LRCLibResponse: Decodable {
    let syncedLyrics: String?
    let plainLyrics: String?
}
