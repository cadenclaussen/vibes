//
//  FriendProfile.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import Foundation

struct FriendProfile: Codable, Identifiable, Hashable {
    let id: String
    let username: String
    let displayName: String
    let musicTasteTags: [String]
    let vibestreak: Int
    let streakLastUpdated: Date?
    let friendshipId: String?

    // Returns 0 if streak has expired (not updated yesterday or today)
    var activeVibestreak: Int {
        guard vibestreak > 0, let lastUpdated = streakLastUpdated else {
            return 0
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastUpdateDay = calendar.startOfDay(for: lastUpdated)

        if lastUpdateDay == today || lastUpdateDay == yesterday {
            return vibestreak
        }
        return 0
    }

    init(from userProfile: UserProfile, vibestreak: Int = 0, streakLastUpdated: Date? = nil, friendshipId: String? = nil) {
        self.id = userProfile.uid
        self.username = userProfile.username
        self.displayName = userProfile.displayName
        self.musicTasteTags = userProfile.musicTasteTags
        self.vibestreak = vibestreak
        self.streakLastUpdated = streakLastUpdated
        self.friendshipId = friendshipId
    }
}
