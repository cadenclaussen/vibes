import SwiftUI

struct ArtistProfileView: View {
    let artist: UnifiedArtist

    @Environment(AppRouter.self) private var router
    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    @State private var viewModel: ArtistProfileViewModel

    private let spotifyService = SpotifyDataService.shared

    init(artist: UnifiedArtist) {
        self.artist = artist
        self._viewModel = State(wrappedValue: ArtistProfileViewModel(artist: artist))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isLoading {
                        // Show placeholder header while loading
                        ArtistHeaderView(artist: artist)
                        loadingView
                    } else if let error = viewModel.error {
                        ArtistHeaderView(artist: artist)
                        errorView(error)
                    } else {
                        // Show full header with loaded data
                        ArtistHeaderView(artist: viewModel.artist)
                        contentView
                    }

                    // Bottom padding for MiniPlayer
                    Spacer()
                        .frame(height: 100)
                }
            }
            .ignoresSafeArea(edges: .top)

            MiniPlayerView()
        }
        .navigationTitle(artist.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadData()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading artist data...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView(
            "Failed to Load Artist",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
        .padding(.top, 20)
    }

    private var contentView: some View {
        VStack(spacing: 24) {
            // Top Songs
            if !viewModel.topTracks.isEmpty {
                topSongsSection
            }

            // Albums
            if !viewModel.albums.isEmpty {
                ArtistAlbumsSection(
                    albums: viewModel.albums,
                    onAlbumTap: { album in
                        router.navigateToAlbumDetail(album)
                    }
                )
            }
        }
    }

    private var topSongsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                router.navigateToArtistTopSongs(artist: viewModel.artist)
            } label: {
                HStack {
                    Text("Top Songs")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
            .buttonStyle(.plain)

            LazyVStack(spacing: 0) {
                ForEach(viewModel.topTracks) { track in
                    SongSearchRow(
                        track: track,
                        onPlay: { viewModel.playTrack(track, using: spotifyRemote) },
                        onOpenInSpotify: {
                            if let uri = track.spotifyUri {
                                spotifyService.openInSpotify(uri: uri)
                            }
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ArtistProfileView(
            artist: UnifiedArtist(
                id: "3TVXtAsR1Inumwj472S9r4",
                name: "Drake",
                imageURL: nil,
                genres: ["hip-hop", "rap", "pop", "r&b"]
            )
        )
    }
    .environment(AppRouter())
    .environment(SpotifyRemoteService.shared)
}
