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
    @State private var selectedTab = 0
    @State private var shouldEditProfile = false

    var body: some View {
        TabView(selection: $selectedTab) {
            SearchTab(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)

            FriendsView(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
                .tag(1)

            StatsTab(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)

            ProfileView(shouldEditProfile: $shouldEditProfile)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

// Placeholder views for tabs we haven't built yet
struct SearchTab: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(.tertiaryLabel))

                Text("Under Construction")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This feature is coming soon")
                    .font(.body)
                    .foregroundColor(Color(.secondaryLabel))
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SettingsMenu(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                }
            }
        }
    }
}

struct StatsTab: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(.tertiaryLabel))

                Text("Under Construction")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This feature is coming soon")
                    .font(.body)
                    .foregroundColor(Color(.secondaryLabel))
            }
            .navigationTitle("Stats")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SettingsMenu(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
