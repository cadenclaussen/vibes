//
//  ProfileView.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import SwiftUI
import FirebaseAuth
import PhotosUI

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

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var spotifyService = SpotifyService.shared
    @EnvironmentObject var authManager: AuthManager
    @Binding var shouldEditProfile: Bool
    @State private var genreInput = ""
    @State private var showingSpotifyAuth = false
    @State private var selectedTimeRange: TimeRange = .mediumTerm
    @State private var topArtists: [Artist] = []
    @State private var topTracks: [Track] = []
    @State private var recentlyPlayed: [PlayHistory] = []
    @State private var isLoadingStats = false
    @State private var statsError: String?
    @State private var achievements: [Achievement] = []
    @State private var showingAllAchievements = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isUploadingPhoto = false
    @State private var photoUploadError: String?

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Profile")
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
            Task {
                await loadStats()
            }
        }
        .onDisappear {
            if viewModel.isEditing {
                Task {
                    await viewModel.updateProfile()
                }
            }
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
        } catch {
            statsError = error.localizedDescription
        }

        isLoadingStats = false
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
                    Task {
                        await viewModel.updateProfile()
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
        ScrollView {
            VStack(spacing: 24) {
                profileHeader(profile)
                spotifySection

                if spotifyService.isAuthenticated {
                    musicPersonalitySection
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

                genresSection(profile)
                achievementsSection(profile)
                infoSection(profile)

                if let error = viewModel.errorMessage {
                    errorSection(error)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingSpotifyAuth) {
            SpotifyAuthView()
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

            if let error = photoUploadError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

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

    @ViewBuilder
    private func profilePictureView(_ profile: UserProfile) -> some View {
        ZStack {
            if let urlString = profile.profilePictureURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderImage
                    case .empty:
                        ProgressView()
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                placeholderImage
            }

            if viewModel.isEditing {
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 100, height: 100)

                if isUploadingPhoto {
                    ProgressView()
                        .tint(.white)
                } else {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 4) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Change")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            await handlePhotoSelection(newItem)
                        }
                    }
                }
            }
        }
    }

    private var placeholderImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(Color(.tertiaryLabel))
    }

    private func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item = item,
              let userId = authManager.user?.uid else { return }

        isUploadingPhoto = true
        photoUploadError = nil

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                photoUploadError = "Failed to load image"
                isUploadingPhoto = false
                return
            }

            let downloadURL = try await StorageService.shared.uploadProfilePicture(
                userId: userId,
                imageData: data
            )

            try await FirestoreService.shared.updateProfilePictureURL(
                userId: userId,
                url: downloadURL
            )

            await viewModel.loadProfile()
        } catch {
            photoUploadError = "Upload failed: \(error.localizedDescription)"
        }

        isUploadingPhoto = false
        selectedPhotoItem = nil
    }

    private func infoSection(_ profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            infoRow(label: "Email", value: profile.email)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
                Text("No genres added yet")
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

            HStack {
                TextField("Add genre", text: $genreInput)
                    .textFieldStyle(.roundedBorder)
                Button(action: addGenre) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(genreInput.isEmpty)
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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

        stats.genresCount = profile.musicTasteTags.count
        stats.isSpotifyConnected = spotifyService.isAuthenticated

        // Load actual stats from Firestore
        do {
            let firestoreStats = try await FirestoreService.shared.getAchievementStats(userId: profile.uid)
            stats.songsShared = firestoreStats.songsShared
            stats.playlistsShared = firestoreStats.playlistsShared
            stats.friendsCount = firestoreStats.friendsCount
            stats.maxVibestreak = firestoreStats.maxVibestreak
        } catch {
            print("Failed to load achievement stats: \(error)")
        }

        achievements = stats.buildAchievements()
    }

    // MARK: - Stats Sections

    private var timeRangePickerSection: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.displayName).tag(range)
            }
        }
        .pickerStyle(.segmented)
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
                        TopArtistCell(artist: artist)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
                        TopTrackRow(rank: index + 1, track: track)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
                        ForEach(recentlyPlayed, id: \.track.id) { history in
                            RecentlyPlayedCell(playHistory: history)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Error Section

    private func errorSection(_ error: String) -> some View {
        Text(error)
            .font(.caption)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }

    private func addGenre() {
        let trimmed = genreInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !viewModel.musicTasteTags.contains(trimmed) else { return }
        viewModel.musicTasteTags.append(trimmed)
        genreInput = ""
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

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color(.secondaryLabel))
                .frame(width: 20)

            if let imageUrl = track.album.images.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
                .frame(width: 40, height: 40)
                .cornerRadius(4)
            } else {
                Image(systemName: "music.note")
                    .frame(width: 40, height: 40)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(4)
            }

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
    }
}

struct RecentlyPlayedCell: View {
    let playHistory: PlayHistory

    var body: some View {
        VStack(spacing: 6) {
            if let imageUrl = playHistory.track.album.images.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Image(systemName: "music.note")
                    .font(.title)
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(width: 80, height: 80)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
            }

            VStack(spacing: 2) {
                Text(playHistory.track.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(playHistory.track.artists.first?.name ?? "")
                    .font(.caption2)
                    .foregroundColor(Color(.secondaryLabel))
                    .lineLimit(1)
            }
        }
        .frame(width: 80)
    }
}

#Preview {
    ProfileView(shouldEditProfile: .constant(false))
        .environmentObject(AuthManager.shared)
}
