//
//  AppRouter.swift
//  vibes
//
//  Centralized navigation router for the app.
//

import SwiftUI

// MARK: - Tab Enum

enum Tab: Int, CaseIterable {
    case feed = 0
    case explore = 1
    case profile = 2

    var title: String {
        switch self {
        case .feed: return "Feed"
        case .explore: return "Explore"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .feed: return "house"
        case .explore: return "sparkles"
        case .profile: return "person.circle"
        }
    }

    var selectedIcon: String {
        switch self {
        case .feed: return "house.fill"
        case .explore: return "sparkles"
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
    case settings
    case editProfile
}

// MARK: - App Router

@Observable
class AppRouter {
    var selectedTab: Tab = .feed
    var feedPath = NavigationPath()
    var explorePath = NavigationPath()
    var profilePath = NavigationPath()

    // For triggering specific actions
    var shouldFocusSearch = false

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
            selectedTab = .feed
            feedPath.append(friend)

        case .settings:
            selectedTab = .profile
            profilePath.append(AppDestination.settings)

        case .editProfile:
            selectedTab = .profile
            profilePath.append(AppDestination.editProfile)
        }
    }

    func popToRoot(tab: Tab? = nil) {
        let targetTab = tab ?? selectedTab
        switch targetTab {
        case .feed:
            feedPath = NavigationPath()
        case .explore:
            explorePath = NavigationPath()
        case .profile:
            profilePath = NavigationPath()
        }
    }

    func popToRootAll() {
        feedPath = NavigationPath()
        explorePath = NavigationPath()
        profilePath = NavigationPath()
    }

    // MARK: - Quick Actions

    func goToSearch() {
        selectedTab = .explore
        shouldFocusSearch = true
    }

    func goToFeed() {
        selectedTab = .feed
    }

    func goToProfile() {
        selectedTab = .profile
    }

    func goToSettings() {
        navigate(to: .settings)
    }
}
