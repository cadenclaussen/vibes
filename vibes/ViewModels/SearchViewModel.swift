import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedSearchType: SearchType = .track
    @Published var searchResults: [Track] = []
    @Published var artistResults: [Artist] = []
    @Published var albumResults: [Album] = []
    @Published var playlistResults: [Playlist] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasSearched = false
    @Published var iTunesPreviews: [String: String] = [:]
    @Published var recentSearches: [String] = []

    private let spotifyService = SpotifyService.shared
    private let itunesService = iTunesService.shared
    private var searchTask: Task<Void, Never>?

    private let recentSearchesKey = "recentSearches"
    private let maxRecentSearches = 10

    var isSpotifyConnected: Bool {
        spotifyService.isAuthenticated
    }

    init() {
        loadRecentSearches()
    }

    func getPreviewUrl(for track: Track) -> String? {
        return track.previewUrl ?? iTunesPreviews[track.id]
    }

    // MARK: - Recent Searches

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }

    private func saveRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Remove if already exists, then add to front
        recentSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        recentSearches.insert(trimmed, at: 0)

        // Keep only last N searches
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }

        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }

    func selectRecentSearch(_ query: String) {
        searchText = query
        search()
    }

    // MARK: - Search

    func search() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            clearResults()
            return
        }

        saveRecentSearch(query)

        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            errorMessage = nil
            hasSearched = true

            do {
                switch selectedSearchType {
                case .track:
                    iTunesPreviews = [:]
                    let results = try await spotifyService.searchTracks(query: query, limit: 30)
                    if !Task.isCancelled {
                        searchResults = results
                        await fetchItunesPreviews(for: results)
                    }
                case .artist:
                    let results = try await spotifyService.searchArtists(query: query, limit: 30)
                    if !Task.isCancelled {
                        artistResults = results
                    }
                case .album:
                    let results = try await spotifyService.searchAlbums(query: query, limit: 30)
                    if !Task.isCancelled {
                        albumResults = results
                    }
                case .playlist:
                    let results = try await spotifyService.searchPlaylists(query: query, limit: 30)
                    if !Task.isCancelled {
                        playlistResults = results
                    }
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                    clearResultsForCurrentType()
                }
            }

            if !Task.isCancelled {
                isLoading = false
            }
        }
    }

    private func fetchItunesPreviews(for tracks: [Track]) async {
        let tracksNeedingPreview = tracks.filter { $0.previewUrl == nil }
        if tracksNeedingPreview.isEmpty { return }

        let trackData = tracksNeedingPreview.map { track in
            (id: track.id, name: track.name, artist: track.artists.first?.name ?? "")
        }

        let previews = await itunesService.searchPreviews(for: trackData)
        if !Task.isCancelled {
            iTunesPreviews = previews
        }
    }

    func clearSearch() {
        searchText = ""
        clearResults()
    }

    private func clearResults() {
        searchResults = []
        artistResults = []
        albumResults = []
        playlistResults = []
        hasSearched = false
        errorMessage = nil
        iTunesPreviews = [:]
    }

    private func clearResultsForCurrentType() {
        switch selectedSearchType {
        case .track:
            searchResults = []
        case .artist:
            artistResults = []
        case .album:
            albumResults = []
        case .playlist:
            playlistResults = []
        }
    }

    func onSearchTypeChanged() {
        // Re-search with new type if there's a query
        if !searchText.isEmpty && hasSearched {
            search()
        }
    }

    var hasResults: Bool {
        switch selectedSearchType {
        case .track:
            return !searchResults.isEmpty
        case .artist:
            return !artistResults.isEmpty
        case .album:
            return !albumResults.isEmpty
        case .playlist:
            return !playlistResults.isEmpty
        }
    }
}
