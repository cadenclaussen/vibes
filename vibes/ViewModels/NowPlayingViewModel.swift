import Foundation

@Observable
class NowPlayingViewModel {
    var lyrics: SyncedLyrics?
    var isLoadingLyrics = false
    var lyricsError: Error?
    var currentLineIndex: Int?

    private var currentTrackId: String?
    private let lyricsService = LyricsService.shared

    var hasSyncedLyrics: Bool {
        guard let lyrics = lyrics, !lyrics.isEmpty else { return false }
        // Check if lyrics have actual timestamps (not all 0)
        return lyrics.lines.contains { $0.startTime > 0 }
    }

    @MainActor
    func loadLyrics(for track: UnifiedTrack) async {
        // Don't reload if same track
        if currentTrackId == track.id && lyrics != nil {
            return
        }

        currentTrackId = track.id
        isLoadingLyrics = true
        lyricsError = nil
        lyrics = nil
        currentLineIndex = nil

        do {
            let duration = track.durationMs.map { TimeInterval($0) / 1000 }
            lyrics = try await lyricsService.getLyrics(
                trackName: track.name,
                artistName: track.artistName,
                albumName: track.albumName,
                duration: duration
            )
        } catch {
            lyricsError = error
        }

        isLoadingLyrics = false
    }

    func updateCurrentLine(playbackPosition: TimeInterval) {
        guard let lyrics = lyrics, hasSyncedLyrics else { return }

        let newIndex = lyrics.currentLineIndex(at: playbackPosition)
        if newIndex != currentLineIndex {
            currentLineIndex = newIndex
        }
    }

    func reset() {
        currentTrackId = nil
        lyrics = nil
        isLoadingLyrics = false
        lyricsError = nil
        currentLineIndex = nil
    }
}
