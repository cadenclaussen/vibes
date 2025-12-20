//
//  ArtistDetailView.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI

struct ArtistDetailView: View {
    let artist: Artist
    @StateObject private var spotifyService = SpotifyService.shared
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var topTracks: [Track] = []
    @State private var albums: [Album] = []
    @State private var previewUrls: [String: String] = [:]
    @State private var isLoadingTracks = true
    @State private var isLoadingAlbums = true
    @State private var errorMessage: String?
    @State private var selectedAlbum: Album?
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
            AlbumDetailView(album: album)
        }
        .task {
            await loadData()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            if let imageUrl = artist.images?.first?.url,
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

            if let followers = artist.followers?.total {
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
                        ArtistTopTrackRow(rank: index + 1, track: track, previewUrl: previewUrls[track.id])
                        if index < min(topTracks.count - 1, 9) {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
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
                                ArtistAlbumCard(album: album)
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
        async let tracksTask: () = loadTopTracks()
        async let albumsTask: () = loadAlbums()
        _ = await (tracksTask, albumsTask)
    }

    private func loadTopTracks() async {
        isLoadingTracks = true
        do {
            topTracks = try await spotifyService.getArtistTopTracks(artistId: artist.id)
            await loadiTunesPreviews()
        } catch {
            print("Failed to load top tracks: \(error)")
        }
        isLoadingTracks = false
    }

    private func loadiTunesPreviews() async {
        let tracksNeedingPreviews = topTracks.map { track in
            (id: track.id, name: track.name, artist: track.artists.first?.name ?? "")
        }

        let previews = await iTunesService.shared.searchPreviews(for: tracksNeedingPreviews)
        previewUrls = previews
    }

    private func loadAlbums() async {
        isLoadingAlbums = true
        do {
            albums = try await spotifyService.getArtistAlbums(artistId: artist.id)
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

struct ArtistTopTrackRow: View {
    let rank: Int
    let track: Track
    let previewUrl: String?
    @ObservedObject var audioPlayer = AudioPlayerService.shared

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == track.id
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    private var hasPreview: Bool {
        previewUrl != nil
    }

    var body: some View {
        Button {
            if let url = previewUrl {
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

    private func formatDuration(_ milliseconds: Int) -> String {
        let seconds = milliseconds / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct ArtistAlbumCard: View {
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

            Text(String(album.releaseDate.prefix(4)))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 140)
    }
}

#Preview {
    NavigationStack {
        ArtistDetailView(artist: Artist(
            id: "1",
            name: "Test Artist",
            uri: "spotify:artist:1",
            externalUrls: nil,
            images: nil,
            genres: nil,
            followers: Followers(total: 1000000),
            popularity: nil
        ))
    }
}
