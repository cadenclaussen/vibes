//
//  ProfileView.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import SwiftUI
import FirebaseAuth

enum TimeRange: String, CaseIterable {
    case shortTerm = "short_term"
    case mediumTerm = "medium_term"
    case longTerm = "long_term"

    var displayName: String {
        switch self {
        case .shortTerm: return "4 Weeks"
        case .mediumTerm: return "6 Months"
        case .longTerm: return "All Time"
        }
    }
}

enum SettingsTab: String, CaseIterable {
    case profile = "Profile"
    case stats = "Stats"
    case achievements = "Achievements"
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var spotifyService = SpotifyService.shared
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @EnvironmentObject var authManager: AuthManager
    @Binding var shouldEditProfile: Bool
    @State private var showingGenrePicker = false
    @State private var showingSpotifyAuth = false
    @State private var selectedTimeRange: TimeRange = .mediumTerm
    @State private var topArtists: [Artist] = []
    @State private var topTracks: [Track] = []
    @State private var recentlyPlayed: [PlayHistory] = []
    @State private var isLoadingStats = false
    @State private var statsError: String?
    @State private var achievements: [Achievement] = []
    @State private var showingAllAchievements = false
    @State private var trackToSend: Track?
    @State private var trackToAddToPlaylist: Track?
    @State private var previewUrlForSend: String?
    @State private var showingAISettings = false
    @State private var iTunesPreviews: [String: String] = [:]
    @State private var selectedSettingsTab: SettingsTab = .profile
    private let itunesService = iTunesService.shared

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Settings")
                .toolbar {
                    if viewModel.profile != nil {
                        toolbarContent
                    }
                }
        }
        .task {
            await viewModel.loadProfile()
            await loadStats()
        }
        .onChange(of: shouldEditProfile) { _, newValue in
            if newValue && !viewModel.isEditing {
                viewModel.toggleEditMode()
                shouldEditProfile = false
            }
        }
        .onChange(of: selectedTimeRange) { _, _ in
            HapticService.selectionChanged()
            Task {
                await loadStats()
            }
        }
        .onChange(of: selectedSettingsTab) { _, _ in
            HapticService.selectionChanged()
        }
        .onDisappear {
            if viewModel.isEditing {
                Task {
                    await viewModel.updateProfile()
                }
            }
            audioPlayer.stop()
        }
    }

    private func loadStats() async {
        guard spotifyService.isAuthenticated else { return }

        isLoadingStats = true
        statsError = nil

        do {
            async let artists = spotifyService.getTopArtists(timeRange: selectedTimeRange.rawValue, limit: 6)
            async let tracks = spotifyService.getTopTracks(timeRange: selectedTimeRange.rawValue, limit: 10)
            async let recent = spotifyService.getRecentlyPlayed(limit: 10)

            topArtists = try await artists
            topTracks = try await tracks
            recentlyPlayed = try await recent

            // Sync top artists to profile for compatibility calculations
            // Use medium_term data as the best representation of taste
            if selectedTimeRange == .mediumTerm, let userId = authManager.user?.uid {
                let artistNames = topArtists.map { $0.name }
                try? await FirestoreService.shared.syncTopArtistsToProfile(userId: userId, artists: artistNames)
            }

            await fetchItunesPreviews()
        } catch {
            statsError = error.localizedDescription
        }

        isLoadingStats = false
    }

    private func fetchItunesPreviews() async {
        var allTracks: [(id: String, name: String, artist: String)] = []

        for track in topTracks where track.previewUrl == nil {
            allTracks.append((id: track.id, name: track.name, artist: track.artists.first?.name ?? ""))
        }

        for history in recentlyPlayed where history.track.previewUrl == nil {
            let track = history.track
            if !allTracks.contains(where: { $0.id == track.id }) {
                allTracks.append((id: track.id, name: track.name, artist: track.artists.first?.name ?? ""))
            }
        }

        if !allTracks.isEmpty {
            let previews = await itunesService.searchPreviews(for: allTracks)
            iTunesPreviews = previews
        }
    }

    private func getPreviewUrl(for track: Track) -> String? {
        return track.previewUrl ?? iTunesPreviews[track.id]
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if viewModel.isEditing {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    viewModel.cancelEdit()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    HapticService.lightImpact()
                    Task {
                        await viewModel.updateProfile()
                        HapticService.success()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                SettingsMenu(selectedTab: .constant(3), shouldEditProfile: $shouldEditProfile)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let profile = viewModel.profile {
            profileContent(profile)
        } else {
            errorStateView
        }
    }

    private var errorStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Failed to load profile")
                .foregroundColor(Color(.secondaryLabel))
            Spacer()
        }
        .padding()
    }

    private func profileContent(_ profile: UserProfile) -> some View {
        VStack(spacing: 0) {
            settingsTabPicker
                .padding(.horizontal)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 24) {
                    switch selectedSettingsTab {
                    case .achievements:
                        achievementsTabContent(profile)
                    case .stats:
                        statsTabContent
                    case .profile:
                        profileTabContent(profile)
                    }

                    if let error = viewModel.errorMessage {
                        errorSection(error)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingSpotifyAuth) {
            SpotifyAuthView()
        }
        .sheet(item: $trackToSend) { track in
            FriendPickerView(
                track: track,
                previewUrl: previewUrlForSend
            )
        }
        .sheet(item: $trackToAddToPlaylist) { track in
            PlaylistPickerView(
                trackUri: "spotify:track:\(track.id)",
                trackName: track.name,
                artistName: track.artists.map { $0.name }.joined(separator: ", "),
                albumArtUrl: track.album.images.first?.url,
                onAdded: {}
            )
        }
        .sheet(isPresented: $showingAISettings) {
            AISettingsView()
        }
    }

    private var settingsTabPicker: some View {
        Picker("Settings Tab", selection: $selectedSettingsTab) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Achievements Tab

    private func achievementsTabContent(_ profile: UserProfile) -> some View {
        VStack(spacing: 24) {
            achievementsSection(profile)
        }
    }

    // MARK: - Stats Tab

    private var statsTabContent: some View {
        VStack(spacing: 24) {
            if !spotifyService.isAuthenticated {
                statsNotConnectedView
            } else {
                timeRangePickerSection
                if isLoadingStats {
                    statsLoadingSection
                } else if let error = statsError {
                    statsErrorSection(error)
                } else {
                    topArtistsSection
                    topTracksSection
                    recentlyPlayedSection
                }
            }
        }
    }

    private var statsNotConnectedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundColor(Color(.tertiaryLabel))
            Text("Connect Spotify to see your stats")
                .font(.headline)
                .foregroundColor(Color(.secondaryLabel))
            Text("View your top artists, top songs, and recently played tracks")
                .font(.caption)
                .foregroundColor(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
            Button {
                showingSpotifyAuth = true
            } label: {
                HStack {
                    Image(systemName: "music.note")
                    Text("Connect Spotify")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Profile Tab

    private func profileTabContent(_ profile: UserProfile) -> some View {
        VStack(spacing: 24) {
            profileHeader(profile)
            spotifySection
            aiFeaturesSection
            if spotifyService.isAuthenticated {
                musicPersonalitySection
            }
            genresSection(profile)
            infoSection(profile)
        }
    }

    private func profileHeader(_ profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            profilePictureView(profile)

            if viewModel.isEditing {
                TextField("Display Name", text: $viewModel.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 32)
            } else {
                Text(profile.displayName)
                    .font(.title)
                    .fontWeight(.bold)
            }

            Text("@\(profile.username)")
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))

            if !viewModel.isEditing {
                Button {
                    viewModel.toggleEditMode()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("Edit Profile")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
                .padding(.top, 8)
            }
        }
    }

    private func profilePictureView(_ profile: UserProfile) -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(Color(.tertiaryLabel))
    }

    private func infoSection(_ profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            infoRow(label: "Email", value: profile.email)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
        
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(Color(.secondaryLabel))

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(Color(.label))
        }
    }

    private var spotifySection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "music.note")
                    .foregroundColor(.green)
                Text("Spotify")
                    .font(.headline)

                Spacer()

                if spotifyService.isAuthenticated {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            if spotifyService.isAuthenticated {
                if let profile = spotifyService.userProfile {
                    HStack {
                        Text("Connected as")
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                        Text(profile.displayName ?? profile.id)
                            .font(.caption)
                            .foregroundColor(Color(.label))
                        Spacer()
                    }
                }

                Button {
                    showingSpotifyAuth = true
                } label: {
                    Text("Manage Connection")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Button {
                    showingSpotifyAuth = true
                } label: {
                    HStack {
                        Image(systemName: "music.note")
                        Text("Connect Spotify")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
        
    }

    private var aiFeaturesSection: some View {
        let geminiService = GeminiService.shared

        return VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("AI Features")
                    .font(.headline)

                Spacer()

                if geminiService.isConfigured {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            if geminiService.isConfigured {
                HStack {
                    Text("Gemini API")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                    Text("Connected")
                        .font(.caption)
                        .foregroundColor(Color(.label))
                    Spacer()
                }

                Button {
                    showingAISettings = true
                } label: {
                    Text("Manage AI Settings")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Enable AI-powered playlist ideas and friend blends")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))

                Button {
                    showingAISettings = true
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Set Up AI Features")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
        
    }

    private func genresSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorite Genres")
                .font(.headline)

            if viewModel.isEditing {
                editingGenresView
            } else {
                displayGenresView(profile)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
        
    }

    private func displayGenresView(_ profile: UserProfile) -> some View {
        Group {
            if profile.musicTasteTags.isEmpty {
                Text("No genres added yet")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(profile.musicTasteTags, id: \.self) { genre in
                        Text(genre)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(16)
                    }
                }
            }
        }
    }

    private var editingGenresView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.musicTasteTags.isEmpty {
                Text("No genres selected")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.musicTasteTags, id: \.self) { genre in
                        HStack(spacing: 4) {
                            Text(genre)
                                .font(.caption)
                            Button(action: {
                                viewModel.musicTasteTags.removeAll { $0 == genre }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(16)
                    }
                }
            }

            Button {
                showingGenrePicker = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Genres")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .sheet(isPresented: $showingGenrePicker) {
                GenrePickerView(selectedGenres: $viewModel.musicTasteTags)
            }
        }
    }

    // MARK: - Music Personality Section

    private var musicPersonalitySection: some View {
        MusicPersonalityCardView()
    }

    // MARK: - Achievements Section

    private func achievementsSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)

                Spacer()

                let unlockedCount = achievements.filter { $0.isUnlocked }.count
                Text("\(unlockedCount)/\(achievements.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button {
                    showingAllAchievements = true
                } label: {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            if achievements.isEmpty {
                Text("Loading achievements...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                AchievementsGridView(achievements: achievements)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
        
        .sheet(isPresented: $showingAllAchievements) {
            NavigationStack {
                AchievementsListView(achievements: achievements)
                    .navigationTitle("Achievements")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showingAllAchievements = false
                            }
                        }
                    }
            }
        }
        .task {
            await loadAchievements(profile)
        }
    }

    private func loadAchievements(_ profile: UserProfile) async {
        var stats = AchievementStats()

        let genresCount = profile.musicTasteTags.count
        let isSpotifyConnected = spotifyService.isAuthenticated
        let isAIConfigured = !(UserDefaults.standard.string(forKey: "gemini_api_key") ?? "").isEmpty

        stats.genresCount = genresCount
        stats.isSpotifyConnected = isSpotifyConnected
        stats.isAIConfigured = isAIConfigured

        // Load actual stats from Firestore
        var songsShared = 0
        var playlistsShared = 0
        var friendsCount = 0
        var maxVibestreak = 0
        var reactionsReceived = 0

        do {
            let firestoreStats = try await FirestoreService.shared.getAchievementStats(userId: profile.uid)
            songsShared = firestoreStats.songsShared
            playlistsShared = firestoreStats.playlistsShared
            friendsCount = firestoreStats.friendsCount
            maxVibestreak = firestoreStats.maxVibestreak
            reactionsReceived = firestoreStats.reactionsReceived

            stats.songsShared = songsShared
            stats.playlistsShared = playlistsShared
            stats.friendsCount = friendsCount
            stats.maxVibestreak = maxVibestreak
            stats.reactionsReceived = reactionsReceived
        } catch {
            print("Failed to load achievement stats: \(error)")
        }

        // Cache Firestore stats for future local achievement checks
        LocalAchievementStats.shared.cacheFirestoreStats(
            songsShared: songsShared,
            playlistsShared: playlistsShared,
            friendsCount: friendsCount,
            maxVibestreak: maxVibestreak,
            reactionsReceived: reactionsReceived,
            genresCount: genresCount,
            isSpotifyConnected: isSpotifyConnected,
            isAIConfigured: isAIConfigured
        )

        // Load local stats (playlist adds, preview plays, etc.)
        stats.loadLocalStats()

        achievements = stats.buildAchievements()

        // Check for newly unlocked achievements and show banner
        AchievementNotificationService.shared.checkForNewAchievements(achievements)
    }

    // MARK: - Stats Sections

    private var timeRangePickerSection: some View {
        HStack {
            Text("Time Range")
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))
            Spacer()
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.displayName).tag(range)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
        .cardStyle()
        
    }

    private var statsLoadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading your stats...")
                .font(.caption)
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func statsErrorSection(_ error: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            Text("Failed to load stats")
                .font(.headline)
            Text(error)
                .font(.caption)
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task {
                    await loadStats()
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
        
    }

    private var topArtistsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Artists")
                .font(.headline)

            if topArtists.isEmpty {
                Text("No top artists data available")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(topArtists) { artist in
                        NavigationLink(destination: ArtistDetailView(artist: artist)) {
                            TopArtistCell(artist: artist)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
        
    }

    private var topTracksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Songs")
                .font(.headline)

            if topTracks.isEmpty {
                Text("No top tracks data available")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(topTracks.enumerated()), id: \.element.id) { index, track in
                        TopTrackRow(
                            rank: index + 1,
                            track: track,
                            previewUrl: getPreviewUrl(for: track),
                            onSendTapped: { trackToSend = $0 },
                            onAddToPlaylistTapped: { trackToAddToPlaylist = $0 }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
        
    }

    private var recentlyPlayedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Played")
                .font(.headline)

            if recentlyPlayed.isEmpty {
                Text("No recent plays")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(recentlyPlayed.enumerated()), id: \.offset) { index, history in
                            RecentlyPlayedCell(
                                playHistory: history,
                                index: index,
                                previewUrl: getPreviewUrl(for: history.track),
                                onSendTapped: { trackToSend = $0 },
                                onAddToPlaylistTapped: { trackToAddToPlaylist = $0 }
                            )
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
        
    }

    // MARK: - Error Section

    private func errorSection(_ error: String) -> some View {
        Text(error)
            .font(.caption)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .cardStyle()
            
    }

}

// MARK: - Helper Views

struct TopArtistCell: View {
    let artist: Artist

    var body: some View {
        VStack(spacing: 6) {
            if let imageUrl = artist.images?.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Image(systemName: "music.mic")
                    .font(.title)
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(width: 80, height: 80)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Circle())
            }

            Text(artist.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TopTrackRow: View {
    let rank: Int
    let track: Track
    var previewUrl: String?
    var onSendTapped: ((Track) -> Void)?
    var onAddToPlaylistTapped: ((Track) -> Void)?
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var showNoPreviewAlert = false

    // Use rank + track.id for unique identifier to handle duplicates
    private var uniqueTrackId: String {
        "top-\(rank)-\(track.id)"
    }

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == uniqueTrackId
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    private var hasPreview: Bool {
        previewUrl != nil
    }

    private var spotifyUrl: URL? {
        URL(string: "https://open.spotify.com/track/\(track.id)")
    }

    var body: some View {
        Button {
            HapticService.lightImpact()
            if let url = previewUrl {
                audioPlayer.playUrl(url, trackId: uniqueTrackId)
            } else {
                showNoPreviewAlert = true
            }
        } label: {
            HStack(spacing: 12) {
                Text("\(rank)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(width: 20)

                albumArtView

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Text(track.artists.map { $0.name }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(1)
                }

                Spacer()
            }
            .contentShape(Rectangle())
            .opacity(hasPreview ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                HapticService.lightImpact()
                onSendTapped?(track)
            } label: {
                Label("Send to Friend", systemImage: "paperplane")
            }

            Button {
                HapticService.lightImpact()
                onAddToPlaylistTapped?(track)
            } label: {
                Label("Add to Playlist", systemImage: "plus.circle")
            }

            if let url = spotifyUrl {
                Button {
                    HapticService.lightImpact()
                    UIApplication.shared.open(url)
                } label: {
                    Label("Open in Spotify", systemImage: "arrow.up.right")
                }
            }
        }
        .alert("No Preview Available", isPresented: $showNoPreviewAlert) {
            if let url = spotifyUrl {
                Button("Open in Spotify") {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("This track doesn't have a preview. Open it in Spotify to listen.")
        }
    }

    private var albumArtView: some View {
        ZStack {
            if let imageUrl = track.album.images.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
            } else {
                Image(systemName: "music.note")
                    .foregroundColor(Color(.tertiaryLabel))
            }

            if hasPreview {
                Color.black.opacity(isCurrentTrack ? 0.4 : 0)
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .opacity(isCurrentTrack ? 1 : 0)
            }

            if isCurrentTrack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * audioPlayer.playbackProgress, height: 2)
                }
                .frame(height: 2)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(width: 40, height: 40)
        .cornerRadius(4)
        .clipped()
    }
}

struct RecentlyPlayedCell: View {
    let playHistory: PlayHistory
    let index: Int
    var previewUrl: String?
    var onSendTapped: ((Track) -> Void)?
    var onAddToPlaylistTapped: ((Track) -> Void)?
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var showNoPreviewAlert = false

    private var track: Track {
        playHistory.track
    }

    // Use index for unique identifier to handle same song played multiple times
    private var uniqueTrackId: String {
        "recent-\(index)-\(track.id)"
    }

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == uniqueTrackId
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    private var hasPreview: Bool {
        previewUrl != nil
    }

    private var spotifyUrl: URL? {
        URL(string: "https://open.spotify.com/track/\(track.id)")
    }

    var body: some View {
        Button {
            HapticService.lightImpact()
            if let url = previewUrl {
                audioPlayer.playUrl(url, trackId: uniqueTrackId)
            } else {
                showNoPreviewAlert = true
            }
        } label: {
            VStack(spacing: 6) {
                albumArtView

                VStack(spacing: 2) {
                    Text(track.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Text(track.artists.first?.name ?? "")
                        .font(.caption2)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(1)
                }
            }
            .frame(width: 80)
            .contentShape(Rectangle())
            .opacity(hasPreview ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                HapticService.lightImpact()
                onSendTapped?(track)
            } label: {
                Label("Send to Friend", systemImage: "paperplane")
            }

            Button {
                HapticService.lightImpact()
                onAddToPlaylistTapped?(track)
            } label: {
                Label("Add to Playlist", systemImage: "plus.circle")
            }

            if let url = spotifyUrl {
                Button {
                    HapticService.lightImpact()
                    UIApplication.shared.open(url)
                } label: {
                    Label("Open in Spotify", systemImage: "arrow.up.right")
                }
            }
        }
        .alert("No Preview Available", isPresented: $showNoPreviewAlert) {
            if let url = spotifyUrl {
                Button("Open in Spotify") {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("This track doesn't have a preview. Open it in Spotify to listen.")
        }
    }

    private var albumArtView: some View {
        ZStack {
            if let imageUrl = track.album.images.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
            } else {
                Image(systemName: "music.note")
                    .font(.title)
                    .foregroundColor(Color(.tertiaryLabel))
                    .background(Color(.tertiarySystemBackground))
            }

            if hasPreview {
                Color.black.opacity(isCurrentTrack ? 0.4 : 0)
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                    .opacity(isCurrentTrack ? 1 : 0)
            }

            if isCurrentTrack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * audioPlayer.playbackProgress, height: 3)
                }
                .frame(height: 3)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(width: 80, height: 80)
        .cornerRadius(8)
        .clipped()
    }
}

#Preview {
    ProfileView(shouldEditProfile: .constant(false))
        .environmentObject(AuthManager.shared)
}
