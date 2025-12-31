import Foundation
import FirebaseFirestore

struct Achievement: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var userId: String
    var type: AchievementType
    var unlockedAt: Date
    var progress: Int

    enum AchievementType: String, Codable, CaseIterable {
        case firstShare = "firstShare"
        case tenFollows = "tenFollows"
        case genreExplorer = "genreExplorer"
        case streakBronze = "streakBronze"
        case streakSilver = "streakSilver"
        case streakGold = "streakGold"

        var title: String {
            switch self {
            case .firstShare: return "First Share"
            case .tenFollows: return "Social Butterfly"
            case .genreExplorer: return "Genre Explorer"
            case .streakBronze: return "Bronze Streak"
            case .streakSilver: return "Silver Streak"
            case .streakGold: return "Gold Streak"
            }
        }

        var description: String {
            switch self {
            case .firstShare: return "Shared your first song"
            case .tenFollows: return "Following 10 users"
            case .genreExplorer: return "Listened to 10+ genres"
            case .streakBronze: return "7-day streak"
            case .streakSilver: return "30-day streak"
            case .streakGold: return "100-day streak"
            }
        }

        var icon: String {
            switch self {
            case .firstShare: return "paperplane.fill"
            case .tenFollows: return "person.3.fill"
            case .genreExplorer: return "globe"
            case .streakBronze: return "flame.fill"
            case .streakSilver: return "flame.fill"
            case .streakGold: return "flame.fill"
            }
        }
    }

    init(
        id: String? = nil,
        userId: String,
        type: AchievementType,
        unlockedAt: Date = Date(),
        progress: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.unlockedAt = unlockedAt
        self.progress = progress
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
}
