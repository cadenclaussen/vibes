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
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool
    @State private var showPlaylistRecommendations = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
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

                        // AI-Powered Recommendations section
                        if !viewModel.aiRecommendations.isEmpty || viewModel.isLoadingAIRecommendations {
                            aiRecommendationsSection
                        }

                        // AI Playlist Ideas section
                        if geminiService.isConfigured || spotifyService.isAuthenticated {
                            aiPlaylistSection
                        }

                        if !viewModel.trendingSongs.isEmpty || viewModel.isLoadingTrending {
                            trendingSection
                        }

                        // Only show empty state if nothing is loading and everything is empty
                        let nothingLoading = !viewModel.isLoadingNewReleases &&
                                           !viewModel.isLoadingRecommendations &&
                                           !viewModel.isLoadingTrending &&
                                           !viewModel.isLoadingAIRecommendations
                        if nothingLoading &&
                           viewModel.recentlyActiveFriends.isEmpty &&
                           viewModel.newReleases.isEmpty &&
                           viewModel.recommendations.isEmpty &&
                           viewModel.trendingSongs.isEmpty &&
                           viewModel.aiRecommendations.isEmpty {
                            emptyStateSection
                        }
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
            }
            .navigationTitle("Discover")
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
        .onChange(of: geminiService.isConfigured) { _, isConfigured in
            if isConfigured {
                Task {
                    await viewModel.loadAIRecommendations()
                }
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
        .sheet(isPresented: $showPlaylistRecommendations) {
            PlaylistRecommendationsView()
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
                .coachMarkTarget("section_forYou")
            }
        }
    }

    // MARK: - AI Recommendations Section

    private var aiRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("AI Picks For You")
                    .font(.headline)
                Spacer()
                if viewModel.isLoadingAIRecommendations {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            if !viewModel.aiRecommendationsReason.isEmpty {
                Text(viewModel.aiRecommendationsReason)
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            if viewModel.aiRecommendations.isEmpty && viewModel.isLoadingAIRecommendations {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
                .frame(height: 100)
                .cardStyle()
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.aiRecommendations) { resolved in
                        AIRecommendationRow(resolved: resolved) {
                            withAnimation {
                                viewModel.dismissAIRecommendation(resolved)
                            }
                        }
                    }
                }
                .padding()
                .cardStyle()
                .coachMarkTarget("section_aiPicks")
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
        .coachMarkTarget("section_aiFeatures")
    }
}

// MARK: - Blend Friend Card

struct BlendFriendCard: View {
    let blendable: BlendableFriend

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)

                if let urlString = blendable.friend.profilePictureURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.purple)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.purple)
                }

                // Blend icon overlay
                Circle()
                    .fill(Color.purple)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "wand.and.stars")
                            .font(.caption2)
                            .foregroundColor(.white)
                    )
                    .offset(x: 24, y: 24)
            }

            Text(blendable.friend.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundColor(Color(.label))

            if blendable.messageCount > 0 {
                Text("\(blendable.messageCount) msgs")
                    .font(.caption2)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .frame(width: 80)
    }
}

// MARK: - Helper Views

struct RecentlyActiveFriendCard: View {
    let friend: RecentlyActiveFriend

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                if let albumArt = friend.lastSharedAlbumArt,
                   let url = URL(string: albumArt) {
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
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(width: 80, height: 80)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)
                }

                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .offset(x: 2, y: 2)
            }

            VStack(spacing: 2) {
                Text(friend.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if let song = friend.lastSharedSong {
                    Text(song)
                        .font(.caption2)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(1)
                }
            }
        }
        .frame(width: 80)
    }
}

struct NewReleaseCard: View {
    let album: Album

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let imageUrl = album.images.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
                .frame(width: 140, height: 140)
                .cornerRadius(8)
            } else {
                Image(systemName: "music.note")
                    .font(.title)
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(width: 140, height: 140)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(album.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(album.releaseDate.prefix(4))  // Just the year
                    .font(.caption2)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .frame(width: 140)
    }
}

