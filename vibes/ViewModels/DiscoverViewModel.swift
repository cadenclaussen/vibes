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
    @Published var upcomingConcerts: [Concert] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var isLoadingNewReleases = false
    @Published var isLoadingRecommendations = false
    @Published var isLoadingTrending = false
    @Published var isLoadingFriends = false
    @Published var isLoadingBlendable = false
    @Published var isLoadingConcerts = false

    private let spotifyService = SpotifyService.shared
    private let friendService = FriendService.shared
    private let itunesService = iTunesService.shared
    private let ticketmasterService = TicketmasterService.shared
    private lazy var db = Firestore.firestore()

    func loadAllData() async {
        isLoading = true
        errorMessage = nil

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

    func loadUpcomingConcerts() async {
        guard spotifyService.isAuthenticated else { return }
        guard ticketmasterService.isConfigured else { return }
        guard !ticketmasterService.userCity.isEmpty else { return }

        isLoadingConcerts = true
        do {
            // Get user's top artists
            let topArtists = try await spotifyService.getTopArtists(timeRange: "medium_term", limit: 20)
            let artistNames = topArtists.map { $0.name }

            // Search for concerts
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
