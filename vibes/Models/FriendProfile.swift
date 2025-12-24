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
    let favoriteArtists: [String]
    let vibestreak: Int
    let streakLastUpdated: Date?
    let friendshipId: String?
    let isOnline: Bool
    let lastSeen: Date?

    // Now Playing
    let nowPlayingTrackId: String?
    let nowPlayingTrackName: String?
    let nowPlayingArtistName: String?
    let nowPlayingAlbumArt: String?
    let nowPlayingUpdatedAt: Date?

    var isCurrentlyPlaying: Bool {
        guard let updatedAt = nowPlayingUpdatedAt,
              nowPlayingTrackName != nil else { return false }
        // Consider "now playing" valid for 3 minutes
        return Date().timeIntervalSince(updatedAt) < 180
    }

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

    // Returns true if both users have messaged each other today (streak incremented today)
    var vibestreakCompletedToday: Bool {
        guard let lastUpdated = streakLastUpdated else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastUpdateDay = calendar.startOfDay(for: lastUpdated)
        return lastUpdateDay == today
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
        self.favoriteArtists = userProfile.favoriteArtists
        self.vibestreak = vibestreak
        self.streakLastUpdated = streakLastUpdated
        self.friendshipId = friendshipId
        self.isOnline = userProfile.isOnline ?? false
        self.lastSeen = userProfile.lastSeen
        self.nowPlayingTrackId = userProfile.nowPlayingTrackId
        self.nowPlayingTrackName = userProfile.nowPlayingTrackName
        self.nowPlayingArtistName = userProfile.nowPlayingArtistName
        self.nowPlayingAlbumArt = userProfile.nowPlayingAlbumArt
        self.nowPlayingUpdatedAt = userProfile.nowPlayingUpdatedAt
    }
}
