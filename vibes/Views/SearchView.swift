import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @ObservedObject var spotifyService = SpotifyService.shared
    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool
    @Binding var navigateToFriend: FriendProfile?
    @State private var trackToSend: Track?
    @State private var trackToAddToPlaylist: Track?
    @State private var playlistToSend: Playlist?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if spotifyService.isAuthenticated {
                    searchContent
                } else {
                    spotifyNotConnectedView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                audioPlayer.stop()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SettingsMenu(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                }
            }
            .navigationDestination(for: Artist.self) { artist in
                ArtistDetailView(artist: artist)
            }
            .navigationDestination(for: Album.self) { album in
                AlbumDetailView(album: album)
            }
            .navigationDestination(for: Playlist.self) { playlist in
                PlaylistDetailView(playlist: playlist)
            }
        }
    }

    private var searchContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Search")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 8)

            searchBar
            searchTypeSelector
            Divider()
            resultsView
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search \(viewModel.selectedSearchType.displayName.lowercased())...", text: $viewModel.searchText)
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
        .padding(12)
        .background(Color(.tertiarySystemFill))
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }

    private var searchTypeSelector: some View {
        Picker("Search Type", selection: $viewModel.selectedSearchType) {
            ForEach(SearchType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .onChange(of: viewModel.selectedSearchType) { _, _ in
            HapticService.selectionChanged()
            viewModel.onSearchTypeChanged()
        }
    }

    @ViewBuilder
    private var resultsView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(message: error)
        } else if !viewModel.hasResults && viewModel.hasSearched {
            emptyResultsView
        } else if viewModel.searchText.isEmpty && !viewModel.recentSearches.isEmpty {
            recentSearchesView
        } else if !viewModel.hasResults {
            initialStateView
        } else {
            resultsList
        }
    }

    // MARK: - Recent Searches

    private var recentSearchesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Recent")
                        .font(.headline)
                    Spacer()
                    Button("Clear") {
                        viewModel.clearRecentSearches()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                ForEach(viewModel.recentSearches, id: \.self) { query in
                    Button {
                        viewModel.selectRecentSearch(query)
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.secondary)
                            Text(query)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    Divider()
                        .padding(.leading, 48)
                }
            }
        }
    }

    // MARK: - State Views

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            Text("Find songs, artists, albums, and playlists")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    // MARK: - Results List

    @ViewBuilder
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                switch viewModel.selectedSearchType {
                case .track:
                    trackResultsList
                case .artist:
                    artistResultsList
                case .album:
                    albumResultsList
                case .playlist:
                    playlistResultsList
                }
            }
        }
        .sheet(item: $trackToSend) { track in
            FriendPickerView(
                track: track,
                previewUrl: viewModel.getPreviewUrl(for: track),
                onSongSent: { friend in
                    navigateToFriend = friend
                    selectedTab = 2  // Switch to Chats tab
                }
            )
        }
        .sheet(item: $trackToAddToPlaylist) { track in
            PlaylistPickerView(
                trackUri: track.uri,
                trackName: track.name,
                artistName: track.artists.map { $0.name }.joined(separator: ", "),
                albumArtUrl: track.album.images.first?.url,
                onAdded: {}
            )
        }
        .sheet(item: $playlistToSend) { playlist in
            FriendPickerView(
                playlist: playlist,
                onPlaylistSent: { friend in
                    navigateToFriend = friend
                    selectedTab = 2  // Switch to Chats tab
                }
            )
        }
    }

    private var trackResultsList: some View {
        ForEach(viewModel.searchResults) { track in
            TrackRow(
                track: track,
                viewModel: viewModel,
                onSendTapped: { selectedTrack in
                    trackToSend = selectedTrack
                },
                onAddToPlaylistTapped: { selectedTrack in
                    trackToAddToPlaylist = selectedTrack
                }
            )
            Divider()
                .padding(.leading, 72)
        }
    }

    private var artistResultsList: some View {
        ForEach(viewModel.artistResults) { artist in
            NavigationLink(value: artist) {
                ArtistRow(artist: artist)
            }
            .buttonStyle(.plain)
            Divider()
                .padding(.leading, 72)
        }
    }

    private var albumResultsList: some View {
        ForEach(viewModel.albumResults) { album in
            NavigationLink(value: album) {
                AlbumRow(album: album)
            }
            .buttonStyle(.plain)
            Divider()
                .padding(.leading, 72)
        }
    }

    private var playlistResultsList: some View {
        ForEach(viewModel.playlistResults) { playlist in
            NavigationLink(value: playlist) {
                PlaylistRow(playlist: playlist, onSendTapped: { playlist in
                    playlistToSend = playlist
                })
            }
            .buttonStyle(.plain)
            Divider()
                .padding(.leading, 72)
        }
    }

    // MARK: - Spotify Not Connected

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
                selectedTab = 3
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

#Preview {
    SearchView(selectedTab: .constant(1), shouldEditProfile: .constant(false), navigateToFriend: .constant(nil))
}
