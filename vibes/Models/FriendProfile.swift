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

    init(from userProfile: UserProfile) {
        self.id = userProfile.uid
        self.username = userProfile.username
        self.displayName = userProfile.displayName
        self.musicTasteTags = userProfile.musicTasteTags
    }
}
