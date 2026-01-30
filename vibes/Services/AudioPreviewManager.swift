import AVFoundation
import Observation

@Observable
class AudioPreviewManager {
    static let shared = AudioPreviewManager()

    var currentTrack: UnifiedTrack?
    var isPlaying = false
    var progress: Double = 0
    var duration: Double = 30.0

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var playerItemObserver: NSKeyValueObservation?

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    func play(_ track: UnifiedTrack) {
        guard let urlString = track.previewURL,
              let url = URL(string: urlString) else {
            print("No preview URL available for: \(track.name)")
            return
        }

        stop()

        currentTrack = track
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        playerItemObserver = playerItem.observe(\.status) { [weak self] item, _ in
            if item.status == .readyToPlay {
                DispatchQueue.main.async {
                    self?.player?.play()
                    self?.isPlaying = true
                }
            } else if item.status == .failed {
                print("Player item failed: \(item.error?.localizedDescription ?? "unknown error")")
                DispatchQueue.main.async {
                    self?.stop()
                }
            }
        }

        addTimeObserver()
        addEndObserver()
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    func stop() {
        player?.pause()
        removeTimeObserver()
        playerItemObserver?.invalidate()
        playerItemObserver = nil
        player = nil
        currentTrack = nil
        isPlaying = false
        progress = 0
    }

    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player?.currentItem?.duration,
                  duration.isNumeric else { return }

            let currentTime = CMTimeGetSeconds(time)
            let totalDuration = CMTimeGetSeconds(duration)

            self.progress = currentTime / totalDuration
            self.duration = totalDuration
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    private func addEndObserver() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.stop()
        }
    }

    var formattedProgress: String {
        guard let player = player,
              let item = player.currentItem,
              item.duration.isNumeric else {
            return "0:00"
        }

        let currentSeconds = CMTimeGetSeconds(player.currentTime())
        let minutes = Int(currentSeconds) / 60
        let seconds = Int(currentSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var hasPreview: Bool {
        currentTrack?.previewURL != nil
    }

    static func trackHasPreview(_ track: UnifiedTrack) -> Bool {
        track.previewURL != nil
    }
}
