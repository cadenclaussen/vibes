//
//  ProfileHelperViews.swift
//  vibes
//
//  Helper views for ProfileView - artist cells, track rows, etc.
//

import SwiftUI

// MARK: - Top Artist Cell

struct TopArtistCell: View {
    let artist: Artist

    var body: some View {
        VStack(spacing: 6) {
            if let imageUrl = artist.images?.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.tertiarySystemBackground)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Image(systemName: "music.mic")
                    .font(.title)
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(width: 80, height: 80)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Circle())
            }

            Text(artist.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Top Track Row

struct TopTrackRow: View {
    let rank: Int
    let track: Track
    var previewUrl: String?
    var onSendTapped: ((Track) -> Void)?
    var onAddToPlaylistTapped: ((Track) -> Void)?
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var showNoPreviewAlert = false

    private var uniqueTrackId: String {
        "top-\(rank)-\(track.id)"
    }

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == uniqueTrackId
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    private var hasPreview: Bool {
        previewUrl != nil
    }

    private var spotifyUrl: URL? {
        URL(string: "https://open.spotify.com/track/\(track.id)")
    }

    var body: some View {
        Button {
            HapticService.lightImpact()
            if let url = previewUrl {
                audioPlayer.playUrl(url, trackId: uniqueTrackId)
            } else {
                showNoPreviewAlert = true
            }
        } label: {
            HStack(spacing: 12) {
                Text("\(rank)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(width: 20)

                albumArtView

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
            .contentShape(Rectangle())
            .opacity(hasPreview ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                HapticService.lightImpact()
                onSendTapped?(track)
            } label: {
                Label("Send to Friend", systemImage: "paperplane")
            }

            Button {
                HapticService.lightImpact()
                onAddToPlaylistTapped?(track)
            } label: {
                Label("Add to Playlist", systemImage: "plus.circle")
            }

            if let url = spotifyUrl {
                Button {
                    HapticService.lightImpact()
                    UIApplication.shared.open(url)
                } label: {
                    Label("Open in Spotify", systemImage: "arrow.up.right")
                }
            }
        }
        .alert("No Preview Available", isPresented: $showNoPreviewAlert) {
            if let url = spotifyUrl {
                Button("Open in Spotify") {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("This track doesn't have a preview. Open it in Spotify to listen.")
        }
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
                Image(systemName: "music.note")
                    .foregroundColor(Color(.tertiaryLabel))
            }

            if hasPreview {
                Color.black.opacity(isCurrentTrack ? 0.4 : 0)
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .opacity(isCurrentTrack ? 1 : 0)
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
        .frame(width: 40, height: 40)
        .cornerRadius(4)
        .clipped()
    }
}

// MARK: - Recently Played Cell

struct RecentlyPlayedCell: View {
    let playHistory: PlayHistory
    let index: Int
    var previewUrl: String?
    var onSendTapped: ((Track) -> Void)?
    var onAddToPlaylistTapped: ((Track) -> Void)?
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var showNoPreviewAlert = false

    private var track: Track {
        playHistory.track
    }

    private var uniqueTrackId: String {
        "recent-\(index)-\(track.id)"
    }

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == uniqueTrackId
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    private var hasPreview: Bool {
        previewUrl != nil
    }

    private var spotifyUrl: URL? {
        URL(string: "https://open.spotify.com/track/\(track.id)")
    }

    var body: some View {
        Button {
            HapticService.lightImpact()
            if let url = previewUrl {
                audioPlayer.playUrl(url, trackId: uniqueTrackId)
            } else {
                showNoPreviewAlert = true
            }
        } label: {
            VStack(spacing: 6) {
                albumArtView

                VStack(spacing: 2) {
                    Text(track.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Text(track.artists.first?.name ?? "")
                        .font(.caption2)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(1)
                }
            }
            .frame(width: 80)
            .contentShape(Rectangle())
            .opacity(hasPreview ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                HapticService.lightImpact()
                onSendTapped?(track)
            } label: {
                Label("Send to Friend", systemImage: "paperplane")
            }

            Button {
                HapticService.lightImpact()
                onAddToPlaylistTapped?(track)
            } label: {
                Label("Add to Playlist", systemImage: "plus.circle")
            }

            if let url = spotifyUrl {
                Button {
                    HapticService.lightImpact()
                    UIApplication.shared.open(url)
                } label: {
                    Label("Open in Spotify", systemImage: "arrow.up.right")
                }
            }
        }
        .alert("No Preview Available", isPresented: $showNoPreviewAlert) {
            if let url = spotifyUrl {
                Button("Open in Spotify") {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("This track doesn't have a preview. Open it in Spotify to listen.")
        }
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
                Image(systemName: "music.note")
                    .font(.title)
                    .foregroundColor(Color(.tertiaryLabel))
                    .background(Color(.tertiarySystemBackground))
            }

            if hasPreview {
                Color.black.opacity(isCurrentTrack ? 0.4 : 0)
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                    .opacity(isCurrentTrack ? 1 : 0)
            }

            if isCurrentTrack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * audioPlayer.playbackProgress, height: 3)
                }
                .frame(height: 3)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(width: 80, height: 80)
        .cornerRadius(8)
        .clipped()
    }
}
