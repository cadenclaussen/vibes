//
//  DiscoverViewModel.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

struct TrendingSong: Identifiable {
    let id: String
    let spotifyTrackId: String
    let songTitle: String
    let songArtist: String
    let albumArtUrl: String?
    let previewUrl: String?
    let sharedBy: [String]  // Friend names who shared this song
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
class DiscoverViewModel: ObservableObject {
    @Published var newReleases: [Album] = []
    @Published var recommendations: [Track] = []
    @Published var trendingSongs: [TrendingSong] = []
    @Published var recentlyActiveFriends: [RecentlyActiveFriend] = []
    @Published var blendableFriends: [BlendableFriend] = []
    @Published var aiRecommendations: [ResolvedAIRecommendation] = []
    @Published var aiRecommendationsReason: String = ""
    private var pendingAIRecommendations: [ResolvedAIRecommendation] = []
    private var dismissedTrackIds: Set<String> = []
    private var dismissedSongNames: [String] = [] // "trackName by artistName" for Gemini

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var isLoadingNewReleases = false
    @Published var isLoadingRecommendations = false
    @Published var isLoadingTrending = false
    @Published var isLoadingFriends = false
    @Published var isLoadingBlendable = false
    @Published var isLoadingAIRecommendations = false

    private let spotifyService = SpotifyService.shared
    private let friendService = FriendService.shared
    private let geminiService = GeminiService.shared
    private let itunesService = iTunesService.shared
    private lazy var db = Firestore.firestore()

    func loadAllData() async {
        isLoading = true
        errorMessage = nil

        async let releasesTask: () = loadNewReleases()
        async let recommendationsTask: () = loadRecommendations()
        async let trendingTask: () = loadTrendingSongs()
        async let friendsTask: () = loadRecentlyActiveFriends()
        async let blendableTask: () = loadBlendableFriends()
        async let aiRecsTask: () = loadAIRecommendations()

        _ = await (releasesTask, recommendationsTask, trendingTask, friendsTask, blendableTask, aiRecsTask)

        isLoading = false
    }

