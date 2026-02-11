import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            FeedView()
                .tabItem {
                    Label(AppRouter.Tab.feed.title, systemImage: AppRouter.Tab.feed.icon)
                }
                .tag(AppRouter.Tab.feed)

            ExploreView()
                .tabItem {
                    Label(AppRouter.Tab.explore.title, systemImage: AppRouter.Tab.explore.icon)
                }
                .tag(AppRouter.Tab.explore)

            ProfileView()
                .tabItem {
                    Label(AppRouter.Tab.profile.title, systemImage: AppRouter.Tab.profile.icon)
                }
                .tag(AppRouter.Tab.profile)
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetContent(for: sheet)
        }
    }

    @ViewBuilder
    private func sheetContent(for sheet: AppRouter.Sheet) -> some View {
        switch sheet {
        case .shareSong(let track):
            ShareSheetView(track: track)
        case .userPicker(let track):
            ShareSheetView(track: track)
        case .playlistPicker(let track):
            PlaylistPickerSheet(track: track)
        case .aiPlaylist:
            AIPlaylistSheet()
        case .findUsers:
            UserSearchView()
        case .editProfile:
            EditProfileSheet()
        }
    }
}

// MARK: - Placeholder Views

struct FeedView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthManager.self) private var authManager
    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    @Environment(SetupManager.self) private var setupManager
    @State private var viewModel = FeedViewModel()
    @State private var followingCount = 0

    private let socialService = SocialService.shared

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.feedPath) {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Setup card - only show when not all complete
                        if !setupManager.isAllComplete {
                            SetupCard()
                                .padding(.horizontal)
                        }

                        // Find People and My Following cards
                        HStack(spacing: 12) {
                            FindPeopleCard {
                                router.presentFindUsers()
                            }

                            MyFollowingCard(count: followingCount) {
                                if let userId = authManager.user?.uid {
                                    router.navigateToFollowing(for: userId)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Feed content
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 40)
                        } else if viewModel.feedItems.isEmpty {
                            emptyFeedView
                        } else {
                            feedContentView
                        }

                        // Bottom padding for mini player
                        Color.clear.frame(height: 80)
                    }
                }
                .refreshable {
                    await viewModel.refreshFeed()
                }

                MiniPlayerView()
                    .animation(.easeInOut(duration: 0.2), value: spotifyRemote.currentTrack != nil)
            }
            .navigationTitle("Feed")
            .navigationDestination(for: UnifiedTrack.self) { track in
                SongDetailPlaceholder(track: track)
            }
            .navigationDestination(for: UserProfile.self) { user in
                UserProfileView(user: user)
            }
            .navigationDestination(for: Concert.self) { concert in
                ConcertDetailPlaceholder(concert: concert)
            }
            .navigationDestination(for: SettingsDestination.self) { destination in
                SettingsView()
            }
            .navigationDestination(for: SetupDestination.self) { destination in
                switch destination {
                case .checklist:
                    SetupChecklistView()
                case .spotify:
                    SpotifySetupView()
                case .gemini:
                    GeminiSetupView()
                case .ticketmaster:
                    TicketmasterSetupView()
                }
            }
            .navigationDestination(for: ConcertDiscoveryDestination.self) { _ in
                ConcertDiscoveryView()
            }
            .navigationDestination(for: ReleasesDiscoveryDestination.self) { _ in
                ReleasesDiscoveryView()
            }
            .navigationDestination(for: DiscoverMusicDestination.self) { _ in
                DiscoverMusicView()
            }
            .navigationDestination(for: UnifiedArtist.self) { artist in
                ArtistProfileView(artist: artist)
            }
            .navigationDestination(for: UnifiedAlbum.self) { album in
                AlbumDetailView(album: album)
            }
            .navigationDestination(for: SocialDestination.self) { destination in
                switch destination {
                case .followers(let userId):
                    FollowListView(viewModel: FollowViewModel(mode: .followers, userId: userId))
                case .following(let userId):
                    FollowListView(viewModel: FollowViewModel(mode: .following, userId: userId))
                }
            }
            .navigationDestination(for: ArtistTopSongsDestination.self) { destination in
                ArtistTopSongsView(artist: destination.artist)
            }
            .task {
                viewModel.setupManager = setupManager
                await viewModel.loadFeed()
                await loadFollowingCount()
            }
        }
    }

    private var emptyFeedView: some View {
        ContentUnavailableView(
            "Your Feed is Empty",
            systemImage: "music.note.list",
            description: Text("Follow friends and artists to see activity here")
        )
        .padding(.top, 40)
    }

    private var feedContentView: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.feedItems) { item in
                feedCard(for: item)
                Divider()
            }
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private func feedCard(for item: FeedItem) -> some View {
        switch item {
        case .songShare(let share):
            SongShareCard(share: share) {
                navigateToSender(share: share)
            }
        case .concert(let concert):
            ConcertFeedCard(concert: concert)
        case .newRelease(let album):
            ReleaseFeedCard(album: album)
        case .aiRecommendation(let track, let reason):
            RecommendationFeedCard(track: track, reason: reason)
        case .friendRecommendation(let track, let friends):
            FriendRecommendationCard(track: track, friendUsernames: friends)
                .padding(.horizontal)
        case .newFollow:
            EmptyView()
        }
    }

    private func navigateToSender(share: SongShare) {
        let senderProfile = UserProfile(
            uid: share.senderId,
            email: "",
            username: share.senderUsername,
            displayName: share.senderUsername,
            profilePictureURL: share.senderProfilePicture
        )
        router.navigateToUserProfile(senderProfile)
    }

    private func loadFollowingCount() async {
        guard let userId = authManager.user?.uid else { return }
        do {
            followingCount = try await socialService.getFollowingCount(for: userId)
        } catch {
            // Silently fail
        }
    }
}

