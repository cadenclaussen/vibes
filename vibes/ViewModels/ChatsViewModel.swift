//
//  ChatsViewModel.swift
//  vibes
//
//  Created by Claude Code on 12/19/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ChatsViewModel: ObservableObject {
    @Published var friends: [FriendProfile] = []
    @Published var dmThreads: [MessageThread] = []
    @Published var groupThreads: [GroupThread] = []
    @Published var pendingRequests: [(friendship: Friendship, profile: FriendProfile)] = []
    @Published var notifications: [FriendNotification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let friendsViewModel = FriendsViewModel()
    private let firestoreService = FirestoreService.shared
    private let friendService = FriendService.shared
    private let compatibilityService = CompatibilityService.shared

    private var dmListener: ListenerRegistration?
    private var groupListener: ListenerRegistration?
    private var currentUserArtists: [String] = []
    private var currentUserGenres: [String] = []

    var friendsNowPlaying: [FriendProfile] {
        friends.filter { $0.isCurrentlyPlaying }
    }

    var allChats: [ChatItem] {
        var chats: [ChatItem] = []

        for friend in friends {
            let thread = dmThreads.first { thread in
                (thread.userId1 == currentUserId && thread.userId2 == friend.id) ||
                (thread.userId2 == currentUserId && thread.userId1 == friend.id)
            }

            let unreadCount: Int
            if let thread = thread {
                if thread.userId1 == currentUserId {
                    unreadCount = thread.unreadCountUser1
                } else {
                    unreadCount = thread.unreadCountUser2
                }
            } else {
                unreadCount = 0
            }

            // Calculate compatibility
            let compatibility = compatibilityService.calculateCompatibility(
                userArtists: currentUserArtists,
                userGenres: currentUserGenres,
                friendArtists: friend.favoriteArtists,
                friendGenres: friend.musicTasteTags
            )

            chats.append(ChatItem(
                id: "dm_\(friend.id)",
                name: friend.displayName,
                lastMessage: thread?.lastMessageContent ?? "",
                timestamp: thread?.lastMessageTimestamp ?? Date.distantPast,
                unreadCount: unreadCount,
                friend: friend,
                vibestreak: friend.activeVibestreak,
                compatibility: compatibility
            ))
        }

        return chats.sorted { $0.timestamp > $1.timestamp }
    }

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func loadData() async {
        isLoading = true

        await loadCurrentUserProfile()
        await loadFriends()
        await loadPendingRequests()
        await loadNotifications()
        setupListeners()

        isLoading = false
    }

    private func loadCurrentUserProfile() async {
        guard let userId = currentUserId else { return }
        do {
            let profile = try await firestoreService.getUserProfile(userId: userId)
            currentUserArtists = profile.favoriteArtists
            currentUserGenres = profile.musicTasteTags
        } catch {
            print("Failed to load current user profile: \(error.localizedDescription)")
        }
    }

    private func loadFriends() async {
        do {
            friends = try await friendService.fetchFriends()
        } catch {
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
        }
    }

    private func loadPendingRequests() async {
        do {
            pendingRequests = try await friendService.fetchPendingRequests()
        } catch {
            errorMessage = "Failed to load requests: \(error.localizedDescription)"
        }
    }

    private func loadNotifications() async {
        do {
            notifications = try await friendService.fetchNotifications()
        } catch {
            errorMessage = "Failed to load notifications: \(error.localizedDescription)"
        }
    }

    private func setupListeners() {
        guard let userId = currentUserId else { return }

        dmListener?.remove()
        dmListener = firestoreService.listenToThreads(userId: userId) { [weak self] threads in
            self?.dmThreads = threads
        }

        groupListener?.remove()
        groupListener = firestoreService.listenToGroups(userId: userId) { [weak self] groups in
            self?.groupThreads = groups
        }
    }

    func acceptFriendRequest(friendshipId: String) async {
        do {
            try await friendService.acceptFriendRequest(friendshipId: friendshipId)
            await loadFriends()
            await loadPendingRequests()
            await loadNotifications()
        } catch {
            errorMessage = "Failed to accept request: \(error.localizedDescription)"
        }
    }

    func declineFriendRequest(friendshipId: String) async {
        do {
            try await friendService.declineFriendRequest(friendshipId: friendshipId)
            await loadPendingRequests()
            await loadNotifications()
        } catch {
            errorMessage = "Failed to decline request: \(error.localizedDescription)"
        }
    }

    func markNotificationAsRead(notificationId: String) async {
        do {
            try await friendService.markNotificationAsRead(notificationId: notificationId)
            await loadNotifications()
        } catch {
            print("Failed to mark notification as read: \(error.localizedDescription)")
        }
    }

    deinit {
        dmListener?.remove()
        groupListener?.remove()
    }
}