    func loadNewReleases() async {
        guard spotifyService.isAuthenticated else { return }

        isLoadingNewReleases = true
        do {
            // Get user's top artists from multiple time ranges for better coverage
            async let shortTermTask = spotifyService.getTopArtists(timeRange: "short_term", limit: 10)
            async let mediumTermTask = spotifyService.getTopArtists(timeRange: "medium_term", limit: 10)

            let (shortTerm, mediumTerm) = try await (shortTermTask, mediumTermTask)

            // Combine and deduplicate artists
            var seenArtistIds = Set<String>()
            var allArtists: [Artist] = []
            for artist in shortTerm + mediumTerm {
                if !seenArtistIds.contains(artist.id) {
                    seenArtistIds.insert(artist.id)
                    allArtists.append(artist)
                }
            }

            // Sync top artists to profile for compatibility calculations
            if let userId = Auth.auth().currentUser?.uid {
                let artistNames = allArtists.prefix(20).map { $0.name }
                try? await FirestoreService.shared.syncTopArtistsToProfile(userId: userId, artists: artistNames)
            }

            var personalizedReleases: [Album] = []
            // Extended to 6 months for better results
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()

            // Get recent albums from user's top 10 artists
            for artist in allArtists.prefix(10) {
                do {
                    let artistAlbums = try await spotifyService.getArtistAlbums(artistId: artist.id, limit: 5)
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

            // Fall back to Spotify's general new releases if no personalized results
            if personalizedReleases.isEmpty {
                personalizedReleases = try await spotifyService.getNewReleases(limit: 20)
            }

            // Sort by release date (newest first)
            personalizedReleases.sort { album1, album2 in
                let date1 = parseReleaseDate(album1.releaseDate) ?? Date.distantPast
                let date2 = parseReleaseDate(album2.releaseDate) ?? Date.distantPast
                return date1 > date2
            }

            // Remove duplicates and limit
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

        let formatters = [
            "yyyy-MM-dd",
            "yyyy-MM",
            "yyyy"
        ]

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
        guard spotifyService.isAuthenticated else { return }

        isLoadingRecommendations = true
        do {
            // Spotify deprecated /recommendations endpoint in Nov 2024
            // Alternative: Get popular tracks from user's top artists
            let topArtists = try await spotifyService.getTopArtists(timeRange: "medium_term", limit: 5)

            var popularTracks: [Track] = []
            var seenTrackIds = Set<String>()

            for artist in topArtists {
                do {
                    let artistTracks = try await spotifyService.getArtistTopTracks(artistId: artist.id)
                    // Take top 3 tracks from each artist, avoiding duplicates
                    for var track in artistTracks.prefix(3) {
                        if !seenTrackIds.contains(track.id) {
                            seenTrackIds.insert(track.id)
                            // Try iTunes fallback if no Spotify preview
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

            // Shuffle and take first 10
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
            // Get friends list
            let friends = try await friendService.fetchFriends()
            let friendIds = friends.map { $0.id }

            guard !friendIds.isEmpty else {
                isLoadingTrending = false
                return
            }

            // Query messages from last 7 days that are song type
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

            // Query all message threads involving current user
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

            // Group by spotifyTrackId and count
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

            // Create friend name lookup
            var friendNameLookup: [String: String] = [:]
            for friend in friends {
                friendNameLookup[friend.id] = friend.displayName
            }

            // Convert to TrendingSong and sort by count
            trendingSongs = songCounts.values
                .sorted { $0.count > $1.count }
                .prefix(10)
                .map { item in
                    let sharedByNames = item.senders.compactMap { senderId -> String? in
                        if senderId == currentUserId {
                            return "You"
                        }
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

                // Get the most recent song message from this friend
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

            // Sort by most recent activity
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

                // Get message count and last message date for this thread
                let countSnapshot = try await db.collection("messageThreads")
                    .document(threadId)
                    .collection("messages")
                    .count
                    .getAggregation(source: .server)

                let messageCount = Int(truncating: countSnapshot.count)

                // Get most recent message date
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

            // Sort by message count (most active first), then by recent activity
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

    func loadAIRecommendations() async {
        guard spotifyService.isAuthenticated && geminiService.isConfigured else { return }
        guard !isLoadingAIRecommendations else { return } // Prevent concurrent loads

        // Skip if we already have enough songs (don't replace on refresh)
        let currentTotal = aiRecommendations.count + pendingAIRecommendations.count
        if currentTotal >= 10 {
            print("[AI Recs] Already have \(currentTotal) songs, skipping load")
            return
        }

        // Load dismissed songs for Gemini
        loadDismissedTrackIds()

        isLoadingAIRecommendations = true
        do {
            // Build music profile from Spotify data
            async let topArtistsTask = spotifyService.getTopArtists(timeRange: "medium_term", limit: 10)
            async let topTracksTask = spotifyService.getTopTracks(timeRange: "medium_term", limit: 20)
            async let recentHistoryTask = spotifyService.getRecentlyPlayed(limit: 20)

            let (topArtists, topTracks, recentHistory) = try await (topArtistsTask, topTracksTask, recentHistoryTask)

            // Extract tracks from play history
            let recentTracks = recentHistory.map { $0.track }

            let profile = MusicProfile.from(
                artists: topArtists,
                tracks: topTracks,
                recentTracks: recentTracks
            )

            // If we have some songs already, just add more - don't replace
            if aiRecommendations.count > 0 {
                print("[AI Recs] Have \(aiRecommendations.count) songs, adding more")
                let neededCount = 10 - currentTotal
                let (recommendations, _) = try await geminiService.generatePersonalizedRecommendations(
                    profile: profile,
                    count: neededCount + 15,
                    avoidSongs: dismissedSongNames
                )
                await resolveAndAddToPending(from: recommendations)
            } else {
                // First load - request many songs upfront to avoid needing retries
                await loadAIRecommendationsWithRetry(profile: profile)
            }

            print("[AI Recs] Final count: \(aiRecommendations.count) visible, \(pendingAIRecommendations.count) pending")
        } catch {
            print("Failed to load AI recommendations: \(error)")
        }
        isLoadingAIRecommendations = false
    }

    private func loadAIRecommendationsWithRetry(profile: MusicProfile, retryCount: Int = 0) async {
        let maxRetries = 3

        do {
            let (recommendations, reason) = try await geminiService.generatePersonalizedRecommendations(
                profile: profile,
                count: 40,
                avoidSongs: dismissedSongNames
            )
            print("[AI Recs] Gemini returned \(recommendations.count) recommendations")
            aiRecommendationsReason = reason

            // Resolve songs to Spotify tracks
            await resolveSongs(from: recommendations)

            // If all were dismissed/filtered and we haven't retried too many times, try again
            if aiRecommendations.isEmpty && pendingAIRecommendations.isEmpty && retryCount < maxRetries {
                print("[AI Recs] All recommendations filtered out, retrying (\(retryCount + 1)/\(maxRetries))...")
                await loadAIRecommendationsWithRetry(profile: profile, retryCount: retryCount + 1)
            }
        } catch {
            print("Failed to load AI recommendations: \(error)")
        }
    }

    private func resolveSongs(from recommendations: [AIRecommendedSong]) async {
        // Load dismissed track IDs
        loadDismissedTrackIds()

        var resolved: [ResolvedAIRecommendation] = []
        var resolvedTrackIds = Set<String>() // Track IDs already added to avoid duplicates
        var notFoundCount = 0
        var dismissedCount = 0
        var noPreviewCount = 0
        var duplicateCount = 0

        for recommendation in recommendations {
            do {
                let tracks = try await spotifyService.searchTracks(query: recommendation.searchQuery, limit: 1)

                if let track = tracks.first {
                    // Skip if already dismissed
                    if dismissedTrackIds.contains(track.id) {
                        dismissedCount += 1
                        continue
                    }

                    // Skip if already added (duplicate)
                    if resolvedTrackIds.contains(track.id) {
                        duplicateCount += 1
                        continue
                    }

                    // Try to get preview URL from Spotify or iTunes
                    var previewUrl = track.previewUrl
                    if previewUrl == nil {
                        previewUrl = await itunesService.searchPreview(
                            trackName: track.name,
                            artistName: track.artists.first?.name ?? ""
                        )
                    }

                    // Allow songs without preview - they can still be sent/opened in Spotify
                    if previewUrl == nil {
                        noPreviewCount += 1
                    }

                    resolvedTrackIds.insert(track.id)
                    resolved.append(ResolvedAIRecommendation(
                        id: recommendation.id,
                        recommendation: recommendation,
                        track: track,
                        previewUrl: previewUrl
                    ))
                } else {
                    notFoundCount += 1
                    print("[AI Recs] Spotify couldn't find: \(recommendation.searchQuery)")
                }
            } catch {
                notFoundCount += 1
                continue
            }
        }

        print("[AI Recs] Resolved: \(resolved.count), Not found: \(notFoundCount), Dismissed: \(dismissedCount), No preview: \(noPreviewCount), Duplicates: \(duplicateCount)")

        // Show first 5, keep rest as pending
        let visibleCount = 5
        aiRecommendations = Array(resolved.prefix(visibleCount))
        pendingAIRecommendations = Array(resolved.dropFirst(visibleCount))
    }

    func dismissAIRecommendation(_ recommendation: ResolvedAIRecommendation) {
        // Add to dismissed set
        if let track = recommendation.track {
            dismissedTrackIds.insert(track.id)
            // Also save song name for Gemini
            let songName = "\(track.name) by \(track.artists.first?.name ?? "Unknown")"
            dismissedSongNames.append(songName)
            saveDismissedTrackIds()
            // Track for The Resurrection achievement (dismissed songs can be resurrected)
            LocalAchievementStats.shared.trackSongRemoved(trackId: track.id)
        }

        // Remove from visible list
        aiRecommendations.removeAll { $0.id == recommendation.id }

        // Add from pending if available
        if !pendingAIRecommendations.isEmpty {
            let next = pendingAIRecommendations.removeFirst()
            aiRecommendations.append(next)
        }

        // Fetch more if total songs (visible + pending) drops below 8
        let totalSongs = aiRecommendations.count + pendingAIRecommendations.count
        if totalSongs < 8 && !isLoadingAIRecommendations {
            Task {
                await fetchMoreRecommendations()
            }
        }
    }

    private func fetchMoreRecommendations() async {
        guard spotifyService.isAuthenticated && geminiService.isConfigured else { return }
        guard !isLoadingAIRecommendations else { return }

        // Calculate how many we need to reach 10 total
        let currentTotal = aiRecommendations.count + pendingAIRecommendations.count
        let neededCount = 10 - currentTotal
        guard neededCount > 0 else { return }

        // Load dismissed songs for Gemini
        loadDismissedTrackIds()

        isLoadingAIRecommendations = true
        do {
            async let topArtistsTask = spotifyService.getTopArtists(timeRange: "medium_term", limit: 10)
            async let topTracksTask = spotifyService.getTopTracks(timeRange: "medium_term", limit: 20)
            async let recentHistoryTask = spotifyService.getRecentlyPlayed(limit: 20)

            let (topArtists, topTracks, recentHistory) = try await (topArtistsTask, topTracksTask, recentHistoryTask)
            let recentTracks = recentHistory.map { $0.track }

            let profile = MusicProfile.from(
                artists: topArtists,
                tracks: topTracks,
                recentTracks: recentTracks
            )

            // Request only the number we need (plus buffer for songs without previews)
            let (recommendations, _) = try await geminiService.generatePersonalizedRecommendations(
                profile: profile,
                count: neededCount + 7,
                avoidSongs: dismissedSongNames
            )

            // Resolve and add to pending
            await resolveAndAddToPending(from: recommendations)
        } catch {
            print("Failed to fetch more AI recommendations: \(error)")
        }
        isLoadingAIRecommendations = false
    }

    private func resolveAndAddToPending(from recommendations: [AIRecommendedSong]) async {
        for recommendation in recommendations {
            // Stop if we have 10 total
            let totalCount = aiRecommendations.count + pendingAIRecommendations.count
            if totalCount >= 10 { break }

            do {
                let tracks = try await spotifyService.searchTracks(query: recommendation.searchQuery, limit: 1)

                if let track = tracks.first {
                    // Skip if already dismissed or already in lists
                    if dismissedTrackIds.contains(track.id) { continue }
                    if aiRecommendations.contains(where: { $0.track?.id == track.id }) { continue }
                    if pendingAIRecommendations.contains(where: { $0.track?.id == track.id }) { continue }

                    // Try to get preview URL from Spotify or iTunes
                    var previewUrl = track.previewUrl
                    if previewUrl == nil {
                        previewUrl = await itunesService.searchPreview(
                            trackName: track.name,
                            artistName: track.artists.first?.name ?? ""
                        )
                    }

                    // Allow songs without preview - they can still be sent/opened in Spotify
                    let resolved = ResolvedAIRecommendation(
                        id: recommendation.id,
                        recommendation: recommendation,
                        track: track,
                        previewUrl: previewUrl
                    )

                    // Add directly to visible if under 5, otherwise to pending
                    if aiRecommendations.count < 5 {
                        aiRecommendations.append(resolved)
                    } else {
                        pendingAIRecommendations.append(resolved)
                    }
                }
            } catch {
                continue
            }
        }
    }

    private func loadDismissedTrackIds() {
        if let saved = UserDefaults.standard.array(forKey: "dismissedAIRecommendations") as? [String] {
            dismissedTrackIds = Set(saved)
        }
        if let savedNames = UserDefaults.standard.array(forKey: "dismissedAISongNames") as? [String] {
            dismissedSongNames = savedNames
        }
    }

    private func saveDismissedTrackIds() {
        // Keep only last 100 dismissed tracks
        let toSave = Array(dismissedTrackIds.suffix(100))
        UserDefaults.standard.set(toSave, forKey: "dismissedAIRecommendations")
        // Keep only last 50 song names for Gemini (to avoid huge prompts)
        let namesToSave = Array(dismissedSongNames.suffix(50))
        UserDefaults.standard.set(namesToSave, forKey: "dismissedAISongNames")
    }
}
