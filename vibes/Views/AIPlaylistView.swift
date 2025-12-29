import SwiftUI

struct AIPlaylistView: View {
    @StateObject private var viewModel = AIPlaylistViewModel()
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @StateObject private var musicServiceManager = MusicServiceManager.shared
    @State private var showingSaveSheet = false
    @State private var playlistName = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                if !viewModel.playlistSuggestions.isEmpty {
                    suggestionCardsSection
                }
                if viewModel.selectedSuggestion != nil {
                    songsSection
                }
            }
            .padding()
        }
        .navigationTitle("AI Playlists")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSaveSheet) {
            savePlaylistSheet
        }
        .alert("Playlist Created", isPresented: .constant(viewModel.savedPlaylistUrl != nil)) {
            Button("Open in \(musicServiceManager.serviceName)") {
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
            Text("Your playlist has been saved to \(musicServiceManager.serviceName)!")
        }
        .onAppear {
            audioPlayer.stop()
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("AI Playlist Ideas")
                .font(.title2)
                .fontWeight(.bold)

            Text("Get personalized playlist themes based on your listening history")
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)

            if viewModel.isGenerating {
                ProgressView("Analyzing your music taste...")
                    .padding(.top, 8)
            } else if viewModel.playlistSuggestions.isEmpty {
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

            if viewModel.remainingRequests < 10 {
                Text("\(viewModel.remainingRequests) AI requests remaining today")
                    .font(.caption)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }

    private var generateButton: some View {
        Button {
            HapticService.mediumImpact()
            Task {
                await viewModel.generatePlaylists()
                if viewModel.errorMessage == nil {
                    HapticService.success()
                } else {
                    HapticService.error()
                }
            }
        } label: {
            HStack {
                Image(systemName: "sparkles")
                Text("Generate Playlist Ideas")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.purple, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
        }
        .disabled(!viewModel.canGenerate)
        .opacity(viewModel.canGenerate ? 1 : 0.5)
    }

    private var suggestionCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Playlist Ideas")
                    .font(.headline)
                Spacer()
                Button {
                    Task {
                        await viewModel.generatePlaylists()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.purple)
                }
                .disabled(viewModel.isGenerating)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.playlistSuggestions) { suggestion in
                        PlaylistSuggestionCard(
                            suggestion: suggestion,
                            isSelected: viewModel.selectedSuggestion?.id == suggestion.id
                        ) {
                            Task {
                                await viewModel.selectSuggestion(suggestion)
                            }
                        }
                    }
                }
            }
        }
    }

    private var songsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let suggestion = viewModel.selectedSuggestion {
                VStack(alignment: .leading, spacing: 8) {
                    Text(suggestion.theme)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(suggestion.description)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestion.moodTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.15))
                                    .foregroundColor(.purple)
                                    
                            }
                        }
                    }
                }

                if viewModel.isResolvingSongs {
                    HStack {
                        ProgressView()
                        Text("Finding songs...")
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    .padding(.vertical, 20)
                } else if !viewModel.resolvedSongs.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(viewModel.resolvedSongs) { song in
                            ResolvedSongRow(
                                song: song,
                                isPlaying: audioPlayer.currentTrackId == song.unifiedTrack?.id && audioPlayer.isPlaying
                            ) {
                                if let previewUrl = song.previewUrl {
                                    audioPlayer.playUrl(previewUrl, trackId: song.unifiedTrack?.id ?? song.id)
                                }
                            }
                            if song.id != viewModel.resolvedSongs.last?.id {
                                Divider()
                            }
                        }
                    }
                    .cardStyle()
                    

                    saveButton
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            playlistName = viewModel.selectedSuggestion?.theme ?? "AI Playlist"
            showingSaveSheet = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Save to \(musicServiceManager.serviceName)")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(musicServiceManager.serviceColor)

        }
        .disabled(viewModel.isSavingPlaylist || viewModel.resolvedSongs.filter { $0.isResolved }.isEmpty)
        .padding(.top, 8)
    }

    private var savePlaylistSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Playlist name", text: $playlistName)
                } header: {
                    Text("Name")
                } footer: {
                    Text("\(viewModel.resolvedSongs.filter { $0.isResolved }.count) songs will be added")
                }
            }
            .navigationTitle("Save Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingSaveSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.savePlaylist(name: playlistName)
                            if viewModel.savedPlaylistUrl != nil {
                                // Track for achievements
                                LocalAchievementStats.shared.aiPlaylistsCreated += 1
                                LocalAchievementStats.shared.checkLocalAchievements()
                            }
                            showingSaveSheet = false
                        }
                    }
                    .disabled(playlistName.isEmpty || viewModel.isSavingPlaylist)
                }
            }
        }
        .presentationDetents([.height(200)])
    }
}

// MARK: - Playlist Suggestion Card

struct PlaylistSuggestionCard: View {
    let suggestion: PlaylistSuggestion
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(suggestion.theme)
                    .font(.headline)
                    .foregroundColor(Color(.label))
                    .lineLimit(2)

                Text(suggestion.description)
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
                    .lineLimit(3)

                Spacer()

                HStack {
                    Image(systemName: "music.note.list")
                        .foregroundColor(.purple)
                    Text("\(suggestion.suggestedSongs.count) songs")
                        .font(.caption)
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            .padding()
            .frame(width: 160, height: 140)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Resolved Song Row

struct ResolvedSongRow: View {
    let song: ResolvedSong
    let isPlaying: Bool
    let onPlay: () -> Void
    @StateObject var musicServiceManager = MusicServiceManager.shared
    @State private var showFriendPicker = false
    @State private var showPlaylistPicker = false

    var body: some View {
        HStack(spacing: 12) {
            // Album art or placeholder
            if let track = song.unifiedTrack, let imageUrl = track.album.imageUrl {
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
                if let track = song.unifiedTrack {
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
                    Text(song.suggestion.trackName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(.tertiaryLabel))
                        .lineLimit(1)

                    Text("\(song.suggestion.artistName) - Not found")
                        .font(.caption)
                        .foregroundColor(Color(.tertiaryLabel))
                        .lineLimit(1)
                }

                Text(song.suggestion.reason)
                    .font(.caption2)
                    .foregroundColor(.purple)
                    .lineLimit(1)
            }

            Spacer()

            // Show X if track not found
            if song.unifiedTrack == nil {
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .padding(12)
        .contentShape(Rectangle())
        .onTapGesture {
            if song.previewUrl != nil {
                onPlay()
            }
        }
        .contextMenu {
            if let track = song.unifiedTrack {
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
            if let track = song.unifiedTrack {
                FriendPickerView(unifiedTrack: track, previewUrl: song.previewUrl)
            }
        }
        .sheet(isPresented: $showPlaylistPicker) {
            if let track = song.unifiedTrack {
                UnifiedPlaylistPickerView(track: track) {}
            }
        }
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
