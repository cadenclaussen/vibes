import SwiftUI

struct StatsView: View {
    @State private var viewModel = StatsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.topArtists.isEmpty {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else {
                statsContent
            }
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
                        viewModel.openArtistInSpotify(artist)
                    }
                }

                if !viewModel.topSongs.isEmpty {
                    TopSongsSection(songs: viewModel.topSongs) { song in
                        viewModel.openTrackInSpotify(song)
                    }
                }

                if !viewModel.topGenres.isEmpty {
                    TopGenresSection(genres: viewModel.topGenres)
                }

                if !viewModel.recentlyPlayed.isEmpty {
                    RecentlyPlayedSection(tracks: viewModel.recentlyPlayed) { track in
                        viewModel.openTrackInSpotify(track)
                    }
                }
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
        ContentUnavailableView {
            Label("Couldn't Load Stats", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.loadStats()
                }
            }
            .buttonStyle(.borderedProminent)
        }
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
