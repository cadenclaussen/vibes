import SwiftUI

@Observable
class AppRouter {
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
            case .feed: return "house.fill"
            case .explore: return "magnifyingglass"
            case .profile: return "person.fill"
            }
        }
    }

    var selectedTab: Tab = .feed
    var feedPath = NavigationPath()
    var explorePath = NavigationPath()
    var profilePath = NavigationPath()

    var presentedSheet: Sheet?

    enum Sheet: Identifiable {
        case shareSong(UnifiedTrack)
        case userPicker(UnifiedTrack)
        case playlistPicker(UnifiedTrack)
        case aiPlaylist
        case findUsers
        case editProfile

        var id: String {
            switch self {
            case .shareSong(let track): return "share_\(track.id)"
            case .userPicker(let track): return "userPicker_\(track.id)"
            case .playlistPicker(let track): return "playlistPicker_\(track.id)"
            case .aiPlaylist: return "aiPlaylist"
            case .findUsers: return "findUsers"
            case .editProfile: return "editProfile"
            }
        }
    }

    // Navigation methods
    func navigateToSongDetail(_ song: UnifiedTrack) {
        switch selectedTab {
        case .feed:
            feedPath.append(song)
        case .explore:
            explorePath.append(song)
        case .profile:
            profilePath.append(song)
        }
    }

    func navigateToArtistDetail(_ artist: UnifiedArtist) {
        switch selectedTab {
        case .feed:
            feedPath.append(artist)
        case .explore:
            explorePath.append(artist)
        case .profile:
            profilePath.append(artist)
        }
    }

    func navigateToAlbumDetail(_ album: UnifiedAlbum) {
        switch selectedTab {
        case .feed:
            feedPath.append(album)
        case .explore:
            explorePath.append(album)
        case .profile:
            profilePath.append(album)
        }
    }

    func navigateToUserProfile(_ user: UserProfile) {
        switch selectedTab {
        case .feed:
            feedPath.append(user)
        case .explore:
            explorePath.append(user)
        case .profile:
            profilePath.append(user)
        }
    }

    func navigateToConcert(_ concert: Concert) {
        switch selectedTab {
        case .feed:
            feedPath.append(concert)
        case .explore:
            explorePath.append(concert)
        case .profile:
            profilePath.append(concert)
        }
    }

    func navigateToSettings() {
        selectedTab = .profile
        profilePath.append(SettingsDestination.main)
    }

    func goToExplore() {
        selectedTab = .explore
    }

    func goToFeed() {
        selectedTab = .feed
    }

    func goToProfile() {
        selectedTab = .profile
    }

    func navigateToSetupChecklist() {
        feedPath.append(SetupDestination.checklist)
    }

    func navigateToConcertDiscovery() {
        feedPath.append(ConcertDiscoveryDestination.artistList)
    }

    // Sheet presentation
    func presentShareSheet(for song: UnifiedTrack) {
        presentedSheet = .shareSong(song)
    }

    func presentUserPicker(for song: UnifiedTrack) {
        presentedSheet = .userPicker(song)
    }

    func presentPlaylistPicker(for song: UnifiedTrack) {
        presentedSheet = .playlistPicker(song)
    }

    func presentAIPlaylistSheet() {
        presentedSheet = .aiPlaylist
    }

    func presentFindUsers() {
        presentedSheet = .findUsers
    }

    func presentEditProfile() {
        presentedSheet = .editProfile
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    // Pop to root
    func popToRoot() {
        switch selectedTab {
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
}

// Settings navigation destination
enum SettingsDestination: Hashable {
    case main
    case spotify
    case gemini
    case concertCity
    case privacy
}

// Setup navigation destination
enum SetupDestination: Hashable {
    case checklist
    case spotify
    case gemini
    case ticketmaster
}

// Concert Discovery navigation destination
enum ConcertDiscoveryDestination: Hashable {
    case artistList
}
