//
//  SearchHelperViews.swift
//  vibes
//
//  Helper views for SearchView - row components for search results.
//

import SwiftUI

// MARK: - Track Row

struct TrackRow: View {
    let track: Track
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var showNoPreviewAlert = false
    let onSendTapped: (Track) -> Void
    let onAddToPlaylistTapped: (Track) -> Void

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == track.id
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    private var previewUrl: String? {
        viewModel.getPreviewUrl(for: track)
    }

    private var hasPreview: Bool {
        previewUrl != nil
    }

    var body: some View {
        Button {
            HapticService.lightImpact()
            if let url = previewUrl {
                audioPlayer.playUrl(url, trackId: track.id)
            } else {
                showNoPreviewAlert = true
            }
        } label: {
            HStack(spacing: 12) {
                albumArtView
                trackInfo
                Spacer()
                playIndicator
                durationLabel
            }
            .padding(.horizontal, 20)
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

            Button {
                HapticService.lightImpact()
                onAddToPlaylistTapped(track)
            } label: {
                Label("Add to Playlist", systemImage: "plus.circle")
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
        .alert("Preview Unavailable", isPresented: $showNoPreviewAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("No preview available for this track.")
        }
    }

    private var albumArtView: some View {
        ZStack(alignment: .bottom) {
            Group {
                if let imageUrl = track.album.images.first?.url,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            albumPlaceholder
                        case .empty:
                            ProgressView()
                        @unknown default:
                            albumPlaceholder
                        }
                    }
                } else {
                    albumPlaceholder
                }
            }
            .frame(width: 48, height: 48)

            if isCurrentTrack {
                Rectangle()
                    .fill(.black.opacity(0.4))
                    .frame(width: 48, height: 48)

                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .frame(width: 48, height: 48)
            }

            if isCurrentTrack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * audioPlayer.playbackProgress, height: 2)
                }
                .frame(height: 2)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(width: 48, height: 48)
        .cornerRadius(4)
        .clipped()
    }

    @ViewBuilder
    private var playIndicator: some View {
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

    private var albumPlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "music.note")
                    .foregroundColor(.secondary)
            }
    }

    private var trackInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                    .lineLimit(1)
            }

            Text(track.artists.map { $0.name }.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }

    private var durationLabel: some View {
        Text(formatDuration(track.durationMs))
            .font(.caption)
            .foregroundColor(.secondary)
            .monospacedDigit()
    }

    private func formatDuration(_ milliseconds: Int) -> String {
        let seconds = milliseconds / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Artist Row

struct ArtistRow: View {
    let artist: Artist

    var body: some View {
        HStack(spacing: 12) {
            artistImage
            artistInfo
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var artistImage: some View {
        Group {
            if let imageUrl = artist.images?.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    artistPlaceholder
                }
            } else {
                artistPlaceholder
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }

    private var artistPlaceholder: some View {
        Circle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "music.mic")
                    .foregroundColor(.secondary)
            }
    }

    private var artistInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(artist.name)
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(1)

            if let followers = artist.followers?.total {
                Text(formatFollowers(followers))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Artist")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
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

// MARK: - Album Row

struct AlbumRow: View {
    let album: Album

    var body: some View {
        HStack(spacing: 12) {
            albumImage
            albumInfo
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var albumImage: some View {
        Group {
            if let imageUrl = album.images.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    albumPlaceholder
                }
            } else {
                albumPlaceholder
            }
        }
        .frame(width: 48, height: 48)
        .cornerRadius(4)
    }

    private var albumPlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "music.note")
                    .foregroundColor(.secondary)
            }
    }

    private var albumInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(album.name)
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(1)

            HStack(spacing: 4) {
                Text(String(album.releaseDate.prefix(4)))
                    .foregroundColor(.secondary)
                Text("-")
                    .foregroundColor(.secondary)
                Text("\(album.totalTracks) tracks")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
    }
}

// MARK: - Playlist Row

struct PlaylistRow: View {
    let playlist: Playlist
    let onSendTapped: ((Playlist) -> Void)?

    init(playlist: Playlist, onSendTapped: ((Playlist) -> Void)? = nil) {
        self.playlist = playlist
        self.onSendTapped = onSendTapped
    }

    var body: some View {
        HStack(spacing: 12) {
            playlistImage
            playlistInfo
            Spacer()
            if let onSendTapped = onSendTapped {
                Button {
                    onSendTapped(playlist)
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var playlistImage: some View {
        Group {
            if let imageUrl = playlist.images?.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    playlistPlaceholder
                }
            } else {
                playlistPlaceholder
            }
        }
        .frame(width: 48, height: 48)
        .cornerRadius(4)
    }

    private var playlistPlaceholder: some View {
        Rectangle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "music.note.list")
                    .foregroundColor(.secondary)
            }
    }

    private var playlistInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(playlist.name)
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(1)

            HStack(spacing: 4) {
                Text("by \(playlist.owner.displayName ?? "Unknown")")
                    .foregroundColor(.secondary)
                Text("-")
                    .foregroundColor(.secondary)
                Text("\(playlist.tracks.total) tracks")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            .lineLimit(1)
        }
    }
}

// MARK: - Sound Wave Animation

struct SoundWaveBar: View {
    let delay: Double
    @State private var animating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.green)
            .frame(width: 3, height: animating ? 16 : 6)
            .animation(
                .easeInOut(duration: 0.4)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: animating
            )
            .onAppear { animating = true }
    }
}
