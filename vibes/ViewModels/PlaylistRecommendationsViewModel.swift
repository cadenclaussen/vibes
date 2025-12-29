import Foundation
import Combine

struct PlaylistRecommendation: Identifiable {
    let id: String
    let recommendation: AIRecommendedSong
    let track: UnifiedTrack
    let previewUrl: String?
}

@MainActor
class PlaylistRecommendationsViewModel: ObservableObject {
    @Published var playlists: [UnifiedPlaylist] = []
    @Published var selectedPlaylist: UnifiedPlaylist?
    @Published var recommendations: [PlaylistRecommendation] = []
    @Published var addedCount: Int = 0
    @Published var isLoadingPlaylists = false
    @Published var isLoadingRecommendations = false
    @Published var isAddingSongId: String?
    @Published var errorMessage: String?
    @Published var cooldownSeconds: Int = 0

    private var pendingRecommendations: [PlaylistRecommendation] = []
    private var cooldownTimer: Timer?
    private var shownSongNames: [String] = []
    private var playlistTrackNames: [String] = []

    private let musicServiceManager = MusicServiceManager.shared
    private let geminiService = GeminiService.shared
    private let itunesService = iTunesService.shared

    var totalProcessed: Int {
        addedCount + dismissedCount
    }

    private var dismissedCount: Int = 0

    func loadPlaylists() async {
        isLoadingPlaylists = true
        errorMessage = nil

        do {
            let service = musicServiceManager.currentService
            playlists = try await service.getUserPlaylists(limit: 50, offset: 0)
        } catch {
            errorMessage = "Failed to load playlists: \(error.localizedDescription)"
        }

        isLoadingPlaylists = false
    }

    func selectPlaylist(_ playlist: UnifiedPlaylist) async {
        selectedPlaylist = playlist
        recommendations = []
        pendingRecommendations = []
        shownSongNames = []
        addedCount = 0
        dismissedCount = 0
        await loadPlaylistTracksAndGenerateRecommendations()
    }

    func deselectPlaylist() {
        selectedPlaylist = nil
        recommendations = []
        pendingRecommendations = []
        shownSongNames = []
        playlistTrackNames = []
        addedCount = 0
        dismissedCount = 0
    }

    private func loadPlaylistTracksAndGenerateRecommendations() async {
        guard let playlist = selectedPlaylist else { return }

        isLoadingRecommendations = true
        errorMessage = nil

        do {
            let service = musicServiceManager.currentService
            let tracks = try await service.getPlaylistTracks(playlistId: playlist.id, limit: 50)
            playlistTrackNames = tracks.map { "\($0.name) by \($0.artists.first?.name ?? "Unknown")" }
            await generateRecommendations()
        } catch {
            errorMessage = "Failed to load playlist: \(error.localizedDescription)"
            isLoadingRecommendations = false
        }
    }

    private func generateRecommendations() async {
        guard let playlist = selectedPlaylist else { return }
        guard !playlistTrackNames.isEmpty else {
            errorMessage = "Playlist is empty. Add some songs first!"
            isLoadingRecommendations = false
            return
        }

        isLoadingRecommendations = true

        do {
            let avoidList = playlistTrackNames + shownSongNames
            let aiRecs = try await geminiService.generatePlaylistRecommendations(
                playlistTracks: playlistTrackNames,
                playlistName: playlist.name,
                count: 15,
                avoidSongs: avoidList
            )

            await resolveSongs(from: aiRecs)
        } catch let error as GeminiError {
            if case .rateLimitWithRetry(let seconds) = error {
                errorMessage = "AI rate limit reached (20/min). Please wait."
                startCooldown(seconds: seconds + 5) // Add buffer
            } else if case .rateLimitExceeded = error {
                errorMessage = "Too many requests. Please wait a moment."
                startCooldown(seconds: 60)
            } else if case .dailyLimitReached = error {
                errorMessage = "Daily AI limit reached (50/day). Try again tomorrow."
            } else {
                errorMessage = "AI recommendation failed: \(error.localizedDescription)"
            }
        } catch {
            errorMessage = "AI recommendation failed: \(error.localizedDescription)"
        }

        isLoadingRecommendations = false
    }

    private func startCooldown(seconds: Int) {
        cooldownSeconds = seconds
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                if self.cooldownSeconds > 0 {
                    self.cooldownSeconds -= 1
                } else {
                    timer.invalidate()
                    self.cooldownTimer = nil
                }
            }
        }
    }

    private func resolveSongs(from aiRecs: [AIRecommendedSong]) async {
        let service = musicServiceManager.currentService
        var resolved: [PlaylistRecommendation] = []
        var resolvedTrackIds = Set<String>()

        for rec in aiRecs {
            do {
                let tracks = try await service.searchTracks(query: rec.searchQuery, limit: 1)

                guard let track = tracks.first else { continue }
                if resolvedTrackIds.contains(track.id) { continue }

                var previewUrl = track.previewUrl
                if previewUrl == nil {
                    previewUrl = await itunesService.searchPreview(
                        trackName: track.name,
                        artistName: track.artists.first?.name ?? ""
                    )
                }

                guard previewUrl != nil else { continue }

                resolvedTrackIds.insert(track.id)
                resolved.append(PlaylistRecommendation(
                    id: rec.id,
                    recommendation: rec,
                    track: track,
                    previewUrl: previewUrl
                ))

                let songName = "\(track.name) by \(track.artists.first?.name ?? "Unknown")"
                shownSongNames.append(songName)

            } catch {
                continue
            }
        }

        let visibleCount = 5
        recommendations = Array(resolved.prefix(visibleCount))
        pendingRecommendations = Array(resolved.dropFirst(visibleCount))
    }

    func addSong(_ rec: PlaylistRecommendation) async {
        guard let playlist = selectedPlaylist else { return }

        isAddingSongId = rec.id

        do {
            let service = musicServiceManager.currentService
            let trackUri = service.getTrackUri(for: rec.track)
            try await service.addTracksToPlaylist(playlistId: playlist.id, trackUris: [trackUri])

            HapticService.success()

            LocalAchievementStats.shared.songsAddedToPlaylists += 1
            LocalAchievementStats.shared.checkTimeBasedAchievements()
            let trackId = rec.track.id
            LocalAchievementStats.shared.checkResurrection(trackId: trackId)
            LocalAchievementStats.shared.checkLocalAchievements()

            addedCount += 1
            removeAndRefill(rec)

        } catch {
            HapticService.error()
            errorMessage = "Failed to add song: \(error.localizedDescription)"
        }

        isAddingSongId = nil
    }

    func dismissSong(_ rec: PlaylistRecommendation) {
        HapticService.lightImpact()
        dismissedCount += 1
        removeAndRefill(rec)
    }

    private func removeAndRefill(_ rec: PlaylistRecommendation) {
        recommendations.removeAll { $0.id == rec.id }

        if !pendingRecommendations.isEmpty {
            let next = pendingRecommendations.removeFirst()
            recommendations.append(next)
        }

        let totalRemaining = recommendations.count + pendingRecommendations.count
        if totalRemaining < 3 && !isLoadingRecommendations {
            Task {
                await generateRecommendations()
            }
        }
    }
}
