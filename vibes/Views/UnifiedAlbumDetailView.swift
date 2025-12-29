//
//  UnifiedAlbumDetailView.swift
//  vibes
//
//  Album detail view that works with both Apple Music and Spotify.
//

import SwiftUI

struct UnifiedAlbumDetailView: View {
    let album: UnifiedAlbum
    @StateObject private var musicServiceManager = MusicServiceManager.shared
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var tracks: [UnifiedSimplifiedTrack] = []
    @State private var previewUrls: [String: String] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var trackToSend: UnifiedTrack?
    @State private var trackToAddToPlaylist: UnifiedTrack?
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
            if let imageUrl = album.imageUrl,
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
                if !album.releaseDate.isEmpty {
                    Text(String(album.releaseDate.prefix(4)))
                }
                if !album.releaseDate.isEmpty && album.trackCount > 0 {
                    Text("-")
                }
                if album.trackCount > 0 {
                    Text("\(album.trackCount) tracks")
                }
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
                    UnifiedAlbumTrackRow(
                        track: track,
                        album: album,
                        previewUrl: previewUrls[track.id] ?? track.previewUrl,
                        onSendTapped: { trackToSend = $0 },
                        onAddToPlaylistTapped: { trackToAddToPlaylist = $0 }
                    )
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
    }

    private func loadTracks() async {
        isLoading = true
        errorMessage = nil

        LocalAchievementStats.shared.albumsViewed += 1
        LocalAchievementStats.shared.checkLocalAchievements()

        do {
            let service = musicServiceManager.currentService
            tracks = try await service.getAlbumTracks(albumId: album.id, limit: 50)
            await loadiTunesPreviews()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadiTunesPreviews() async {
        let tracksNeedingPreviews = tracks.compactMap { track -> (id: String, name: String, artist: String)? in
            if track.previewUrl == nil {
                return (id: track.id, name: track.name, artist: track.artists.first?.name ?? "")
            }
            return nil
        }

        if tracksNeedingPreviews.isEmpty { return }

        let previews = await iTunesService.shared.searchPreviews(for: tracksNeedingPreviews)
        previewUrls = previews
    }
}

struct UnifiedAlbumTrackRow: View {
    let track: UnifiedSimplifiedTrack
    let album: UnifiedAlbum
    let previewUrl: String?
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @StateObject var musicServiceManager = MusicServiceManager.shared
    let onSendTapped: (UnifiedTrack) -> Void
    let onAddToPlaylistTapped: (UnifiedTrack) -> Void

    private var fullTrack: UnifiedTrack {
        UnifiedTrack(
            id: track.id,
            originalId: track.originalId,
            serviceType: track.serviceType,
            name: track.name,
            artists: track.artists,
            album: album,
            durationMs: track.durationMs,
            isExplicit: track.isExplicit,
            previewUrl: previewUrl ?? track.previewUrl,
            externalUrl: nil,
            uri: track.uri
        )
    }

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == track.id
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    private var hasPreview: Bool {
        previewUrl != nil || track.previewUrl != nil
    }

    var body: some View {
        Button {
            if let url = previewUrl ?? track.previewUrl {
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
                        if track.isExplicit {
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
                onSendTapped(fullTrack)
            } label: {
                Label("Send to Friend", systemImage: "paperplane")
            }

            if musicServiceManager.isAuthenticated {
                Button {
                    HapticService.lightImpact()
                    onAddToPlaylistTapped(fullTrack)
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

    private func openInMusicApp() {
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
        UnifiedAlbumDetailView(album: UnifiedAlbum(
            id: "1",
            originalId: "1",
            serviceType: .spotify,
            name: "Test Album",
            imageUrl: nil,
            releaseDate: "2024-01-01",
            trackCount: 10,
            externalUrl: nil,
            uri: nil
        ))
    }
}
