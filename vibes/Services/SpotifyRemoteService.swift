import Foundation
import SpotifyiOS

enum SpotifyRemoteError: LocalizedError {
    case notConnected
    case spotifyNotInstalled
    case connectionFailed(String)
    case playbackFailed(String)

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to Spotify"
        case .spotifyNotInstalled:
            return "Spotify app is not installed"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .playbackFailed(let message):
            return "Playback failed: \(message)"
        }
    }
}

@MainActor
@Observable
class SpotifyRemoteService: NSObject {
    static let shared = SpotifyRemoteService()

    private(set) var isConnected = false
    private(set) var isPlaying = false
    private(set) var currentTrack: UnifiedTrack?
    private(set) var playbackPosition: TimeInterval = 0
    private(set) var trackDuration: TimeInterval = 30

    var progress: Double {
        guard trackDuration > 0 else { return 0 }
        return min(playbackPosition / trackDuration, 1.0)
    }

    var formattedProgress: String {
        let elapsed = Int(playbackPosition)
        let total = Int(trackDuration)
        return String(format: "%d:%02d / %d:%02d", elapsed / 60, elapsed % 60, total / 60, total % 60)
    }

    private var appRemote: SPTAppRemote?
    private var connectionCompletion: ((Result<Void, Error>) -> Void)?
    private var pendingTrack: UnifiedTrack?

    private let previewDuration: TimeInterval = 30

    private override init() {
        super.init()
        setupAppRemote()
    }

    private func setupAppRemote() {
        let configuration = SPTConfiguration(
            clientID: Constants.Spotify.clientId,
            redirectURL: URL(string: Constants.Spotify.redirectUri)!
        )
        appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote?.delegate = self
    }

    func connect() async throws {
        guard let appRemote = appRemote else {
            throw SpotifyRemoteError.notConnected
        }

        if isConnected {
            return
        }

        guard let accessToken = KeychainManager.shared.getSpotifyAccessToken() else {
            throw SpotifyRemoteError.notConnected
        }

        return try await withCheckedThrowingContinuation { continuation in
            connectionCompletion = { result in
                continuation.resume(with: result)
            }
            appRemote.connectionParameters.accessToken = accessToken
            appRemote.connect()
        }
    }

    func disconnect() {
        appRemote?.disconnect()
        isConnected = false
        stop()
    }

    func play(_ track: UnifiedTrack) {
        currentTrack = track
        pendingTrack = track
        playbackPosition = 0

        guard let uri = track.spotifyUri else { return }

        if isConnected {
            playPendingTrack()
        } else {
            // This will open Spotify and trigger auth flow
            appRemote?.authorizeAndPlayURI(uri, asRadio: false, additionalScopes: nil) { success in
                if !success {
                    print("Could not open Spotify - app may not be installed")
                }
            }
        }
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else if currentTrack != nil {
            resume()
        }
    }

    private func playPendingTrack() {
        guard let track = pendingTrack,
              let uri = track.spotifyUri,
              let playerAPI = appRemote?.playerAPI else { return }

        pendingTrack = nil

        playerAPI.play(uri) { [weak self] _, error in
            Task { @MainActor [weak self] in
                if let error = error {
                    print("Playback error: \(error.localizedDescription)")
                } else {
                    self?.isPlaying = true
                    self?.playbackPosition = 0
                    self?.schedulePreviewStop()
                    self?.startProgressTimer()
                }
            }
        }
    }

    func pause() {
        guard let playerAPI = appRemote?.playerAPI else { return }
        playerAPI.pause(nil)
        isPlaying = false
        previewStopTask?.cancel()
        progressTimer?.cancel()
    }

    func resume() {
        guard let playerAPI = appRemote?.playerAPI else { return }
        playerAPI.resume(nil)
        isPlaying = true
        schedulePreviewStop()
        startProgressTimer()
    }

    func stop() {
        pause()
        currentTrack = nil
        playbackPosition = 0
    }

    private var previewStopTask: Task<Void, Never>?
    private var progressTimer: Task<Void, Never>?

    private func schedulePreviewStop() {
        previewStopTask?.cancel()
        let remaining = previewDuration - playbackPosition
        previewStopTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(max(remaining, 0)))
            if !Task.isCancelled {
                self?.pause()
            }
        }
    }

    private func startProgressTimer() {
        progressTimer?.cancel()
        progressTimer = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                if let self = self, self.isPlaying {
                    self.playbackPosition = min(self.playbackPosition + 0.1, self.previewDuration)
                }
            }
        }
    }

    // Called when app becomes active and Spotify redirects back
    func handleOpenURL(_ url: URL) {
        guard let appRemote = appRemote else { return }

        let parameters = appRemote.authorizationParameters(from: url)

        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            try? KeychainManager.shared.saveSpotifyAccessToken(accessToken)
            appRemote.connect()
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("Spotify auth error: \(errorDescription)")
            connectionCompletion?(.failure(SpotifyRemoteError.connectionFailed(errorDescription)))
            connectionCompletion = nil
        }
    }
}

extension SpotifyRemoteService: SPTAppRemoteDelegate {
    nonisolated func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        Task { @MainActor in
            isConnected = true
            appRemote.playerAPI?.delegate = self
            appRemote.playerAPI?.subscribe(toPlayerState: nil)

            connectionCompletion?(.success(()))
            connectionCompletion = nil

            playPendingTrack()
        }
    }

    nonisolated func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        Task { @MainActor in
            isConnected = false
            let errorMessage = error?.localizedDescription ?? "Unknown error"
            connectionCompletion?(.failure(SpotifyRemoteError.connectionFailed(errorMessage)))
            connectionCompletion = nil
        }
    }

    nonisolated func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        Task { @MainActor in
            isConnected = false
        }
    }
}

extension SpotifyRemoteService: SPTAppRemotePlayerStateDelegate {
    nonisolated func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        Task { @MainActor in
            isPlaying = !playerState.isPaused
            let actualDuration = TimeInterval(playerState.track.duration) / 1000
            trackDuration = min(actualDuration, previewDuration)
        }
    }
}
