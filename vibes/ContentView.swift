//
//  ContentView.swift
//  vibes
//
//  Created by Caden Claussen on 11/22/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
    }
}

struct MainTabView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    @State private var shouldEditProfile = false
    @State private var navigateToFriend: FriendProfile?

    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DiscoverView(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                    .tabItem {
                        Label("Discover", systemImage: "waveform.circle.fill")
                    }
                    .tag(0)

                SearchView(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile, navigateToFriend: $navigateToFriend)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(1)

                ChatsView(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                    .tabItem {
                        Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(2)

                ProfileView(shouldEditProfile: $shouldEditProfile)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }

            AchievementBannerOverlay()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