struct FindPeopleCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "person.badge.plus")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text("Find People")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct MyFollowingCard: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.purple.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text("Following (\(count))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct ExploreView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    @State private var searchViewModel = SearchViewModel()
    @State private var isSearchFocused = false

    private let spotifyService = SpotifyDataService.shared

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.explorePath) {
            ZStack(alignment: .bottom) {
                Group {
                    if searchViewModel.isSearching {
                        loadingView
                    } else if let error = searchViewModel.error {
                        errorView(error)
                    } else if searchViewModel.showResults {
                        SearchResultsView(
                            artists: searchViewModel.artists,
                            albums: searchViewModel.albums,
                            tracks: searchViewModel.tracks,
                            onArtistTap: { artist in
                                router.navigateToArtistDetail(artist)
                            },
                            onAlbumTap: { album in
                                router.navigateToAlbumDetail(album)
                            },
                            onTrackPlay: { track in
                                playPreview(track)
                            },
                            onTrackOpenInSpotify: { track in
                                if let uri = track.spotifyUri {
                                    spotifyService.openInSpotify(uri: uri)
                                }
                            }
                        )
                    } else if searchViewModel.showRecentSearches {
                        ScrollView {
                            RecentSearchesView(
                                searches: searchViewModel.recentSearches,
                                onSelect: { search in
                                    searchViewModel.selectRecentSearch(search)
                                    searchViewModel.search()
                                },
                                onClear: {
                                    searchViewModel.clearRecentSearches()
                                }
                            )
                            .padding(.top)
                        }
                    } else {
                        defaultContent
                    }
                }

                MiniPlayerView()
                    .animation(.easeInOut(duration: 0.2), value: spotifyRemote.currentTrack != nil)
            }
            .navigationTitle("Explore")
            .searchable(
                text: Binding(
                    get: { searchViewModel.query },
                    set: { searchViewModel.query = $0 }
                ),
                isPresented: $isSearchFocused,
                prompt: "Search songs, artists, albums"
            )
            .onChange(of: searchViewModel.query) { _, _ in
                searchViewModel.search()
            }
            .navigationDestination(for: UnifiedTrack.self) { track in
                SongDetailPlaceholder(track: track)
            }
            .navigationDestination(for: UnifiedArtist.self) { artist in
                ArtistProfileView(artist: artist)
            }
            .navigationDestination(for: UnifiedAlbum.self) { album in
                AlbumDetailView(album: album)
            }
            .navigationDestination(for: Concert.self) { concert in
                ConcertDetailPlaceholder(concert: concert)
            }
            .navigationDestination(for: UserProfile.self) { user in
                UserProfileView(user: user)
            }
            .navigationDestination(for: SocialDestination.self) { destination in
                switch destination {
                case .followers(let userId):
                    FollowListView(viewModel: FollowViewModel(mode: .followers, userId: userId))
                case .following(let userId):
                    FollowListView(viewModel: FollowViewModel(mode: .following, userId: userId))
                }
            }
            .navigationDestination(for: ArtistTopSongsDestination.self) { destination in
                ArtistTopSongsView(artist: destination.artist)
            }
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Searching...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            Spacer()
        }
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView(
            "Search Failed",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
    }

    private var defaultContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("For You")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    ContentUnavailableView(
                        "Search for Music",
                        systemImage: "magnifyingglass",
                        description: Text("Find songs, artists, and albums")
                    )
                }
            }
            .padding(.top)
        }
    }

    private func playPreview(_ track: UnifiedTrack) {
        if spotifyRemote.currentTrack?.id == track.id {
            spotifyRemote.togglePlayPause()
        } else {
            spotifyRemote.play(track)
        }
    }
}

