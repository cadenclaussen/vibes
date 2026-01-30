import Foundation
import SwiftUI

enum DiscoverMusicError: LocalizedError, Equatable {
    case noSeedData
    case spotifyNotConnected
    case networkError(String)
    case exhausted
    case filterTooStrict

    var errorDescription: String? {
        switch self {
        case .noSeedData:
            return "No listening history found"
        case .spotifyNotConnected:
            return "Spotify not connected"
        case .networkError(let message):
            return "Network error: \(message)"
        case .exhausted:
            return "No more recommendations available"
        case .filterTooStrict:
            return "No songs found"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noSeedData:
            return "Listen to more music on Spotify to get personalized recommendations."
        case .spotifyNotConnected:
            return "Connect your Spotify account to discover new music."
        case .networkError:
            return "Check your connection and try again."
        case .exhausted:
            return "Try again later for fresh recommendations."
        case .filterTooStrict:
            return "Try lowering the obscurity level to find more songs."
        }
    }
}

@Observable
class DiscoverMusicViewModel {
    // MARK: - State

    var songQueue: [UnifiedTrack] = []
    var isLoading: Bool = false
    var isReplenishing: Bool = false
    var error: Error?

    // Popularity filter: 100 = all tracks, lower = more obscure
    var maxPopularity: Int = 100

    // MARK: - Private

    private var dismissedSongIds: Set<String> = []
    private var replenishTask: Task<Void, Never>?

    private let queueTargetSize = 10
    private let replenishThreshold = 7
    private let visibleCount = 5

    // MARK: - Computed Properties

    var visibleSongs: [UnifiedTrack] {
        Array(songQueue.prefix(visibleCount))
    }

    var isSpotifyConnected: Bool {
        SpotifyAuthService.shared.isAuthenticated
    }

    var hasNoSeedData: Bool {
        if let err = error as? DiscoverMusicError {
            if case .noSeedData = err {
                return true
            }
        }
        return false
    }

    var isFilterTooStrict: Bool {
        if let err = error as? DiscoverMusicError {
            if case .filterTooStrict = err {
                return true
            }
        }
        return false
    }

    var isSpotifyError: Bool {
        if let err = error as? DiscoverMusicError {
            if case .spotifyNotConnected = err {
                return true
            }
        }
        if let dataErr = error as? SpotifyDataError {
            if case .notAuthenticated = dataErr {
                return true
            }
        }
        return false
    }

    // MARK: - Actions

    func loadInitialRecommendations() async {
        if !isSpotifyConnected {
            error = DiscoverMusicError.spotifyNotConnected
            return
        }

        isLoading = true
        error = nil

        do {
            // Use artist-based discovery (recommendations API was deprecated)
            let tracks = try await SpotifyDataService.shared.discoverTracks(
                limit: queueTargetSize,
                maxPopularity: maxPopularity
            )

            if tracks.isEmpty {
                // If filter is active, it's likely too strict
                if maxPopularity < 100 {
                    throw DiscoverMusicError.filterTooStrict
                } else {
                    throw DiscoverMusicError.noSeedData
                }
            }

            songQueue = tracks
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func dismissSong(at index: Int) {
        guard index >= 0 && index < songQueue.count else { return }

        let song = songQueue[index]
        dismissedSongIds.insert(song.id)
        songQueue.remove(at: index)

        replenishQueueIfNeeded()
    }

    func dismissSong(_ song: UnifiedTrack) {
        guard let index = songQueue.firstIndex(where: { $0.id == song.id }) else { return }
        dismissSong(at: index)
    }

    func clearSession() {
        replenishTask?.cancel()
        songQueue = []
        dismissedSongIds = []
        isLoading = false
        isReplenishing = false
        error = nil
    }

    func retry() async {
        clearSession()
        await loadInitialRecommendations()
    }

    // MARK: - Queue Management

    private func replenishQueueIfNeeded() {
        if songQueue.count >= replenishThreshold {
            return
        }

        if isReplenishing {
            return
        }

        replenishTask?.cancel()
        replenishTask = Task {
            await replenishQueue()
        }
    }

    private func replenishQueue() async {
        isReplenishing = true

        let needed = queueTargetSize - songQueue.count

        do {
            // fetch extra to account for filtering
            let newSongs = try await SpotifyDataService.shared.discoverTracks(
                limit: needed + 5,
                maxPopularity: maxPopularity
            )
            let filtered = newSongs.filter { song in
                !dismissedSongIds.contains(song.id) &&
                !songQueue.contains(where: { $0.id == song.id })
            }

            let toAdd = Array(filtered.prefix(needed))

            await MainActor.run {
                self.songQueue.append(contentsOf: toAdd)
            }
        } catch {
            // silent failure for background replenishment
            // only show error if queue is completely empty
            if songQueue.isEmpty {
                await MainActor.run {
                    self.error = error
                }
            }
        }

        await MainActor.run {
            self.isReplenishing = false
        }
    }
}
