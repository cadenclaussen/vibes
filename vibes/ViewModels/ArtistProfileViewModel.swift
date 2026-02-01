import Foundation

@Observable
class ArtistProfileViewModel {
    var artist: UnifiedArtist
    var allTopTracks: [UnifiedTrack] = []  // All tracks from API
    var albums: [UnifiedAlbum] = []
    var isLoading = false
    var error: Error?

    // Show first 5 in preview section
    var topTracks: [UnifiedTrack] {
        Array(allTopTracks.prefix(5))
    }

    private let spotifyService = SpotifyDataService.shared

    init(artist: UnifiedArtist) {
        self.artist = artist
    }

    @MainActor
    func loadData() async {
        if !allTopTracks.isEmpty || !albums.isEmpty { return }

        isLoading = true
        error = nil

        do {
            async let artistTask = spotifyService.getArtist(artistId: artist.id)
            async let tracksTask = spotifyService.getArtistTopTracks(artistId: artist.id)
            async let albumsTask = spotifyService.getArtistAlbums(artistId: artist.id, limit: 20)

            let (fullArtist, tracks, fetchedAlbums) = try await (artistTask, tracksTask, albumsTask)
            artist = fullArtist
            // Store all tracks, sorted by popularity (highest first)
            allTopTracks = tracks.sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
            albums = fetchedAlbums
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func playTrack(_ track: UnifiedTrack, using spotifyRemote: SpotifyRemoteService) {
        if spotifyRemote.currentTrack?.id == track.id {
            spotifyRemote.togglePlayPause()
        } else {
            spotifyRemote.playWithQueue(track, queue: topTracks)
        }
    }
}
