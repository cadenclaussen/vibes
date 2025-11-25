//
//  FriendService.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendService {
    static let shared = FriendService()
    private lazy var db = Firestore.firestore()

    private init() {}

    // MARK: - Friend Requests

    func sendFriendRequest(toUsername: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let usersRef = db.collection("users")
        print("🔍 Searching for username: '\(toUsername)'")

        let snapshot = try await usersRef.whereField("username", isEqualTo: toUsername).getDocuments()

        print("📊 Found \(snapshot.documents.count) documents")
        for doc in snapshot.documents {
            print("   - Document ID: \(doc.documentID)")
            if let data = doc.data() as? [String: Any] {
                print("   - Username in doc: \(data["username"] ?? "nil")")
            }
        }

        guard let targetUser = snapshot.documents.first else {
            print("❌ No user found with username: '\(toUsername)'")

            let allUsers = try await usersRef.getDocuments()
            print("📋 Total users in collection: \(allUsers.documents.count)")
            for doc in allUsers.documents.prefix(5) {
                if let data = doc.data() as? [String: Any] {
                    print("   - User: \(data["username"] ?? "no username")")
                }
            }

            throw NSError(domain: "FriendService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        let targetUserId = targetUser.documentID

        if targetUserId == currentUserId {
            throw NSError(domain: "FriendService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cannot send friend request to yourself"])
        }

        let existingFriendship = try await checkExistingFriendship(userId: currentUserId, friendId: targetUserId)
        if existingFriendship != nil {
            throw NSError(domain: "FriendService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Friend request already exists"])
        }

        let friendship = Friendship(
            userId: currentUserId,
            friendId: targetUserId,
            status: .pending,
            initiatorId: currentUserId,
            vibestreak: 0,
            lastInteractionDate: nil,
            compatibilityScore: 0.0,
            sharedArtists: [],
            createdAt: Date(),
            acceptedAt: nil
        )

        try db.collection("friendships").document().setData(from: friendship)

        let currentUserProfile = try await fetchUserProfile(userId: currentUserId)
        try await createNotification(
            userId: targetUserId,
            type: .friendRequest,
            fromUserId: currentUserId,
            fromUsername: currentUserProfile.username,
            message: "\(currentUserProfile.displayName) sent you a friend request"
        )
    }

    func acceptFriendRequest(friendshipId: String) async throws {
        let friendshipRef = db.collection("friendships").document(friendshipId)
        try await friendshipRef.updateData([
            "status": Friendship.FriendshipStatus.accepted.rawValue,
            "acceptedAt": Date()
        ])

        let friendshipDoc = try await friendshipRef.getDocument()
        guard let friendship = try? friendshipDoc.data(as: Friendship.self) else { return }

        let currentUserProfile = try await fetchUserProfile(userId: friendship.friendId)
        try await createNotification(
            userId: friendship.userId,
            type: .friendAccepted,
            fromUserId: friendship.friendId,
            fromUsername: currentUserProfile.username,
            message: "\(currentUserProfile.displayName) accepted your friend request"
        )
    }

    func declineFriendRequest(friendshipId: String) async throws {
        try await db.collection("friendships").document(friendshipId).delete()
    }

    func removeFriend(friendshipId: String) async throws {
        try await db.collection("friendships").document(friendshipId).delete()
    }

    // MARK: - Fetch Friends

    func fetchFriends() async throws -> [FriendProfile] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let friendshipsRef = db.collection("friendships")

        let sentRequests = try await friendshipsRef
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: Friendship.FriendshipStatus.accepted.rawValue)
            .getDocuments()

        let receivedRequests = try await friendshipsRef
            .whereField("friendId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: Friendship.FriendshipStatus.accepted.rawValue)
            .getDocuments()

        var friendIds: [String] = []
        friendIds.append(contentsOf: sentRequests.documents.compactMap { doc in
            guard let friendship = try? doc.data(as: Friendship.self) else { return nil }
            return friendship.friendId
        })
        friendIds.append(contentsOf: receivedRequests.documents.compactMap { doc in
            guard let friendship = try? doc.data(as: Friendship.self) else { return nil }
            return friendship.userId
        })

        var friendProfiles: [FriendProfile] = []
        for friendId in friendIds {
            if let profile = try? await fetchUserProfile(userId: friendId) {
                friendProfiles.append(FriendProfile(from: profile))
            }
        }

        return friendProfiles
    }

    func fetchPendingRequests() async throws -> [(friendship: Friendship, profile: FriendProfile)] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let snapshot = try await db.collection("friendships")
            .whereField("friendId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: Friendship.FriendshipStatus.pending.rawValue)
            .getDocuments()

        var requests: [(friendship: Friendship, profile: FriendProfile)] = []

        for document in snapshot.documents {
            if let friendship = try? document.data(as: Friendship.self),
               let userProfile = try? await fetchUserProfile(userId: friendship.userId) {
                requests.append((friendship, FriendProfile(from: userProfile)))
            }
        }

        return requests
    }

    // MARK: - Notifications

    func fetchNotifications() async throws -> [FriendNotification] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: currentUserId)
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: FriendNotification.self) }
    }

    func markNotificationAsRead(notificationId: String) async throws {
        try await db.collection("notifications").document(notificationId).updateData(["isRead": true])
    }

    // MARK: - Helper Methods

    private func checkExistingFriendship(userId: String, friendId: String) async throws -> Friendship? {
        let sentRequest = try await db.collection("friendships")
            .whereField("userId", isEqualTo: userId)
            .whereField("friendId", isEqualTo: friendId)
            .getDocuments()

        if let doc = sentRequest.documents.first {
            return try? doc.data(as: Friendship.self)
        }

        let receivedRequest = try await db.collection("friendships")
            .whereField("userId", isEqualTo: friendId)
            .whereField("friendId", isEqualTo: userId)
            .getDocuments()

        if let doc = receivedRequest.documents.first {
            return try? doc.data(as: Friendship.self)
        }

        return nil
    }

    private func fetchUserProfile(userId: String) async throws -> UserProfile {
        let doc = try await db.collection("users").document(userId).getDocument()
        guard let profile = try? doc.data(as: UserProfile.self) else {
            throw NSError(domain: "FriendService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
        }
        return profile
    }

    private func createNotification(userId: String, type: FriendNotification.NotificationType, fromUserId: String, fromUsername: String, message: String) async throws {
        let notification = FriendNotification(
            userId: userId,
            type: type,
            fromUserId: fromUserId,
            fromUsername: fromUsername,
            message: message,
            createdAt: Date(),
            isRead: false
        )
        try db.collection("notifications").document().setData(from: notification)
    }
}
