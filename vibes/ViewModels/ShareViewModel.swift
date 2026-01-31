import Foundation
import FirebaseAuth

@Observable
@MainActor
final class ShareViewModel {
    var following: [UserProfile] = []
    var selectedUserIds: Set<String> = []
    var message = ""
    var isLoading = false
    var isSending = false
    var error: Error?
    var didSend = false

    let track: UnifiedTrack
    private let socialService = SocialService.shared

    init(track: UnifiedTrack) {
        self.track = track
    }

    var canSend: Bool {
        !selectedUserIds.isEmpty && !isSending
    }

    var selectedCount: Int {
        selectedUserIds.count
    }

    func load() async {
        isLoading = true
        error = nil

        do {
            guard let userId = AuthManager.shared.user?.uid else {
                throw VibesError.notAuthenticated
            }
            following = try await socialService.getFollowing(for: userId)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func toggleSelection(_ user: UserProfile) {
        if selectedUserIds.contains(user.uid) {
            selectedUserIds.remove(user.uid)
        } else {
            selectedUserIds.insert(user.uid)
        }
    }

    func isSelected(_ user: UserProfile) -> Bool {
        selectedUserIds.contains(user.uid)
    }

    func send() async throws {
        guard canSend else { return }

        isSending = true
        error = nil

        do {
            let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
            try await socialService.shareSong(
                track,
                to: Array(selectedUserIds),
                message: trimmedMessage.isEmpty ? nil : trimmedMessage
            )
            didSend = true
        } catch {
            self.error = error
            throw error
        }

        isSending = false
    }
}
