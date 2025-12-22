import Foundation
import Combine

struct PlaylistRecommendation: Identifiable {
    let id: String
    let recommendation: AIRecommendedSong
    let track: Track
    let previewUrl: String?
}

@MainActor
class PlaylistRecommendationsViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var selectedPlaylist: Playlist?
    @Published var recommendations: [PlaylistRecommendation] = []
    @Published var addedCount: Int = 0
    @Published var isLoadingPlaylists = false
    @Published var isLoadingRecommendations = false
    @Published var isAddingSongId: String?
    @Published var errorMessage: String?

    private var pendingRecommendations: [PlaylistRecommendation] = []
    private var shownSongNames: [String] = []
    private var playlistTrackNames: [String] = []

    private let spotifyService = SpotifyService.shared
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
            var userPlaylists = try await spotifyService.getUserPlaylists()
            if let userId = spotifyService.userProfile?.id {
                userPlaylists = userPlaylists.filter { $0.owner.id == userId }
            }
            playlists = userPlaylists
        } catch {
            errorMessage = "Failed to load playlists: \(error.localizedDescription)"
        }

        isLoadingPlaylists = false
    }

    func selectPlaylist(_ playlist: Playlist) async {
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
            let tracks = try await spotifyService.getPlaylistTracks(playlistId: playlist.id, limit: 50)
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
        } catch {
            errorMessage = "AI recommendation failed: \(error.localizedDescription)"
        }

        isLoadingRecommendations = false
    }

    private func resolveSongs(from aiRecs: [AIRecommendedSong]) async {
        var resolved: [PlaylistRecommendation] = []
        var resolvedTrackIds = Set<String>()

        for rec in aiRecs {
            do {
                let tracks = try await spotifyService.searchTracks(query: rec.searchQuery, limit: 1)

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
            try await spotifyService.addTrackToPlaylist(
                playlistId: playlist.id,
                trackUri: rec.track.uri
            )

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
