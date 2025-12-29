import Foundation
import Combine
import SwiftUI

@MainActor
class MusicServiceManager: ObservableObject {
    static let shared = MusicServiceManager()

    @Published private(set) var activeServiceType: MusicServiceType?
    @Published var isAuthenticated: Bool = false
    @Published var userProfile: UnifiedUserProfile?

    private var _spotifyAdapter: SpotifyServiceAdapter?
    private var _appleMusicService: AppleMusicService?

    private var spotifyAdapter: SpotifyServiceAdapter {
        if _spotifyAdapter == nil {
            _spotifyAdapter = SpotifyServiceAdapter.shared
        }
        return _spotifyAdapter!
    }

    private var appleMusicService: AppleMusicService {
        if _appleMusicService == nil {
            _appleMusicService = AppleMusicService.shared
        }
        return _appleMusicService!
    }

    private let userDefaults = UserDefaults.standard
    private let selectedServiceKey = "selectedMusicService"

    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadSelectedService()
    }

    // MARK: - Current Service Access

    var currentService: any MusicStreamingService {
        switch activeServiceType {
        case .spotify:
            return spotifyAdapter
        case .appleMusic:
            return appleMusicService
        case .none:
            return spotifyAdapter
        }
    }

    var capabilities: MusicServiceCapabilities {
        switch activeServiceType {
        case .spotify:
            return .spotify
        case .appleMusic:
            return .appleMusic
        case .none:
            return .spotify
        }
    }

    // MARK: - Service Selection

    func selectService(_ type: MusicServiceType) {
        userDefaults.set(type.rawValue, forKey: selectedServiceKey)
        activeServiceType = type

        switch type {
        case .spotify:
            setupSpotifyObserversIfNeeded()
        case .appleMusic:
            setupAppleMusicObserversIfNeeded()
        }

        updateAuthenticationStatus()
        updateUserProfile()
    }

    func clearServiceSelection() {
        userDefaults.removeObject(forKey: selectedServiceKey)
        activeServiceType = nil
        isAuthenticated = false
        userProfile = nil
    }

    private func loadSelectedService() {
        if let savedType = userDefaults.string(forKey: selectedServiceKey),
           let type = MusicServiceType(rawValue: savedType) {
            activeServiceType = type

            switch type {
            case .spotify:
                setupSpotifyObserversIfNeeded()
            case .appleMusic:
                setupAppleMusicObserversIfNeeded()
            }

            updateAuthenticationStatus()
            updateUserProfile()
        } else if SpotifyService.shared.isAuthenticated {
            activeServiceType = .spotify
            userDefaults.set(MusicServiceType.spotify.rawValue, forKey: selectedServiceKey)
            setupSpotifyObserversIfNeeded()
            updateAuthenticationStatus()
            updateUserProfile()
        }
    }

    // MARK: - Authentication

    func authenticate() async throws {
        guard let serviceType = activeServiceType else {
            throw MusicServiceError.notAuthenticated
        }

        switch serviceType {
        case .spotify:
            try await spotifyAdapter.authenticate()
        case .appleMusic:
            try await appleMusicService.authenticate()
        }

        updateAuthenticationStatus()
        updateUserProfile()
    }

    func signOut() {
        switch activeServiceType {
        case .spotify:
            spotifyAdapter.signOut()
        case .appleMusic:
            appleMusicService.signOut()
        case .none:
            break
        }

        isAuthenticated = false
        userProfile = nil
    }

    func checkAuthenticationStatus() {
        switch activeServiceType {
        case .spotify:
            spotifyAdapter.checkAuthenticationStatus()
        case .appleMusic:
            appleMusicService.checkAuthenticationStatus()
        case .none:
            break
        }

        updateAuthenticationStatus()
        updateUserProfile()
    }

    private func updateAuthenticationStatus() {
        switch activeServiceType {
        case .spotify:
            isAuthenticated = spotifyAdapter.isAuthenticated
        case .appleMusic:
            isAuthenticated = appleMusicService.isAuthenticated
        case .none:
            isAuthenticated = false
        }
    }

    private func updateUserProfile() {
        switch activeServiceType {
        case .spotify:
            userProfile = spotifyAdapter.userProfile
        case .appleMusic:
            userProfile = appleMusicService.userProfile
        case .none:
            userProfile = nil
        }
    }

    // MARK: - Observers

    private var hasSetupSpotifyObservers = false
    private var hasSetupAppleMusicObservers = false

    private func setupSpotifyObserversIfNeeded() {
        guard !hasSetupSpotifyObservers else { return }
        hasSetupSpotifyObservers = true

        spotifyAdapter.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.activeServiceType == .spotify {
                    self?.updateAuthenticationStatus()
                }
            }
            .store(in: &cancellables)

        spotifyAdapter.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.activeServiceType == .spotify {
                    self?.updateUserProfile()
                }
            }
            .store(in: &cancellables)
    }

    private func setupAppleMusicObserversIfNeeded() {
        guard !hasSetupAppleMusicObservers else { return }
        hasSetupAppleMusicObservers = true

        appleMusicService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.activeServiceType == .appleMusic {
                    self?.updateAuthenticationStatus()
                }
            }
            .store(in: &cancellables)

        appleMusicService.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.activeServiceType == .appleMusic {
                    self?.updateUserProfile()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Convenience Methods

    var hasSelectedService: Bool {
        activeServiceType != nil
    }

    var canShowNowPlaying: Bool {
        activeServiceType == .spotify && isAuthenticated
    }

    var requiresSubscription: Bool {
        activeServiceType == .appleMusic
    }

    var serviceName: String {
        activeServiceType?.displayName ?? "Music Service"
    }

    var serviceColor: Color {
        activeServiceType?.brandColor ?? .gray
    }

    var serviceIcon: String {
        activeServiceType?.iconName ?? "music.note"
    }

    // MARK: - OAuth Callback Handling (Spotify)

    func handleSpotifyCallback(url: URL) async throws {
        try await spotifyAdapter.handleAuthorizationCallback(url: url)
        if activeServiceType == .spotify {
            updateAuthenticationStatus()
            updateUserProfile()
        }
    }

    func getSpotifyAuthorizationURL() -> URL? {
        return spotifyAdapter.getAuthorizationURL()
    }
}
