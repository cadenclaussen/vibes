//
//  HomeViewModel.swift
//  vibes
//
//  ViewModel for the Home tab - personalized hub with quick actions and recent activity.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

struct RecentChat: Identifiable {
    let id: String
    let friend: FriendProfile
    let lastMessage: String?
    let lastMessageDate: Date
    let unreadCount: Int
}

struct FriendActivity: Identifiable {
    let id: String
    let friendName: String
    let activityType: ActivityType
    let songTitle: String?
    let artistName: String?
    let timestamp: Date

    enum ActivityType {
        case sharedSong
        case sentMessage
        case newFriend
    }
}

struct VibestreakReminder: Identifiable {
    let id: String
    let friend: FriendProfile
    let currentStreak: Int
    let hoursRemaining: Int
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recentChats: [RecentChat] = []
    @Published var friendActivity: [FriendActivity] = []
    @Published var vibestreakReminders: [VibestreakReminder] = []
    @Published var todaysPick: UnifiedTrack?

    @Published var isLoading = false
    @Published var isLoadingChats = false
    @Published var isLoadingActivity = false
    @Published var isLoadingPick = false

    @Published var userName: String = ""

    private let friendService = FriendService.shared
    private let musicServiceManager = MusicServiceManager.shared
    private lazy var db = Firestore.firestore()

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    func loadAllData() async {
        isLoading = true

        // Load user name
        if let userId = Auth.auth().currentUser?.uid {
            do {
                let doc = try await db.collection("users").document(userId).getDocument()
                if let data = doc.data() {
                    userName = data["displayName"] as? String ?? "there"
                }
            } catch {
                userName = "there"
            }
        }

        async let chatsTask: () = loadRecentChats()
        async let activityTask: () = loadFriendActivity()
        async let streaksTask: () = loadVibestreakReminders()
        async let pickTask: () = loadTodaysPick()

        _ = await (chatsTask, activityTask, streaksTask, pickTask)

        isLoading = false
    }

    func loadRecentChats() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        isLoadingChats = true
        do {
            let friends = try await friendService.fetchFriends()
            var chats: [RecentChat] = []

            for friend in friends.prefix(5) {
                let threadId = [currentUserId, friend.id].sorted().joined(separator: "_")

                let snapshot = try await db.collection("messageThreads")
                    .document(threadId)
                    .collection("messages")
                    .order(by: "timestamp", descending: true)
                    .limit(to: 1)
                    .getDocuments()

                if let doc = snapshot.documents.first,
                   let message = try? doc.data(as: Message.self) {
                    let lastMessageText: String?
                    if message.messageType == .song {
                        lastMessageText = "Shared a song: \(message.songTitle ?? "Unknown")"
                    } else if message.messageType == .playlist {
                        lastMessageText = "Shared a playlist"
                    } else {
                        lastMessageText = message.textContent
                    }

                    chats.append(RecentChat(
                        id: threadId,
                        friend: friend,
                        lastMessage: lastMessageText,
                        lastMessageDate: message.timestamp,
                        unreadCount: 0
                    ))
                }
            }

            recentChats = chats.sorted { $0.lastMessageDate > $1.lastMessageDate }.prefix(3).map { $0 }
        } catch {
            print("Failed to load recent chats: \(error)")
        }
        isLoadingChats = false
    }

    func loadFriendActivity() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        isLoadingActivity = true
        do {
            let friends = try await friendService.fetchFriends()
            var activities: [FriendActivity] = []

            let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()

            for friend in friends {
                let threadId = [currentUserId, friend.id].sorted().joined(separator: "_")

                let snapshot = try await db.collection("messageThreads")
                    .document(threadId)
                    .collection("messages")
                    .whereField("senderId", isEqualTo: friend.id)
                    .whereField("messageType", isEqualTo: "song")
                    .whereField("timestamp", isGreaterThan: oneDayAgo)
                    .order(by: "timestamp", descending: true)
                    .limit(to: 1)
                    .getDocuments()

                if let doc = snapshot.documents.first,
                   let message = try? doc.data(as: Message.self) {
                    activities.append(FriendActivity(
                        id: "\(friend.id)_\(message.id ?? UUID().uuidString)",
                        friendName: friend.displayName,
                        activityType: .sharedSong,
                        songTitle: message.songTitle,
                        artistName: message.songArtist,
                        timestamp: message.timestamp
                    ))
                }
            }

            friendActivity = activities.sorted { $0.timestamp > $1.timestamp }.prefix(5).map { $0 }
        } catch {
            print("Failed to load friend activity: \(error)")
        }
        isLoadingActivity = false
    }

    func loadVibestreakReminders() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        do {
            let friends = try await friendService.fetchFriends()
            var reminders: [VibestreakReminder] = []

            for friend in friends {
                let threadId = [currentUserId, friend.id].sorted().joined(separator: "_")

                // Check if there's an active vibestreak
                let threadDoc = try await db.collection("messageThreads").document(threadId).getDocument()
                if let data = threadDoc.data(),
                   let currentStreak = data["vibestreak"] as? Int,
                   currentStreak > 0,
                   let lastMessageDate = (data["lastMessageDate"] as? Timestamp)?.dateValue() {

                    // Calculate hours remaining (24h from last message)
                    let deadline = Calendar.current.date(byAdding: .hour, value: 24, to: lastMessageDate) ?? Date()
                    let hoursRemaining = max(0, Int(deadline.timeIntervalSince(Date()) / 3600))

                    // Only show if less than 12 hours remaining
                    if hoursRemaining > 0 && hoursRemaining <= 12 {
                        reminders.append(VibestreakReminder(
                            id: friend.id,
                            friend: friend,
                            currentStreak: currentStreak,
                            hoursRemaining: hoursRemaining
                        ))
                    }
                }
            }

            vibestreakReminders = reminders.sorted { $0.hoursRemaining < $1.hoursRemaining }
        } catch {
            print("Failed to load vibestreak reminders: \(error)")
        }
    }

    func loadTodaysPick() async {
        guard musicServiceManager.isAuthenticated else { return }

        isLoadingPick = true
        do {
            let service = musicServiceManager.currentService
            let topArtists = try await service.getTopArtists(timeRange: .mediumTerm, limit: 3)

            guard let randomArtist = topArtists.randomElement() else {
                isLoadingPick = false
                return
            }

            let topTracks = try await service.getArtistTopTracks(artistId: randomArtist.id)
            todaysPick = topTracks.randomElement()
        } catch {
            print("Failed to load today's pick: \(error)")
        }
        isLoadingPick = false
    }
}
