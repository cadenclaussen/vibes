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
    @State private var showingMusicServicePicker = false
    @State private var showingAISettings = false
    @State private var showingConcertSettings = false
    @State private var showingDeleteAccount = false
    @AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = true

    var body: some View {
        List {
            accountSection
            musicServiceSection
            aiFeaturesSection
            concertFeaturesSection
            supportSection
            aboutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSpotifyAuth) {
            SpotifyAuthView()
        }
        .sheet(isPresented: $showingAISettings) {
            AISettingsView()
        }
        .sheet(isPresented: $showingConcertSettings) {
            ConcertSettingsView()
        }
        .sheet(isPresented: $showingDeleteAccount) {
            DeleteAccountView()
        }
        .sheet(isPresented: $showingMusicServicePicker) {
            musicServicePickerSheet
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

    // MARK: - Music Service Section

    private var musicServiceSection: some View {
        Section {
            if musicServiceManager.hasSelectedService {
                HStack {
                    Image(systemName: musicServiceManager.serviceIcon)
                        .foregroundColor(musicServiceManager.serviceColor)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(musicServiceManager.serviceName)
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

                if musicServiceManager.isAuthenticated {
                    Button {
                        if musicServiceManager.activeServiceType == .spotify {
                            showingSpotifyAuth = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .frame(width: 24)
                            Text("Manage Connection")
                        }
                    }
                } else {
                    Button {
                        if musicServiceManager.activeServiceType == .spotify {
                            showingSpotifyAuth = true
                        } else {
                            Task {
                                try? await musicServiceManager.authenticate()
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "link")
                                .frame(width: 24)
                            Text("Connect \(musicServiceManager.serviceName)")
                        }
                    }
                }

                Button {
                    showingMusicServicePicker = true
                } label: {
                    HStack {
                        Image(systemName: "repeat")
                            .frame(width: 24)
                        Text("Change Music Service")
                    }
                }
            } else {
                Button {
                    showingMusicServicePicker = true
                } label: {
                    HStack {
                        Image(systemName: "music.note")
                            .frame(width: 24)
                        Text("Choose Music Service")
                    }
                }
            }
        } header: {
            Text("Music Service")
        } footer: {
            if !musicServiceManager.hasSelectedService {
                Text("Connect a music service to personalize your experience")
            }
        }
    }

    // MARK: - AI Features Section

    private var aiFeaturesSection: some View {
        let geminiService = GeminiService.shared

        return Section {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Features")
                    if geminiService.isConfigured {
                        Text("Gemini API Connected")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Not configured")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if geminiService.isConfigured {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            Button {
                showingAISettings = true
            } label: {
                HStack {
                    Image(systemName: "gearshape")
                        .frame(width: 24)
                    Text(geminiService.isConfigured ? "Manage AI Settings" : "Set Up AI Features")
                }
            }
        } header: {
            Text("AI Features")
        } footer: {
            if !geminiService.isConfigured {
                Text("Enable AI-powered playlist ideas and friend blends")
            }
        }
    }

    // MARK: - Concert Features Section

    private var concertFeaturesSection: some View {
        let ticketmasterService = TicketmasterService.shared
        let isConfigured = ticketmasterService.isConfigured && !ticketmasterService.userCity.isEmpty

        return Section {
            HStack {
                Image(systemName: "ticket.fill")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Concert Discovery")
                    if isConfigured {
                        Text("Location: \(ticketmasterService.userCity)")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Not configured")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if isConfigured {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            Button {
                showingConcertSettings = true
            } label: {
                HStack {
                    Image(systemName: "gearshape")
                        .frame(width: 24)
                    Text(isConfigured ? "Manage Concert Settings" : "Set Up Concerts")
                }
            }
        } header: {
            Text("Concerts")
        } footer: {
            if !isConfigured {
                Text("Find concerts from your top artists near you")
            }
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        Section {
            Button {
                HapticService.lightImpact()
                router.selectedTab = .home
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

    // MARK: - Music Service Picker Sheet

    private var musicServicePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                MusicServicePicker { type in
                    if type == .spotify {
                        showingMusicServicePicker = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingSpotifyAuth = true
                        }
                    } else {
                        Task {
                            try? await musicServiceManager.authenticate()
                            showingMusicServicePicker = false
                        }
                    }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Music Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingMusicServicePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
