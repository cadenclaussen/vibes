import SwiftUI

struct NowPlayingView: View {
    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = NowPlayingViewModel()

    var body: some View {
        ZStack {
            // Background gradient from album art colors
            backgroundGradient

            VStack(spacing: 0) {
                // Drag indicator
                dragIndicator
                    .padding(.top, 8)

                if let track = spotifyRemote.currentTrack {
                    // Album artwork
                    albumArtwork(track)
                        .padding(.top, 20)

                    // Track info
                    trackInfo(track)
                        .padding(.top, 16)

                    // Lyrics
                    LyricsView(
                        lyrics: viewModel.lyrics,
                        currentLineIndex: viewModel.currentLineIndex,
                        isLoading: viewModel.isLoadingLyrics,
                        error: viewModel.lyricsError,
                        hasSyncedLyrics: viewModel.hasSyncedLyrics
                    )
                    .frame(maxHeight: .infinity)
                    .padding(.top, 16)

                    // Progress bar (display only)
                    ProgressBarView(
                        currentTime: spotifyRemote.playbackPosition,
                        duration: spotifyRemote.trackDuration
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Up next indicator
                    upNextView
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                    // Playback controls
                    playbackControls
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                } else {
                    Spacer()
                    Text("No track playing")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .task {
            if let track = spotifyRemote.currentTrack {
                await viewModel.loadLyrics(for: track)
            }
        }
        .onChange(of: spotifyRemote.currentTrack?.id) { _, newId in
            if let track = spotifyRemote.currentTrack {
                Task {
                    await viewModel.loadLyrics(for: track)
                }
            }
        }
        .onChange(of: spotifyRemote.playbackPosition) { _, position in
            viewModel.updateCurrentLine(playbackPosition: position)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemGray6).opacity(0.3),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var dragIndicator: some View {
        Capsule()
            .fill(Color(.systemGray3))
            .frame(width: 36, height: 5)
    }

    private func albumArtwork(_ track: UnifiedTrack) -> some View {
        AsyncImage(url: URL(string: track.albumArtURL ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color(.systemGray4))
                .overlay {
                    Image(systemName: "music.note")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                }
        }
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
    }

    private func trackInfo(_ track: UnifiedTrack) -> some View {
        VStack(spacing: 6) {
            Text(track.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(track.artistName)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
        }
        .padding(.horizontal)
    }

    private var upNextView: some View {
        HStack(spacing: 8) {
            if let nextTrack = spotifyRemote.upNext {
                Text("Up next:")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                Text(nextTrack.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                Text("·")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                Text(nextTrack.artistName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            } else {
                Text("Nothing up next")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            Spacer()
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 24) {
            // Shuffle toggle
            Button {
                spotifyRemote.toggleShuffle()
            } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 20))
                    .foregroundStyle(spotifyRemote.isShuffleEnabled ? .green : .white.opacity(0.5))
            }
            .disabled(spotifyRemote.queue.isEmpty)

            // Previous/restart button
            Button {
                spotifyRemote.playPrevious()
            } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }

            // Play/pause button
            Button {
                spotifyRemote.togglePlayPause()
            } label: {
                Image(systemName: spotifyRemote.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white)
            }

            // Next button
            Button {
                spotifyRemote.playNext()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(spotifyRemote.hasNextTrack ? .white : .white.opacity(0.3))
            }
            .disabled(!spotifyRemote.hasNextTrack)
        }
    }
}

#Preview {
    NowPlayingView()
        .environment(SpotifyRemoteService.shared)
}