struct RecommendationRow: View {
    let track: Track
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @ObservedObject var spotifyService = SpotifyService.shared
    @State private var showFriendPicker = false
    @State private var showPlaylistPicker = false

    private var trackUri: String {
        "spotify:track:\(track.id)"
    }

    private var isPlaying: Bool {
        audioPlayer.currentTrackId == track.id && audioPlayer.isPlaying
    }

    var body: some View {
        HStack(spacing: 12) {
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
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
                } else {
                    Image(systemName: "music.note")
                        .frame(width: 50, height: 50)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(6)
                }

                // Play overlay
                if track.previewUrl != nil {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 30, height: 30)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
            .onTapGesture {
                if track.previewUrl != nil {
                    audioPlayer.play(track: track)
                }
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
        .contextMenu {
            Button {
                HapticService.lightImpact()
                showFriendPicker = true
            } label: {
                Label("Send to Friend", systemImage: "paperplane")
            }

            if spotifyService.isAuthenticated {
                Button {
                    HapticService.lightImpact()
                    showPlaylistPicker = true
                } label: {
                    Label("Add to Playlist", systemImage: "plus.circle")
                }
            }

            Button {
                HapticService.lightImpact()
                if let url = URL(string: "https://open.spotify.com/track/\(track.id)") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.right")
            }
        }
        .sheet(isPresented: $showFriendPicker) {
            FriendPickerView(track: track, previewUrl: track.previewUrl)
        }
        .sheet(isPresented: $showPlaylistPicker) {
            PlaylistPickerView(
                trackUri: trackUri,
                trackName: track.name,
                artistName: track.artists.map { $0.name }.joined(separator: ", "),
                albumArtUrl: track.album.images.first?.url,
                onAdded: {}
            )
        }
    }
}

struct TrendingSongRow: View {
    let song: TrendingSong
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @ObservedObject var spotifyService = SpotifyService.shared
    @State private var showFriendPicker = false
    @State private var showPlaylistPicker = false

    private var trackUri: String {
        "spotify:track:\(song.spotifyTrackId)"
    }

    private var isPlaying: Bool {
        audioPlayer.currentTrackId == song.spotifyTrackId && audioPlayer.isPlaying
    }

