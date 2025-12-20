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
    let profilePictureURL: String?
    let musicTasteTags: [String]
    let vibestreak: Int
    let streakLastUpdated: Date?
    let friendshipId: String?
    let isOnline: Bool
    let lastSeen: Date?

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

    var lastSeenText: String? {
        guard !isOnline else { return nil }
        guard let lastSeen = lastSeen else { return nil }

        let seconds = Int(Date().timeIntervalSince(lastSeen))

        if seconds < 60 {
            return "Active now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "Active \(minutes)m ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "Active \(hours)h ago"
        } else {
            let days = seconds / 86400
            if days == 1 {
                return "Active yesterday"
            }
            return "Active \(days)d ago"
        }
    }

    init(from userProfile: UserProfile, vibestreak: Int = 0, streakLastUpdated: Date? = nil, friendshipId: String? = nil) {
        self.id = userProfile.uid
        self.username = userProfile.username
        self.displayName = userProfile.displayName
        self.profilePictureURL = userProfile.profilePictureURL
        self.musicTasteTags = userProfile.musicTasteTags
        self.vibestreak = vibestreak
        self.streakLastUpdated = streakLastUpdated
        self.friendshipId = friendshipId
        self.isOnline = userProfile.isOnline ?? false
        self.lastSeen = userProfile.lastSeen
    }
}
