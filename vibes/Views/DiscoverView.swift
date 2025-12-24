//
//  DiscoverView.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = DiscoverViewModel()
    @StateObject private var spotifyService = SpotifyService.shared
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @StateObject private var geminiService = GeminiService.shared
    @StateObject private var ticketmasterService = TicketmasterService.shared
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool
    @State private var showPlaylistRecommendations = false
    @State private var showConcertSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    Text("Discover")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if !spotifyService.isAuthenticated {
                        connectSpotifySection
                    } else if viewModel.isLoading {
                        loadingSection
                    } else {
                        if !viewModel.recentlyActiveFriends.isEmpty {
                            recentlyActiveSection
                        }

                        // Show New Releases if we have data OR if still loading
                        if !viewModel.newReleases.isEmpty || viewModel.isLoadingNewReleases {
                            newReleasesSection
                        }

                        // Show For You if we have data OR if still loading
                        if !viewModel.recommendations.isEmpty || viewModel.isLoadingRecommendations {
                            forYouSection
                        }

                        // AI Playlist Ideas section
                        if geminiService.isConfigured || spotifyService.isAuthenticated {
                            aiPlaylistSection
                        }

                        // Upcoming Concerts section
                        if ticketmasterService.isConfigured || spotifyService.isAuthenticated {
                            concertsSection
                        }

                        if !viewModel.trendingSongs.isEmpty || viewModel.isLoadingTrending {
                            trendingSection
                        }

                        // Only show empty state if nothing is loading and everything is empty
                        let nothingLoading = !viewModel.isLoadingNewReleases &&
                                           !viewModel.isLoadingRecommendations &&
                                           !viewModel.isLoadingTrending
                        if nothingLoading &&
                           viewModel.recentlyActiveFriends.isEmpty &&
                           viewModel.newReleases.isEmpty &&
                           viewModel.recommendations.isEmpty &&
                           viewModel.trendingSongs.isEmpty {
                            emptyStateSection
                        }
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SettingsMenu(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                }
            }
            .refreshable {
                await viewModel.loadAllData()
            }
        }
        .task {
            await viewModel.loadAllData()
        }
        .onChange(of: spotifyService.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task {
                    await viewModel.loadAllData()
                }
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
        .sheet(isPresented: $showPlaylistRecommendations) {
            PlaylistRecommendationsView()
        }
        .sheet(isPresented: $showConcertSettings) {
            ConcertSettingsView()
        }
        .onChange(of: ticketmasterService.isConfigured) { _, isConfigured in
            if isConfigured {
                Task {
                    await viewModel.loadUpcomingConcerts()
                }
            }
        }
        .onChange(of: ticketmasterService.userCity) { _, _ in
            if ticketmasterService.isConfigured {
                Task {
                    await viewModel.loadUpcomingConcerts()
                }
            }
        }
    }

    // MARK: - Connect Spotify Section

    private var connectSpotifySection: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 50))
                .foregroundColor(.green)

            Text("Connect Spotify")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Connect your Spotify account to discover new music and see what your friends are listening to.")
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)

            Button {
                selectedTab = 3  // Go to Profile tab
            } label: {
                Text("Go to Profile")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Loading Section

    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading your personalized feed...")
                .font(.caption)
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Empty State Section

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 50))
                .foregroundColor(Color(.tertiaryLabel))

            Text("Nothing to show yet")
                .font(.headline)

            Text("Start sharing songs with friends to see trending music here!")
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Recently Active Section

    private var recentlyActiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Active")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recentlyActiveFriends) { friend in
                        RecentlyActiveFriendCard(friend: friend)
                    }
                }
            }
        }
    }

    // MARK: - New Releases Section

    private var newReleasesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Releases")
                .font(.headline)

            if viewModel.isLoadingNewReleases && viewModel.newReleases.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 180)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.newReleases) { album in
                            NavigationLink(destination: AlbumDetailView(album: album)) {
                                NewReleaseCard(album: album)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - For You Section

    private var forYouSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("For You")
                    .font(.headline)
                Spacer()
                Text("Popular from your top artists")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            if viewModel.isLoadingRecommendations && viewModel.recommendations.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 100)
                .padding()
                .cardStyle()
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.recommendations) { track in
                        RecommendationRow(track: track)
                    }
                }
                .padding()
                .cardStyle()
            }
        }
    }

    // MARK: - Trending Section

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trending Among Friends")
                    .font(.headline)
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
            }

            if viewModel.isLoadingTrending && viewModel.trendingSongs.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 100)
                .padding()
                .cardStyle()
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.trendingSongs) { song in
                        TrendingSongRow(song: song)
                    }
                }
                .padding()
                .cardStyle()
            }
        }
    }

    // MARK: - AI Features Section

    private var aiPlaylistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("AI Features")
                    .font(.headline)
                Spacer()
            }

            if geminiService.isConfigured {
                // AI Playlist Card
                NavigationLink(destination: AIPlaylistView()) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)

                            Image(systemName: "wand.and.stars")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Generate Playlist Ideas")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(.label))

                            Text("Get personalized themes based on your listening")
                                .font(.caption)
                                .foregroundColor(Color(.secondaryLabel))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .padding()
                    .cardStyle()
                }
                .buttonStyle(.plain)

                // Grow Your Playlists Card
                Button {
                    showPlaylistRecommendations = true
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.green.opacity(0.3), .teal.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)

                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Grow Your Playlists")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(.label))

                            Text("Get AI song suggestions for any playlist")
                                .font(.caption)
                                .foregroundColor(Color(.secondaryLabel))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .padding()
                    .cardStyle()
                }
                .buttonStyle(.plain)

                // Friend Blend Section
                if !viewModel.blendableFriends.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Blend with a Friend")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color(.secondaryLabel))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.blendableFriends.prefix(8)) { blendable in
                                    NavigationLink(destination: FriendBlendView(friend: blendable.friend)) {
                                        BlendFriendCard(blendable: blendable)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundColor(.purple)

                    Text("Set up AI Features")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Add your Gemini API key to get personalized AI-generated playlists and friend blends")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)

                    Text("Settings > AI Features")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .cardStyle()
            }
        }
    }

    // MARK: - Concerts Section

    private var concertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "ticket.fill")
                    .foregroundColor(.orange)
                Text("Upcoming Concerts")
                    .font(.headline)
                Spacer()
            }

            if ticketmasterService.isConfigured && !ticketmasterService.userCity.isEmpty {
                if viewModel.isLoadingConcerts && viewModel.upcomingConcerts.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .frame(height: 100)
                    .padding()
                    .cardStyle()
                } else if viewModel.upcomingConcerts.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "music.mic")
                            .font(.title)
                            .foregroundColor(Color(.tertiaryLabel))
                        Text("No upcoming concerts found")
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))
                        Text("We'll keep checking for your top artists near \(ticketmasterService.userCity)")
                            .font(.caption)
                            .foregroundColor(Color(.tertiaryLabel))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cardStyle()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.upcomingConcerts) { concert in
                                ConcertCard(concert: concert)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "ticket.fill")
                        .font(.title)
                        .foregroundColor(.orange)

                    Text("Find Concerts Near You")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Get notified about upcoming shows from your favorite artists")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)

                    Button {
                        showConcertSettings = true
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Set Up Concerts")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .cardStyle()
            }
        }
    }
}

#Preview {
    DiscoverView(selectedTab: .constant(0), shouldEditProfile: .constant(false))
        .environmentObject(AuthManager.shared)
}
