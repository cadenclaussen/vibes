import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
@MainActor
final class SocialService {
    static let shared = SocialService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - User Search

    func getAllUsers(limit: Int = 50) async throws -> [UserProfile] {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            return []
        }

        // Get all users ordered by most recently joined
        let snapshot = try await db.collection(Constants.Firestore.users)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            if let profile = try? doc.data(as: UserProfile.self),
               profile.uid != currentUserId {
                return profile
            }
            return nil
        }
    }

    func searchUsers(query: String) async throws -> [UserProfile] {
        guard !query.isEmpty else { return [] }

        let lowercasedQuery = query.lowercased()

        // Search by username prefix
        let usernameSnapshot = try await db.collection(Constants.Firestore.users)
            .whereField("username", isGreaterThanOrEqualTo: lowercasedQuery)
            .whereField("username", isLessThan: lowercasedQuery + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()

        var results: [UserProfile] = []
        var seenIds = Set<String>()

        for doc in usernameSnapshot.documents {
            if let profile = try? doc.data(as: UserProfile.self),
               profile.uid != AuthManager.shared.user?.uid {
                results.append(profile)
                seenIds.insert(profile.uid)
            }
        }

        // Also search by display name if we have room
        if results.count < 20 {
            let displayNameSnapshot = try await db.collection(Constants.Firestore.users)
                .whereField("displayName", isGreaterThanOrEqualTo: query)
                .whereField("displayName", isLessThan: query + "\u{f8ff}")
                .limit(to: 20 - results.count)
                .getDocuments()

            for doc in displayNameSnapshot.documents {
                if let profile = try? doc.data(as: UserProfile.self),
                   profile.uid != AuthManager.shared.user?.uid,
                   !seenIds.contains(profile.uid) {
                    results.append(profile)
                }
            }
        }

        return results
    }

    // MARK: - Follow Operations

    func follow(userId: String) async throws {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            throw VibesError.notAuthenticated
        }

        let friendship = Friendship(
            followerId: currentUserId,
            followingId: userId,
            createdAt: Date()
        )

        try await db.collection(Constants.Firestore.friendships)
            .addDocument(from: friendship)
    }

    func unfollow(userId: String) async throws {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            throw VibesError.notAuthenticated
        }

        let snapshot = try await db.collection(Constants.Firestore.friendships)
            .whereField("followerId", isEqualTo: currentUserId)
            .whereField("followingId", isEqualTo: userId)
            .getDocuments()

        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
    }

    func isFollowing(userId: String) async throws -> Bool {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            return false
        }

        let snapshot = try await db.collection(Constants.Firestore.friendships)
            .whereField("followerId", isEqualTo: currentUserId)
            .whereField("followingId", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments()

        return !snapshot.documents.isEmpty
    }

    func getFollowingIds() async throws -> [String] {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            return []
        }

        let snapshot = try await db.collection(Constants.Firestore.friendships)
            .whereField("followerId", isEqualTo: currentUserId)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            doc.data()["followingId"] as? String
        }
    }

    func getFollowers(for userId: String) async throws -> [UserProfile] {
        let snapshot = try await db.collection(Constants.Firestore.friendships)
            .whereField("followingId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        let followerIds = snapshot.documents.compactMap { doc in
            doc.data()["followerId"] as? String
        }

        return try await fetchUserProfiles(ids: followerIds)
    }

    func getFollowing(for userId: String) async throws -> [UserProfile] {
        let snapshot = try await db.collection(Constants.Firestore.friendships)
            .whereField("followerId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        let followingIds = snapshot.documents.compactMap { doc in
            doc.data()["followingId"] as? String
        }

        return try await fetchUserProfiles(ids: followingIds)
    }

    func getFollowerCount(for userId: String) async throws -> Int {
        let snapshot = try await db.collection(Constants.Firestore.friendships)
            .whereField("followingId", isEqualTo: userId)
            .count
            .getAggregation(source: .server)

        return Int(truncating: snapshot.count)
    }

    func getFollowingCount(for userId: String) async throws -> Int {
        let snapshot = try await db.collection(Constants.Firestore.friendships)
            .whereField("followerId", isEqualTo: userId)
            .count
            .getAggregation(source: .server)

        return Int(truncating: snapshot.count)
    }

    private func fetchUserProfiles(ids: [String]) async throws -> [UserProfile] {
        guard !ids.isEmpty else { return [] }

        // Firestore 'in' queries limited to 30 items
        var profiles: [UserProfile] = []
        for chunk in ids.chunked(into: 30) {
            let snapshot = try await db.collection(Constants.Firestore.users)
                .whereField("uid", in: chunk)
                .getDocuments()

            for doc in snapshot.documents {
                if let profile = try? doc.data(as: UserProfile.self) {
                    profiles.append(profile)
                }
            }
        }

        // Preserve original order
        let idOrder = Dictionary(uniqueKeysWithValues: ids.enumerated().map { ($1, $0) })
        return profiles.sorted { (idOrder[$0.uid] ?? 0) < (idOrder[$1.uid] ?? 0) }
    }

    // MARK: - Song Sharing

    func shareSong(_ track: UnifiedTrack, message: String?) async throws {
        guard let currentUser = AuthManager.shared.userProfile else {
            throw VibesError.notAuthenticated
        }

        let share = SongShare(
            senderId: currentUser.uid,
            senderUsername: currentUser.username,
            senderProfilePicture: currentUser.profilePictureURL,
            recipientId: nil,
            spotifyTrackId: track.id,
            trackName: track.name,
            artistName: track.artistName,
            albumArtURL: track.albumArtURL ?? "",
            previewURL: track.previewURL,
            message: message,
            timestamp: Date()
        )

        try db.collection(Constants.Firestore.songShares).addDocument(from: share)
    }

    func getSharesFromFollowing(limit: Int = 50) async throws -> [SongShare] {
        let followingIds = try await getFollowingIds()
        guard !followingIds.isEmpty else { return [] }

        // Get muted user IDs to filter them out
        let mutedIds = Set(try await getMutedIds())

        // Filter out muted users from following list
        let unmutedFollowingIds = followingIds.filter { !mutedIds.contains($0) }
        guard !unmutedFollowingIds.isEmpty else { return [] }

        // Query shares from people we follow (excluding muted)
        var allShares: [SongShare] = []

        // Firestore 'in' queries limited to 30 items
        for chunk in unmutedFollowingIds.chunked(into: 30) {
            let snapshot = try await db.collection(Constants.Firestore.songShares)
                .whereField("senderId", in: chunk)
                .order(by: "timestamp", descending: true)
                .limit(to: limit)
                .getDocuments()

            for doc in snapshot.documents {
                if let share = try? doc.data(as: SongShare.self) {
                    allShares.append(share)
                }
            }
        }

        // Sort by timestamp and limit
        return allShares
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(limit)
            .map { $0 }
    }

    func getReceivedShares(limit: Int = 50) async throws -> [SongShare] {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            return []
        }

        let snapshot = try await db.collection(Constants.Firestore.songShares)
            .whereField("recipientId", isEqualTo: currentUserId)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: SongShare.self)
        }
    }

    func getUserShares(userId: String, limit: Int = 50) async throws -> [SongShare] {
        let snapshot = try await db.collection(Constants.Firestore.songShares)
            .whereField("senderId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: SongShare.self)
        }
    }

    func getUserProfile(userId: String) async throws -> UserProfile? {
        let doc = try await db.collection(Constants.Firestore.users)
            .document(userId)
            .getDocument()

        return try? doc.data(as: UserProfile.self)
    }

    // MARK: - Friend Recommendations

    struct FriendRecommendation {
        let trackId: String
        let trackName: String
        let artistName: String
        let albumArtURL: String
        let friendUsernames: [String]
    }

    func getPopularSongsAmongFriends(minFriends: Int = 1, limit: Int = 10) async throws -> [FriendRecommendation] {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            return []
        }

        // Get shares from people we follow (last 30 days)
        let followingIds = try await getFollowingIds()
        guard !followingIds.isEmpty else { return [] }

        // Get muted users to exclude
        let mutedIds = Set(try await getMutedIds())
        let unmutedFollowingIds = followingIds.filter { !mutedIds.contains($0) }
        guard !unmutedFollowingIds.isEmpty else { return [] }

        // Get user's own shared songs to exclude
        let userShares = try await getUserShares(userId: currentUserId, limit: 100)
        let userSharedTrackIds = Set(userShares.map { $0.spotifyTrackId })

        // Fetch all shares from friends (last 30 days)
        var allShares: [SongShare] = []
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()

        for chunk in unmutedFollowingIds.chunked(into: 30) {
            let snapshot = try await db.collection(Constants.Firestore.songShares)
                .whereField("senderId", in: chunk)
                .whereField("timestamp", isGreaterThan: Timestamp(date: thirtyDaysAgo))
                .getDocuments()

            for doc in snapshot.documents {
                if let share = try? doc.data(as: SongShare.self) {
                    allShares.append(share)
                }
            }
        }

        // Group by track ID and collect unique friend usernames
        var trackToFriends: [String: (share: SongShare, friends: Set<String>)] = [:]
        for share in allShares {
            // Skip songs user has already shared
            if userSharedTrackIds.contains(share.spotifyTrackId) {
                continue
            }

            if var existing = trackToFriends[share.spotifyTrackId] {
                existing.friends.insert(share.senderUsername)
                trackToFriends[share.spotifyTrackId] = existing
            } else {
                trackToFriends[share.spotifyTrackId] = (share, [share.senderUsername])
            }
        }

        // Filter to songs shared by minimum number of friends, sort by friend count
        let recommendations = trackToFriends.values
            .filter { $0.friends.count >= minFriends }
            .sorted { $0.friends.count > $1.friends.count }
            .prefix(limit)
            .map { item in
                FriendRecommendation(
                    trackId: item.share.spotifyTrackId,
                    trackName: item.share.trackName,
                    artistName: item.share.artistName,
                    albumArtURL: item.share.albumArtURL,
                    friendUsernames: Array(item.friends).sorted()
                )
            }

        return Array(recommendations)
    }

    // MARK: - Mute Operations

    func mute(userId: String) async throws {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            throw VibesError.notAuthenticated
        }

        let muteData: [String: Any] = [
            "muterId": currentUserId,
            "mutedId": userId,
            "createdAt": Timestamp(date: Date())
        ]

        try await db.collection(Constants.Firestore.mutes)
            .addDocument(data: muteData)
    }

    func unmute(userId: String) async throws {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            throw VibesError.notAuthenticated
        }

        let snapshot = try await db.collection(Constants.Firestore.mutes)
            .whereField("muterId", isEqualTo: currentUserId)
            .whereField("mutedId", isEqualTo: userId)
            .getDocuments()

        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
    }

    func isMuted(userId: String) async throws -> Bool {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            return false
        }

        let snapshot = try await db.collection(Constants.Firestore.mutes)
            .whereField("muterId", isEqualTo: currentUserId)
            .whereField("mutedId", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments()

        return !snapshot.documents.isEmpty
    }

    func getMutedIds() async throws -> [String] {
        guard let currentUserId = AuthManager.shared.user?.uid else {
            return []
        }

        let snapshot = try await db.collection(Constants.Firestore.mutes)
            .whereField("muterId", isEqualTo: currentUserId)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            doc.data()["mutedId"] as? String
        }
    }
}

// MARK: - Array Extension

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
