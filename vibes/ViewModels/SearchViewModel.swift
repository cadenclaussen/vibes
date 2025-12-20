import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Track] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasSearched = false
    @Published var iTunesPreviews: [String: String] = [:] // Track ID -> iTunes preview URL

    private let spotifyService = SpotifyService.shared
    private let itunesService = iTunesService.shared
    private var searchTask: Task<Void, Never>?

    var isSpotifyConnected: Bool {
        spotifyService.isAuthenticated
    }

    func getPreviewUrl(for track: Track) -> String? {
        // Prefer Spotify preview, fall back to iTunes
        return track.previewUrl ?? iTunesPreviews[track.id]
    }

    func search() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            searchResults = []
            hasSearched = false
            iTunesPreviews = [:]
            return
        }

        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            errorMessage = nil
            hasSearched = true
            iTunesPreviews = [:]

            do {
                let results = try await spotifyService.searchTracks(query: query, limit: 30)
                if !Task.isCancelled {
                    searchResults = results
                    // Fetch iTunes previews for tracks without Spotify previews
                    await fetchItunesPreviews(for: results)
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                    searchResults = []
                }
            }

            if !Task.isCancelled {
                isLoading = false
            }
        }
    }

    private func fetchItunesPreviews(for tracks: [Track]) async {
        // Only fetch for tracks without Spotify preview
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
        searchResults = []
        hasSearched = false
        errorMessage = nil
        iTunesPreviews = [:]
    }
}
