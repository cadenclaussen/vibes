import Foundation

enum FeedItem: Identifiable {
    case songShare(SongShare)
    case concert(Concert)
    case newFollow(Friendship, UserProfile)
    case newRelease(UnifiedAlbum)
    case aiRecommendation(UnifiedTrack, String) // track + reason

    var id: String {
        switch self {
        case .songShare(let share):
            return "share_\(share.id ?? UUID().uuidString)"
        case .concert(let concert):
            return "concert_\(concert.id)"
        case .newFollow(let friendship, _):
            return "follow_\(friendship.id ?? UUID().uuidString)"
        case .newRelease(let album):
            return "release_\(album.id)"
        case .aiRecommendation(let track, _):
            return "ai_\(track.id)"
        }
    }

    var timestamp: Date {
        switch self {
        case .songShare(let share):
            return share.timestamp
        case .concert(let concert):
            return concert.date
        case .newFollow(let friendship, _):
            return friendship.createdAt
        case .newRelease:
            return Date() // Use current date for releases
        case .aiRecommendation:
            return Date() // AI recommendations are always fresh
        }
    }

    var sortScore: Double {
        // Higher score = shown first
        let recencyScore = -timestamp.timeIntervalSinceNow / 3600 // Hours ago
        let typeBoost: Double
        switch self {
        case .songShare: typeBoost = 100
        case .concert: typeBoost = 80
        case .newFollow: typeBoost = 60
        case .newRelease: typeBoost = 70
        case .aiRecommendation: typeBoost = 50
        }
        return typeBoost - min(recencyScore, 168) // Cap at 1 week
    }
}
