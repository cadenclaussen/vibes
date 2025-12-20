import Foundation

struct iTunesSearchResult: Codable {
    let resultCount: Int
    let results: [iTunesTrack]
}

struct iTunesTrack: Codable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let collectionName: String?
    let previewUrl: String?
    let artworkUrl100: String?
    let trackTimeMillis: Int?
}

class iTunesService {
    static let shared = iTunesService()
    private let baseURL = "https://itunes.apple.com/search"

    private init() {}

    func searchPreview(trackName: String, artistName: String) async -> String? {
        let query = "\(trackName) \(artistName)"
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?term=\(encodedQuery)&media=music&entity=song&limit=5") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(iTunesSearchResult.self, from: data)

            // Find best match by comparing track and artist names
            let normalizedTrackName = trackName.lowercased()
            let normalizedArtistName = artistName.lowercased()

            for track in result.results {
                let itunesTrack = track.trackName.lowercased()
                let itunesArtist = track.artistName.lowercased()

                // Check if track name and artist are similar enough
                if itunesTrack.contains(normalizedTrackName) || normalizedTrackName.contains(itunesTrack) {
                    if itunesArtist.contains(normalizedArtistName) || normalizedArtistName.contains(itunesArtist) {
                        return track.previewUrl
                    }
                }
            }

            // If no exact match, return first result's preview if available
            return result.results.first?.previewUrl
        } catch {
            print("iTunes search failed: \(error)")
            return nil
        }
    }

    func searchPreviews(for tracks: [(id: String, name: String, artist: String)]) async -> [String: String] {
        var previews: [String: String] = [:]

        await withTaskGroup(of: (String, String?).self) { group in
            for track in tracks {
                group.addTask {
                    let preview = await self.searchPreview(trackName: track.name, artistName: track.artist)
                    return (track.id, preview)
                }
            }

            for await (id, preview) in group {
                if let preview = preview {
                    previews[id] = preview
                }
            }
        }

        return previews
    }
}
