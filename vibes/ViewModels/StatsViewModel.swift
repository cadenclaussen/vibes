import Foundation

@Observable
class StatsViewModel {
    var timeRange: SpotifyTimeRange = .shortTerm
    var topArtists: [UnifiedArtist] = []
    var topSongs: [UnifiedTrack] = []
    var topGenres: [String] = []
    var recentlyPlayed: [RecentTrack] = []

    var previewArtists: [UnifiedArtist] = []
    var isLoadingPreview = false
    var isLoading = false
    var error: Error?

    private let spotifyService = SpotifyDataService.shared

    var timeRangeDisplayName: String {
        switch timeRange {
        case .shortTerm: return "4 Weeks"
        case .mediumTerm: return "6 Months"
        case .longTerm: return "All Time"
        }
    }

    @MainActor
    func loadPreview() async {
        isLoadingPreview = true
        error = nil

        do {
            previewArtists = try await spotifyService.getTopArtists(limit: 3, timeRange: .shortTerm)
        } catch {
            self.error = error
        }

        isLoadingPreview = false
    }

    @MainActor
    func loadStats() async {
        isLoading = true
        error = nil

        do {
            async let artistsTask = spotifyService.getTopArtists(limit: 10, timeRange: timeRange)
            async let songsTask = spotifyService.getTopTracks(limit: 10, timeRange: timeRange)
            async let recentTask = spotifyService.getRecentlyPlayed(limit: 20)

            let (artists, songs, recent) = try await (artistsTask, songsTask, recentTask)

            topArtists = artists
            topSongs = songs
            recentlyPlayed = recent
            topGenres = spotifyService.extractTopGenres(from: artists, count: 5)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    @MainActor
    func refresh() async {
        await loadStats()
    }

    @MainActor
    func setTimeRange(_ range: SpotifyTimeRange) async {
        timeRange = range
        await loadStats()
    }

    func openArtistInSpotify(_ artist: UnifiedArtist) {
        guard let uri = artist.spotifyUri else { return }
        spotifyService.openInSpotify(uri: uri)
    }

    func openTrackInSpotify(_ track: UnifiedTrack) {
        guard let uri = track.spotifyUri else { return }
        spotifyService.openInSpotify(uri: uri)
    }
}
