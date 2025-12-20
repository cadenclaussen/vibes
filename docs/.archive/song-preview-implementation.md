# Song Preview Implementation with AVPlayer

This document describes how to implement tap-to-play 30-second song previews using AVPlayer.

## Overview

Spotify provides a `previewUrl` field on Track objects containing a URL to a 30-second audio preview. We'll use AVPlayer to stream and play these previews when users tap on search results.

## Prerequisites

- Track model already has `previewUrl: String?` (vibes/Models/SpotifyModels.swift:65)
- SearchView displays track results (vibes/Views/SearchView.swift)

## Implementation Steps

### 1. Create AudioPlayerService

Create a singleton service to manage audio playback across the app.

**File: vibes/Services/AudioPlayerService.swift**

```swift
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

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    func play(track: Track) {
        guard let urlString = track.previewUrl,
              let url = URL(string: urlString) else {
            print("No preview URL available for track: \(track.name)")
            return
        }

        // If same track, toggle play/pause
        if currentTrackId == track.id {
            togglePlayPause()
            return
        }

        // Stop current playback
        stop()

        // Create new player
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

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
        currentTrackId = track.id
        player?.play()
        isPlaying = true
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
        player?.pause()
        player = nil
        isPlaying = false
        currentTrackId = nil
        playbackProgress = 0
    }

    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player?.currentItem?.duration,
                  duration.seconds.isFinite else { return }

            self.playbackProgress = time.seconds / duration.seconds
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    @objc private func playerDidFinishPlaying() {
        isPlaying = false
        playbackProgress = 0
        currentTrackId = nil
    }

    deinit {
        stop()
    }
}
```

### 2. Update TrackRow to Support Playback

Modify TrackRow in SearchView.swift to show play/pause state and handle taps.

**Changes to vibes/Views/SearchView.swift:**

```swift
struct TrackRow: View {
    let track: Track
    @ObservedObject var audioPlayer = AudioPlayerService.shared

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == track.id
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    var body: some View {
        Button {
            audioPlayer.play(track: track)
        } label: {
            HStack(spacing: 12) {
                albumArtView
                trackInfo
                Spacer()
                playIndicator
                durationLabel
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var albumArtView: some View {
        ZStack {
            // Album art (existing code)
            Group {
                if let imageUrl = track.album.images.first?.url,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            albumPlaceholder
                        case .empty:
                            ProgressView()
                        @unknown default:
                            albumPlaceholder
                        }
                    }
                } else {
                    albumPlaceholder
                }
            }
            .frame(width: 48, height: 48)
            .cornerRadius(4)

            // Play/pause overlay when this track is active
            if isCurrentTrack {
                Rectangle()
                    .fill(.black.opacity(0.4))
                    .frame(width: 48, height: 48)
                    .cornerRadius(4)

                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
        }
    }

    @ViewBuilder
    private var playIndicator: some View {
        if isCurrentTrack && isPlaying {
            // Animated sound wave indicator
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    SoundWaveBar(delay: Double(index) * 0.1)
                }
            }
            .frame(width: 20)
        } else if track.previewUrl == nil {
            // No preview available
            Image(systemName: "speaker.slash")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // ... rest of existing code (albumPlaceholder, trackInfo, durationLabel, formatDuration)
}

// Animated sound wave bar
struct SoundWaveBar: View {
    let delay: Double
    @State private var animating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.green)
            .frame(width: 3, height: animating ? 16 : 6)
            .animation(
                .easeInOut(duration: 0.4)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: animating
            )
            .onAppear { animating = true }
    }
}
```

### 3. Add Progress Bar (Optional)

Add a mini progress bar to show playback progress.

```swift
private var albumArtView: some View {
    ZStack(alignment: .bottom) {
        // ... existing album art code ...

        // Progress bar at bottom of album art
        if isCurrentTrack {
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.green)
                    .frame(width: geometry.size.width * audioPlayer.playbackProgress, height: 2)
            }
            .frame(height: 2)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
    .frame(width: 48, height: 48)
    .cornerRadius(4)
    .clipped()
}
```

### 4. Add Now Playing Mini Bar (Optional)

Add a persistent mini player at the bottom of SearchView showing current track.

```swift
// Add to SearchView body, after resultsView
if let trackId = audioPlayer.currentTrackId,
   let track = viewModel.searchResults.first(where: { $0.id == trackId }) {
    NowPlayingBar(track: track)
}

struct NowPlayingBar: View {
    let track: Track
    @ObservedObject var audioPlayer = AudioPlayerService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.green)
                    .frame(width: geometry.size.width * audioPlayer.playbackProgress)
            }
            .frame(height: 2)

            HStack(spacing: 12) {
                // Album art
                AsyncImage(url: URL(string: track.album.images.first?.url ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color(.tertiarySystemFill))
                }
                .frame(width: 40, height: 40)
                .cornerRadius(4)

                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.subheadline)
                        .lineLimit(1)
                    Text(track.artists.map { $0.name }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Play/pause button
                Button {
                    audioPlayer.togglePlayPause()
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }

                // Close button
                Button {
                    audioPlayer.stop()
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
        }
    }
}
```

## Key Considerations

### Preview URL Availability

Not all tracks have preview URLs. Spotify has been reducing preview availability. Handle nil gracefully:
- Show a "no preview" indicator (speaker.slash icon)
- Disable tap action when no preview available
- Consider showing a message to user

### Audio Session

The audio session setup in `setupAudioSession()` ensures:
- Audio plays even when silent switch is on (`.playback` category)
- Interruptions from calls/other apps are handled properly

### Memory Management

- Stop playback when view disappears
- Remove observers in deinit
- Use weak self in closures

### User Experience

- Show clear visual feedback for current playing track
- Provide easy way to stop playback
- Consider haptic feedback on play/pause
- Handle errors gracefully (network issues, invalid URLs)

## Testing

1. Search for songs
2. Tap a track with preview - should start playing
3. Tap same track - should pause
4. Tap different track - should switch
5. Let track finish - should reset state
6. Test track with no preview - should show indicator

## Files to Create/Modify

| File | Action |
|------|--------|
| vibes/Services/AudioPlayerService.swift | Create |
| vibes/Views/SearchView.swift | Modify TrackRow |

## Related

- [Spotify Preview URL Documentation](https://developer.spotify.com/documentation/web-api/reference/get-track)
- [AVPlayer Documentation](https://developer.apple.com/documentation/avfoundation/avplayer)
