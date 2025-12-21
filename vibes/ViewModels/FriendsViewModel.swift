//
//  FriendsViewModel.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import Foundation
import Combine

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [FriendProfile] = []
    @Published var pendingRequests: [(friendship: Friendship, profile: FriendProfile)] = []
    @Published var notifications: [FriendNotification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let friendService = FriendService.shared

    func loadFriends() async {
        isLoading = true
        errorMessage = nil

        do {
            friends = try await friendService.fetchFriends()
        } catch {
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func loadPendingRequests() async {
        do {
            pendingRequests = try await friendService.fetchPendingRequests()
        } catch {
            errorMessage = "Failed to load requests: \(error.localizedDescription)"
        }
    }

    func loadNotifications() async {
        do {
            notifications = try await friendService.fetchNotifications()
        } catch {
            errorMessage = "Failed to load notifications: \(error.localizedDescription)"
        }
    }

    func sendFriendRequest(username: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await friendService.sendFriendRequest(toUsername: username)
            // Track for achievements
            LocalAchievementStats.shared.friendRequestsSent += 1
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
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

    func removeFriend(friendshipId: String) async {
        do {
            try await friendService.removeFriend(friendshipId: friendshipId)
            await loadFriends()
        } catch {
            errorMessage = "Failed to remove friend: \(error.localizedDescription)"
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
}
