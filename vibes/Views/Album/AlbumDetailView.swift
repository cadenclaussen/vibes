import SwiftUI

struct AlbumDetailView: View {
    let album: UnifiedAlbum

    @Environment(AppRouter.self) private var router
    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    @State private var viewModel: AlbumDetailViewModel

    private let spotifyService = SpotifyDataService.shared

    init(album: UnifiedAlbum) {
        self.album = album
        self._viewModel = State(wrappedValue: AlbumDetailViewModel(album: album))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    AlbumHeaderView(
                        album: album,
                        trackCount: viewModel.trackCountText,
                        onArtistTap: { artist in navigateToArtist(artist) },
                        onPlayAll: { viewModel.playAll(using: spotifyRemote) },
                        onShuffle: { viewModel.shuffle(using: spotifyRemote) }
                    )

                    Divider()
                        .padding(.top, 16)

                    if viewModel.isLoading {
                        loadingView
                    } else if let error = viewModel.error {
                        errorView(error)
                    } else {
                        trackList
                    }

                    // Bottom padding for MiniPlayer
                    Spacer()
                        .frame(height: 100)
                }
            }

            MiniPlayerView()
        }
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadTracks()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading tracks...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView(
            "Failed to Load Tracks",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
        .padding(.top, 20)
    }

    private var trackList: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, track in
                AlbumTrackRow(
                    track: track,
                    trackNumber: index + 1,
                    onPlay: { viewModel.playTrack(track, using: spotifyRemote) },
                    onSendToFriend: { router.presentUserPicker(for: track) },
                    onAddToPlaylist: { router.presentPlaylistPicker(for: track) },
                    onOpenInSpotify: {
                        if let uri = track.spotifyUri {
                            spotifyService.openInSpotify(uri: uri)
                        }
                    }
                )
            }
        }
    }

    private func navigateToArtist(_ artistCredit: ArtistCredit) {
        let artist = UnifiedArtist(
            id: artistCredit.id,
            name: artistCredit.name
        )
        router.navigateToArtistDetail(artist)
    }
}

#Preview {
    NavigationStack {
        AlbumDetailView(
            album: UnifiedAlbum(
                id: "1",
                name: "Views",
                artistName: "Drake",
                artistId: "3TVXtAsR1Inumwj472S9r4",
                releaseDate: "2016-04-29",
                totalTracks: 20
            )
        )
    }
    .environment(AppRouter())
    .environment(SpotifyRemoteService.shared)
}
