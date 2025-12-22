//
//  TutorialView.swift
//  vibes
//
//  Created by Claude Code on 12/21/25.
//

import SwiftUI

struct TutorialPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let features: [TutorialFeature]
}

struct TutorialFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct TutorialView: View {
    @Binding var hasCompletedTutorial: Bool
    @State private var currentPage = 0
    @State private var showSpotifyConnect = false
    @State private var animateContent = false
    @StateObject private var spotifyService = SpotifyService.shared

    private let pages: [TutorialPage] = [
        TutorialPage(
            title: "Welcome to Vibes",
            subtitle: "Your social music experience powered by AI",
            icon: "waveform.circle.fill",
            color: .purple,
            features: [
                TutorialFeature(icon: "music.note.list", title: "Share Music", description: "Send songs to friends instantly"),
                TutorialFeature(icon: "brain.head.profile", title: "AI-Powered", description: "Get personalized recommendations"),
                TutorialFeature(icon: "person.2.fill", title: "Connect", description: "See what friends are listening to")
            ]
        ),
        TutorialPage(
            title: "Discover",
            subtitle: "Find new music tailored just for you",
            icon: "waveform.circle.fill",
            color: .blue,
            features: [
                TutorialFeature(icon: "sparkles", title: "New Releases", description: "Latest drops from your favorite artists"),
                TutorialFeature(icon: "heart.fill", title: "For You", description: "Songs based on your listening history"),
                TutorialFeature(icon: "person.wave.2.fill", title: "Friends Activity", description: "See what your friends are jamming to")
            ]
        ),
        TutorialPage(
            title: "AI Magic",
            subtitle: "Let AI curate your perfect soundtrack",
            icon: "brain.head.profile",
            color: .pink,
            features: [
                TutorialFeature(icon: "wand.and.stars", title: "AI Picks", description: "Personalized songs with match scores"),
                TutorialFeature(icon: "list.bullet.rectangle.portrait", title: "AI Playlists", description: "Themed playlists for any mood or activity"),
                TutorialFeature(icon: "arrow.triangle.merge", title: "Friend Blends", description: "Create unique playlists with a friend's taste")
            ]
        ),
        TutorialPage(
            title: "Search & Play",
            subtitle: "Find any song, artist, album, or playlist",
            icon: "magnifyingglass",
            color: .green,
            features: [
                TutorialFeature(icon: "music.note", title: "Tracks", description: "Search millions of songs"),
                TutorialFeature(icon: "person.fill", title: "Artists", description: "Explore artist profiles and discographies"),
                TutorialFeature(icon: "play.circle.fill", title: "Preview", description: "Tap any song to hear a 30-second preview")
            ]
        ),
        TutorialPage(
            title: "Song Actions",
            subtitle: "Long-press any song for quick actions",
            icon: "hand.tap.fill",
            color: .orange,
            features: [
                TutorialFeature(icon: "paperplane.fill", title: "Send to Friend", description: "Share songs directly in chat"),
                TutorialFeature(icon: "plus.circle.fill", title: "Add to Playlist", description: "Save to your Spotify playlists"),
                TutorialFeature(icon: "arrow.up.right.square", title: "Open in Spotify", description: "Listen to the full track in Spotify")
            ]
        ),
        TutorialPage(
            title: "Chats & Vibestreaks",
            subtitle: "Connect with friends through music",
            icon: "bubble.left.and.bubble.right.fill",
            color: .cyan,
            features: [
                TutorialFeature(icon: "music.note", title: "Share Songs", description: "Send tracks with preview playback"),
                TutorialFeature(icon: "flame.fill", title: "Vibestreaks", description: "Exchange songs daily to build streaks"),
                TutorialFeature(icon: "headphones", title: "Now Playing", description: "See what friends are listening to live")
            ]
        ),
        TutorialPage(
            title: "Profile & Stats",
            subtitle: "Track your music journey",
            icon: "person.crop.circle.fill",
            color: .indigo,
            features: [
                TutorialFeature(icon: "chart.bar.fill", title: "Top Artists & Songs", description: "Your most-played music over time"),
                TutorialFeature(icon: "music.quarternote.3", title: "Favorite Genres", description: "Customize your music taste profile"),
                TutorialFeature(icon: "trophy.fill", title: "Achievements", description: "Unlock badges as you use the app")
            ]
        ),
        TutorialPage(
            title: "Ready to Vibe",
            subtitle: "Connect Spotify to unlock all features",
            icon: "checkmark.circle.fill",
            color: .green,
            features: [
                TutorialFeature(icon: "link", title: "Connect Spotify", description: "Sync your music library and stats"),
                TutorialFeature(icon: "key.fill", title: "AI Features", description: "Add a Gemini API key in Settings"),
                TutorialFeature(icon: "arrow.right.circle.fill", title: "Let's Go", description: "Start discovering and sharing music")
            ]
        )
    ]

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        TutorialPageView(page: page, isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, _ in
                    HapticService.selectionChanged()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        animateContent = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            animateContent = true
                        }
                    }
                }

                bottomSection
            }
        }
        .sheet(isPresented: $showSpotifyConnect) {
            SpotifyAuthView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateContent = true
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                pages[currentPage].color.opacity(0.15),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.4), value: currentPage)
    }

    private var bottomSection: some View {
        VStack(spacing: 20) {
            progressIndicator

            if currentPage == pages.count - 1 {
                lastPageButtons
            } else {
                navigationButtons
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? pages[currentPage].color : Color(.tertiaryLabel))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private var navigationButtons: some View {
        HStack {
            Button {
                HapticService.lightImpact()
                completeTutorial()
            } label: {
                Text("Skip")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

            Spacer()

            Button {
                HapticService.lightImpact()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentPage += 1
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Next")
                    Image(systemName: "arrow.right")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(pages[currentPage].color)
                .clipShape(Capsule())
                .shadow(color: pages[currentPage].color.opacity(0.4), radius: 8, y: 4)
            }
        }
    }

    private var lastPageButtons: some View {
        VStack(spacing: 14) {
            if !spotifyService.isAuthenticated {
                Button {
                    HapticService.lightImpact()
                    showSpotifyConnect = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "music.note")
                        Text("Connect Spotify")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.green.opacity(0.4), radius: 8, y: 4)
                }
            }

            Button {
                HapticService.mediumImpact()
                completeTutorial()
            } label: {
                Text(spotifyService.isAuthenticated ? "Get Started" : "Skip for Now")
                    .fontWeight(.semibold)
                    .foregroundColor(spotifyService.isAuthenticated ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        spotifyService.isAuthenticated
                            ? AnyShapeStyle(LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            : AnyShapeStyle(Color(.tertiarySystemFill))
                    )
                    .clipShape(Capsule())
                    .shadow(
                        color: spotifyService.isAuthenticated ? Color.blue.opacity(0.3) : .clear,
                        radius: 8,
                        y: 4
                    )
            }
        }
    }

    private func completeTutorial() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            hasCompletedTutorial = true
        }
    }
}

