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
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool

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

                        if !viewModel.newReleases.isEmpty {
                            newReleasesSection
                        }

                        if !viewModel.recommendations.isEmpty {
                            forYouSection
                        }

                        if !viewModel.trendingSongs.isEmpty {
                            trendingSection
                        }

                        if viewModel.recentlyActiveFriends.isEmpty &&
                           viewModel.newReleases.isEmpty &&
                           viewModel.recommendations.isEmpty &&
                           viewModel.trendingSongs.isEmpty {
                            emptyStateSection
                        }
                    }
                }
                .padding()
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.newReleases) { album in
                        NewReleaseCard(album: album)
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
                Text("Based on your listening")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            VStack(spacing: 8) {
                ForEach(viewModel.recommendations) { track in
                    RecommendationRow(track: track)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
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

            VStack(spacing: 8) {
                ForEach(viewModel.trendingSongs) { song in
                    TrendingSongRow(song: song)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
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
    }
}

struct TrendingSongRow: View {
    let song: TrendingSong
    @ObservedObject var audioPlayer = AudioPlayerService.shared

    private var isPlaying: Bool {
        audioPlayer.currentTrackId == song.spotifyTrackId && audioPlayer.isPlaying
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
    }
}

#Preview {
    DiscoverView(selectedTab: .constant(0), shouldEditProfile: .constant(false))
        .environmentObject(AuthManager.shared)
}
