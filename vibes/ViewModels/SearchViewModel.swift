import Foundation
import Combine

@Observable
class SearchViewModel {
    var query: String = ""
    var artists: [UnifiedArtist] = []
    var albums: [UnifiedAlbum] = []
    var tracks: [UnifiedTrack] = []

    var isSearching = false
    var hasSearched = false
    var error: Error?

    var recentSearches: [String] = []

    private var searchTask: Task<Void, Never>?
    private let spotifyService = SpotifyDataService.shared
    private let recentSearchesKey = "recentSearches"
    private let maxRecentSearches = 10

    init() {
        loadRecentSearches()
    }

    var showRecentSearches: Bool {
        query.isEmpty && !recentSearches.isEmpty && !hasSearched
    }

    var showResults: Bool {
        hasSearched && !query.isEmpty
    }

    var hasResults: Bool {
        !artists.isEmpty || !albums.isEmpty || !tracks.isEmpty
    }

    @MainActor
    func search() {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            clearResults()
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce

            if Task.isCancelled { return }

            isSearching = true
            error = nil

            do {
                let results = try await spotifyService.search(query: trimmed, limit: 5)

                if Task.isCancelled { return }

                artists = results.artists
                albums = results.albums
                tracks = results.tracks
                hasSearched = true
                addRecentSearch(trimmed)
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }

            isSearching = false
        }
    }

    @MainActor
    func clearSearch() {
        query = ""
        clearResults()
    }

    @MainActor
    func clearResults() {
        artists = []
        albums = []
        tracks = []
        hasSearched = false
        error = nil
    }

    func selectRecentSearch(_ search: String) {
        query = search
    }

    // MARK: - Recent Searches

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }

    func addRecentSearch(_ search: String) {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return }

        recentSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        recentSearches.insert(trimmed, at: 0)

        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }

        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    func removeRecentSearch(_ search: String) {
        recentSearches.removeAll { $0 == search }
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
}
