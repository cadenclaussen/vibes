import Foundation
import SwiftUI
import Combine

@Observable
class ReleasesDiscoveryViewModel {
    // MARK: - State

    var artists: [RankedArtist] = []
    var releases: [RankedRelease] = []
    var searchQuery: String = ""
    var searchResults: [UnifiedArtist] = []

    var isLoadingArtists: Bool = false
    var isLoadingReleases: Bool = false
    var isSearching: Bool = false

    var artistsError: Error?
    var releasesError: Error?
    var searchError: Error?

    var hasSearchedReleases: Bool = false

    // MARK: - Private

    private var searchTask: Task<Void, Never>?
    private let persistenceKey = "releasesDiscoveryArtists"
    private let maxArtists = 20

    // MARK: - Computed Properties

    var canAddArtist: Bool {
        artists.count < maxArtists
    }

    var artistCount: Int {
        artists.count
    }

    var canFindReleases: Bool {
        !artists.isEmpty && !isLoadingReleases
    }

    var isSpotifyConnected: Bool {
        SpotifyAuthService.shared.isAuthenticated
    }

    // MARK: - Actions

    func loadTopArtists() async {
        if loadSavedArtists() {
            return
        }

        if !isSpotifyConnected {
            return
        }

        isLoadingArtists = true
        artistsError = nil

        do {
            let topArtists = try await SpotifyDataService.shared.getTopArtists(
                limit: 10,
                timeRange: .mediumTerm
            )

            artists = topArtists.enumerated().map { index, artist in
                RankedArtist(artist: artist, rank: index + 1)
            }

            saveArtists()
        } catch {
            artistsError = error
        }

        isLoadingArtists = false
    }

    func searchArtists(query: String) {
        searchTask?.cancel()

        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        searchError = nil

        searchTask = Task {
            // Debounce 300ms
            try? await Task.sleep(nanoseconds: 300_000_000)

            if Task.isCancelled { return }

            do {
                let results = try await SpotifyDataService.shared.searchArtists(
                    query: query,
                    limit: 10
                )

                if Task.isCancelled { return }

                await MainActor.run {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                if Task.isCancelled { return }

                await MainActor.run {
                    self.searchError = error
                    self.isSearching = false
                }
            }
        }
    }

    func addArtist(_ artist: UnifiedArtist) {
        if !canAddArtist {
            return
        }

        if artists.contains(where: { $0.artist.id == artist.id }) {
            return
        }

        let newRank = artists.count + 1
        let rankedArtist = RankedArtist(artist: artist, rank: newRank)
        artists.append(rankedArtist)

        searchQuery = ""
        searchResults = []

        saveArtists()
    }

    func removeArtist(at offsets: IndexSet) {
        artists.remove(atOffsets: offsets)
        reRankArtists()
        saveArtists()
    }

    func removeArtist(_ artist: RankedArtist) {
        artists.removeAll { $0.id == artist.id }
        reRankArtists()
        saveArtists()
    }

    func moveArtist(from source: IndexSet, to destination: Int) {
        artists.move(fromOffsets: source, toOffset: destination)
        reRankArtists()
        saveArtists()
    }

    func findReleases() async {
        if artists.isEmpty {
            return
        }

        isLoadingReleases = true
        releasesError = nil
        hasSearchedReleases = false

        do {
            releases = try await SpotifyDataService.shared.getReleasesForArtists(
                artists: artists
            )
            hasSearchedReleases = true
        } catch {
            releasesError = error
        }

        isLoadingReleases = false
    }

    func resetToSpotifyArtists() async {
        clearSavedArtists()
        artists = []
        releases = []
        hasSearchedReleases = false
        await loadTopArtists()
    }

    func isArtistAlreadyAdded(_ artist: UnifiedArtist) -> Bool {
        artists.contains { $0.artist.id == artist.id }
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        searchTask?.cancel()
        isSearching = false
    }

    // MARK: - Persistence

    func saveArtists() {
        do {
            let data = try JSONEncoder().encode(artists)
            UserDefaults.standard.set(data, forKey: persistenceKey)
        } catch {
            print("Failed to save artists: \(error)")
        }
    }

    @discardableResult
    func loadSavedArtists() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey) else {
            return false
        }

        do {
            artists = try JSONDecoder().decode([RankedArtist].self, from: data)
            return !artists.isEmpty
        } catch {
            print("Failed to load saved artists: \(error)")
            return false
        }
    }

    func clearSavedArtists() {
        UserDefaults.standard.removeObject(forKey: persistenceKey)
    }

    // MARK: - Private Helpers

    private func reRankArtists() {
        for (index, _) in artists.enumerated() {
            artists[index].rank = index + 1
        }
    }
}
