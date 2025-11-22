//
//  FriendsViewModel.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friendship] = []
    @Published var searchResults: [UserProfile] = []
    @Published var searchQuery = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firestoreService = FirestoreService.shared
    private let authManager = AuthManager.shared
    private var searchTask: Task<Void, Never>?

    func loadFriends() async {
        guard let userId = authManager.user?.uid else {
            errorMessage = "Not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            friends = try await firestoreService.getFriends(userId: userId)
        } catch {
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func searchUsers() {
        searchTask?.cancel()

        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }

        guard let userId = authManager.user?.uid else { return }

        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }

                let results = try await firestoreService.searchUsers(query: searchQuery, excludeUserId: userId)
                if !Task.isCancelled {
                    searchResults = results
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = "Search failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func sendFriendRequest(to friendId: String) async {
        guard let userId = authManager.user?.uid else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await firestoreService.sendFriendRequest(from: userId, to: friendId)
            searchResults.removeAll { $0.uid == friendId }
        } catch {
            errorMessage = "Failed to send friend request: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func acceptFriendRequest(friendshipId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await firestoreService.acceptFriendRequest(friendshipId: friendshipId)
            await loadFriends()
        } catch {
            errorMessage = "Failed to accept friend request: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        searchTask?.cancel()
    }
}
