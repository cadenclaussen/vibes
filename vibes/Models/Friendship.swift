//
//  Friendship.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import Foundation
import FirebaseFirestore

struct Friendship: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var friendId: String
    var status: FriendshipStatus
    var initiatorId: String
    var vibestreak: Int
    var lastInteractionDate: Date?
    var compatibilityScore: Double
    var sharedArtists: [String]
    var createdAt: Date
    var acceptedAt: Date?

    enum FriendshipStatus: String, Codable {
        case pending
        case accepted
    }
}
