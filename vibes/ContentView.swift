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
    @Environment(AppRouter.self) private var router

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
    @AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false
    @Environment(AppRouter.self) private var router
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        if !hasCompletedTutorial {
            TutorialView(hasCompletedTutorial: $hasCompletedTutorial)
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        @Bindable var router = router

        return TabView(selection: $router.selectedTab) {
            FeedView()
                .tabItem {
                    Label(Tab.feed.title, systemImage: Tab.feed.icon)
                }
                .tag(Tab.feed)

            ExploreView()
                .tabItem {
                    Label(Tab.explore.title, systemImage: Tab.explore.icon)
                }
                .tag(Tab.explore)

            ProfileView()
                .tabItem {
                    Label(Tab.profile.title, systemImage: Tab.profile.icon)
                }
                .tag(Tab.profile)
        }
        .onChange(of: router.selectedTab) { _, _ in
            AudioPlayerService.shared.stop()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppRouter())
        .environmentObject(AuthManager.shared)
}