    // Construct a Track for FriendPickerView
    private var track: Track {
        let album = Album(
            id: "",
            name: "",
            images: song.albumArtUrl.map { [SpotifyImage(url: $0, height: nil, width: nil)] } ?? [],
            releaseDate: "",
            totalTracks: 0,
            uri: ""
        )
        return Track(
            id: song.spotifyTrackId,
            name: song.songTitle,
            artists: [Artist(id: "", name: song.songArtist, uri: "", externalUrls: nil, images: nil, genres: nil, followers: nil, popularity: nil)],
            album: album,
            durationMs: 0,
            explicit: false,
            popularity: 0,
            previewUrl: song.previewUrl,
            uri: trackUri,
            externalUrls: ExternalUrls(spotify: "https://open.spotify.com/track/\(song.spotifyTrackId)")
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if let albumArt = song.albumArtUrl,
                   let url = URL(string: albumArt) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color(.tertiarySystemBackground)
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
                } else {
                    Image(systemName: "music.note")
                        .frame(width: 50, height: 50)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(6)
                }

                // Play overlay
                if song.previewUrl != nil {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 30, height: 30)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
            .onTapGesture {
                if let previewUrl = song.previewUrl {
                    audioPlayer.playUrl(previewUrl, trackId: song.spotifyTrackId)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(song.songTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(song.songArtist)
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)

                    if song.sharedBy.count <= 2 {
                        Text(song.sharedBy.joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(.orange)
                    } else {
                        Text("\(song.shareCount) friends shared")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()
        }
        .contextMenu {
            Button {
                HapticService.lightImpact()
                showFriendPicker = true
            } label: {
                Label("Send to Friend", systemImage: "paperplane")
            }

            if spotifyService.isAuthenticated {
                Button {
                    HapticService.lightImpact()
                    showPlaylistPicker = true
                } label: {
                    Label("Add to Playlist", systemImage: "plus.circle")
                }
            }

            Button {
                HapticService.lightImpact()
                if let url = URL(string: "https://open.spotify.com/track/\(song.spotifyTrackId)") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Open in Spotify", systemImage: "arrow.up.right")
            }
        }
        .sheet(isPresented: $showFriendPicker) {
            FriendPickerView(track: track, previewUrl: song.previewUrl)
        }
        .sheet(isPresented: $showPlaylistPicker) {
            PlaylistPickerView(
                trackUri: trackUri,
                trackName: song.songTitle,
                artistName: song.songArtist,
                albumArtUrl: song.albumArtUrl,
                onAdded: {}
            )
        }
    }
}

struct AIRecommendationRow: View {
    let resolved: ResolvedAIRecommendation
    let onDismiss: () -> Void
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @ObservedObject var spotifyService = SpotifyService.shared
    @State private var showFriendPicker = false
    @State private var showPlaylistPicker = false

    private var track: Track? {
        resolved.track
    }

    private var trackUri: String {
        guard let track = track else { return "" }
        return "spotify:track:\(track.id)"
    }

    private var isPlaying: Bool {
        guard let track = track else { return false }
        return audioPlayer.currentTrackId == track.id && audioPlayer.isPlaying
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if let imageUrl = track?.album.images.first?.url,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color(.tertiarySystemBackground)
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
                } else {
                    Image(systemName: "music.note")
                        .frame(width: 50, height: 50)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(6)
                }

                // Play overlay
                if resolved.previewUrl != nil {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 30, height: 30)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(track?.name ?? resolved.recommendation.trackName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(track?.artists.map { $0.name }.joined(separator: ", ") ?? resolved.recommendation.artistName)
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
                    .lineLimit(1)

                // Show AI reason
                Text(resolved.recommendation.basedOn)
                    .font(.caption2)
                    .foregroundColor(.purple)
                    .lineLimit(1)
            }

            Spacer()

            // Match score indicator
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 32, height: 32)

                Text("\(Int(resolved.recommendation.matchScore * 100))%")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.purple)
            }

            // Dismiss button
            Button {
                HapticService.lightImpact()
                // Stop audio if this song is currently playing
                if isPlaying {
                    audioPlayer.stop()
                }
                onDismiss()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let previewUrl = resolved.previewUrl, let track = track {
                audioPlayer.playUrl(previewUrl, trackId: track.id)
            }
        }
        .contextMenu {
            if let track = track {
                Button {
                    HapticService.lightImpact()
                    showFriendPicker = true
                } label: {
                    Label("Send to Friend", systemImage: "paperplane")
                }

                if spotifyService.isAuthenticated {
                    Button {
                        HapticService.lightImpact()
                        showPlaylistPicker = true
                    } label: {
                        Label("Add to Playlist", systemImage: "plus.circle")
                    }
                }

                Button {
                    HapticService.lightImpact()
                    if let url = URL(string: "https://open.spotify.com/track/\(track.id)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open in Spotify", systemImage: "arrow.up.right")
                }
            }
        }
        .sheet(isPresented: $showFriendPicker) {
            if let track = track {
                FriendPickerView(track: track, previewUrl: resolved.previewUrl)
            }
        }
        .sheet(isPresented: $showPlaylistPicker) {
            if let track = track {
                PlaylistPickerView(
                    trackUri: trackUri,
                    trackName: track.name,
                    artistName: track.artists.map { $0.name }.joined(separator: ", "),
                    albumArtUrl: track.album.images.first?.url,
                    onAdded: {}
                )
            }
        }
    }
}

#Preview {
    DiscoverView(selectedTab: .constant(0), shouldEditProfile: .constant(false))
        .environmentObject(AuthManager.shared)
}
