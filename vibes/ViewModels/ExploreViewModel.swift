//
//  ExploreViewModel.swift
//  vibes
//
//  Combined ViewModel for search and discovery functionality.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

// MARK: - Discovery Types

struct TrendingSong: Identifiable {
    let id: String
    let spotifyTrackId: String
    let songTitle: String
    let songArtist: String
    let albumArtUrl: String?
    let previewUrl: String?
    let sharedBy: [String]
    let shareCount: Int
}

struct RecentlyActiveFriend: Identifiable {
    let id: String
    let friendId: String
    let displayName: String
    let lastSharedSong: String?
    let lastSharedArtist: String?
    let lastSharedAlbumArt: String?
    let lastActiveDate: Date
}

struct BlendableFriend: Identifiable {
    let id: String
    let friend: FriendProfile
    let messageCount: Int
    let lastMessageDate: Date?
}

@MainActor
class ExploreViewModel: ObservableObject {
    // MARK: - Search Properties

    @Published var searchText = ""
    @Published var selectedSearchType: UnifiedSearchType = .track
    @Published var searchResults: [UnifiedTrack] = []
    @Published var artistResults: [UnifiedArtist] = []
    @Published var albumResults: [UnifiedAlbum] = []
    @Published var playlistResults: [UnifiedPlaylist] = []
    @Published var isSearching = false
    @Published var searchError: String?
    @Published var hasSearched = false
    @Published var recentSearches: [String] = []

    // MARK: - Discovery Properties

    @Published var newReleases: [UnifiedAlbum] = []
    @Published var recommendations: [UnifiedTrack] = []
    @Published var trendingSongs: [TrendingSong] = []
    @Published var recentlyActiveFriends: [RecentlyActiveFriend] = []
    @Published var blendableFriends: [BlendableFriend] = []
    @Published var upcomingConcerts: [Concert] = []

    @Published var isLoading = false
    @Published var isLoadingNewReleases = false
    @Published var isLoadingRecommendations = false
    @Published var isLoadingTrending = false
    @Published var isLoadingFriends = false
    @Published var isLoadingBlendable = false
    @Published var isLoadingConcerts = false

    // MARK: - Private

    private let musicServiceManager = MusicServiceManager.shared
    private let friendService = FriendService.shared
    private let itunesService = iTunesService.shared
    private let ticketmasterService = TicketmasterService.shared
    private lazy var db = Firestore.firestore()
    private var searchTask: Task<Void, Never>?

    private let recentSearchesKey = "recentSearches"
    private let maxRecentSearches = 10

    // MARK: - Computed Properties

