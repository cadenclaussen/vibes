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
              let url = URL(string: "\(baseURL)?term=\(encodedQuery)&media=music&entity=song&limit=10") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(iTunesSearchResult.self, from: data)

            // Normalize track name (strip parentheticals, clean up)
            let normalizedTrackName = normalizeTrackName(trackName)
            // Extract all artist names (handles "featuring", "ft.", "&", etc.)
            let artistNames = extractArtistNames(artistName)
            // Check if user is searching for a remix/alternate version
            let searchIsRemix = isRemixOrAlternateVersion(trackName)

            var bestMatch: (track: iTunesTrack, score: Int)?

            for track in result.results {
                let itunesTrackNormalized = normalizeTrackName(track.trackName)
                let itunesArtists = extractArtistNames(track.artistName)
                let resultIsRemix = isRemixOrAlternateVersion(track.trackName)

                // If user wants the original, skip remix versions
                if !searchIsRemix && resultIsRemix {
                    continue
                }

                // Calculate match score
                var score = 0

                // Track name must match well (exact or cleaned match)
                let trackMatches = itunesTrackNormalized == normalizedTrackName ||
                    itunesTrackNormalized.hasPrefix(normalizedTrackName + " ") ||
                    normalizedTrackName.hasPrefix(itunesTrackNormalized + " ") ||
                    (itunesTrackNormalized.contains(normalizedTrackName) && normalizedTrackName.count >= 4)

                if !trackMatches {
                    continue
                }
                score += 10

                // Check if any artist matches
                var artistMatched = false
                for searchArtist in artistNames {
                    for itunesArtist in itunesArtists {
                        if itunesArtist == searchArtist ||
                            itunesArtist.contains(searchArtist) ||
                            searchArtist.contains(itunesArtist) {
                            artistMatched = true
                            score += 5
                            break
                        }
                    }
                    if artistMatched { break }
                }

                if !artistMatched {
                    continue
                }

                // Prefer exact track name matches
                if itunesTrackNormalized == normalizedTrackName {
                    score += 3
                }

                // Bonus for matching the original when that's what was requested
                if !searchIsRemix && !resultIsRemix {
                    score += 2
                }

                // Update best match if this is better
                if bestMatch == nil || score > bestMatch!.score {
                    bestMatch = (track, score)
                }
            }

            // Only return if we found a good match - don't fall back to first result
            return bestMatch?.track.previewUrl
        } catch {
            print("iTunes search failed: \(error)")
            return nil
        }
    }

    private func isRemixOrAlternateVersion(_ name: String) -> Bool {
        let lowercased = name.lowercased()
        let remixPatterns = [
            "remix", "mix", "edit", "version", "bootleg", "rework",
            "vip", "flip", "mashup", "mash-up", "cover", "acoustic",
            "live", "instrumental", "acapella", "a cappella", "extended",
            "radio edit", "club mix", "dub mix", "stripped"
        ]
        for pattern in remixPatterns {
            if lowercased.contains(pattern) {
                return true
            }
        }
        return false
    }

    private func normalizeTrackName(_ name: String) -> String {
        var normalized = name.lowercased()
        // Remove common suffixes in parentheses/brackets
        let patterns = [
            "\\s*\\(feat\\..*\\)",
            "\\s*\\(ft\\..*\\)",
            "\\s*\\(with.*\\)",
            "\\s*\\[.*\\]",
            "\\s*-\\s*remaster.*",
            "\\s*-\\s*single.*",
            "\\s*\\(remaster.*\\)"
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                normalized = regex.stringByReplacingMatches(
                    in: normalized,
                    range: NSRange(normalized.startIndex..., in: normalized),
                    withTemplate: ""
                )
            }
        }
        return normalized.trimmingCharacters(in: .whitespaces)
    }

    private func extractArtistNames(_ artist: String) -> [String] {
        var names: [String] = []
        // Split on common separators
        let separators = [" feat. ", " feat ", " ft. ", " ft ", " & ", ", ", " x ", " with "]
        var remaining = artist.lowercased()

        for separator in separators {
            let parts = remaining.components(separatedBy: separator)
            if parts.count > 1 {
                names.append(parts[0].trimmingCharacters(in: .whitespaces))
                remaining = parts.dropFirst().joined(separator: separator)
            }
        }
        names.append(remaining.trimmingCharacters(in: .whitespaces))

        return names.filter { !$0.isEmpty }
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
