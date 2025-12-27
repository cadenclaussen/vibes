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
    @AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false
    @State private var selectedTab = 0
    @State private var shouldEditProfile = false
    @State private var navigateToFriend: FriendProfile?

    var body: some View {
        if !hasCompletedTutorial {
            TutorialView(hasCompletedTutorial: $hasCompletedTutorial)
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        ZStack {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                DiscoverView(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                                    .frame(width: geometry.size.width)
                                    .id(0)

                                SearchView(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile, navigateToFriend: $navigateToFriend)
                                    .frame(width: geometry.size.width)
                                    .id(1)

                                ChatsView(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                                    .frame(width: geometry.size.width)
                                    .id(2)

                                ProfileView(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                                    .frame(width: geometry.size.width)
                                    .id(3)
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .scrollPosition(id: Binding(
                            get: { selectedTab },
                            set: { if let newValue = $0 { selectedTab = newValue } }
                        ))
                        .onChange(of: selectedTab) { _, newValue in
                            AudioPlayerService.shared.stop()
                            withAnimation(.smooth(duration: 0.3)) {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                }

                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)

            AchievementBannerOverlay()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(icon: String, label: String)] = [
        ("waveform.circle.fill", "Discover"),
        ("magnifyingglass", "Search"),
        ("bubble.left.and.bubble.right.fill", "Chats"),
        ("gearshape.fill", "Settings")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                tabButton(index: index)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 2)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, y: -4)
                .ignoresSafeArea()
        )
    }

    private func tabButton(index: Int) -> some View {
        let isSelected = selectedTab == index
        return Button {
            withAnimation(.smooth(duration: 0.35)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tabs[index].icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
                    )
                Text(tabs[index].label)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .accentColor : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
