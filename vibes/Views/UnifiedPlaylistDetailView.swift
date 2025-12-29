//
//  UnifiedPlaylistDetailView.swift
//  vibes
//
//  Playlist detail view that works with both Apple Music and Spotify.
//

import SwiftUI

struct UnifiedPlaylistDetailView: View {
    let playlist: UnifiedPlaylist
    @StateObject private var musicServiceManager = MusicServiceManager.shared
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var tracks: [UnifiedTrack] = []
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
        .navigationTitle(playlist.name)
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
            if let imageUrl = playlist.imageUrl,
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
                Text("by \(playlist.ownerName ?? "Unknown")")
                Text("-")
                Text("\(playlist.trackCount) tracks")
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
                ForEach(Array(tracks.enumerated()), id: \.offset) { index, track in
                    UnifiedPlaylistTrackRow(
                        track: track,
                        index: index,
                        previewUrl: previewUrls[track.id] ?? track.previewUrl,
                        onSendTapped: { trackToSend = $0 },
                        onAddToPlaylistTapped: { trackToAddToPlaylist = $0 }
                    )
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
            let service = musicServiceManager.currentService
            tracks = try await service.getPlaylistTracks(playlistId: playlist.id, limit: 100)
            await loadiTunesPreviews()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadiTunesPreviews() async {
        let tracksNeedingPreviews = tracks.enumerated().compactMap { index, track -> (id: String, name: String, artist: String)? in
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

struct UnifiedPlaylistTrackRow: View {
    let track: UnifiedTrack
    let index: Int
    let previewUrl: String?
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @StateObject var musicServiceManager = MusicServiceManager.shared
    let onSendTapped: (UnifiedTrack) -> Void
    let onAddToPlaylistTapped: (UnifiedTrack) -> Void

    private var uniqueTrackId: String {
        "playlist-\(index)-\(track.id)"
    }

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == uniqueTrackId
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
                audioPlayer.playUrl(url, trackId: uniqueTrackId)
            }
        } label: {
            HStack(spacing: 12) {
                albumArtView

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
        .frame(width: 48, height: 48)
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

#Preview {
    NavigationStack {
        UnifiedPlaylistDetailView(playlist: UnifiedPlaylist(
            id: "1",
            originalId: "1",
            serviceType: .spotify,
            name: "Test Playlist",
            description: nil,
            imageUrl: nil,
            ownerName: "Test User",
            trackCount: 50,
            isPublic: true,
            isCollaborative: false,
            externalUrl: nil,
            uri: nil
        ))
    }
}
