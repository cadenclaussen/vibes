//
//  AlbumDetailView.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @StateObject private var spotifyService = SpotifyService.shared
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var tracks: [SimplifiedTrack] = []
    @State private var previewUrls: [String: String] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                tracksList
            }
        }
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadTracks()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            if let imageUrl = album.images.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
                .frame(width: 200, height: 200)
                .cornerRadius(8)
                .shadow(radius: 8)
            }

            Text(album.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Text(String(album.releaseDate.prefix(4)))
                Text("-")
                Text("\(album.totalTracks) tracks")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var tracksList: some View {
        if isLoading {
            ProgressView()
                .padding(.vertical, 40)
        } else if let error = errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title)
                    .foregroundColor(.orange)
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button("Retry") {
                    Task { await loadTracks() }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        } else {
            LazyVStack(spacing: 0) {
                ForEach(tracks) { track in
                    AlbumTrackRow(track: track, album: album, previewUrl: previewUrls[track.id])
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
    }

    private func loadTracks() async {
        isLoading = true
        errorMessage = nil

        // Track for achievements
        LocalAchievementStats.shared.albumsViewed += 1

        do {
            tracks = try await spotifyService.getAlbumTracks(albumId: album.id)
            await loadiTunesPreviews()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadiTunesPreviews() async {
        let tracksNeedingPreviews = tracks.map { track in
            (id: track.id, name: track.name, artist: track.artists.first?.name ?? "")
        }

        let previews = await iTunesService.shared.searchPreviews(for: tracksNeedingPreviews)
        previewUrls = previews
    }
}

struct AlbumTrackRow: View {
    let track: SimplifiedTrack
    let album: Album
    let previewUrl: String?
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @ObservedObject var spotifyService = SpotifyService.shared
    @State private var showFriendPicker = false
    @State private var showPlaylistPicker = false

    private var trackUri: String {
        "spotify:track:\(track.id)"
    }

    private var fullTrack: Track {
        Track(
            id: track.id,
            name: track.name,
            artists: track.artists,
            album: album,
            durationMs: track.durationMs,
            explicit: track.explicit,
            popularity: 0,
            previewUrl: previewUrl,
            uri: track.uri,
            externalUrls: ExternalUrls(spotify: "https://open.spotify.com/track/\(track.id)")
        )
    }

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
                Text("\(track.trackNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        if track.explicit {
                            Text("E")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(.tertiarySystemFill))
                                .cornerRadius(2)
                        }
                        Text(track.name)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }

                    Text(track.artists.map { $0.name }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
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

                Text(formatDuration(track.durationMs))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .opacity(hasPreview ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
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
            FriendPickerView(track: fullTrack, previewUrl: previewUrl)
        }
        .sheet(isPresented: $showPlaylistPicker) {
            PlaylistPickerView(
                trackUri: trackUri,
                trackName: track.name,
                artistName: track.artists.map { $0.name }.joined(separator: ", "),
                albumArtUrl: album.images.first?.url,
                onAdded: {}
            )
        }
    }

    private func formatDuration(_ milliseconds: Int) -> String {
        let seconds = milliseconds / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    NavigationStack {
        AlbumDetailView(album: Album(
            id: "1",
            name: "Test Album",
            images: [],
            releaseDate: "2024-01-01",
            totalTracks: 10,
            uri: "spotify:album:1"
        ))
    }
}
