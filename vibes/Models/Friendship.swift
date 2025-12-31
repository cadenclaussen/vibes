import Foundation
import FirebaseFirestore

struct Friendship: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var followerId: String
    var followingId: String
    var createdAt: Date
    var vibestreak: Int
    var lastInteractionDate: Date?

    init(
        id: String? = nil,
        followerId: String,
        followingId: String,
        createdAt: Date = Date(),
        vibestreak: Int = 0,
        lastInteractionDate: Date? = nil
    ) {
        self.id = id
        self.followerId = followerId
        self.followingId = followingId
        self.createdAt = createdAt
        self.vibestreak = vibestreak
        self.lastInteractionDate = lastInteractionDate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(followerId)
        hasher.combine(followingId)
    }

    static func == (lhs: Friendship, rhs: Friendship) -> Bool {
        lhs.followerId == rhs.followerId && lhs.followingId == rhs.followingId
    }
}
