import SwiftUI

struct TutorialView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var currentPage = 0
    @State private var isConnectingSpotify = false

    private let cards = TutorialCard.allCards

    var body: some View {
        VStack(spacing: 0) {
            // Skip button (hidden on last card)
            HStack {
                Spacer()
                if currentPage < cards.count - 1 {
                    Button("Skip") {
                        completeTutorial()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(height: 44)

            // Card content
            TabView(selection: $currentPage) {
                ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                    TutorialCardView(
                        card: card,
                        isLastCard: index == cards.count - 1,
                        isConnectingSpotify: $isConnectingSpotify,
                        onConnectSpotify: connectSpotify,
                        onSkipSpotify: completeTutorial
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<cards.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 32)
        }
    }

    private func connectSpotify() {
        isConnectingSpotify = true
        // TODO: Implement Spotify OAuth flow
        // For now, just complete tutorial
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isConnectingSpotify = false
            completeTutorial()
        }
    }

    private func completeTutorial() {
        authManager.completeTutorial()
    }
}

struct TutorialCardView: View {
    let card: TutorialCard
    let isLastCard: Bool
    @Binding var isConnectingSpotify: Bool
    let onConnectSpotify: () -> Void
    let onSkipSpotify: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: card.icon)
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            // Text content
            VStack(spacing: 12) {
                Text(card.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(card.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Last card has special buttons
            if isLastCard {
                VStack(spacing: 12) {
                    if isConnectingSpotify {
                        ProgressView()
                            .frame(height: 50)
                    } else {
                        Button(action: onConnectSpotify) {
                            HStack {
                                Image(systemName: "music.note")
                                Text("Connect Spotify")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 32)

                        Button("Skip for now") {
                            onSkipSpotify()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .padding()
    }
}

struct TutorialCard: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String

    static let allCards: [TutorialCard] = [
        TutorialCard(
            icon: "waveform.circle.fill",
            title: "Welcome to Vibes",
            description: "Discover and share music with your friends in a whole new way."
        ),
        TutorialCard(
            icon: "person.2.fill",
            title: "Follow Friends",
            description: "Follow your friends to see what they're listening to and share songs with them."
        ),
        TutorialCard(
            icon: "paperplane.fill",
            title: "Share Songs",
            description: "Share songs to your feed for all followers, or send directly to specific friends."
        ),
        TutorialCard(
            icon: "magnifyingglass",
            title: "Discover Music",
            description: "Search for any song, artist, or album. Get personalized recommendations based on your taste."
        ),
        TutorialCard(
            icon: "ticket.fill",
            title: "Find Concerts",
            description: "Discover upcoming concerts in your city for artists you love."
        ),
        TutorialCard(
            icon: "sparkles",
            title: "AI-Powered Playlists",
            description: "Let AI help you create the perfect playlist for any mood or occasion."
        ),
        TutorialCard(
            icon: "music.note",
            title: "Connect Spotify",
            description: "Link your Spotify account to unlock personalized recommendations and save songs to your library."
        )
    ]
}

#Preview {
    TutorialView()
        .environment(AuthManager.shared)
}
