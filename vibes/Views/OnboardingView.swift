//
//  OnboardingView.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var showSpotifyConnect = false
    @StateObject private var spotifyService = SpotifyService.shared

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Vibes",
            subtitle: "Share your music taste with friends and discover what they're listening to",
            icon: "waveform.circle.fill",
            color: .purple
        ),
        OnboardingPage(
            title: "Share Songs",
            subtitle: "Send your favorite tracks to friends with just a tap. They can preview them right in the chat",
            icon: "music.note.list",
            color: .blue
        ),
        OnboardingPage(
            title: "Build Vibestreaks",
            subtitle: "Exchange songs daily with friends to build your vibestreak. The longer the streak, the cooler the badge",
            icon: "flame.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "Connect Spotify",
            subtitle: "Link your Spotify to share your music personality, top artists, and discover new music from friends",
            icon: "antenna.radiowaves.left.and.right",
            color: .green
        )
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                bottomSection
            }
        }
        .sheet(isPresented: $showSpotifyConnect) {
            SpotifyAuthView()
        }
    }

    private var bottomSection: some View {
        VStack(spacing: 20) {
            pageIndicator

            if currentPage == pages.count - 1 {
                lastPageButtons
            } else {
                navigationButtons
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? pages[currentPage].color : Color(.tertiaryLabel))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    private var navigationButtons: some View {
        HStack {
            Button {
                completeOnboarding()
            } label: {
                Text("Skip")
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                withAnimation {
                    currentPage += 1
                }
            } label: {
                HStack {
                    Text("Next")
                    Image(systemName: "arrow.right")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(pages[currentPage].color)
                .clipShape(Capsule())
            }
        }
    }

    private var lastPageButtons: some View {
        VStack(spacing: 12) {
            if !spotifyService.isAuthenticated {
                Button {
                    showSpotifyConnect = true
                } label: {
                    HStack {
                        Image(systemName: "music.note")
                        Text("Connect Spotify")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .clipShape(Capsule())
                }
            }

            Button {
                completeOnboarding()
            } label: {
                Text(spotifyService.isAuthenticated ? "Get Started" : "Skip for Now")
                    .fontWeight(.semibold)
                    .foregroundColor(spotifyService.isAuthenticated ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(spotifyService.isAuthenticated ? Color.blue : Color(.tertiarySystemFill))
                    .clipShape(Capsule())
            }
        }
    }

    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 180, height: 180)

                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: 140, height: 140)

                Image(systemName: page.icon)
                    .font(.system(size: 64))
                    .foregroundColor(page.color)
            }

            VStack(spacing: 16) {
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
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
