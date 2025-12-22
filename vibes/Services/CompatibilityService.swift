//
//  CompatibilityService.swift
//  vibes
//
//  Created by Claude Code on 12/21/25.
//

import Foundation

struct CompatibilityResult {
    let score: Int // 0-100
    let sharedArtists: [String]
    let sharedGenres: [String]

    var level: CompatibilityLevel {
        switch score {
        case 80...100: return .high
        case 50..<80: return .medium
        default: return .low
        }
    }

    var emoji: String {
        switch level {
        case .high: return "fire"
        case .medium: return "star"
        case .low: return "sparkle"
        }
    }

    var color: String {
        switch level {
        case .high: return "green"
        case .medium: return "orange"
        case .low: return "gray"
        }
    }
}

enum CompatibilityLevel {
    case high, medium, low
}

class CompatibilityService {
    static let shared = CompatibilityService()
    private init() {}

    // Calculate compatibility between current user and a friend
    func calculateCompatibility(
        userArtists: [String],
        userGenres: [String],
        friendArtists: [String],
        friendGenres: [String]
    ) -> CompatibilityResult {
        // Normalize arrays for comparison (lowercase, trimmed)
        let normalizedUserArtists = Set(userArtists.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        let normalizedFriendArtists = Set(friendArtists.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        let normalizedUserGenres = Set(userGenres.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        let normalizedFriendGenres = Set(friendGenres.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })

        // Find shared items
        let sharedArtistsSet = normalizedUserArtists.intersection(normalizedFriendArtists)
        let sharedGenresSet = normalizedUserGenres.intersection(normalizedFriendGenres)

        // Calculate scores (weighted: artists 60%, genres 40%)
        let artistScore = calculateOverlapScore(
            shared: sharedArtistsSet.count,
            userCount: normalizedUserArtists.count,
            friendCount: normalizedFriendArtists.count
        )
        let genreScore = calculateOverlapScore(
            shared: sharedGenresSet.count,
            userCount: normalizedUserGenres.count,
            friendCount: normalizedFriendGenres.count
        )

        // Weight the scores - prioritize artists (Spotify data) over genres (manual tags)
        let weightedScore: Double
        if normalizedUserArtists.isEmpty && normalizedFriendArtists.isEmpty {
            // No artist data, use only genre score
            weightedScore = genreScore * 100
        } else if normalizedUserGenres.isEmpty && normalizedFriendGenres.isEmpty {
            // No genre data, use only artist score
            weightedScore = artistScore * 100
        } else {
            // Both available - heavily weight artists (90%) since it's real Spotify data
            // Genres are manually selected tags, less reliable for compatibility
            weightedScore = (artistScore * 0.9 + genreScore * 0.1) * 100
        }

        // Get original-case shared items for display
        let sharedArtists = userArtists.filter { artist in
            sharedArtistsSet.contains(artist.lowercased().trimmingCharacters(in: .whitespaces))
        }
        let sharedGenres = userGenres.filter { genre in
            sharedGenresSet.contains(genre.lowercased().trimmingCharacters(in: .whitespaces))
        }

        return CompatibilityResult(
            score: min(100, max(0, Int(weightedScore))),
            sharedArtists: sharedArtists,
            sharedGenres: sharedGenres
        )
    }

    // Jaccard-like overlap score
    private func calculateOverlapScore(shared: Int, userCount: Int, friendCount: Int) -> Double {
        guard userCount > 0 || friendCount > 0 else { return 0 }
        let union = userCount + friendCount - shared
        guard union > 0 else { return 0 }
        return Double(shared) / Double(union)
    }
}
