//
//  SettingsView.swift
//  vibes
//
//  Settings page for account and app configuration.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var spotifyService = SpotifyService.shared
    @StateObject private var musicServiceManager = MusicServiceManager.shared
    @State private var showingSpotifyAuth = false
    @State private var showingConcertSettings = false
    @State private var showingDeleteAccount = false
    @AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = true

    var body: some View {
        List {
            accountSection
            spotifySection
            concertFeaturesSection
            supportSection
            aboutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSpotifyAuth) {
            SpotifyAuthView()
        }
        .sheet(isPresented: $showingConcertSettings) {
            ConcertSettingsView()
        }
        .sheet(isPresented: $showingDeleteAccount) {
            DeleteAccountView()
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        Section {
            Button {
                do {
                    try authManager.signOut()
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.primary)
                        .frame(width: 24)
                    Text("Sign Out")
                        .foregroundColor(.primary)
                }
            }

            Button {
                showingDeleteAccount = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    Text("Delete Account")
                        .foregroundColor(.red)
                }
            }
        } header: {
            Text("Account")
        }
    }

    // MARK: - Spotify Section

    private var spotifySection: some View {
        Section {
            HStack {
                Image(systemName: "music.note")
                    .foregroundColor(.green)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spotify")
                    if musicServiceManager.isAuthenticated {
                        if let profile = musicServiceManager.userProfile {
                            Text("Connected as \(profile.displayName ?? "User")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Connected")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("Not connected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if musicServiceManager.isAuthenticated {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            Button {
                showingSpotifyAuth = true
            } label: {
                HStack {
                    Image(systemName: musicServiceManager.isAuthenticated ? "arrow.triangle.2.circlepath" : "link")
                        .frame(width: 24)
                    Text(musicServiceManager.isAuthenticated ? "Manage Connection" : "Connect Spotify")
                }
            }
        } header: {
            Text("Music Service")
        } footer: {
            if !musicServiceManager.isAuthenticated {
                Text("Connect Spotify to personalize your experience")
            }
        }
    }

    // MARK: - Concert Features Section

    private var concertFeaturesSection: some View {
        let ticketmasterService = TicketmasterService.shared
        let hasCity = !ticketmasterService.userCity.isEmpty

        return Section {
            HStack {
                Image(systemName: "ticket.fill")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Concert Discovery")
                    if hasCity {
                        Text("Location: \(ticketmasterService.userCity)")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Set your city")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if hasCity {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            Button {
                showingConcertSettings = true
            } label: {
                HStack {
                    Image(systemName: hasCity ? "pencil" : "location.fill")
                        .frame(width: 24)
                    Text(hasCity ? "Change City" : "Set Your City")
                }
            }
        } header: {
            Text("Concerts")
        } footer: {
            if !hasCity {
                Text("Set your city to discover concerts from your top artists")
            }
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        Section {
            Button {
                HapticService.lightImpact()
                router.selectedTab = .feed
                hasCompletedTutorial = false
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "play.circle")
                        .frame(width: 24)
                    Text("Replay Tutorial")
                }
            }
        } header: {
            Text("Support")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}
