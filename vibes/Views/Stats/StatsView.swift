import SwiftUI

struct StatsView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    @State private var viewModel = StatsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if viewModel.isLoading && viewModel.topArtists.isEmpty {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else {
                    statsContent
                }
            }

            MiniPlayerView()
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                timeRangePicker
            }
        }
        .task {
            if viewModel.topArtists.isEmpty {
                await viewModel.loadStats()
            }
        }
    }

    private var statsContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !viewModel.topArtists.isEmpty {
                    TopArtistsSection(artists: viewModel.topArtists) { artist in
                        router.navigateToArtistDetail(artist)
                    }
                }

                if !viewModel.topSongs.isEmpty {
                    TopSongsSection(
                        songs: viewModel.topSongs,
                        onSongTap: { song in
                            spotifyRemote.playWithQueue(song, queue: viewModel.topSongs)
                        },
                        onShare: { song in
                            router.presentShareSheet(for: song)
                        },
                        onOpenInSpotify: { song in
                            if let uri = song.spotifyUri {
                                SpotifyDataService.shared.openInSpotify(uri: uri)
                            }
                        }
                    )
                }

                if !viewModel.topGenres.isEmpty {
                    TopGenresSection(genres: viewModel.topGenres)
                }

                if !viewModel.recentlyPlayed.isEmpty {
                    RecentlyPlayedSection(
                        tracks: viewModel.recentlyPlayed,
                        onTrackTap: { track in
                            let allTracks = viewModel.recentlyPlayed.map { $0.track }
                            spotifyRemote.playWithQueue(track, queue: allTracks)
                        },
                        onShare: { track in
                            router.presentShareSheet(for: track)
                        },
                        onOpenInSpotify: { track in
                            if let uri = track.spotifyUri {
                                SpotifyDataService.shared.openInSpotify(uri: uri)
                            }
                        }
                    )
                }

                // Bottom padding for MiniPlayer
                Spacer()
                    .frame(height: 80)
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading your stats...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        let isAuthError = isSpotifyAuthError(error)

        return ContentUnavailableView {
            Label(
                isAuthError ? "Spotify Disconnected" : "Couldn't Load Stats",
                systemImage: isAuthError ? "link.badge.plus" : "exclamationmark.triangle"
            )
        } description: {
            Text(isAuthError
                 ? "Your Spotify session has expired or is missing permissions. Please reconnect to load your stats."
                 : error.localizedDescription)
        } actions: {
            if isAuthError {
                Button("Reconnect Spotify") {
                    router.navigateToSpotifySetup()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Try Again") {
                    Task {
                        await viewModel.loadStats()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func isSpotifyAuthError(_ error: Error) -> Bool {
        if let authError = error as? SpotifyAuthError {
            switch authError {
            case .notAuthenticated:
                return true
            case .tokenExchangeFailed(let message):
                let lower = message.lowercased()
                return lower.contains("revoked") || lower.contains("invalid") || lower.contains("expired")
            default:
                return false
            }
        }
        if let dataError = error as? SpotifyDataError {
            switch dataError {
            case .notAuthenticated, .forbidden:
                return true
            default:
                return false
            }
        }
        return false
    }

    private var timeRangePicker: some View {
        Menu {
            ForEach([SpotifyTimeRange.shortTerm, .mediumTerm, .longTerm], id: \.rawValue) { range in
                Button {
                    Task {
                        await viewModel.setTimeRange(range)
                    }
                } label: {
                    HStack {
                        Text(displayName(for: range))
                        if viewModel.timeRange == range {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.timeRangeDisplayName)
                    .font(.subheadline)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(.primary)
        }
    }

    private func displayName(for range: SpotifyTimeRange) -> String {
        switch range {
        case .shortTerm: return "4 Weeks"
        case .mediumTerm: return "6 Months"
        case .longTerm: return "All Time"
        }
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
    .environment(AppRouter())
    .environment(AuthManager.shared)
}
