import SwiftUI

struct SetupButton: View {
    let title: String
    let subtitle: String
    let isComplete: Bool
    let destination: SetupDestination

    var body: some View {
        NavigationLink(value: destination) {
            HStack(spacing: 12) {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isComplete ? .green : .red)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(isComplete ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(isComplete ? "configured" : "not configured")")
    }
}

#Preview {
    VStack(spacing: 16) {
        SetupButton(
            title: "Spotify",
            subtitle: "Connect your music library",
            isComplete: false,
            destination: .spotify
        )
        SetupButton(
            title: "Gemini API Key",
            subtitle: "Enable AI features",
            isComplete: true,
            destination: .gemini
        )
    }
    .padding()
}
