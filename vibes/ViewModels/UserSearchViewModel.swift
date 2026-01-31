import Foundation

@Observable
@MainActor
final class UserSearchViewModel {
    var searchQuery = ""
    var results: [UserProfile] = []
    var isLoading = false
    var error: Error?

    private(set) var followingIds: Set<String> = []
    private var searchTask: Task<Void, Never>?
    private let socialService = SocialService.shared

    func search() {
        searchTask?.cancel()

        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        searchTask = Task {
            // Debounce 300ms
            try? await Task.sleep(for: .milliseconds(300))

            guard !Task.isCancelled else { return }

            isLoading = true
            error = nil

            do {
                results = try await socialService.searchUsers(query: searchQuery)
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }

            isLoading = false
        }
    }

    func loadFollowingIds() async {
        do {
            let ids = try await socialService.getFollowingIds()
            followingIds = Set(ids)
        } catch {
            // Silently fail - we'll just show all as not following
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
        } catch {
            self.error = error
        }
    }
}
