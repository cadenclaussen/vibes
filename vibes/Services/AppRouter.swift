//
//  AppRouter.swift
//  vibes
//
//  Centralized navigation router for the app.
//

import SwiftUI

// MARK: - Tab Enum

enum Tab: Int, CaseIterable {
    case home = 0
    case explore = 1
    case chats = 2
    case profile = 3

    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .chats: return "Chats"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .explore: return "sparkles"
        case .chats: return "bubble.left.and.bubble.right"
        case .profile: return "person.circle"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "sparkles"
        case .chats: return "bubble.left.and.bubble.right.fill"
        case .profile: return "person.circle.fill"
        }
    }
}

// MARK: - App Destination

enum AppDestination: Hashable {
    case artist(Artist)
    case album(Album)
    case playlist(Playlist)
    case chat(FriendProfile)
    case groupChat(GroupThread)
    case settings
    case achievements
    case editProfile
}

// MARK: - App Router

@Observable
class AppRouter {
    var selectedTab: Tab = .home
    var homePath = NavigationPath()
    var explorePath = NavigationPath()
    var chatsPath = NavigationPath()
    var profilePath = NavigationPath()

    // For triggering specific actions
    var shouldFocusSearch = false
    var shouldShowNewChat = false
    var shouldShowBlend = false

    // MARK: - Navigation

    func navigate(to destination: AppDestination) {
        switch destination {
        case .artist(let artist):
            selectedTab = .explore
            explorePath.append(artist)

        case .album(let album):
            selectedTab = .explore
            explorePath.append(album)

        case .playlist(let playlist):
            selectedTab = .explore
            explorePath.append(playlist)

        case .chat(let friend):
            selectedTab = .chats
            chatsPath.append(friend)

        case .groupChat(let group):
            selectedTab = .chats
            chatsPath.append(group)

        case .settings:
            selectedTab = .profile
            profilePath.append(AppDestination.settings)

        case .achievements:
            selectedTab = .profile
            // Achievements handled within ProfileView tabs

        case .editProfile:
            selectedTab = .profile
            profilePath.append(AppDestination.editProfile)
        }
    }

    func popToRoot(tab: Tab? = nil) {
        let targetTab = tab ?? selectedTab
        switch targetTab {
        case .home:
            homePath = NavigationPath()
        case .explore:
            explorePath = NavigationPath()
        case .chats:
            chatsPath = NavigationPath()
        case .profile:
            profilePath = NavigationPath()
        }
    }

    func popToRootAll() {
        homePath = NavigationPath()
        explorePath = NavigationPath()
        chatsPath = NavigationPath()
        profilePath = NavigationPath()
    }

    // MARK: - Quick Actions

    func goToSearch() {
        selectedTab = .explore
        shouldFocusSearch = true
    }

    func goToNewChat() {
        selectedTab = .chats
        shouldShowNewChat = true
    }

    func goToBlend() {
        selectedTab = .explore
        shouldShowBlend = true
    }

    func goToChats() {
        selectedTab = .chats
    }

    func goToProfile() {
        selectedTab = .profile
    }

    func goToSettings() {
        navigate(to: .settings)
    }
}
