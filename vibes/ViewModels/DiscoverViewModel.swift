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

@MainActor
class DiscoverViewModel: ObservableObject {
    @Published var newReleases: [Album] = []
    @Published var recommendations: [Track] = []
    @Published var trendingSongs: [TrendingSong] = []
    @Published var recentlyActiveFriends: [RecentlyActiveFriend] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var isLoadingNewReleases = false
    @Published var isLoadingRecommendations = false
    @Published var isLoadingTrending = false
    @Published var isLoadingFriends = false

    private let spotifyService = SpotifyService.shared
    private let friendService = FriendService.shared
    private lazy var db = Firestore.firestore()

    func loadAllData() async {
        isLoading = true
        errorMessage = nil

        async let releasesTask: () = loadNewReleases()
        async let recommendationsTask: () = loadRecommendations()
        async let trendingTask: () = loadTrendingSongs()
        async let friendsTask: () = loadRecentlyActiveFriends()

        _ = await (releasesTask, recommendationsTask, trendingTask, friendsTask)

        isLoading = false
    }

    func loadNewReleases() async {
        guard spotifyService.isAuthenticated else { return }

        isLoadingNewReleases = true
        do {
            newReleases = try await spotifyService.getNewReleases(limit: 10)
        } catch {
            print("Failed to load new releases: \(error)")
        }
        isLoadingNewReleases = false
    }

    func loadRecommendations() async {
        guard spotifyService.isAuthenticated else { return }

        isLoadingRecommendations = true
        do {
            // Get user's top tracks and artists to use as seeds
            let topTracks = try await spotifyService.getTopTracks(timeRange: "medium_term", limit: 3)
            let topArtists = try await spotifyService.getTopArtists(timeRange: "medium_term", limit: 2)

            let trackIds = topTracks.map { $0.id }
            let artistIds = topArtists.map { $0.id }

            recommendations = try await spotifyService.getRecommendations(
                seedTracks: trackIds,
                seedArtists: artistIds,
                limit: 10
            )
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
}
