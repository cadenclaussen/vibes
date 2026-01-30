import SwiftUI

struct MiniPlayerView: View {
    @Environment(AudioPreviewManager.self) private var audioManager

    var body: some View {
        if let track = audioManager.currentTrack {
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * audioManager.progress)
                }
                .frame(height: 2)
                .background(Color(.tertiarySystemFill))

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

                    // Time
                    Text(audioManager.formattedProgress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()

                    // Play/Pause button
                    Button {
                        audioManager.togglePlayPause()
                    } label: {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                    }

                    // Close button
                    Button {
                        audioManager.stop()
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
    .environment(AudioPreviewManager.shared)
}
