import Foundation
import AVFoundation
import Combine

@MainActor
class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()

    @Published var isPlaying = false
    @Published var currentTrackId: String?
    @Published var playbackProgress: Double = 0

    private var player: AVPlayer?
    private var timeObserver: Any?

    private var audioSessionConfigured = false

    private init() {}

    private func setupAudioSessionIfNeeded() {
        guard !audioSessionConfigured else { return }
        audioSessionConfigured = true
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    func play(track: Track) {
        guard let urlString = track.previewUrl else {
            return
        }
        playUrl(urlString, trackId: track.id)
    }

    func playUrl(_ urlString: String, trackId: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        // Setup audio session on first play
        setupAudioSessionIfNeeded()

        // If same track, toggle play/pause
        if currentTrackId == trackId {
            togglePlayPause()
            return
        }

        // Stop current playback
        stop()

        // Create asset and check if playable
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = 1.0

        // Observe when track finishes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        // Add time observer for progress
        addTimeObserver()

        // Start playback
        currentTrackId = trackId
        player?.play()
        isPlaying = true

        // Track for achievements
        LocalAchievementStats.shared.previewPlays += 1
    }

    func togglePlayPause() {
        guard let player = player else { return }

        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    func stop() {
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.pause()
        player = nil
        isPlaying = false
        currentTrackId = nil
        playbackProgress = 0
    }

    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self = self,
                      let duration = self.player?.currentItem?.duration,
                      duration.seconds.isFinite else { return }

                self.playbackProgress = time.seconds / duration.seconds
            }
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    @objc private func playerDidFinishPlaying() {
        Task { @MainActor in
            isPlaying = false
            playbackProgress = 0
            currentTrackId = nil
        }
    }

    nonisolated deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
