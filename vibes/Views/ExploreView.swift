//
//  ExploreView.swift
//  vibes
//
//  Combined Search + Discover view.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(AppRouter.self) private var router
    @StateObject private var viewModel = ExploreViewModel()
    @StateObject private var musicServiceManager = MusicServiceManager.shared
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @StateObject private var ticketmasterService = TicketmasterService.shared
    @State private var showConcertSettings = false
    @State private var trackToSend: UnifiedTrack?
    @State private var trackToAddToPlaylist: UnifiedTrack?
    @State private var playlistToSend: UnifiedPlaylist?
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack(path: Binding(
            get: { router.explorePath },
            set: { router.explorePath = $0 }
        )) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    headerSection
                    searchSection

                    if !musicServiceManager.isAuthenticated {
                        connectMusicServiceSection
                    } else if viewModel.isInSearchMode {
                        searchResultsSection
                    } else {
                        discoveryContent
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.loadAllData()
            }
            .navigationDestination(for: UnifiedArtist.self) { artist in
                UnifiedArtistDetailView(artist: artist)
            }
            .navigationDestination(for: UnifiedAlbum.self) { album in
                UnifiedAlbumDetailView(album: album)
            }
            .navigationDestination(for: UnifiedPlaylist.self) { playlist in
                UnifiedPlaylistDetailView(playlist: playlist)
            }
        }
        .task {
            await viewModel.loadAllData()
        }
        .onChange(of: musicServiceManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task {
                    await viewModel.loadAllData()
                }
            }
        }
        .onChange(of: router.shouldFocusSearch) { _, shouldFocus in
            if shouldFocus {
                isSearchFocused = true
                router.shouldFocusSearch = false
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
        .sheet(isPresented: $showConcertSettings) {
            ConcertSettingsView()
        }
        .sheet(item: $trackToSend) { track in
            FriendPickerView(
                unifiedTrack: track,
                previewUrl: viewModel.getPreviewUrl(for: track),
                onSongSent: { friend in
                    router.navigate(to: .chat(friend))
                }
            )
        }
        .sheet(item: $trackToAddToPlaylist) { track in
            UnifiedPlaylistPickerView(track: track, onAdded: {})
        }
        .sheet(item: $playlistToSend) { playlist in
            FriendPickerView(
                unifiedPlaylist: playlist,
                onPlaylistSent: { friend in
                    router.navigate(to: .chat(friend))
                }
            )
        }
        .onChange(of: ticketmasterService.isConfigured) { _, isConfigured in
            if isConfigured {
                Task {
                    await viewModel.loadUpcomingConcerts()
                }
            }
        }
        .onChange(of: ticketmasterService.userCity) { _, _ in
            if ticketmasterService.isConfigured {
                Task {
                    await viewModel.loadUpcomingConcerts()
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Text("Explore")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 8)
    }

    // MARK: - Search Section

    private var searchSection: some View {
        VStack(spacing: 8) {
            searchBar
            if viewModel.isInSearchMode || !viewModel.searchText.isEmpty {
                searchTypeSelector
            }
        }
        .padding(.horizontal, 20)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search songs, artists, albums...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .focused($isSearchFocused)
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
    }

    private var searchTypeSelector: some View {
        Picker("Search Type", selection: $viewModel.selectedSearchType) {
            ForEach(UnifiedSearchType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 8)
        .onChange(of: viewModel.selectedSearchType) { _, _ in
            HapticService.selectionChanged()
            viewModel.onSearchTypeChanged()
        }
    }

    // MARK: - Search Results

    @ViewBuilder
    private var searchResultsSection: some View {
        Divider()
            .padding(.horizontal, 20)

        if viewModel.isSearching {
            searchLoadingView
        } else if let error = viewModel.searchError {
            searchErrorView(message: error)
        } else if !viewModel.hasSearchResults && viewModel.hasSearched {
            emptySearchResultsView
        } else if viewModel.searchText.isEmpty && !viewModel.recentSearches.isEmpty {
            recentSearchesView
        } else if !viewModel.hasSearchResults {
            searchInitialStateView
        } else {
            searchResultsList
        }
    }

    private var searchLoadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Searching...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }

    private func searchErrorView(message: String) -> some View {
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
        .frame(height: 300)
    }

    private var emptySearchResultsView: some View {
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
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }

    private var searchInitialStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Search for Music")
                .font(.headline)
            Text("Find songs, artists, albums, and playlists")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }

    private var recentSearchesView: some View {
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

    @ViewBuilder
    private var searchResultsList: some View {
        LazyVStack(spacing: 0) {
            switch viewModel.selectedSearchType {
            case .track:
                ForEach(viewModel.searchResults) { track in
                    UnifiedTrackRow(
                        track: track,
                        onSendTapped: { trackToSend = $0 },
                        onAddToPlaylistTapped: { trackToAddToPlaylist = $0 }
                    )
                    Divider()
                        .padding(.leading, 72)
                }
            case .artist:
                ForEach(viewModel.artistResults) { artist in
                    NavigationLink(value: artist) {
                        UnifiedArtistRow(artist: artist)
                    }
                    .buttonStyle(.plain)
                    Divider()
                        .padding(.leading, 72)
                }
            case .album:
                ForEach(viewModel.albumResults) { album in
                    NavigationLink(value: album) {
                        UnifiedAlbumRow(album: album)
                    }
                    .buttonStyle(.plain)
                    Divider()
                        .padding(.leading, 72)
                }
            case .playlist:
                ForEach(viewModel.playlistResults) { playlist in
                    NavigationLink(value: playlist) {
                        UnifiedPlaylistRow(playlist: playlist, onSendTapped: { playlistToSend = $0 })
                    }
                    .buttonStyle(.plain)
                    Divider()
                        .padding(.leading, 72)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Discovery Content

    @ViewBuilder
    private var discoveryContent: some View {
        if viewModel.isLoading {
            loadingSection
        } else {
            VStack(alignment: .leading, spacing: 24) {
                if !viewModel.recommendations.isEmpty || viewModel.isLoadingRecommendations {
                    forYouSection
                }

                if ticketmasterService.isConfigured || musicServiceManager.isAuthenticated {
                    concertsSection
                }

                let nothingLoading = !viewModel.isLoadingRecommendations
                if nothingLoading &&
                   viewModel.recommendations.isEmpty {
                    emptyStateSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }

    // MARK: - Connect Music Service

    private var connectMusicServiceSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 50))
                .foregroundColor(musicServiceManager.serviceColor)

            Text("Connect \(musicServiceManager.serviceName)")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Connect your music account to discover new music and see what your friends are listening to.")
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)

            Button {
                router.goToSettings()
            } label: {
                Text("Go to Settings")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(musicServiceManager.serviceColor)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
    }

    // MARK: - Loading Section

    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading your personalized feed...")
                .font(.caption)
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Empty State Section

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 50))
                .foregroundColor(Color(.tertiaryLabel))

            Text("Nothing to show yet")
                .font(.headline)

            Text("Start sharing songs with friends to see trending music here!")
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - For You Section

    private var forYouSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("For You")
                    .font(.headline)
                Spacer()
                Text("Popular from your top artists")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            if viewModel.isLoadingRecommendations && viewModel.recommendations.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 100)
                .padding()
                .cardStyle()
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.recommendations) { track in
                        UnifiedRecommendationRow(track: track)
                    }
                }
                .padding()
                .cardStyle()
            }
        }
    }

    // MARK: - Concerts Section

    private var concertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "ticket.fill")
                    .foregroundColor(.orange)
                Text("Upcoming Concerts")
                    .font(.headline)
                Spacer()
            }

            if ticketmasterService.isConfigured && !ticketmasterService.userCity.isEmpty {
                if viewModel.isLoadingConcerts && viewModel.upcomingConcerts.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .frame(height: 100)
                    .padding()
                    .cardStyle()
                } else if viewModel.upcomingConcerts.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "music.mic")
                            .font(.title)
                            .foregroundColor(Color(.tertiaryLabel))
                        Text("No upcoming concerts found")
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))
                        Text("We'll keep checking for your top artists near \(ticketmasterService.userCity)")
                            .font(.caption)
                            .foregroundColor(Color(.tertiaryLabel))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cardStyle()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.upcomingConcerts) { concert in
                                ConcertCard(concert: concert)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "ticket.fill")
                        .font(.title)
                        .foregroundColor(.orange)

                    Text("Find Concerts Near You")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Get notified about upcoming shows from your favorite artists")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)

                    Button {
                        showConcertSettings = true
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Set Up Concerts")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .cardStyle()
            }
        }
    }
}

#Preview {
    ExploreView()
        .environment(AppRouter())
        .environmentObject(AuthManager.shared)
}
