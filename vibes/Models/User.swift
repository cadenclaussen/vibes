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

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            profileVisibility = try container.decodeIfPresent(String.self, forKey: .profileVisibility) ?? "friends"
            showNowPlaying = try container.decodeIfPresent(Bool.self, forKey: .showNowPlaying) ?? true
            showListeningStats = try container.decodeIfPresent(Bool.self, forKey: .showListeningStats) ?? true
            allowFriendRequests = try container.decodeIfPresent(String.self, forKey: .allowFriendRequests) ?? "everyone"
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Required fields that should always exist
        uid = try container.decode(String.self, forKey: .uid)
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? username

        // Optional fields
        id = try container.decodeIfPresent(String.self, forKey: .id)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        profilePictureURL = try container.decodeIfPresent(String.self, forKey: .profilePictureURL)
        spotifyId = try container.decodeIfPresent(String.self, forKey: .spotifyId)
        customLyrics = try container.decodeIfPresent(String.self, forKey: .customLyrics)
        profileTheme = try container.decodeIfPresent(String.self, forKey: .profileTheme)
        fcmToken = try container.decodeIfPresent(String.self, forKey: .fcmToken)
        isOnline = try container.decodeIfPresent(Bool.self, forKey: .isOnline)
        lastSeen = try container.decodeIfPresent(Date.self, forKey: .lastSeen)

        // Now Playing fields
        nowPlayingTrackId = try container.decodeIfPresent(String.self, forKey: .nowPlayingTrackId)
        nowPlayingTrackName = try container.decodeIfPresent(String.self, forKey: .nowPlayingTrackName)
        nowPlayingArtistName = try container.decodeIfPresent(String.self, forKey: .nowPlayingArtistName)
        nowPlayingAlbumArt = try container.decodeIfPresent(String.self, forKey: .nowPlayingAlbumArt)
        nowPlayingUpdatedAt = try container.decodeIfPresent(Date.self, forKey: .nowPlayingUpdatedAt)

        // Fields with defaults (previously non-optional without custom decoder)
        spotifyLinked = try container.decodeIfPresent(Bool.self, forKey: .spotifyLinked) ?? false
        favoriteArtists = try container.decodeIfPresent([String].self, forKey: .favoriteArtists) ?? []
        favoriteSongs = try container.decodeIfPresent([String].self, forKey: .favoriteSongs) ?? []
        favoriteAlbums = try container.decodeIfPresent([String].self, forKey: .favoriteAlbums) ?? []
        musicTasteTags = try container.decodeIfPresent([String].self, forKey: .musicTasteTags) ?? []
        pinnedSongs = try container.decodeIfPresent([String].self, forKey: .pinnedSongs) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        privacySettings = try container.decodeIfPresent(PrivacySettings.self, forKey: .privacySettings) ?? PrivacySettings()
    }
}
