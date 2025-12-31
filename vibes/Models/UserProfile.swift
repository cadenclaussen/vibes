import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var username: String
    var displayName: String
    var bio: String?
    var profilePictureURL: String?
    var spotifyId: String?
    var spotifyLinked: Bool
    var geminiKeyConfigured: Bool
    var concertCity: String?
    var createdAt: Date
    var updatedAt: Date
    var fcmToken: String?
    var privacySettings: PrivacySettings

    struct PrivacySettings: Codable, Hashable {
        var profileVisibility: String = "public"
        var showListeningStats: Bool = true

        init(profileVisibility: String = "public", showListeningStats: Bool = true) {
            self.profileVisibility = profileVisibility
            self.showListeningStats = showListeningStats
        }
    }

    init(
        id: String? = nil,
        uid: String,
        email: String,
        username: String,
        displayName: String,
        bio: String? = nil,
        profilePictureURL: String? = nil,
        spotifyId: String? = nil,
        spotifyLinked: Bool = false,
        geminiKeyConfigured: Bool = false,
        concertCity: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        fcmToken: String? = nil,
        privacySettings: PrivacySettings = PrivacySettings()
    ) {
        self.id = id
        self.uid = uid
        self.email = email
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.profilePictureURL = profilePictureURL
        self.spotifyId = spotifyId
        self.spotifyLinked = spotifyLinked
        self.geminiKeyConfigured = geminiKeyConfigured
        self.concertCity = concertCity
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.fcmToken = fcmToken
        self.privacySettings = privacySettings
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }

    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        lhs.uid == rhs.uid
    }
}
