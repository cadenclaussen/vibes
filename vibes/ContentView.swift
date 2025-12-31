import SwiftUI

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
            ShareSongSheet(track: track)
        case .userPicker(let track):
            UserPickerSheet(track: track)
        case .playlistPicker(let track):
            PlaylistPickerSheet(track: track)
        case .aiPlaylist:
            AIPlaylistSheet()
        case .findUsers:
            FindUsersSheet()
        case .editProfile:
            EditProfileSheet()
        }
    }
}

// MARK: - Placeholder Views

struct FeedView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.feedPath) {
            ScrollView {
                VStack(spacing: 16) {
                    if !authManager.isSpotifyLinked {
                        SetupCard(
                            title: "Connect Spotify",
                            message: "Link your Spotify account to unlock all features",
                            buttonTitle: "Connect",
                            action: { router.navigateToSettings() }
                        )
                        .padding(.horizontal)
                    }

                    ContentUnavailableView(
                        "No Activity Yet",
                        systemImage: "music.note.list",
                        description: Text("Follow friends and share songs to see activity here")
                    )
                    .padding(.top, 60)
                }
            }
            .navigationTitle("Feed")
            .navigationDestination(for: UnifiedTrack.self) { track in
                SongDetailPlaceholder(track: track)
            }
            .navigationDestination(for: UserProfile.self) { user in
                UserProfilePlaceholder(user: user)
            }
            .navigationDestination(for: Concert.self) { concert in
                ConcertDetailPlaceholder(concert: concert)
            }
            .navigationDestination(for: SettingsDestination.self) { destination in
                SettingsView()
            }
        }
    }
}

struct ExploreView: View {
    @Environment(AppRouter.self) private var router
    @State private var searchText = ""

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.explorePath) {
            ScrollView {
                VStack(spacing: 24) {
                    // For You section placeholder
                    VStack(alignment: .leading, spacing: 12) {
                        Text("For You")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ContentUnavailableView(
                            "Connect Spotify",
                            systemImage: "sparkles",
                            description: Text("Get personalized recommendations")
                        )
                    }

                    // Concerts section placeholder
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Concerts Near You")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ContentUnavailableView(
                            "Set Your City",
                            systemImage: "ticket",
                            description: Text("Set your city in Settings to discover concerts")
                        )
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search songs, artists, albums")
            .navigationDestination(for: UnifiedTrack.self) { track in
                SongDetailPlaceholder(track: track)
            }
            .navigationDestination(for: UnifiedArtist.self) { artist in
                ArtistDetailPlaceholder(artist: artist)
            }
            .navigationDestination(for: UnifiedAlbum.self) { album in
                AlbumDetailPlaceholder(album: album)
            }
            .navigationDestination(for: Concert.self) { concert in
                ConcertDetailPlaceholder(concert: concert)
            }
        }
    }
}

struct ProfileView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthManager.self) private var authManager

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
                    }
                    .padding(.top)

                    // Stats row placeholder
                    HStack(spacing: 40) {
                        StatItem(value: "0", label: "Following")
                        StatItem(value: "0", label: "Followers")
                    }

                    // Setup cards
                    VStack(spacing: 12) {
                        if !authManager.isSpotifyLinked {
                            SetupCard(
                                title: "Connect Spotify",
                                message: "Get personalized recommendations",
                                buttonTitle: "Connect",
                                action: { router.navigateToSettings() }
                            )
                        }

                        if !authManager.isGeminiConfigured {
                            SetupCard(
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.navigateToSettings()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: SettingsDestination.self) { _ in
                SettingsView()
            }
            .navigationDestination(for: UserProfile.self) { user in
                UserProfilePlaceholder(user: user)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct SetupCard: View {
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

struct UserProfilePlaceholder: View {
    let user: UserProfile

    var body: some View {
        Text("User: \(user.displayName)")
            .navigationTitle(user.displayName)
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

struct ShareSongSheet: View {
    let track: UnifiedTrack
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Share: \(track.name)")
                .navigationTitle("Share Song")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

struct UserPickerSheet: View {
    let track: UnifiedTrack
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Send to friend: \(track.name)")
                .navigationTitle("Send to Friend")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

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

struct FindUsersSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Find Users")
                .navigationTitle("Find Users")
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
}
