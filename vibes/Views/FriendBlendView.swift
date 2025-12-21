import SwiftUI

struct FriendBlendView: View {
    @StateObject private var viewModel: FriendBlendViewModel
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @EnvironmentObject var authManager: AuthManager

    init(friend: FriendProfile) {
        _viewModel = StateObject(wrappedValue: FriendBlendViewModel(friend: friend))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                if let blend = viewModel.blendResult {
                    blendInfoSection(blend)
                }
                if !viewModel.resolvedSongs.isEmpty {
                    songsSection
                }
            }
            .padding()
        }
        .navigationTitle("Music Blend")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Playlist Created", isPresented: .constant(viewModel.savedPlaylistUrl != nil)) {
            Button("Open in Spotify") {
                if let urlString = viewModel.savedPlaylistUrl,
                   let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
                viewModel.savedPlaylistUrl = nil
            }
            Button("Done", role: .cancel) {
                viewModel.savedPlaylistUrl = nil
            }
        } message: {
            Text("Your blend playlist has been saved to Spotify!")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Profile pictures side by side
            HStack(spacing: -20) {
                profileImage(url: nil) // Current user profile picture
                profileImage(url: viewModel.friend.profilePictureURL)
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 3)
                    )
            }

            VStack(spacing: 4) {
                Text("You + \(viewModel.friend.displayName)")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Create a playlist that blends both your music tastes")
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
            }

            if viewModel.isGenerating {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Creating your perfect blend...")
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }
                .padding(.top, 8)
            } else if viewModel.blendResult == nil {
                generateButton
            }

            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.top, 8)
            }
        }
    }

    private func profileImage(url: String?) -> some View {
        Group {
            if let urlString = url, let imageUrl = URL(string: urlString) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
            } else {
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
        }
        .frame(width: 70, height: 70)
        .clipShape(Circle())
    }

    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generateBlend()
            }
        } label: {
            HStack {
                Image(systemName: "wand.and.stars")
                Text("Create Blend")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
        }
        .disabled(!viewModel.canGenerate)
        .opacity(viewModel.canGenerate ? 1 : 0.5)
    }

    private func blendInfoSection(_ blend: BlendResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text(blend.blendName)
                    .font(.headline)
            }

            Text(blend.blendAnalysis)
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))

            if viewModel.isResolvingSongs {
                HStack {
                    ProgressView()
                    Text("Finding songs on Spotify...")
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var songsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Songs")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(viewModel.resolvedSongs) { song in
                    BlendSongRow(
                        song: song,
                        friendName: viewModel.friend.displayName,
                        isPlaying: audioPlayer.currentTrackId == song.track?.id && audioPlayer.isPlaying
                    ) {
                        if let previewUrl = song.previewUrl {
                            audioPlayer.playUrl(previewUrl, trackId: song.track?.id ?? song.id)
                        }
                    }
                    if song.id != viewModel.resolvedSongs.last?.id {
                        Divider()
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            saveButton
        }
    }

    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveAsSpotifyPlaylist()
            }
        } label: {
            HStack {
                if viewModel.isSavingPlaylist {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "plus.circle.fill")
                }
                Text(viewModel.isSavingPlaylist ? "Saving..." : "Save to Spotify")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.green)
            .cornerRadius(12)
        }
        .disabled(viewModel.isSavingPlaylist || viewModel.resolvedSongs.filter { $0.isResolved }.isEmpty)
        .padding(.top, 8)
    }
}

// MARK: - Blend Song Row

struct BlendSongRow: View {
    let song: ResolvedBlendSong
    let friendName: String
    let isPlaying: Bool
    let onPlay: () -> Void

    @State private var showingDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                // Album art
                if let track = song.track, let imageUrl = track.album.images.first?.url {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(4)
                    .overlay(playOverlay)
                } else {
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "music.note")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(4)
                }

                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    if let track = song.track {
                        Text(track.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color(.label))
                            .lineLimit(1)

                        Text(track.artists.first?.name ?? "")
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                            .lineLimit(1)
                    } else {
                        Text(song.recommendation.trackName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color(.tertiaryLabel))
                            .lineLimit(1)

                        Text("Not found on Spotify")
                            .font(.caption)
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }

                Spacer()

                // Blend score
                VStack(alignment: .trailing, spacing: 2) {
                    BlendScoreBadge(score: song.recommendation.blendScore)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingDetails.toggle()
                        }
                    } label: {
                        Image(systemName: showingDetails ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }

                // Play button
                if song.previewUrl != nil {
                    Button(action: onPlay) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding(12)

            if showingDetails {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.purple)
                            .frame(width: 16)
                        Text("You: \(song.recommendation.user1Affinity)")
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                    }

                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        Text("\(friendName): \(song.recommendation.user2Affinity)")
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var playOverlay: some View {
        if isPlaying {
            ZStack {
                Color.black.opacity(0.4)
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        SoundWaveBar(delay: Double(index) * 0.1)
                    }
                }
            }
            .cornerRadius(4)
        }
    }
}

// MARK: - Blend Score Badge

struct BlendScoreBadge: View {
    let score: Double

    var color: Color {
        if score >= 0.8 {
            return .green
        } else if score >= 0.5 {
            return .orange
        } else {
            return .purple
        }
    }

    var body: some View {
        Text("\(Int(score * 100))%")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .cornerRadius(4)
    }
}
