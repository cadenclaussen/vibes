//
//  DiscoverHelperViews.swift
//  vibes
//
//  Helper views for DiscoverView - cards, rows, etc.
//

import SwiftUI

// MARK: - Concert Card

struct ConcertCard: View {
    let concert: Concert

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: concert.date)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: concert.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                if let imageUrl = concert.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        concertPlaceholder
                    }
                    .frame(width: 160, height: 90)
                    .clipped()
                    .cornerRadius(8)
                } else {
                    concertPlaceholder
                }

                VStack {
                    Spacer()
                    HStack {
                        Text(formattedDate)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(4)
                        Spacer()
                    }
                    .padding(6)
                }
            }
            .frame(width: 160, height: 90)

            VStack(alignment: .leading, spacing: 2) {
                Text(concert.artistName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(concert.venueName)
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(formattedTime)
                        .font(.caption2)

                    if let price = concert.priceRange {
                        Text("  \(price)")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                .foregroundColor(Color(.secondaryLabel))
            }
        }
        .frame(width: 160)
        .onTapGesture {
            if let urlString = concert.ticketUrl, let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }

    private var concertPlaceholder: some View {
        ZStack {
            Color(.tertiarySystemBackground)
            Image(systemName: "music.mic")
                .font(.title)
                .foregroundColor(Color(.tertiaryLabel))
        }
        .frame(width: 160, height: 90)
        .cornerRadius(8)
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

// MARK: - Recently Active Friend Card

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

// MARK: - New Release Card

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

                Text(album.releaseDate.prefix(4))
                    .font(.caption2)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .frame(width: 140)
    }
}

// MARK: - Recommendation Row

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

                if track.previewUrl != nil {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 30, height: 30)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
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
        .contentShape(Rectangle())
        .onTapGesture {
            if track.previewUrl != nil {
                audioPlayer.play(track: track)
            } else {
                if let url = URL(string: "https://open.spotify.com/track/\(track.id)") {
                    UIApplication.shared.open(url)
                }
            }
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

// MARK: - Trending Song Row

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

    private var track: Track {
        let album = Album(
            id: "",
            name: "",
            images: song.albumArtUrl.map { [SpotifyImage(url: $0, height: nil, width: nil)] } ?? [],
            releaseDate: "",
            totalTracks: 0,
            uri: "",
            artists: [Artist(id: "", name: song.songArtist, uri: "", externalUrls: nil, images: nil, genres: nil, followers: nil, popularity: nil)]
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

// MARK: - AI Recommendation Row

struct AIRecommendationRow: View {
    let resolved: ResolvedAIRecommendation
    let onDismiss: () -> Void
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @StateObject var musicServiceManager = MusicServiceManager.shared
    @State private var showFriendPicker = false
    @State private var showPlaylistPicker = false

    private var track: UnifiedTrack? {
        resolved.unifiedTrack
    }

    private var isPlaying: Bool {
        guard let track = track else { return false }
        return audioPlayer.currentTrackId == track.id && audioPlayer.isPlaying
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if let imageUrl = track?.album.imageUrl,
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

                Text(resolved.recommendation.basedOn)
                    .font(.caption2)
                    .foregroundColor(.purple)
                    .lineLimit(1)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 32, height: 32)

                Text("\(Int(resolved.recommendation.matchScore * 100))%")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.purple)
            }

            Button {
                HapticService.lightImpact()
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

                if musicServiceManager.isAuthenticated {
                    Button {
                        HapticService.lightImpact()
                        showPlaylistPicker = true
                    } label: {
                        Label("Add to Playlist", systemImage: "plus.circle")
                    }
                }

                Button {
                    HapticService.lightImpact()
                    if let url = URL(string: track.externalUrl ?? "") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open in \(musicServiceManager.serviceName)", systemImage: "arrow.up.right")
                }
            }
        }
        .sheet(isPresented: $showFriendPicker) {
            if let track = track {
                FriendPickerView(unifiedTrack: track, previewUrl: resolved.previewUrl)
            }
        }
        .sheet(isPresented: $showPlaylistPicker) {
            if let track = track {
                UnifiedPlaylistPickerView(track: track) {}
            }
        }
    }
}

// MARK: - Unified New Release Card

struct UnifiedNewReleaseCard: View {
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

                if !album.releaseDate.isEmpty {
                    Text(album.releaseDate.prefix(4))
                        .font(.caption2)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
        .frame(width: 140)
    }
}

// MARK: - Unified Recommendation Row

struct UnifiedRecommendationRow: View {
    let track: UnifiedTrack
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @StateObject var musicServiceManager = MusicServiceManager.shared
    @State private var showFriendPicker = false
    @State private var showPlaylistPicker = false

    private var isPlaying: Bool {
        audioPlayer.currentTrackId == track.id && audioPlayer.isPlaying
    }

    var body: some View {
        HStack(spacing: 12) {
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
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
                } else {
                    Image(systemName: "music.note")
                        .frame(width: 50, height: 50)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(6)
                }

                if track.previewUrl != nil {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 30, height: 30)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
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
        .contentShape(Rectangle())
        .onTapGesture {
            if let previewUrl = track.previewUrl {
                audioPlayer.playUrl(previewUrl, trackId: track.id)
            } else {
                openInMusicApp()
            }
        }
        .contextMenu {
            Button {
                HapticService.lightImpact()
                showFriendPicker = true
            } label: {
                Label("Send to Friend", systemImage: "paperplane")
            }

            if musicServiceManager.isAuthenticated {
                Button {
                    HapticService.lightImpact()
                    showPlaylistPicker = true
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
        .sheet(isPresented: $showFriendPicker) {
            FriendPickerView(
                unifiedTrack: track,
                previewUrl: track.previewUrl,
                onSongSent: { _ in }
            )
        }
        .sheet(isPresented: $showPlaylistPicker) {
            UnifiedPlaylistPickerView(
                track: track,
                onAdded: {}
            )
        }
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
}
