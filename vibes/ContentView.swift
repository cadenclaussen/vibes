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
    var body: some View {
        TabView {
            SearchTab()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            FriendsTab()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }

            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

// Placeholder views for tabs we haven't built yet
struct SearchTab: View {
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
        }
    }
}

struct FriendsTab: View {
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
            .navigationTitle("Friends")
        }
    }
}

struct StatsTab: View {
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
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
