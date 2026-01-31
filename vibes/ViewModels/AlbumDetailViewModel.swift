import Foundation

@Observable
class AlbumDetailViewModel {
    var album: UnifiedAlbum
    var tracks: [UnifiedTrack] = []
    var isLoading = false
    var error: Error?

    private let spotifyService = SpotifyDataService.shared

    init(album: UnifiedAlbum) {
        self.album = album
    }

    @MainActor
    func loadTracks() async {
        if !tracks.isEmpty { return }

        isLoading = true
        error = nil

        do {
            tracks = try await spotifyService.getAlbumTracks(albumId: album.id)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    var releaseYear: String? {
        guard let date = album.releaseDate else { return nil }
        return String(date.prefix(4))
    }

    var trackCountText: String {
        let count = album.totalTracks ?? tracks.count
        return count == 1 ? "1 track" : "\(count) tracks"
    }

    func playTrack(_ track: UnifiedTrack, using spotifyRemote: SpotifyRemoteService) {
        if spotifyRemote.currentTrack?.id == track.id {
            spotifyRemote.togglePlayPause()
        } else {
            spotifyRemote.playWithQueue(track, queue: tracks)
        }
    }

    func playAll(using spotifyRemote: SpotifyRemoteService) {
        guard let firstTrack = tracks.first else { return }
        spotifyRemote.playWithQueue(firstTrack, queue: tracks)
    }

    func shuffle(using spotifyRemote: SpotifyRemoteService) {
        guard let randomTrack = tracks.randomElement() else { return }
        spotifyRemote.playWithQueue(randomTrack, queue: tracks)
        spotifyRemote.toggleShuffle()
    }
}
