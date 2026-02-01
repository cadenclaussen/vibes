import Foundation
import FirebaseAuth

@Observable
@MainActor
final class ShareViewModel {
    var message = ""
    var isSending = false
    var error: Error?
    var didSend = false

    let track: UnifiedTrack
    private let socialService = SocialService.shared

    init(track: UnifiedTrack) {
        self.track = track
    }

    var canSend: Bool {
        !isSending
    }

    func send() async throws {
        guard canSend else { return }

        isSending = true
        error = nil

        do {
            let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
            try await socialService.shareSong(
                track,
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
