import SwiftUI

@Observable
@MainActor
final class ProfileViewModel {
    var topGenres: [String] = []
    var isLoadingGenres = false
    var showEditSheet = false

    private let spotifyDataService = SpotifyDataService.shared

    func loadGenres() async {
        // Skip if already loaded or no Spotify connection
        guard topGenres.isEmpty else { return }
        guard KeychainManager.shared.getSpotifyAccessToken() != nil else { return }

        isLoadingGenres = true
        defer { isLoadingGenres = false }

        do {
            let artists = try await spotifyDataService.getTopArtists(limit: 20, timeRange: .mediumTerm)
            topGenres = spotifyDataService.extractTopGenres(from: artists, count: 5)
        } catch {
            // Silently fail - just don't show genres
            topGenres = []
        }
    }

    func refreshGenres() async {
        topGenres = []
        await loadGenres()
    }
}
