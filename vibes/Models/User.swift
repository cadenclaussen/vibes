//
//  User.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var username: String
    var displayName: String
    var bio: String?
    var profilePictureURL: String?
    var spotifyId: String?
    var spotifyLinked: Bool
    var favoriteArtists: [String]
    var favoriteSongs: [String]
    var favoriteAlbums: [String]
    var musicTasteTags: [String]
    var customLyrics: String?
    var profileTheme: String?
    var pinnedSongs: [String]
    var createdAt: Date
    var updatedAt: Date
    var privacySettings: PrivacySettings
    var fcmToken: String?
    var isOnline: Bool?
    var lastSeen: Date?

    // Now Playing
    var nowPlayingTrackId: String?
    var nowPlayingTrackName: String?
    var nowPlayingArtistName: String?
    var nowPlayingAlbumArt: String?
    var nowPlayingUpdatedAt: Date?

    struct PrivacySettings: Codable {
        var profileVisibility: String
        var showNowPlaying: Bool
        var showListeningStats: Bool
        var allowFriendRequests: String

        init() {
            profileVisibility = "friends"
            showNowPlaying = true
            showListeningStats = true
            allowFriendRequests = "everyone"
        }
    }

    init(uid: String, email: String, username: String) {
        self.uid = uid
        self.email = email
        self.username = username
        self.displayName = username
        self.spotifyLinked = false
        self.favoriteArtists = []
        self.favoriteSongs = []
        self.favoriteAlbums = []
        self.musicTasteTags = []
        self.pinnedSongs = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.privacySettings = PrivacySettings()
    }
}
