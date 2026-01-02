import Foundation
import SwiftUI
import Combine

@Observable
class ConcertDiscoveryViewModel {
    // MARK: - State

    var artists: [RankedArtist] = []
    var concerts: [RankedConcert] = []
    var searchQuery: String = ""
    var searchResults: [UnifiedArtist] = []

    var isLoadingArtists: Bool = false
    var isLoadingConcerts: Bool = false
    var isSearching: Bool = false

    var artistsError: Error?
    var concertsError: Error?
    var searchError: Error?

    var hasSearchedConcerts: Bool = false

    // MARK: - Private

    private var searchTask: Task<Void, Never>?
    private let persistenceKey = "concertDiscoveryArtists"
    private let maxArtists = 20

    // MARK: - Computed Properties

    var canAddArtist: Bool {
        artists.count < maxArtists
    }

    var artistCount: Int {
        artists.count
    }

    var canFindConcerts: Bool {
        !artists.isEmpty && !isLoadingConcerts
    }

    var isSpotifyConnected: Bool {
        SpotifyAuthService.shared.isAuthenticated
    }

    var hasTicketmasterKey: Bool {
        KeychainManager.shared.getTicketmasterApiKey() != nil
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

    func findConcerts() async {
        if artists.isEmpty {
            return
        }

        isLoadingConcerts = true
        concertsError = nil
        hasSearchedConcerts = false

        let homeCity = UserDefaults.standard.string(forKey: "concertCity")

        do {
            concerts = try await TicketmasterService.shared.searchConcertsForArtists(
                artists: artists,
                homeCity: homeCity
            )
            hasSearchedConcerts = true
        } catch {
            concertsError = error
        }

        isLoadingConcerts = false
    }

    func resetToSpotifyArtists() async {
        clearSavedArtists()
        artists = []
        concerts = []
        hasSearchedConcerts = false
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
