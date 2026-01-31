import SwiftUI

struct ProgressBarView: View {
    let currentTime: TimeInterval
    let duration: TimeInterval

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0), 1)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Progress bar (display only)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 4)

                    // Progress fill
                    Capsule()
                        .fill(Color.white)
                        .frame(width: max(0, geometry.size.width * progress), height: 4)
                }
            }
            .frame(height: 4)

            // Time labels
            HStack {
                Text(formatTime(currentTime))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .monospacedDigit()

                Spacer()

                Text("-\(formatTime(max(0, duration - currentTime)))")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .monospacedDigit()
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            ProgressBarView(
                currentTime: 65,
                duration: 210
            )
            .padding()
        }
    }
}
