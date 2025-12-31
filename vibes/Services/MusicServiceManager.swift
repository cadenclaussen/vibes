//
//  MusicServiceManager.swift
//  vibes
//
//  Spotify-only music service manager.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class MusicServiceManager: ObservableObject {
    static let shared = MusicServiceManager()

    @Published var isAuthenticated: Bool = false
    @Published var userProfile: UnifiedUserProfile?

    private let spotifyAdapter = SpotifyServiceAdapter.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupObservers()
        updateAuthenticationStatus()
    }

    // MARK: - Current Service Access

    var currentService: any MusicStreamingService {
        return spotifyAdapter
    }

    var capabilities: MusicServiceCapabilities {
        return .spotify
    }

    // MARK: - Authentication

    func authenticate() async throws {
        try await spotifyAdapter.authenticate()
        updateAuthenticationStatus()
        updateUserProfile()
    }

    func signOut() {
        spotifyAdapter.signOut()
        isAuthenticated = false
        userProfile = nil
    }

    func checkAuthenticationStatus() {
        spotifyAdapter.checkAuthenticationStatus()
        updateAuthenticationStatus()
        updateUserProfile()
    }

    private func updateAuthenticationStatus() {
        isAuthenticated = spotifyAdapter.isAuthenticated
    }

    private func updateUserProfile() {
        userProfile = spotifyAdapter.userProfile
    }

    // MARK: - Observers

    private func setupObservers() {
        spotifyAdapter.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAuthenticationStatus()
            }
            .store(in: &cancellables)

        spotifyAdapter.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUserProfile()
            }
            .store(in: &cancellables)
    }

    // MARK: - Convenience

    var serviceName: String { "Spotify" }
    var serviceColor: Color { .green }
    var serviceIcon: String { "music.note" }

    // MARK: - OAuth Callback

    func handleSpotifyCallback(url: URL) async throws {
        try await spotifyAdapter.handleAuthorizationCallback(url: url)
        updateAuthenticationStatus()
        updateUserProfile()
    }

    func getSpotifyAuthorizationURL() -> URL? {
        return spotifyAdapter.getAuthorizationURL()
    }
}