struct ProfileView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthManager.self) private var authManager
    @State private var statsViewModel = StatsViewModel()
    @State private var profileViewModel = ProfileViewModel()
    @State private var followerCount = 0
    @State private var followingCount = 0
    @State private var showEditSheet = false

    private let socialService = SocialService.shared

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.profilePath) {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 12) {
                        if let url = authManager.userProfile?.profilePictureURL,
                           let imageURL = URL(string: url) {
                            AsyncImage(url: imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.secondary)
                        }

                        VStack(spacing: 4) {
                            Text(authManager.userProfile?.displayName ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("@\(authManager.userProfile?.username ?? "username")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        // Bio
                        if let bio = authManager.userProfile?.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    .padding(.top)

                    // Follower/Following counts
                    HStack(spacing: 40) {
                        Button {
                            if let userId = authManager.user?.uid {
                                router.navigateToFollowers(for: userId)
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(followerCount)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("Followers")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            if let userId = authManager.user?.uid {
                                router.navigateToFollowing(for: userId)
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(followingCount)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("Following")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Genre chips
                    GenreChipsView(
                        genres: profileViewModel.topGenres,
                        isLoading: profileViewModel.isLoadingGenres
                    )

                    // Your Stats card
                    StatsPreviewCard(viewModel: statsViewModel)
                        .padding(.horizontal)

                    // Setup cards
                    VStack(spacing: 12) {
                        if !authManager.isSpotifyLinked {
                            PromptCard(
                                title: "Connect Spotify",
                                message: "Get personalized recommendations",
                                buttonTitle: "Connect",
                                action: { router.navigateToSettings() }
                            )
                        }

                        if !authManager.isGeminiConfigured {
                            PromptCard(
                                title: "Enable AI Features",
                                message: "Add your Gemini API key for AI playlists",
                                buttonTitle: "Setup",
                                action: { router.navigateToSettings() }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showEditSheet = true
                    } label: {
                        Text("Edit")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.navigateToSettings()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let profile = authManager.userProfile {
                    EditProfileView(profile: profile) {
                        // Refresh genres after profile update
                        await profileViewModel.refreshGenres()
                    }
                }
            }
            .navigationDestination(for: SettingsDestination.self) { _ in
                SettingsView()
            }
            .navigationDestination(for: StatsDestination.self) { _ in
                StatsView()
            }
            .navigationDestination(for: UserProfile.self) { user in
                UserProfileView(user: user)
            }
            .navigationDestination(for: SocialDestination.self) { destination in
                switch destination {
                case .followers(let userId):
                    FollowListView(viewModel: FollowViewModel(mode: .followers, userId: userId))
                case .following(let userId):
                    FollowListView(viewModel: FollowViewModel(mode: .following, userId: userId))
                }
            }
            .navigationDestination(for: UnifiedArtist.self) { artist in
                ArtistProfileView(artist: artist)
            }
            .navigationDestination(for: ArtistTopSongsDestination.self) { destination in
                ArtistTopSongsView(artist: destination.artist)
            }
            .task {
                await loadFollowCounts()
                await profileViewModel.loadGenres()
            }
        }
    }

    private func loadFollowCounts() async {
        guard let userId = authManager.user?.uid else { return }
        do {
            async let followers = socialService.getFollowerCount(for: userId)
            async let following = socialService.getFollowingCount(for: userId)
            followerCount = try await followers
            followingCount = try await following
        } catch {
            // Silently fail
        }
    }
}

// MARK: - Supporting Views

struct PromptCard: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Placeholder Detail Views

struct SongDetailPlaceholder: View {
    let track: UnifiedTrack

    var body: some View {
        Text("Song: \(track.name)")
            .navigationTitle(track.name)
    }
}

struct ArtistDetailPlaceholder: View {
    let artist: UnifiedArtist

    var body: some View {
        Text("Artist: \(artist.name)")
            .navigationTitle(artist.name)
    }
}

struct AlbumDetailPlaceholder: View {
    let album: UnifiedAlbum

    var body: some View {
        Text("Album: \(album.name)")
            .navigationTitle(album.name)
    }
}

struct ConcertDetailPlaceholder: View {
    let concert: Concert

    var body: some View {
        Text("Concert: \(concert.artistName)")
            .navigationTitle(concert.artistName)
    }
}


struct SettingsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Music Services") {
                HStack {
                    Label("Spotify", systemImage: "music.note")
                    Spacer()
                    if authManager.isSpotifyLinked {
                        Text("Connected")
                            .foregroundStyle(.green)
                    } else {
                        Button("Connect") {
                            // TODO: Connect Spotify
                        }
                    }
                }

                HStack {
                    Label("Gemini API Key", systemImage: "sparkles")
                    Spacer()
                    if authManager.isGeminiConfigured {
                        Text("Configured")
                            .foregroundStyle(.green)
                    } else {
                        Button("Add Key") {
                            // TODO: Add Gemini key
                        }
                    }
                }
            }

            Section("Concerts") {
                HStack {
                    Label("City", systemImage: "location")
                    Spacer()
                    Text(authManager.userProfile?.concertCity ?? "Not set")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Account") {
                Button(role: .destructive) {
                    try? authManager.signOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Placeholder Sheets


struct PlaylistPickerSheet: View {
    let track: UnifiedTrack
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Add to playlist: \(track.name)")
                .navigationTitle("Add to Playlist")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

struct AIPlaylistSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("AI Playlist Generator")
                .navigationTitle("AI Playlist")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}


struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Edit Profile")
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppRouter())
        .environment(AuthManager.shared)
        .environment(SetupManager())
}
