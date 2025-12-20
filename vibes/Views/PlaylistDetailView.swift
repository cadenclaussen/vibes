//
//  PlaylistDetailView.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI

struct PlaylistDetailView: View {
    let playlist: Playlist
    @StateObject private var spotifyService = SpotifyService.shared
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var tracks: [Track] = []
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
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadTracks()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            if let imageUrl = playlist.images?.first?.url,
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
            } else {
                Image(systemName: "music.note.list")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .frame(width: 200, height: 200)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
            }

            Text(playlist.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Text("by \(playlist.owner.displayName ?? "Unknown")")
                Text("-")
                Text("\(playlist.tracks.total) tracks")
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
                    PlaylistTrackRow(track: track, previewUrl: previewUrls[track.id])
                    Divider()
                        .padding(.leading, 72)
                }
            }
        }
    }

    private func loadTracks() async {
        isLoading = true
        errorMessage = nil

        do {
            tracks = try await spotifyService.getPlaylistTracks(playlistId: playlist.id)
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

struct PlaylistTrackRow: View {
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
                albumArtView

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
        .frame(width: 48, height: 48)
        .cornerRadius(4)
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
        PlaylistDetailView(playlist: Playlist(
            id: "1",
            name: "Test Playlist",
            description: nil,
            images: nil,
            owner: PlaylistOwner(id: "1", displayName: "Test User"),
            tracks: PlaylistTracksInfo(total: 50),
            isPublic: true,
            collaborative: false,
            uri: "spotify:playlist:1",
            externalUrls: nil
        ))
    }
}
