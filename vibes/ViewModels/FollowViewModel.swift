import Foundation
import FirebaseAuth

@Observable
@MainActor
final class FollowViewModel {
    enum Mode {
        case followers
        case following
    }

    var users: [UserProfile] = []
    var isLoading = false
    var error: Error?

    let mode: Mode
    let userId: String

    private(set) var followingIds: Set<String> = []
    private let socialService = SocialService.shared

    init(mode: Mode, userId: String) {
        self.mode = mode
        self.userId = userId
    }

    var title: String {
        switch mode {
        case .followers: return "Followers"
        case .following: return "Following"
        }
    }

    func load() async {
        isLoading = true
        error = nil

        do {
            async let usersTask = loadUsers()
            async let followingTask = loadFollowingIds()

            users = try await usersTask
            _ = await followingTask
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func refresh() async {
        await load()
    }

    private func loadUsers() async throws -> [UserProfile] {
        switch mode {
        case .followers:
            return try await socialService.getFollowers(for: userId)
        case .following:
            return try await socialService.getFollowing(for: userId)
        }
    }

    private func loadFollowingIds() async {
        do {
            let ids = try await socialService.getFollowingIds()
            followingIds = Set(ids)
        } catch {
            // Silently fail
        }
    }

    func isFollowing(_ user: UserProfile) -> Bool {
        followingIds.contains(user.uid)
    }

    func follow(_ user: UserProfile) async {
        do {
            try await socialService.follow(userId: user.uid)
            followingIds.insert(user.uid)
        } catch {
            self.error = error
        }
    }

    func unfollow(_ user: UserProfile) async {
        do {
            try await socialService.unfollow(userId: user.uid)
            followingIds.remove(user.uid)

            // If viewing own following list, remove user from list
            if mode == .following && userId == AuthManager.shared.user?.uid {
                users.removeAll { $0.uid == user.uid }
            }
        } catch {
            self.error = error
        }
    }
}
