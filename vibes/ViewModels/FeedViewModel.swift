import Foundation

@Observable
@MainActor
class FeedViewModel {
    var feedItems: [FeedItem] = []
    var isLoading = false
    var error: Error?

    private let artistFollowService = ArtistFollowService.shared
    private let socialService = SocialService.shared
    private let spotifyService = SpotifyDataService.shared
    private let ticketmasterService = TicketmasterService.shared
    var setupManager: SetupManager?

    // Content limits
    private let maxConcerts = 5
    private let maxReleases = 5
    private let maxRecommendations = 3

    init() {}

    func loadFeed() async {
        isLoading = true
        error = nil

        var allItems: [FeedItem] = []

        // Get artists to use for discovery (followed artists first, then Spotify top artists)
        let rankedArtists = await getArtistsForDiscovery()

        // Fetch all content types in parallel
        async let sharesTask = fetchSongShares()
        async let concertsTask = fetchConcerts(artists: rankedArtists)
        async let releasesTask = fetchReleases(artists: rankedArtists)
        async let recommendationsTask = fetchRecommendations()

        let (shares, concerts, releases, recommendations) = await (
            sharesTask,
            concertsTask,
            releasesTask,
            recommendationsTask
        )

        allItems.append(contentsOf: shares)
        allItems.append(contentsOf: concerts)
        allItems.append(contentsOf: releases)
        allItems.append(contentsOf: recommendations)

        // Sort by sortScore (higher = shown first)
        allItems.sort { $0.sortScore > $1.sortScore }

        feedItems = allItems
        isLoading = false
    }

    func refreshFeed() async {
        // Clear caches for fresh data
        artistFollowService.clearCache()

        await loadFeed()
    }

    // MARK: - Private Methods

    private func getArtistsForDiscovery() async -> [RankedArtist] {
        // Try followed artists first
        do {
            let followedArtists = try await artistFollowService.getFollowedArtistsAsRanked()
            if !followedArtists.isEmpty {
                return followedArtists
            }
        } catch {
            // Fall through to Spotify top artists
        }

        // Fall back to Spotify top artists if no followed artists
        guard setupManager?.isSpotifyComplete == true else {
            return []
        }

        do {
            let topArtists = try await spotifyService.getTopArtists(limit: 10, timeRange: .mediumTerm)
            return topArtists.enumerated().map { index, artist in
                RankedArtist(artist: artist, rank: index + 1)
            }
        } catch {
            return []
        }
    }

    private func fetchSongShares() async -> [FeedItem] {
        do {
            let shares = try await socialService.getSharesFromFollowing(limit: 50)
            return shares.map { FeedItem.songShare($0) }
        } catch {
            return []
        }
    }

    private func fetchConcerts(artists: [RankedArtist]) async -> [FeedItem] {
        guard setupManager?.isTicketmasterComplete == true, !artists.isEmpty else {
            return []
        }

        let homeCity = setupManager?.concertCity

        do {
            let rankedConcerts = try await ticketmasterService.searchConcertsForArtists(
                artists: Array(artists.prefix(5)), // Limit API calls
                homeCity: homeCity
            )

            // Filter to future concerts only and limit count
            let now = Date()
            let futureConcerts = rankedConcerts
                .filter { $0.concert.date > now }
                .prefix(maxConcerts)

            return futureConcerts.map { FeedItem.concert($0.concert) }
        } catch {
            return []
        }
    }

    private func fetchReleases(artists: [RankedArtist]) async -> [FeedItem] {
        guard setupManager?.isSpotifyComplete == true, !artists.isEmpty else {
            return []
        }

        do {
            let rankedReleases = try await spotifyService.getReleasesForArtists(
                artists: Array(artists.prefix(5)), // Limit API calls
                recentDays: 14 // Last 2 weeks
            )

            let limitedReleases = rankedReleases.prefix(maxReleases)
            return limitedReleases.map { FeedItem.newRelease($0.album) }
        } catch {
            return []
        }
    }

    private func fetchRecommendations() async -> [FeedItem] {
        guard setupManager?.isSpotifyComplete == true else {
            return []
        }

        do {
            let tracks = try await spotifyService.discoverTracks(limit: maxRecommendations)

            let reasons = [
                "Based on your listening",
                "You might like this",
                "Recommended for you"
            ]

            return tracks.enumerated().map { index, track in
                let reason = reasons[index % reasons.count]
                return FeedItem.aiRecommendation(track, reason)
            }
        } catch {
            return []
        }
    }
}
