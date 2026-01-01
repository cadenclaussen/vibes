import SwiftUI

struct SetupChecklistView: View {
    @Environment(SetupManager.self) private var setupManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SetupButton(
                    title: "Spotify",
                    subtitle: "Connect your music library",
                    isComplete: setupManager.isSpotifyComplete,
                    destination: .spotify
                )

                SetupButton(
                    title: "Gemini API Key",
                    subtitle: "Enable AI features",
                    isComplete: setupManager.isGeminiComplete,
                    destination: .gemini
                )

                SetupButton(
                    title: "Ticketmaster",
                    subtitle: "Discover concerts near you",
                    isComplete: setupManager.isTicketmasterComplete,
                    destination: .ticketmaster
                )

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Setup")
    }
}

#Preview {
    NavigationStack {
        SetupChecklistView()
            .environment(SetupManager())
    }
}
