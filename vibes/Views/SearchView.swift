import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @ObservedObject var spotifyService = SpotifyService.shared
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool
    @Binding var navigateToFriend: FriendProfile?
    @State private var trackToSend: Track?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if spotifyService.isAuthenticated {
                    searchContent
                } else {
                    spotifyNotConnectedView
                }
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SettingsMenu(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                }
            }
        }
    }

    private var searchContent: some View {
        VStack(spacing: 0) {
            searchBar
            Divider()
            resultsView
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search songs, artists...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit {
                    viewModel.search()
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }

    @ViewBuilder
    private var resultsView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(message: error)
        } else if viewModel.searchResults.isEmpty && viewModel.hasSearched {
            emptyResultsView
        } else if viewModel.searchResults.isEmpty {
            initialStateView
        } else {
            resultsList
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Searching...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Search Failed")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                viewModel.search()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }

    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Results")
                .font(.headline)
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private var initialStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Search for Music")
                .font(.headline)
            Text("Find songs and artists on Spotify")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.searchResults) { track in
                    TrackRow(track: track, viewModel: viewModel) { selectedTrack in
                        trackToSend = selectedTrack
                    }
                    Divider()
                        .padding(.leading, 72)
                }
            }
        }
        .sheet(item: $trackToSend) { track in
            FriendPickerView(
                track: track,
                previewUrl: viewModel.getPreviewUrl(for: track),
                onSongSent: { friend in
                    navigateToFriend = friend
                    selectedTab = 1  // Switch to Friends tab
                }
            )
        }
    }

    private var spotifyNotConnectedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "music.note.house")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Connect to Spotify")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Link your Spotify account to search for songs and discover music")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                selectedTab = 3 // Go to Profile tab to connect Spotify
            } label: {
                HStack {
                    Image(systemName: "link")
                    Text("Go to Profile to Connect")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.green)
                .cornerRadius(25)
            }

            Spacer()
        }
    }
}

struct TrackRow: View {
    let track: Track
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @State private var showNoPreviewAlert = false
    let onSendTapped: (Track) -> Void

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
                sendButton
                durationLabel
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .opacity(hasPreview ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
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

            // Play/pause overlay when this track is active
            if isCurrentTrack {
                Rectangle()
                    .fill(.black.opacity(0.4))
                    .frame(width: 48, height: 48)

                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .frame(width: 48, height: 48)
            }

            // Progress bar at bottom
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

    private var sendButton: some View {
        Button {
            onSendTapped(track)
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.body)
                .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
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

#Preview {
    SearchView(selectedTab: .constant(0), shouldEditProfile: .constant(false), navigateToFriend: .constant(nil))
}
