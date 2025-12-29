//
//  UnifiedArtistDetailView.swift
//  vibes
//
//  Artist detail view that works with both Apple Music and Spotify.
//

import SwiftUI

struct UnifiedArtistDetailView: View {
    let artist: UnifiedArtist
    @StateObject private var musicServiceManager = MusicServiceManager.shared
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var topTracks: [UnifiedTrack] = []
    @State private var albums: [UnifiedAlbum] = []
    @State private var isLoadingTracks = true
    @State private var isLoadingAlbums = true
    @State private var errorMessage: String?
    @State private var selectedAlbum: UnifiedAlbum?
    @State private var trackToSend: UnifiedTrack?
    @State private var trackToAddToPlaylist: UnifiedTrack?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                topTracksSection
                albumsSection
            }
            .padding(.bottom, 20)
        }
        .navigationTitle(artist.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedAlbum) { album in
            UnifiedAlbumDetailView(album: album)
        }
        .task {
            await loadData()
        }
        .onAppear {
            audioPlayer.stop()
        }
        .onDisappear {
            audioPlayer.stop()
        }
        .sheet(item: $trackToSend) { track in
            FriendPickerView(
                unifiedTrack: track,
                previewUrl: track.previewUrl,
                onSongSent: { _ in }
            )
        }
        .sheet(item: $trackToAddToPlaylist) { track in
            UnifiedPlaylistPickerView(
                track: track,
                onAdded: {}
            )
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            if let imageUrl = artist.imageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
                .frame(width: 180, height: 180)
                .clipShape(Circle())
                .shadow(radius: 8)
            } else {
                Image(systemName: "music.mic")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .frame(width: 180, height: 180)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Circle())
            }

            Text(artist.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if let followers = artist.followerCount {
                Text(formatFollowers(followers))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var topTracksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Songs")
                .font(.headline)
                .padding(.horizontal, 16)

            if isLoadingTracks {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if topTracks.isEmpty {
                Text("No top tracks available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(topTracks.prefix(10).enumerated()), id: \.element.id) { index, track in
                        UnifiedArtistTopTrackRow(
                            rank: index + 1,
                            track: track,
                            onSendTapped: { trackToSend = $0 },
                            onAddToPlaylistTapped: { trackToAddToPlaylist = $0 }
                        )
                        if index < min(topTracks.count - 1, 9) {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .cardStyle()
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    private var albumsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discography")
                .font(.headline)
                .padding(.horizontal, 16)

            if isLoadingAlbums {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if albums.isEmpty {
                Text("No albums available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(albums) { album in
                            Button {
                                selectedAlbum = album
                            } label: {
                                UnifiedArtistAlbumCard(album: album)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    private func loadData() async {
        LocalAchievementStats.shared.artistsViewed += 1
        LocalAchievementStats.shared.checkLocalAchievements()

        async let tracksTask: () = loadTopTracks()
        async let albumsTask: () = loadAlbums()
        _ = await (tracksTask, albumsTask)
    }

    private func loadTopTracks() async {
        isLoadingTracks = true
        do {
            let service = musicServiceManager.currentService
            topTracks = try await service.getArtistTopTracks(artistId: artist.id)
            await loadiTunesPreviews()
        } catch {
            print("Failed to load top tracks: \(error)")
        }
        isLoadingTracks = false
    }

    private func loadiTunesPreviews() async {
        let tracksNeedingPreviews = topTracks.enumerated().compactMap { index, track -> (id: String, name: String, artist: String)? in
            if track.previewUrl == nil {
                return (id: track.id, name: track.name, artist: track.artists.first?.name ?? "")
            }
            return nil
        }

        if tracksNeedingPreviews.isEmpty { return }

        let previews = await iTunesService.shared.searchPreviews(for: tracksNeedingPreviews)

        for (index, track) in topTracks.enumerated() {
            if track.previewUrl == nil, let preview = previews[track.id] {
                topTracks[index].previewUrl = preview
            }
        }
    }

    private func loadAlbums() async {
        isLoadingAlbums = true
        do {
            let service = musicServiceManager.currentService
            albums = try await service.getArtistAlbums(artistId: artist.id, limit: 20)
        } catch {
            print("Failed to load albums: \(error)")
        }
        isLoadingAlbums = false
    }

    private func formatFollowers(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM followers", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK followers", Double(count) / 1_000)
        } else {
            return "\(count) followers"
        }
    }
}

struct UnifiedArtistTopTrackRow: View {
    let rank: Int
    let track: UnifiedTrack
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @StateObject var musicServiceManager = MusicServiceManager.shared
    let onSendTapped: (UnifiedTrack) -> Void
    let onAddToPlaylistTapped: (UnifiedTrack) -> Void

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == track.id
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    private var hasPreview: Bool {
        track.previewUrl != nil
    }

    var body: some View {
        Button {
            if let url = track.previewUrl {
                audioPlayer.playUrl(url, trackId: track.id)
            }
        } label: {
            HStack(spacing: 12) {
                Text("\(rank)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(width: 24)

                albumArtView

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(formatDuration(track.durationMs))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isPlaying {
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { index in
                            SoundWaveBar(delay: Double(index) * 0.1)
                        }
                    }
                    .frame(width: 20)
                } else if !hasPreview {
                    Image(systemName: "speaker.slash")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .opacity(hasPreview ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                HapticService.lightImpact()
                onSendTapped(track)
            } label: {
                Label("Send to Friend", systemImage: "paperplane")
            }

            if musicServiceManager.isAuthenticated {
                Button {
                    HapticService.lightImpact()
                    onAddToPlaylistTapped(track)
                } label: {
                    Label("Add to Playlist", systemImage: "plus.circle")
                }
            }

            Button {
                HapticService.lightImpact()
                openInMusicApp()
            } label: {
                Label("Open in \(track.serviceType.displayName)", systemImage: "arrow.up.right")
            }
        }
    }

    private var albumArtView: some View {
        ZStack {
            if let imageUrl = track.album.imageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
            } else {
                Color(.tertiarySystemBackground)
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundColor(.secondary)
                    }
            }
        }
        .frame(width: 40, height: 40)
        .cornerRadius(4)
    }

    private func openInMusicApp() {
        guard let externalUrl = track.externalUrl,
              let url = URL(string: externalUrl) else {
            let urlString: String
            switch track.serviceType {
            case .spotify:
                urlString = "https://open.spotify.com/track/\(track.originalId)"
            case .appleMusic:
                urlString = "https://music.apple.com/song/\(track.originalId)"
            }
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
            return
        }
        UIApplication.shared.open(url)
    }

    private func formatDuration(_ milliseconds: Int) -> String {
        let seconds = milliseconds / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct UnifiedArtistAlbumCard: View {
    let album: UnifiedAlbum

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let imageUrl = album.imageUrl,
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
                    .foregroundColor(.secondary)
                    .frame(width: 140, height: 140)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
            }

            Text(album.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)

            if !album.releaseDate.isEmpty {
                Text(String(album.releaseDate.prefix(4)))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 140)
    }
}

#Preview {
    NavigationStack {
        UnifiedArtistDetailView(artist: UnifiedArtist(
            id: "1",
            originalId: "1",
            serviceType: .spotify,
            name: "Test Artist",
            imageUrl: nil,
            genres: nil,
            followerCount: 1000000,
            externalUrl: nil,
            uri: nil
        ))
    }
}
