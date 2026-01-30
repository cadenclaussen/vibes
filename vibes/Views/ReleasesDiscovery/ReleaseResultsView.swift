import SwiftUI

struct ReleaseResultsView: View {
    @Bindable var viewModel: ReleasesDiscoveryViewModel

    var body: some View {
        Group {
            if viewModel.isLoadingReleases {
                loadingView
            } else if let error = viewModel.releasesError {
                errorView(error)
            } else if viewModel.releases.isEmpty {
                emptyStateView
            } else {
                releaseList
            }
        }
        .navigationTitle("Releases")
        .navigationBarTitleDisplayMode(.large)
    }

    private var releaseList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.releases) { rankedRelease in
                    ReleaseRow(rankedRelease: rankedRelease) {
                        openSpotify(rankedRelease.album.spotifyUri)
                    }
                    .padding(.horizontal)
                    Divider()
                        .padding(.leading, 84)
                }
            }
            .padding(.top)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Searching for releases...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("This may take a moment")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.findReleases()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Recent Releases", systemImage: "music.note.list")
        } description: {
            Text("No releases from the last month found for your selected artists. Try adding more artists or check back later.")
        }
    }

    private func openSpotify(_ uri: String?) {
        guard let uri = uri else { return }

        // try to open in Spotify app first
        if let spotifyURL = URL(string: uri),
           UIApplication.shared.canOpenURL(spotifyURL) {
            UIApplication.shared.open(spotifyURL)
            return
        }

        // fallback to web URL
        let albumId = uri.replacingOccurrences(of: "spotify:album:", with: "")
        if let webURL = URL(string: "https://open.spotify.com/album/\(albumId)") {
            UIApplication.shared.open(webURL)
        }
    }
}

#Preview {
    NavigationStack {
        ReleaseResultsView(viewModel: {
            let vm = ReleasesDiscoveryViewModel()
            vm.releases = [
                RankedRelease(
                    album: UnifiedAlbum(
                        id: "1",
                        name: "Certified Lover Boy",
                        artistName: "Drake",
                        albumArtURL: nil,
                        releaseDate: "2024-12-20",
                        totalTracks: 21,
                        spotifyUri: "spotify:album:123"
                    ),
                    artistRank: 1,
                    isNew: true
                ),
                RankedRelease(
                    album: UnifiedAlbum(
                        id: "2",
                        name: "Her Loss",
                        artistName: "Drake & 21 Savage",
                        albumArtURL: nil,
                        releaseDate: "2024-12-15",
                        totalTracks: 16,
                        spotifyUri: "spotify:album:456"
                    ),
                    artistRank: 1,
                    isNew: true
                ),
                RankedRelease(
                    album: UnifiedAlbum(
                        id: "3",
                        name: "Midnights (Deluxe)",
                        artistName: "Taylor Swift",
                        albumArtURL: nil,
                        releaseDate: "2025-01-15",
                        totalTracks: 20,
                        spotifyUri: "spotify:album:789"
                    ),
                    artistRank: 2,
                    isNew: false
                )
            ]
            vm.hasSearchedReleases = true
            return vm
        }())
    }
}
