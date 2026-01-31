import Foundation

@Observable
class ArtistProfileViewModel {
    var artist: UnifiedArtist
    var topTracks: [UnifiedTrack] = []
    var albums: [UnifiedAlbum] = []
    var isLoading = false
    var error: Error?

    private let spotifyService = SpotifyDataService.shared

    init(artist: UnifiedArtist) {
        self.artist = artist
    }

    @MainActor
    func loadData() async {
        if !topTracks.isEmpty || !albums.isEmpty { return }

        isLoading = true
        error = nil

        do {
            async let artistTask = spotifyService.getArtist(artistId: artist.id)
            async let tracksTask = spotifyService.getArtistTopTracks(artistId: artist.id)
            async let albumsTask = spotifyService.getArtistAlbums(artistId: artist.id, limit: 20)

            let (fullArtist, tracks, fetchedAlbums) = try await (artistTask, tracksTask, albumsTask)
            artist = fullArtist
            topTracks = Array(tracks.prefix(5))
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
