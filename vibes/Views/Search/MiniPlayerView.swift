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

                HStack(spacing: 12) {
                    if spotifyRemote.isPlayingAd {
                        // Ad indicator
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
                    } else {
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
                    }

                    Spacer()

                    if !spotifyRemote.isPlayingAd {
                        // Time (hide during ads)
                        Text(spotifyRemote.formattedProgress)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }

                    // Play/Pause button
                    Button {
                        spotifyRemote.togglePlayPause()
                    } label: {
                        Image(systemName: spotifyRemote.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                    }

                    // Close button
                    Button {
                        spotifyRemote.stop()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(.ultraThinMaterial)
            .transition(.move(edge: .bottom).combined(with: .opacity))
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
