import SwiftUI

struct MiniPlayerView: View {
    @Environment(SpotifyRemoteService.self) private var spotifyRemote

    var body: some View {
        if let track = spotifyRemote.currentTrack {
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * spotifyRemote.progress)
                }
                .frame(height: 2)
                .background(Color(.tertiarySystemFill))

                // Content
                HStack(spacing: 12) {
                    if spotifyRemote.isPlayingAd {
                        adContent
                    } else {
                        trackContent(track)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .background(.ultraThinMaterial)
            .contentShape(Rectangle())
            .onTapGesture {
                spotifyRemote.isNowPlayingPresented = true
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .sheet(isPresented: Binding(
                get: { spotifyRemote.isNowPlayingPresented },
                set: { spotifyRemote.isNowPlayingPresented = $0 }
            )) {
                NowPlayingView()
                    .environment(spotifyRemote)
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(.black)
            }
        }
    }

    private var adContent: some View {
        Group {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.tertiarySystemFill))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "speaker.slash.fill")
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("Ad Playing")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Text("Your song will resume shortly")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    private func trackContent(_ track: UnifiedTrack) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: track.albumArtURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.tertiarySystemFill))
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            VStack(alignment: .leading, spacing: 2) {
                Text(track.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(track.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Playback controls
            HStack(spacing: 16) {
                // Shuffle toggle
                Button {
                    spotifyRemote.toggleShuffle()
                } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 14))
                        .foregroundStyle(spotifyRemote.isShuffleEnabled ? .green : .secondary)
                }
                .disabled(spotifyRemote.queue.isEmpty)

                // Previous/restart button
                Button {
                    spotifyRemote.playPrevious()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                }

                // Play/pause button
                Button {
                    spotifyRemote.togglePlayPause()
                } label: {
                    Image(systemName: spotifyRemote.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.primary)
                }

                // Next button
                Button {
                    spotifyRemote.playNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(spotifyRemote.hasNextTrack ? .primary : .tertiary)
                }
                .disabled(!spotifyRemote.hasNextTrack)
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView()
    }
    .environment(SpotifyRemoteService.shared)
}
