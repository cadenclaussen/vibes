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
    private lazy var db = Firestore.firestore()

    private init() {}

    // MARK: - Message Threads

    func getOrCreateThread(userId1: String, userId2: String) async throws -> String {
        print("🔍 Looking for thread between \(userId1) and \(userId2)")

        let threadQuery = try await db.collection("messageThreads")
            .whereField("userId1", in: [userId1, userId2])
            .whereField("userId2", in: [userId1, userId2])
            .getDocuments()

        print("🔍 Found \(threadQuery.documents.count) potential threads")

        if let existingThread = threadQuery.documents.first {
            print("✅ Using existing thread: \(existingThread.documentID)")
            return existingThread.documentID
        }

        print("➕ Creating new thread")
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
        print("✅ Created new thread: \(docRef.documentID)")
        return docRef.documentID
    }

    // MARK: - Message Threads Listening

    func listenToThreads(userId: String, completion: @escaping ([MessageThread]) -> Void) -> ListenerRegistration {
        return db.collection("messageThreads")
            .whereFilter(Filter.orFilter([
                Filter.whereField("userId1", isEqualTo: userId),
                Filter.whereField("userId2", isEqualTo: userId)
            ]))
            .order(by: "lastMessageTimestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }
                let threads = documents.compactMap { try? $0.data(as: MessageThread.self) }
                DispatchQueue.main.async {
                    completion(threads)
                }
            }
    }

    // MARK: - Messages

    func sendMessage(_ message: Message) async throws {
        let messageData = try Firestore.Encoder().encode(message)
        try await db.collection("messages").addDocument(data: messageData)

        try await updateThread(threadId: message.threadId, message: message)

        // Record interaction for vibestreak (only for 1-on-1 messages)
        if let recipientId = message.recipientId {
            try await recordInteraction(
                senderId: message.senderId,
                recipientId: recipientId,
                type: message.messageType == .song ? "song" : "message"
            )
        }
    }

    private func updateThread(threadId: String, message: Message) async throws {
        let messagePreview: String
        if message.messageType == .song {
            messagePreview = "🎵 \(message.songTitle ?? "Shared a song")"
        } else {
            messagePreview = message.textContent ?? ""
        }

        let updateData: [String: Any] = [
            "lastMessageTimestamp": message.timestamp,
            "lastMessageContent": messagePreview,
            "lastMessageType": message.messageType.rawValue
        ]

        try await db.collection("messageThreads").document(threadId).updateData(updateData)
    }

    func listenToMessages(threadId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        print("🎧 Setting up listener for thread: \(threadId)")
        let listener = db.collection("messages")
            .whereField("threadId", isEqualTo: threadId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                print("🔔 LISTENER CALLBACK FIRED for thread: \(threadId)")

                if let error = error {
                    print("❌ Firestore listener error: \(error)")
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents in snapshot")
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }

                print("📦 Firestore snapshot received: \(documents.count) documents")
                let messages = documents.compactMap { doc -> Message? in
                    do {
                        let message = try doc.data(as: Message.self)
                        print("✅ Decoded message: id=\(message.id ?? "nil"), text=\(message.textContent ?? "no-text")")
                        return message
                    } catch {
                        print("❌ Failed to decode message: \(error)")
                        return nil
                    }
                }

                print("📨 Dispatching \(messages.count) messages to main thread")
                DispatchQueue.main.async {
                    completion(messages)
                }
            }

        print("✅ Listener registered for thread: \(threadId)")
        return listener
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

    func addReaction(messageId: String, threadId: String, userId: String, reaction: String) async throws {
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

        guard let friendshipDoc = friendships.documents.first,
              let friendship = try? friendshipDoc.data(as: Friendship.self) else { return }

        let interactionData: [String: Any] = [
            "friendshipId": friendshipDoc.documentID,
            "userId": senderId,
            "interactionType": type,
            "timestamp": Timestamp()
        ]

        try await db.collection("interactions").addDocument(data: interactionData)

        // Update vibestreak
        try await updateVibestreak(friendshipDoc: friendshipDoc, friendship: friendship, senderId: senderId)
    }

    private func updateVibestreak(friendshipDoc: QueryDocumentSnapshot, friendship: Friendship, senderId: String) async throws {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        // Determine if sender is user1 (userId) or user2 (friendId)
        let isUser1 = senderId == friendship.userId

        // Get the other user's last interaction
        let otherUserLastInteraction = isUser1 ? friendship.user2LastInteraction : friendship.user1LastInteraction
        let senderFieldName = isUser1 ? "user1LastInteraction" : "user2LastInteraction"

        var updateData: [String: Any] = [
            senderFieldName: Timestamp(date: now),
            "lastInteractionDate": Timestamp(date: now)
        ]

        // Check if both users have interacted today
        if let otherDate = otherUserLastInteraction {
            let otherDay = calendar.startOfDay(for: otherDate)

            if otherDay == today {
                // Both users have interacted today
                // Check if we already updated the streak today
                let streakAlreadyUpdatedToday: Bool
                if let lastUpdate = friendship.streakLastUpdated {
                    streakAlreadyUpdatedToday = calendar.startOfDay(for: lastUpdate) == today
                } else {
                    streakAlreadyUpdatedToday = false
                }

                if !streakAlreadyUpdatedToday {
                    // Check if streak should continue or reset
                    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
                    var newStreak = 1

                    if let lastStreakUpdate = friendship.streakLastUpdated {
                        let lastUpdateDay = calendar.startOfDay(for: lastStreakUpdate)
                        if lastUpdateDay == yesterday {
                            // Streak continues from yesterday
                            newStreak = friendship.vibestreak + 1
                        } else if lastUpdateDay == today {
                            // Already updated today, keep current streak
                            newStreak = friendship.vibestreak
                        }
                        // Otherwise streak resets to 1
                    }

                    updateData["vibestreak"] = newStreak
                    updateData["streakLastUpdated"] = Timestamp(date: now)

                    // Check for milestones
                    if [7, 30, 100, 365].contains(newStreak) {
                        try await createStreakMilestoneNotification(
                            friendship: friendship,
                            streak: newStreak
                        )
                    }
                }
            }
        }

        try await friendshipDoc.reference.updateData(updateData)
    }

    private func createStreakMilestoneNotification(friendship: Friendship, streak: Int) async throws {
        let milestoneMessage: String
        switch streak {
        case 7:
            milestoneMessage = "1 week vibestreak!"
        case 30:
            milestoneMessage = "1 month vibestreak!"
        case 100:
            milestoneMessage = "100 day vibestreak!"
        case 365:
            milestoneMessage = "1 year vibestreak!"
        default:
            milestoneMessage = "\(streak) day vibestreak!"
        }

        // Notify both users
        for userId in [friendship.userId, friendship.friendId] {
            try await createNotification(
                userId: userId,
                type: "vibestreakMilestone",
                relatedId: friendship.id ?? "",
                content: milestoneMessage,
                title: "🔥 Streak Milestone!"
            )
        }
    }

    func listenToVibestreak(friendshipId: String, completion: @escaping (Int, Date?) -> Void) -> ListenerRegistration {
        return db.collection("friendships").document(friendshipId)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(),
                      let streak = data["vibestreak"] as? Int else { return }
                let lastUpdated = (data["streakLastUpdated"] as? Timestamp)?.dateValue()
                DispatchQueue.main.async {
                    completion(streak, lastUpdated)
                }
            }
    }

    func getFriendship(userId1: String, userId2: String) async throws -> (id: String, vibestreak: Int, streakLastUpdated: Date?)? {
        let friendships = try await db.collection("friendships")
            .whereField("status", isEqualTo: "accepted")
            .whereFilter(Filter.orFilter([
                Filter.andFilter([
                    Filter.whereField("userId", isEqualTo: userId1),
                    Filter.whereField("friendId", isEqualTo: userId2)
                ]),
                Filter.andFilter([
                    Filter.whereField("userId", isEqualTo: userId2),
                    Filter.whereField("friendId", isEqualTo: userId1)
                ])
            ]))
            .getDocuments()

        guard let doc = friendships.documents.first,
              let friendship = try? doc.data(as: Friendship.self) else { return nil }

        return (doc.documentID, friendship.vibestreak, friendship.streakLastUpdated)
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

    func syncTopArtistsToProfile(userId: String, artists: [String]) async throws {
        try await db.collection("users").document(userId).updateData([
            "favoriteArtists": artists,
            "updatedAt": Timestamp()
        ])
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

    // MARK: - Presence

    func updatePresence(userId: String, isOnline: Bool) async throws {
        var data: [String: Any] = [
            "isOnline": isOnline,
            "lastSeen": Date()
        ]

        if !isOnline {
            data["lastSeen"] = Date()
        }

        try await db.collection("users").document(userId).updateData(data)
    }

    func setUserOnline(userId: String) async throws {
        try await updatePresence(userId: userId, isOnline: true)
    }

    func setUserOffline(userId: String) async throws {
        try await updatePresence(userId: userId, isOnline: false)
    }

    // MARK: - Now Playing

    func updateNowPlaying(userId: String, trackId: String?, trackName: String?, artistName: String?, albumArt: String?) async throws {
        var data: [String: Any] = [
            "nowPlayingUpdatedAt": Date()
        ]

        if let trackId = trackId {
            data["nowPlayingTrackId"] = trackId
        } else {
            data["nowPlayingTrackId"] = FieldValue.delete()
        }

        if let trackName = trackName {
            data["nowPlayingTrackName"] = trackName
        } else {
            data["nowPlayingTrackName"] = FieldValue.delete()
        }

        if let artistName = artistName {
            data["nowPlayingArtistName"] = artistName
        } else {
            data["nowPlayingArtistName"] = FieldValue.delete()
        }

        if let albumArt = albumArt {
            data["nowPlayingAlbumArt"] = albumArt
        } else {
            data["nowPlayingAlbumArt"] = FieldValue.delete()
        }

        try await db.collection("users").document(userId).updateData(data)
    }

    func clearNowPlaying(userId: String) async throws {
        try await updateNowPlaying(userId: userId, trackId: nil, trackName: nil, artistName: nil, albumArt: nil)
    }

    // MARK: - Account Deletion

    func deleteAllUserData(userId: String) async throws {
        // Delete user's messages
        let messages = try await db.collection("messages")
            .whereField("senderId", isEqualTo: userId)
            .getDocuments()
        for doc in messages.documents {
            try await doc.reference.delete()
        }

        // Delete messages sent TO this user
        let receivedMessages = try await db.collection("messages")
            .whereField("recipientId", isEqualTo: userId)
            .getDocuments()
        for doc in receivedMessages.documents {
            try await doc.reference.delete()
        }

        // Delete friendships where user is involved
        let friendships1 = try await db.collection("friendships")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        for doc in friendships1.documents {
            try await doc.reference.delete()
        }

        let friendships2 = try await db.collection("friendships")
            .whereField("friendId", isEqualTo: userId)
            .getDocuments()
        for doc in friendships2.documents {
            try await doc.reference.delete()
        }

        // Delete message threads involving user
        let threads1 = try await db.collection("messageThreads")
            .whereField("userId1", isEqualTo: userId)
            .getDocuments()
        for doc in threads1.documents {
            try await doc.reference.delete()
        }

        let threads2 = try await db.collection("messageThreads")
            .whereField("userId2", isEqualTo: userId)
            .getDocuments()
        for doc in threads2.documents {
            try await doc.reference.delete()
        }

        // Delete user's notifications
        let notifications = try await db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        for doc in notifications.documents {
            try await doc.reference.delete()
        }

        // Delete user's interactions
        let interactions = try await db.collection("interactions")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        for doc in interactions.documents {
            try await doc.reference.delete()
        }

        // Delete user profile
        try await db.collection("users").document(userId).delete()

        print("All user data deleted for: \(userId)")
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

    // MARK: - Achievement Stats

    struct UserAchievementStats {
        var songsShared: Int = 0
        var playlistsShared: Int = 0
        var friendsCount: Int = 0
        var maxVibestreak: Int = 0
        var reactionsReceived: Int = 0
    }

    func getAchievementStats(userId: String) async throws -> UserAchievementStats {
        var stats = UserAchievementStats()

        let friendships = try await getFriends(userId: userId)
        stats.friendsCount = friendships.count
        stats.maxVibestreak = friendships.map { $0.vibestreak }.max() ?? 0

        let songMessages = try await db.collection("messages")
            .whereField("senderId", isEqualTo: userId)
            .whereField("messageType", isEqualTo: "song")
            .getDocuments()
        stats.songsShared = songMessages.documents.count

        let playlistMessages = try await db.collection("messages")
            .whereField("senderId", isEqualTo: userId)
            .whereField("messageType", isEqualTo: "playlist")
            .getDocuments()
        stats.playlistsShared = playlistMessages.documents.count

        // Count reactions received on user's messages from other users
        let userMessages = try await db.collection("messages")
            .whereField("senderId", isEqualTo: userId)
            .getDocuments()

        var reactionsCount = 0
        for doc in userMessages.documents {
            if let reactions = doc.data()["reactions"] as? [String: String] {
                // Count reactions from users other than the sender
                for reactorId in reactions.keys where reactorId != userId {
                    reactionsCount += 1
                }
            }
        }
        stats.reactionsReceived = reactionsCount

        return stats
    }

    // MARK: - Group Threads

    func createGroup(name: String, creatorId: String, participantIds: [String]) async throws -> String {
        let allParticipants = ([creatorId] + participantIds).uniqued().sorted()

        // Check if a group with these exact participants already exists
        if let existingGroupId = try await findExistingGroup(participantIds: allParticipants) {
            throw GroupError.alreadyExists(groupId: existingGroupId)
        }

        let groupData: [String: Any] = [
            "name": name,
            "creatorId": creatorId,
            "participantIds": allParticipants,
            "lastMessageTimestamp": Timestamp(),
            "lastMessageContent": "",
            "lastMessageType": "text",
            "lastMessageSenderId": NSNull(),
            "lastMessageSenderName": NSNull(),
            "unreadCounts": Dictionary(uniqueKeysWithValues: allParticipants.map { ($0, 0) }),
            "createdAt": Timestamp()
        ]

        let docRef = try await db.collection("groupThreads").addDocument(data: groupData)
        return docRef.documentID
    }

    enum GroupError: LocalizedError {
        case alreadyExists(groupId: String)
        case notAuthorized

        var errorDescription: String? {
            switch self {
            case .alreadyExists:
                return "A group with these members already exists"
            case .notAuthorized:
                return "Only the group creator can perform this action"
            }
        }
    }

    func findExistingGroup(participantIds: [String]) async throws -> String? {
        let sortedIds = participantIds.sorted()

        // Query groups that contain the first participant
        guard let firstId = sortedIds.first else { return nil }

        let snapshot = try await db.collection("groupThreads")
            .whereField("participantIds", arrayContains: firstId)
            .getDocuments()

        // Check each group to see if participants match exactly
        for doc in snapshot.documents {
            if let groupParticipants = doc.data()["participantIds"] as? [String] {
                if groupParticipants.sorted() == sortedIds {
                    return doc.documentID
                }
            }
        }

        return nil
    }

    func updateGroupName(groupId: String, newName: String, requesterId: String) async throws {
        let doc = try await db.collection("groupThreads").document(groupId).getDocument()

        guard let creatorId = doc.data()?["creatorId"] as? String,
              creatorId == requesterId else {
            throw GroupError.notAuthorized
        }

        try await db.collection("groupThreads").document(groupId).updateData([
            "name": newName
        ])
    }

    func deleteGroup(groupId: String, requesterId: String) async throws {
        let doc = try await db.collection("groupThreads").document(groupId).getDocument()

        guard let creatorId = doc.data()?["creatorId"] as? String,
              creatorId == requesterId else {
            throw GroupError.notAuthorized
        }

        // Delete all messages in the group
        let messagesSnapshot = try await db.collection("groupThreads")
            .document(groupId)
            .collection("messages")
            .getDocuments()

        for messageDoc in messagesSnapshot.documents {
            try await messageDoc.reference.delete()
        }

        // Delete the group document
        try await db.collection("groupThreads").document(groupId).delete()
    }

    func listenToGroups(userId: String, completion: @escaping ([GroupThread]) -> Void) -> ListenerRegistration {
        return db.collection("groupThreads")
            .whereField("participantIds", arrayContains: userId)
            .order(by: "lastMessageTimestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to groups: \(error.localizedDescription)")
                    // If index is missing, try without ordering
                    completion([])
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let groups = documents.compactMap { doc -> GroupThread? in
                    do {
                        return try doc.data(as: GroupThread.self)
                    } catch {
                        print("Error decoding group: \(error)")
                        return nil
                    }
                }
                print("Loaded \(groups.count) groups for user \(userId)")
                completion(groups)
            }
    }

    func listenToGroupMessages(groupId: String, completion: @escaping ([GroupMessage]) -> Void) -> ListenerRegistration {
        return db.collection("groupThreads").document(groupId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let messages = documents.compactMap { doc -> GroupMessage? in
                    try? doc.data(as: GroupMessage.self)
                }
                completion(messages)
            }
    }

    func sendGroupMessage(groupId: String, senderId: String, senderName: String, content: String) async throws {
        let messageData: [String: Any] = [
            "groupId": groupId,
            "senderId": senderId,
            "senderName": senderName,
            "messageType": "text",
            "textContent": content,
            "reactions": [:],
            "timestamp": Timestamp()
        ]

        try await db.collection("groupThreads").document(groupId).collection("messages").addDocument(data: messageData)

        // Update group thread metadata and increment unread counts for other participants
        let groupDoc = try await db.collection("groupThreads").document(groupId).getDocument()
        guard let group = try? groupDoc.data(as: GroupThread.self) else { return }

        var newUnreadCounts = group.unreadCounts
        for participantId in group.participantIds where participantId != senderId {
            newUnreadCounts[participantId, default: 0] += 1
        }

        try await db.collection("groupThreads").document(groupId).updateData([
            "lastMessageTimestamp": Timestamp(),
            "lastMessageContent": content,
            "lastMessageType": "text",
            "lastMessageSenderId": senderId,
            "lastMessageSenderName": senderName,
            "unreadCounts": newUnreadCounts
        ])
    }

    func sendGroupSongMessage(
        groupId: String,
        senderId: String,
        senderName: String,
        trackId: String,
        title: String,
        artist: String,
        albumArtUrl: String?,
        previewUrl: String?,
        caption: String?
    ) async throws {
        let messageData: [String: Any] = [
            "groupId": groupId,
            "senderId": senderId,
            "senderName": senderName,
            "messageType": "song",
            "spotifyTrackId": trackId,
            "songTitle": title,
            "songArtist": artist,
            "albumArtUrl": albumArtUrl ?? NSNull(),
            "previewUrl": previewUrl ?? NSNull(),
            "caption": caption ?? NSNull(),
            "reactions": [:],
            "timestamp": Timestamp()
        ]

        try await db.collection("groupThreads").document(groupId).collection("messages").addDocument(data: messageData)

        // Update group thread metadata
        let groupDoc = try await db.collection("groupThreads").document(groupId).getDocument()
        guard let group = try? groupDoc.data(as: GroupThread.self) else { return }

        var newUnreadCounts = group.unreadCounts
        for participantId in group.participantIds where participantId != senderId {
            newUnreadCounts[participantId, default: 0] += 1
        }

        let preview = caption?.isEmpty == false ? "\(title): \"\(caption!)\"" : title

        try await db.collection("groupThreads").document(groupId).updateData([
            "lastMessageTimestamp": Timestamp(),
            "lastMessageContent": preview,
            "lastMessageType": "song",
            "lastMessageSenderId": senderId,
            "lastMessageSenderName": senderName,
            "unreadCounts": newUnreadCounts
        ])
    }

    func markGroupMessagesAsRead(groupId: String, userId: String) async throws {
        try await db.collection("groupThreads").document(groupId).updateData([
            "unreadCounts.\(userId)": 0
        ])
    }

    func getGroupParticipants(participantIds: [String]) async throws -> [FriendProfile] {
        var profiles: [FriendProfile] = []
        for userId in participantIds {
            do {
                let userProfile = try await getUserProfile(userId: userId)
                let friendProfile = FriendProfile(from: userProfile)
                profiles.append(friendProfile)
            } catch {
                print("Failed to fetch profile for \(userId): \(error)")
            }
        }
        return profiles
    }
}

// Helper extension
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