    var isInSearchMode: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || hasSearched
    }

    var hasSearchResults: Bool {
        switch selectedSearchType {
        case .track: return !searchResults.isEmpty
        case .artist: return !artistResults.isEmpty
        case .album: return !albumResults.isEmpty
        case .playlist: return !playlistResults.isEmpty
        }
    }

    // MARK: - Init

    init() {
        loadRecentSearches()
    }

    // MARK: - Search Methods

    func search() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            clearSearchResults()
            return
        }

        saveRecentSearch(query)

        LocalAchievementStats.shared.searchQueries += 1
        LocalAchievementStats.shared.checkLocalAchievements()

        searchTask?.cancel()
        searchTask = Task {
            isSearching = true
            searchError = nil
            hasSearched = true

            let service = musicServiceManager.currentService

            do {
                switch selectedSearchType {
                case .track:
                    let results = try await service.searchTracks(query: query, limit: 30)
                    if !Task.isCancelled {
                        searchResults = results
                    }
                case .artist:
                    let results = try await service.searchArtists(query: query, limit: 30)
                    if !Task.isCancelled {
                        artistResults = results
                    }
                case .album:
                    let results = try await service.searchAlbums(query: query, limit: 30)
                    if !Task.isCancelled {
                        albumResults = results
                    }
                case .playlist:
                    let results = try await service.searchPlaylists(query: query, limit: 30)
                    if !Task.isCancelled {
                        playlistResults = results
                    }
                }
            } catch {
                if !Task.isCancelled {
                    searchError = error.localizedDescription
                    clearResultsForCurrentType()
                }
            }

            if !Task.isCancelled {
                isSearching = false
            }
        }
    }

    func clearSearch() {
        searchText = ""
        clearSearchResults()
    }

    private func clearSearchResults() {
        searchResults = []
        artistResults = []
        albumResults = []
        playlistResults = []
        hasSearched = false
        searchError = nil
    }

    private func clearResultsForCurrentType() {
        switch selectedSearchType {
        case .track: searchResults = []
        case .artist: artistResults = []
        case .album: albumResults = []
        case .playlist: playlistResults = []
        }
    }

    func onSearchTypeChanged() {
        if !searchText.isEmpty && hasSearched {
            search()
        }
    }

    func getPreviewUrl(for track: UnifiedTrack) -> String? {
        return track.previewUrl
    }

    // MARK: - Recent Searches

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }

    private func saveRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        recentSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        recentSearches.insert(trimmed, at: 0)

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

    // MARK: - Discovery Methods

    func loadAllData() async {
        isLoading = true

        async let releasesTask: () = loadNewReleases()
        async let recommendationsTask: () = loadRecommendations()
        async let trendingTask: () = loadTrendingSongs()
        async let friendsTask: () = loadRecentlyActiveFriends()
        async let blendableTask: () = loadBlendableFriends()
        async let concertsTask: () = loadUpcomingConcerts()

        _ = await (releasesTask, recommendationsTask, trendingTask, friendsTask, blendableTask, concertsTask)

        isLoading = false
    }

    func loadNewReleases() async {
        guard musicServiceManager.isAuthenticated else { return }

        isLoadingNewReleases = true
        do {
            let service = musicServiceManager.currentService

            async let shortTermTask = service.getTopArtists(timeRange: .shortTerm, limit: 10)
            async let mediumTermTask = service.getTopArtists(timeRange: .mediumTerm, limit: 10)

            let (shortTerm, mediumTerm) = try await (shortTermTask, mediumTermTask)

            var seenArtistIds = Set<String>()
            var allArtists: [UnifiedArtist] = []
            for artist in shortTerm + mediumTerm {
                if !seenArtistIds.contains(artist.id) {
                    seenArtistIds.insert(artist.id)
                    allArtists.append(artist)
                }
            }

            if let userId = Auth.auth().currentUser?.uid {
                let artistNames = allArtists.prefix(20).map { $0.name }
                try? await FirestoreService.shared.syncTopArtistsToProfile(userId: userId, artists: artistNames)
            }

            var personalizedReleases: [UnifiedAlbum] = []
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()

            for artist in allArtists.prefix(10) {
                do {
                    let artistAlbums = try await service.getArtistAlbums(artistId: artist.id, limit: 5)
                    let recentAlbums = artistAlbums.filter { album in
                        if let releaseDate = parseReleaseDate(album.releaseDate) {
                            return releaseDate >= sixMonthsAgo
                        }
                        return false
                    }
                    personalizedReleases.append(contentsOf: recentAlbums)
                } catch {
                    continue
                }
            }

            personalizedReleases.sort { album1, album2 in
                let date1 = parseReleaseDate(album1.releaseDate) ?? Date.distantPast
                let date2 = parseReleaseDate(album2.releaseDate) ?? Date.distantPast
                return date1 > date2
            }

            var seenIds = Set<String>()
            newReleases = personalizedReleases.filter { album in
                if seenIds.contains(album.id) { return false }
                seenIds.insert(album.id)
                return true
            }.prefix(10).map { $0 }

        } catch {
            print("Failed to load new releases: \(error)")
        }
        isLoadingNewReleases = false
    }

    private func parseReleaseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let formatters = ["yyyy-MM-dd", "yyyy-MM", "yyyy"]
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }

    func loadRecommendations() async {
        guard musicServiceManager.isAuthenticated else { return }

        isLoadingRecommendations = true
        do {
            let service = musicServiceManager.currentService
            let topArtists = try await service.getTopArtists(timeRange: .mediumTerm, limit: 5)

            var popularTracks: [UnifiedTrack] = []
            var seenTrackIds = Set<String>()

            for artist in topArtists {
                do {
                    let artistTracks = try await service.getArtistTopTracks(artistId: artist.id)
                    for var track in artistTracks.prefix(3) {
                        if !seenTrackIds.contains(track.id) {
                            seenTrackIds.insert(track.id)
                            if track.previewUrl == nil {
                                track.previewUrl = await itunesService.searchPreview(
                                    trackName: track.name,
                                    artistName: track.artists.first?.name ?? ""
                                )
                            }
                            popularTracks.append(track)
                        }
                    }
                } catch {
                    continue
                }
            }

            recommendations = Array(popularTracks.shuffled().prefix(10))
        } catch {
            print("Failed to load recommendations: \(error)")
        }
        isLoadingRecommendations = false
    }

    func loadTrendingSongs() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        isLoadingTrending = true
        do {
            let friends = try await friendService.fetchFriends()
            let friendIds = friends.map { $0.id }

            guard !friendIds.isEmpty else {
                isLoadingTrending = false
                return
            }

            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            var allSongMessages: [Message] = []

            for friendId in friendIds {
                let threadId = [currentUserId, friendId].sorted().joined(separator: "_")

                let snapshot = try await db.collection("messageThreads")
                    .document(threadId)
                    .collection("messages")
                    .whereField("messageType", isEqualTo: "song")
                    .whereField("timestamp", isGreaterThan: sevenDaysAgo)
                    .getDocuments()

                let messages = snapshot.documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                allSongMessages.append(contentsOf: messages)
            }

            var songCounts: [String: (message: Message, count: Int, senders: Set<String>)] = [:]

            for message in allSongMessages {
                guard let trackId = message.spotifyTrackId else { continue }

                if var existing = songCounts[trackId] {
                    existing.count += 1
                    existing.senders.insert(message.senderId)
                    songCounts[trackId] = existing
                } else {
                    songCounts[trackId] = (message: message, count: 1, senders: [message.senderId])
                }
            }

            var friendNameLookup: [String: String] = [:]
            for friend in friends {
                friendNameLookup[friend.id] = friend.displayName
            }

            trendingSongs = songCounts.values
                .sorted { $0.count > $1.count }
                .prefix(10)
                .map { item in
                    let sharedByNames = item.senders.compactMap { senderId -> String? in
                        if senderId == currentUserId { return "You" }
                        return friendNameLookup[senderId]
                    }

                    return TrendingSong(
                        id: item.message.spotifyTrackId ?? UUID().uuidString,
                        spotifyTrackId: item.message.spotifyTrackId ?? "",
                        songTitle: item.message.songTitle ?? "Unknown",
                        songArtist: item.message.songArtist ?? "Unknown",
                        albumArtUrl: item.message.albumArtUrl,
                        previewUrl: item.message.previewUrl,
                        sharedBy: sharedByNames,
                        shareCount: item.count
                    )
                }

        } catch {
            print("Failed to load trending songs: \(error)")
        }
        isLoadingTrending = false
    }

    func loadRecentlyActiveFriends() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        isLoadingFriends = true
        do {
            let friends = try await friendService.fetchFriends()
            var activeFriends: [RecentlyActiveFriend] = []

            for friend in friends {
                let threadId = [currentUserId, friend.id].sorted().joined(separator: "_")

                let snapshot = try await db.collection("messageThreads")
                    .document(threadId)
                    .collection("messages")
                    .whereField("messageType", isEqualTo: "song")
                    .whereField("senderId", isEqualTo: friend.id)
                    .order(by: "timestamp", descending: true)
                    .limit(to: 1)
                    .getDocuments()

                if let doc = snapshot.documents.first,
                   let message = try? doc.data(as: Message.self) {
                    activeFriends.append(RecentlyActiveFriend(
                        id: friend.id,
                        friendId: friend.id,
                        displayName: friend.displayName,
                        lastSharedSong: message.songTitle,
                        lastSharedArtist: message.songArtist,
                        lastSharedAlbumArt: message.albumArtUrl,
                        lastActiveDate: message.timestamp
                    ))
                }
            }

            recentlyActiveFriends = activeFriends.sorted { $0.lastActiveDate > $1.lastActiveDate }

        } catch {
            print("Failed to load recently active friends: \(error)")
        }
        isLoadingFriends = false
    }

    func loadBlendableFriends() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        isLoadingBlendable = true
        do {
            let friends = try await friendService.fetchFriends()
            var friendsWithActivity: [BlendableFriend] = []

            for friend in friends {
                let threadId = [currentUserId, friend.id].sorted().joined(separator: "_")

                let countSnapshot = try await db.collection("messageThreads")
                    .document(threadId)
                    .collection("messages")
                    .count
                    .getAggregation(source: .server)

                let messageCount = Int(truncating: countSnapshot.count)

                let lastMessageSnapshot = try await db.collection("messageThreads")
                    .document(threadId)
                    .collection("messages")
                    .order(by: "timestamp", descending: true)
                    .limit(to: 1)
                    .getDocuments()

                var lastMessageDate: Date? = nil
                if let doc = lastMessageSnapshot.documents.first,
                   let message = try? doc.data(as: Message.self) {
                    lastMessageDate = message.timestamp
                }

                friendsWithActivity.append(BlendableFriend(
                    id: friend.id,
                    friend: friend,
                    messageCount: messageCount,
                    lastMessageDate: lastMessageDate
                ))
            }

            blendableFriends = friendsWithActivity.sorted { f1, f2 in
                if f1.messageCount != f2.messageCount {
                    return f1.messageCount > f2.messageCount
                }
                let date1 = f1.lastMessageDate ?? Date.distantPast
                let date2 = f2.lastMessageDate ?? Date.distantPast
                return date1 > date2
            }
        } catch {
            print("Failed to load blendable friends: \(error)")
        }
        isLoadingBlendable = false
    }

    func loadUpcomingConcerts() async {
        guard musicServiceManager.isAuthenticated else { return }
        guard ticketmasterService.isConfigured else { return }
        guard !ticketmasterService.userCity.isEmpty else { return }

        isLoadingConcerts = true
        do {
            let service = musicServiceManager.currentService
            let topArtists = try await service.getTopArtists(timeRange: .mediumTerm, limit: 20)
            let artistNames = topArtists.map { $0.name }

            upcomingConcerts = try await ticketmasterService.searchConcerts(
                artistNames: artistNames,
                daysAhead: 60
            )
        } catch {
            print("Failed to load concerts: \(error)")
        }
        isLoadingConcerts = false
    }
}
