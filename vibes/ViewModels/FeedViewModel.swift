//
//  FeedViewModel.swift
//  vibes
//
//  ViewModel for the Feed tab - shows shares and friend activity.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

struct SongShare: Identifiable {
    let id: String
    let senderId: String
    let senderName: String?
    let sender: FriendProfile?
    let songId: String
    let songTitle: String
    let songArtist: String
    let albumArtUrl: String?
    let previewUrl: String?
    let createdAt: Date
    var seen: Bool
}

struct FriendActivityItem: Identifiable {
    let id: String
    let friendName: String
    let activityType: ActivityType
    let songTitle: String?
    let artistName: String?
    let timestamp: Date

    enum ActivityType {
        case sharedSong
        case newFriend
    }
}

@MainActor
class FeedViewModel: ObservableObject {
    @Published private(set) var shares: [SongShare] = []
    @Published private(set) var friendActivity: [FriendActivityItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingShares = false
    @Published private(set) var isLoadingActivity = false

    private let friendService = FriendService.shared
    private lazy var db = Firestore.firestore()
    private var friendsCache: [FriendProfile] = []

    func loadAllData() async {
        isLoading = true

        // Fetch friends once and cache
        do {
            friendsCache = try await friendService.fetchFriends()
        } catch {
            print("Failed to fetch friends: \(error)")
            isLoading = false
            return
        }

        // Load shares and activity in parallel
        async let sharesTask: () = loadShares()
        async let activityTask: () = loadFriendActivity()
        _ = await (sharesTask, activityTask)

        isLoading = false
    }

    func loadShares() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard !friendsCache.isEmpty else { return }

        isLoadingShares = true
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        // Use TaskGroup to parallelize queries
        let allShares = await withTaskGroup(of: [SongShare].self) { group in
            for friend in friendsCache {
                group.addTask { [db] in
                    await self.fetchSharesFromFriend(
                        db: db,
                        currentUserId: currentUserId,
                        friend: friend,
                        since: sevenDaysAgo
                    )
                }
            }

            var results: [SongShare] = []
            for await friendShares in group {
                results.append(contentsOf: friendShares)
            }
            return results
        }

        // Sort and limit on main thread
        shares = allShares
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(20)
            .map { $0 }

        isLoadingShares = false
    }

    private nonisolated func fetchSharesFromFriend(
        db: Firestore,
        currentUserId: String,
        friend: FriendProfile,
        since: Date
    ) async -> [SongShare] {
        let threadId = [currentUserId, friend.id].sorted().joined(separator: "_")

        do {
            let snapshot = try await db.collection("messageThreads")
                .document(threadId)
                .collection("messages")
                .whereField("senderId", isEqualTo: friend.id)
                .whereField("messageType", isEqualTo: "song")
                .whereField("timestamp", isGreaterThan: since)
                .order(by: "timestamp", descending: true)
                .limit(to: 5)
                .getDocuments()

            return snapshot.documents.compactMap { doc -> SongShare? in
                guard let message = try? doc.data(as: Message.self) else { return nil }
                return SongShare(
                    id: message.id ?? doc.documentID,
                    senderId: friend.id,
                    senderName: friend.displayName,
                    sender: friend,
                    songId: message.spotifyTrackId ?? "",
                    songTitle: message.songTitle ?? "Unknown",
                    songArtist: message.songArtist ?? "Unknown Artist",
                    albumArtUrl: message.albumArtUrl,
                    previewUrl: message.previewUrl,
                    createdAt: message.timestamp,
                    seen: message.read
                )
            }
        } catch {
            return []
        }
    }

    func loadFriendActivity() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard !friendsCache.isEmpty else { return }

        isLoadingActivity = true
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()

        // Use TaskGroup to parallelize queries
        let allActivities = await withTaskGroup(of: FriendActivityItem?.self) { group in
            for friend in friendsCache {
                group.addTask { [db] in
                    await self.fetchActivityFromFriend(
                        db: db,
                        currentUserId: currentUserId,
                        friend: friend,
                        since: oneDayAgo
                    )
                }
            }

            var results: [FriendActivityItem] = []
            for await activity in group {
                if let activity = activity {
                    results.append(activity)
                }
            }
            return results
        }

        friendActivity = allActivities
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(10)
            .map { $0 }

        isLoadingActivity = false
    }

    private nonisolated func fetchActivityFromFriend(
        db: Firestore,
        currentUserId: String,
        friend: FriendProfile,
        since: Date
    ) async -> FriendActivityItem? {
        let threadId = [currentUserId, friend.id].sorted().joined(separator: "_")

        do {
            let snapshot = try await db.collection("messageThreads")
                .document(threadId)
                .collection("messages")
                .whereField("senderId", isEqualTo: friend.id)
                .whereField("messageType", isEqualTo: "song")
                .whereField("timestamp", isGreaterThan: since)
                .order(by: "timestamp", descending: true)
                .limit(to: 1)
                .getDocuments()

            guard let doc = snapshot.documents.first,
                  let message = try? doc.data(as: Message.self) else {
                return nil
            }

            return FriendActivityItem(
                id: "\(friend.id)_\(message.id ?? UUID().uuidString)",
                friendName: friend.displayName,
                activityType: .sharedSong,
                songTitle: message.songTitle,
                artistName: message.songArtist,
                timestamp: message.timestamp
            )
        } catch {
            return nil
        }
    }
}