struct TutorialPageView: View {
    let page: TutorialPage
    let isActive: Bool

    @State private var showFeatures = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            iconSection

            textSection

            featuresList

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            if isActive {
                showFeatures = false
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                    showFeatures = true
                }
            }
        }
        .onChange(of: isActive) { _, active in
            if active {
                showFeatures = false
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                    showFeatures = true
                }
            }
        }
    }

    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(page.color.opacity(0.1))
                .frame(width: 160, height: 160)
                .scaleEffect(isActive ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isActive)

            Circle()
                .fill(page.color.opacity(0.2))
                .frame(width: 120, height: 120)
                .scaleEffect(isActive ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.05), value: isActive)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [page.color, page.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: page.color.opacity(0.4), radius: 12, y: 4)
                .scaleEffect(isActive ? 1 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: isActive)
                .overlay(
                    Image(systemName: page.icon)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                )
        }
    }

    private var textSection: some View {
        VStack(spacing: 12) {
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var featuresList: some View {
        VStack(spacing: 12) {
            ForEach(Array(page.features.enumerated()), id: \.element.id) { index, feature in
                FeatureRow(feature: feature, color: page.color)
                    .opacity(showFeatures ? 1 : 0)
                    .offset(y: showFeatures ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1),
                        value: showFeatures
                    )
            }
        }
        .padding(.top, 8)
    }
}

struct FeatureRow: View {
    let feature: TutorialFeature
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: feature.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    TutorialView(hasCompletedTutorial: .constant(false))
}
