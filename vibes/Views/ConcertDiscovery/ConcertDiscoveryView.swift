import SwiftUI

struct ConcertDiscoveryView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel = ConcertDiscoveryViewModel()
    @State private var isEditing = false
    @State private var showingResults = false

    var body: some View {
        ZStack {
            mainContent
            searchOverlay
        }
        .navigationTitle("Discover Concerts")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isEditing.toggle()
                    } label: {
                        Label(
                            isEditing ? "Done Editing" : "Edit Order",
                            systemImage: isEditing ? "checkmark" : "arrow.up.arrow.down"
                        )
                    }

                    Button {
                        Task {
                            await viewModel.resetToSpotifyArtists()
                        }
                    } label: {
                        Label("Reset to Top Artists", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await viewModel.loadTopArtists()
        }
        .navigationDestination(isPresented: $showingResults) {
            ConcertResultsView(viewModel: viewModel)
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            searchBar
                .padding()

            if viewModel.isLoadingArtists {
                loadingView
            } else if let error = viewModel.artistsError {
                errorView(error)
            } else if !viewModel.isSpotifyConnected && viewModel.artists.isEmpty {
                spotifyPromptView
            } else if viewModel.artists.isEmpty {
                emptyStateView
            } else {
                artistList
            }

            Spacer()

            findConcertsButton
                .padding()
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search artists to add", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchQuery) { _, newValue in
                    viewModel.searchArtists(query: newValue)
                }

            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.isSearching {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private var searchOverlay: some View {
        if !viewModel.searchResults.isEmpty {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 70)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.searchResults) { artist in
                            ArtistSearchResultRow(
                                artist: artist,
                                isAlreadyAdded: viewModel.isArtistAlreadyAdded(artist),
                                canAdd: viewModel.canAddArtist,
                                onAdd: {
                                    viewModel.addArtist(artist)
                                }
                            )
                            Divider()
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 8)
                .padding(.horizontal)
                .frame(maxHeight: 300)

                Spacer()
            }
            .transition(.opacity)
        }
    }

    private var artistList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(viewModel.artistCount)/20 artists")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)

            List {
                ForEach(Array(viewModel.artists.enumerated()), id: \.element.id) { index, artist in
                    ArtistRow(rankedArtist: artist, displayRank: index + 1) {
                        viewModel.removeArtist(artist)
                    }
                }
                .onMove(perform: viewModel.moveArtist)
                .onDelete(perform: viewModel.removeArtist)
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading your top artists...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        let isAuthError = isSpotifyAuthError(error)

        return ContentUnavailableView {
            Label(
                isAuthError ? "Spotify Disconnected" : "Error",
                systemImage: isAuthError ? "link.badge.plus" : "exclamationmark.triangle"
            )
        } description: {
            Text(isAuthError
                 ? "Your Spotify session has expired. Please reconnect to load your top artists."
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
                        await viewModel.loadTopArtists()
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
        return false
    }

    private var spotifyPromptView: some View {
        ContentUnavailableView {
            Label("Connect Spotify", systemImage: "music.note")
        } description: {
            Text("Connect your Spotify account to see your top artists, or search to add artists manually.")
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Artists", systemImage: "music.mic")
        } description: {
            Text("Search above to add artists you want to find concerts for.")
        }
    }

    private var findConcertsButton: some View {
        Button {
            Task {
                await viewModel.findConcerts()
                if viewModel.concertsError == nil {
                    showingResults = true
                }
            }
        } label: {
            HStack {
                if viewModel.isLoadingConcerts {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "ticket.fill")
                    Text("Find Concerts")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canFindConcerts ? Color.accentColor : Color.gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.canFindConcerts || viewModel.isLoadingConcerts)
    }
}

#Preview {
    NavigationStack {
        ConcertDiscoveryView()
    }
    .environment(AppRouter())
}
