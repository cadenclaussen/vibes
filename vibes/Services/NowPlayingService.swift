//
//  NowPlayingService.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import Foundation
import Combine

@MainActor
class NowPlayingService: ObservableObject {
    static let shared = NowPlayingService()

    @Published var currentTrack: CurrentlyPlaying?
    @Published var isPolling = false

    private var pollTimer: Timer?
    private var userId: String?

    private init() {}

    func startPolling(userId: String) {
        self.userId = userId
        isPolling = true

        // Poll immediately
        Task {
            await updateNowPlaying()
        }

        // Then poll every 30 seconds
        pollTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updateNowPlaying()
            }
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
        isPolling = false

        // Clear now playing when stopping
        if let userId = userId {
            Task {
                try? await FirestoreService.shared.clearNowPlaying(userId: userId)
            }
        }
    }

    private func updateNowPlaying() async {
        guard let userId = userId else { return }
        guard SpotifyService.shared.isAuthenticated else { return }

        do {
            let playing = try await SpotifyService.shared.getCurrentlyPlaying()
            currentTrack = playing

            if let track = playing?.item, playing?.isPlaying == true {
                try await FirestoreService.shared.updateNowPlaying(
                    userId: userId,
                    trackId: track.id,
                    trackName: track.name,
                    artistName: track.artists.first?.name,
                    albumArt: track.album.images.first?.url
                )
            } else {
                try await FirestoreService.shared.clearNowPlaying(userId: userId)
            }
        } catch {
            // Silently fail - don't interrupt user experience
            print("Failed to update now playing: \(error)")
        }
    }
}
