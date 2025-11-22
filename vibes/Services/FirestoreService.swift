//
//  FirestoreService.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Message Threads

    func getOrCreateThread(userId1: String, userId2: String) async throws -> String {
        let threadQuery = try await db.collection("messageThreads")
            .whereField("userId1", in: [userId1, userId2])
            .whereField("userId2", in: [userId1, userId2])
            .getDocuments()

        if let existingThread = threadQuery.documents.first {
            return existingThread.documentID
        }

        let threadData: [String: Any] = [
            "userId1": userId1,
            "userId2": userId2,
            "lastMessageTimestamp": Timestamp(),
            "lastMessageContent": "",
            "lastMessageType": "text",
            "unreadCountUser1": 0,
            "unreadCountUser2": 0,
            "createdAt": Timestamp()
        ]

        let docRef = try await db.collection("messageThreads").addDocument(data: threadData)
        return docRef.documentID
    }

    // MARK: - Messages

    func sendMessage(_ message: Message) async throws {
        let messageData = try Firestore.Encoder().encode(message)
        try await db.collection("messages").addDocument(data: messageData)

        try await updateThread(threadId: message.threadId, message: message)

        try await recordInteraction(
            senderId: message.senderId,
            recipientId: message.recipientId,
            type: message.messageType == .song ? "song" : "message"
        )
    }

    private func updateThread(threadId: String, message: Message) async throws {
        let updateData: [String: Any] = [
            "lastMessageTimestamp": message.timestamp,
            "lastMessageContent": message.messageType == .song ? "🎵 Song" : message.content,
            "lastMessageType": message.messageType.rawValue,
            "unreadCountUser2": FieldValue.increment(Int64(1))
        ]

        try await db.collection("messageThreads").document(threadId).updateData(updateData)
    }

    func listenToMessages(threadId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("messages")
            .whereField("threadId", isEqualTo: threadId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap { try? $0.data(as: Message.self) }
                completion(messages)
            }
    }

    func markMessagesAsRead(threadId: String, userId: String) async throws {
        let messages = try await db.collection("messages")
            .whereField("threadId", isEqualTo: threadId)
            .whereField("recipientId", isEqualTo: userId)
            .whereField("read", isEqualTo: false)
            .getDocuments()

        let batch = db.batch()
        for document in messages.documents {
            batch.updateData(["read": true], forDocument: document.reference)
        }
        try await batch.commit()
    }

    // MARK: - Reactions

    func addReaction(messageId: String, userId: String, reaction: String) async throws {
        try await db.collection("messages").document(messageId).updateData([
            "reactions.\(userId)": reaction
        ])
    }

    // MARK: - Friendships

    func sendFriendRequest(from userId: String, to friendId: String) async throws {
        let friendshipData: [String: Any] = [
            "userId": userId,
            "friendId": friendId,
            "status": "pending",
            "initiatorId": userId,
            "vibestreak": 0,
            "compatibilityScore": 0,
            "sharedArtists": [],
            "createdAt": Timestamp()
        ]

        try await db.collection("friendships").addDocument(data: friendshipData)

        try await createNotification(
            userId: friendId,
            type: "friendRequest",
            relatedId: userId,
            content: "sent you a friend request",
            title: "New Friend Request"
        )
    }

    func acceptFriendRequest(friendshipId: String) async throws {
        try await db.collection("friendships").document(friendshipId).updateData([
            "status": "accepted",
            "acceptedAt": Timestamp()
        ])

        let friendship = try await db.collection("friendships").document(friendshipId).getDocument()
        if let data = friendship.data(),
           let initiatorId = data["initiatorId"] as? String {
            try await createNotification(
                userId: initiatorId,
                type: "friendAccepted",
                relatedId: friendshipId,
                content: "accepted your friend request",
                title: "Friend Request Accepted"
            )
        }
    }

    func getFriends(userId: String) async throws -> [Friendship] {
        let friendships = try await db.collection("friendships")
            .whereField("status", isEqualTo: "accepted")
            .whereFilter(Filter.orFilter([
                Filter.whereField("userId", isEqualTo: userId),
                Filter.whereField("friendId", isEqualTo: userId)
            ]))
            .getDocuments()

        return friendships.documents.compactMap { try? $0.data(as: Friendship.self) }
    }

    func searchUsers(query: String, excludeUserId: String) async throws -> [UserProfile] {
        let users = try await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query)
            .whereField("username", isLessThan: query + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()

        return users.documents
            .compactMap { try? $0.data(as: UserProfile.self) }
            .filter { $0.uid != excludeUserId }
    }

    // MARK: - Vibestreaks

    private func recordInteraction(senderId: String, recipientId: String, type: String) async throws {
        let friendships = try await db.collection("friendships")
            .whereField("status", isEqualTo: "accepted")
            .whereFilter(Filter.orFilter([
                Filter.andFilter([
                    Filter.whereField("userId", isEqualTo: senderId),
                    Filter.whereField("friendId", isEqualTo: recipientId)
                ]),
                Filter.andFilter([
                    Filter.whereField("userId", isEqualTo: recipientId),
                    Filter.whereField("friendId", isEqualTo: senderId)
                ])
            ]))
            .getDocuments()

        guard let friendshipDoc = friendships.documents.first else { return }

        let interactionData: [String: Any] = [
            "friendshipId": friendshipDoc.documentID,
            "userId": senderId,
            "interactionType": type,
            "timestamp": Timestamp()
        ]

        try await db.collection("interactions").addDocument(data: interactionData)

        try await friendshipDoc.reference.updateData([
            "lastInteractionDate": Timestamp()
        ])
    }

    func listenToVibestreak(friendshipId: String, completion: @escaping (Int) -> Void) -> ListenerRegistration {
        return db.collection("friendships").document(friendshipId)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(),
                      let streak = data["vibestreak"] as? Int else { return }
                completion(streak)
            }
    }

    // MARK: - User Profiles

    func getUserProfile(userId: String) async throws -> UserProfile {
        let document = try await db.collection("users").document(userId).getDocument()
        return try document.data(as: UserProfile.self)
    }

    func updateProfile(_ profile: UserProfile) async throws {
        guard let userId = profile.id else { return }

        var updatedProfile = profile
        updatedProfile.updatedAt = Date()

        try db.collection("users").document(userId).setData(from: updatedProfile, merge: true)
    }

    func updatePrivacySettings(userId: String, settings: UserProfile.PrivacySettings) async throws {
        try await db.collection("users").document(userId).updateData([
            "privacySettings": [
                "profileVisibility": settings.profileVisibility,
                "showNowPlaying": settings.showNowPlaying,
                "showListeningStats": settings.showListeningStats,
                "allowFriendRequests": settings.allowFriendRequests
            ]
        ])
    }

    func linkSpotifyAccount(userId: String, spotifyId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "spotifyId": spotifyId,
            "spotifyLinked": true
        ])
    }

    // MARK: - Notifications

    func createNotification(userId: String, type: String, relatedId: String, content: String, title: String, imageURL: String? = nil) async throws {
        let notificationData: [String: Any] = [
            "userId": userId,
            "notificationType": type,
            "relatedId": relatedId,
            "content": content,
            "title": title,
            "imageURL": imageURL ?? "",
            "timestamp": Timestamp(),
            "read": false,
            "actionURL": generateDeepLink(type: type, relatedId: relatedId)
        ]

        try await db.collection("notifications").addDocument(data: notificationData)
    }

    private func generateDeepLink(type: String, relatedId: String) -> String {
        switch type {
        case "message":
            return "vibes://thread/\(relatedId)"
        case "friendRequest":
            return "vibes://friends/requests"
        case "songRecommendation":
            return "vibes://song/\(relatedId)"
        case "vibestreakMilestone":
            return "vibes://friendship/\(relatedId)"
        case "achievement":
            return "vibes://stats/achievements"
        default:
            return "vibes://notifications"
        }
    }
}
