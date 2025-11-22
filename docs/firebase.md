# Firebase Implementation Guide for vibes

Complete step-by-step guide for implementing Firebase to support all vibes features.

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Authentication](#authentication)
3. [Firestore Database Structure](#firestore-database-structure)
4. [Real-time Messaging](#real-time-messaging)
5. [Friend System & Vibestreaks](#friend-system--vibestreaks)
6. [User Profiles (Spaces)](#user-profiles-spaces)
7. [Statistics & Competition](#statistics--competition)
8. [Real-time Activity (Now Playing)](#real-time-activity-now-playing)
9. [Notifications](#notifications)
10. [Storage (Images & Graphics)](#storage-images--graphics)
11. [Security Rules](#security-rules)
12. [Cloud Functions](#cloud-functions)
13. [Testing](#testing)

## Initial Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name: `vibes`
4. Enable Google Analytics (recommended for user insights)
5. Click "Create Project"

### Step 2: Add iOS App to Firebase

1. In Firebase Console, click "Add App" → iOS
2. Enter Bundle ID: `caden.vibes`
3. Enter App Nickname: `vibes`
4. Download `GoogleService-Info.plist`
5. Add `GoogleService-Info.plist` to Xcode project root
   - Drag file into Xcode
   - Check "Copy items if needed"
   - Ensure "Add to targets: vibes" is checked

### Step 3: Install Firebase SDK

Using Swift Package Manager:

1. Open Xcode project
2. File → Add Package Dependencies
3. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
4. Select version: Up to Next Major Version (11.0.0+)
5. Select packages for **initial setup**:
   - `FirebaseAuth` - Authentication
   - `FirebaseFirestore` - Database (includes Codable support built-in)
   - `FirebaseStorage` - File storage
6. Click "Add Package"

**Note**: As of Firebase SDK 10.17.0+, `FirebaseFirestoreSwift` has been merged into `FirebaseFirestore`. All Codable support is now included automatically. See [Firebase Swift Migration Guide](https://firebase.google.com/docs/ios/swift-migration).

**Optional packages to add later**:
- `FirebaseFunctions` - Add when implementing Cloud Functions
- `FirebaseMessaging` - Add when implementing push notifications (FCM)

### Step 4: Initialize Firebase

Edit `vibes/vibesApp.swift`:

```swift
import SwiftUI
import Firebase
import FirebaseMessaging

@main
struct vibesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthManager.shared)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
```

### Step 5: Disable App Delegate Swizzling

Add to Info.plist:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

## Authentication

### Architecture

Use MVVM with AuthManager singleton that manages both Firebase Auth and Spotify OAuth.

### Step 1: Create AuthManager

Create `vibes/Services/AuthManager.swift`:

```swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isSpotifyLinked = false

    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    private init() {
        registerAuthStateHandler()
    }

    private func registerAuthStateHandler() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil

            if let userId = user?.uid {
                self?.checkSpotifyLink(userId: userId)
            }
        }
    }

    private func checkSpotifyLink(userId: String) {
        db.collection("users").document(userId).getDocument { document, _ in
            if let data = document?.data(),
               let spotifyId = data["spotifyId"] as? String,
               !spotifyId.isEmpty {
                self.isSpotifyLinked = true
            }
        }
    }

    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Email/Password Authentication

    func signUp(email: String, password: String, username: String) async throws {
        // Check if username is already taken
        let usernameQuery = try await db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()

        guard usernameQuery.documents.isEmpty else {
            throw AuthError.usernameTaken
        }

        // Create Firebase user
        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        // Create user profile in Firestore
        let userData: [String: Any] = [
            "uid": result.user.uid,
            "email": email,
            "username": username,
            "displayName": username,
            "createdAt": Timestamp(),
            "spotifyId": "",
            "spotifyLinked": false,
            "privacySettings": [
                "profileVisibility": "friends",
                "showNowPlaying": true,
                "showListeningStats": true,
                "allowFriendRequests": "everyone"
            ]
        ]

        try await db.collection("users").document(result.user.uid).setData(userData)
        self.user = result.user
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = result.user
    }

    // MARK: - Google Sign-In
    // Implementation from authentication.md

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        self.user = nil
        self.isSpotifyLinked = false
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - Delete Account

    func deleteAccount() async throws {
        guard let user = user else { return }

        // Delete user data from Firestore (Cloud Function handles cascade)
        try await db.collection("users").document(user.uid).delete()

        // Delete Firebase Auth account
        try await user.delete()
        self.user = nil
    }
}

enum AuthError: LocalizedError {
    case usernameTaken
    case notAuthenticated
    case tokenExpired

    var errorDescription: String? {
        switch self {
        case .usernameTaken:
            return "Username is already taken"
        case .notAuthenticated:
            return "You must be signed in"
        case .tokenExpired:
            return "Session expired. Please sign in again"
        }
    }
}
```

### Step 2: Enable Authentication Methods

1. Go to Firebase Console → Authentication
2. Click "Get Started"
3. Enable providers:
   - Email/Password
   - Google
4. Save

## Firestore Database Structure

### Collections & Document Structure

```
users/{userId}
  - uid: string
  - email: string
  - username: string (unique)
  - displayName: string
  - bio: string (max 200 chars)
  - profilePictureURL: string
  - spotifyId: string
  - spotifyLinked: boolean
  - favoriteArtists: array<string> (Spotify artist IDs)
  - favoriteSongs: array<string> (Spotify track IDs)
  - favoriteAlbums: array<string> (Spotify album IDs)
  - musicTasteTags: array<string> (genres, moods)
  - customLyrics: string
  - profileTheme: string
  - pinnedSongs: array<string>
  - createdAt: timestamp
  - updatedAt: timestamp
  - privacySettings: map
    - profileVisibility: string ("public" | "friends")
    - showNowPlaying: boolean
    - showListeningStats: boolean
    - allowFriendRequests: string ("everyone" | "friendsOfFriends" | "none")
  - fcmToken: string (for push notifications)

friendships/{friendshipId}
  - userId: string
  - friendId: string
  - status: string ("pending" | "accepted")
  - initiatorId: string (who sent the request)
  - vibestreak: number (default: 0)
  - lastInteractionDate: timestamp
  - compatibilityScore: number (0-100)
  - sharedArtists: array<string>
  - createdAt: timestamp
  - acceptedAt: timestamp

messageThreads/{threadId}
  - userId1: string
  - userId2: string
  - lastMessageTimestamp: timestamp
  - lastMessageContent: string
  - lastMessageType: string ("text" | "song")
  - unreadCountUser1: number
  - unreadCountUser2: number
  - createdAt: timestamp

messages/{messageId}
  - threadId: string
  - senderId: string
  - recipientId: string
  - messageType: string ("text" | "song")
  - content: string (text or Spotify track ID)
  - caption: string (optional, for songs)
  - rating: number (1-5, optional for songs)
  - reactions: map<userId, reactionType> (emoji reactions)
  - timestamp: timestamp
  - read: boolean

nowPlaying/{userId}
  - spotifyTrackId: string
  - trackName: string
  - artistName: string
  - albumArt: string (URL)
  - isPlaying: boolean
  - timestamp: timestamp
  - progressMs: number
  - durationMs: number

notifications/{notificationId}
  - userId: string
  - notificationType: string ("message" | "songRecommendation" | "friendRequest" | "vibestreakMilestone" | "achievement" | "friendAccepted")
  - relatedId: string (messageId, trackId, friendshipId, etc.)
  - content: string
  - title: string
  - imageURL: string (optional)
  - timestamp: timestamp
  - read: boolean
  - actionURL: string (deep link)

listeningStats/{userId}__{date}
  - userId: string
  - date: string (YYYY-MM-DD)
  - totalListeningTimeMs: number
  - topArtists: array<map> ([{id, name, playTimeMs}])
  - topSongs: array<map> ([{id, name, playCount}])
  - topGenres: array<map> ([{genre, percentage}])
  - songsSent: number
  - songsReceived: number
  - uniqueArtistsListened: number
  - updatedAt: timestamp

achievements/{userId}__{achievementType}
  - userId: string
  - achievementType: string ("nightOwl" | "earlyBird" | "genreExplorer" | "loyalFan" | "socialButterfly")
  - unlockedAt: timestamp
  - progress: number (for tracking partial progress)
  - metadata: map (specific achievement data)

weeklyRecaps/{userId}__{weekStart}
  - userId: string
  - weekStart: string (YYYY-MM-DD)
  - weekEnd: string (YYYY-MM-DD)
  - topSongs: array<map>
  - topArtist: map
  - totalListeningTimeMs: number
  - topFriendInteractions: array<map>
  - shareableGraphicURL: string
  - createdAt: timestamp

interactions/{interactionId}
  - friendshipId: string
  - userId: string
  - interactionType: string ("song" | "message")
  - timestamp: timestamp
```

### Step 1: Create Data Models

Create `vibes/Models/User.swift`:

```swift
import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var username: String
    var displayName: String
    var bio: String?
    var profilePictureURL: String?
    var spotifyId: String?
    var spotifyLinked: Bool
    var favoriteArtists: [String]
    var favoriteSongs: [String]
    var favoriteAlbums: [String]
    var musicTasteTags: [String]
    var customLyrics: String?
    var profileTheme: String?
    var pinnedSongs: [String]
    var createdAt: Date
    var updatedAt: Date
    var privacySettings: PrivacySettings
    var fcmToken: String?

    struct PrivacySettings: Codable {
        var profileVisibility: String
        var showNowPlaying: Bool
        var showListeningStats: Bool
        var allowFriendRequests: String

        init() {
            profileVisibility = "friends"
            showNowPlaying = true
            showListeningStats = true
            allowFriendRequests = "everyone"
        }
    }

    init(uid: String, email: String, username: String) {
        self.uid = uid
        self.email = email
        self.username = username
        self.displayName = username
        self.spotifyLinked = false
        self.favoriteArtists = []
        self.favoriteSongs = []
        self.favoriteAlbums = []
        self.musicTasteTags = []
        self.pinnedSongs = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.privacySettings = PrivacySettings()
    }
}
```

Create `vibes/Models/Friendship.swift`:

```swift
import Foundation
import FirebaseFirestore

struct Friendship: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var friendId: String
    var status: FriendshipStatus
    var initiatorId: String
    var vibestreak: Int
    var lastInteractionDate: Date?
    var compatibilityScore: Double
    var sharedArtists: [String]
    var createdAt: Date
    var acceptedAt: Date?

    enum FriendshipStatus: String, Codable {
        case pending
        case accepted
    }
}
```

Create `vibes/Models/Message.swift`:

```swift
import Foundation
import FirebaseFirestore

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    var threadId: String
    var senderId: String
    var recipientId: String
    var messageType: MessageType
    var content: String
    var caption: String?
    var rating: Int?
    var reactions: [String: String] // userId: reactionType
    var timestamp: Date
    var read: Bool

    enum MessageType: String, Codable {
        case text
        case song
    }
}

struct MessageThread: Codable, Identifiable {
    @DocumentID var id: String?
    var userId1: String
    var userId2: String
    var lastMessageTimestamp: Date
    var lastMessageContent: String
    var lastMessageType: String
    var unreadCountUser1: Int
    var unreadCountUser2: Int
    var createdAt: Date
}
```

## Real-time Messaging

### Step 1: Create FirestoreService for Messages

Create `vibes/Services/FirestoreService.swift`:

```swift
import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Message Threads

    func getOrCreateThread(userId1: String, userId2: String) async throws -> String {
        // Query for existing thread
        let threadQuery = try await db.collection("messageThreads")
            .whereField("userId1", in: [userId1, userId2])
            .whereField("userId2", in: [userId1, userId2])
            .getDocuments()

        if let existingThread = threadQuery.documents.first {
            return existingThread.documentID
        }

        // Create new thread
        let threadData: [String: Any] = [
            "userId1": userId1,
            "userId2": userId2,
            "lastMessageTimestamp": Timestamp(),
            "lastMessageContent": "",
            "lastMessageType": "text",
            "unreadCountUser1": 0,
            "unreadCountUser2": 0,
            "createdAt": Timestamp()
        ]

        let docRef = try await db.collection("messageThreads").addDocument(data: threadData)
        return docRef.documentID
    }

    // MARK: - Messages

    func sendMessage(_ message: Message) async throws {
        let messageData = try Firestore.Encoder().encode(message)
        try await db.collection("messages").addDocument(data: messageData)

        // Update thread
        try await updateThread(threadId: message.threadId, message: message)

        // Record interaction for vibestreak
        try await recordInteraction(
            senderId: message.senderId,
            recipientId: message.recipientId,
            type: message.messageType == .song ? "song" : "message"
        )
    }

    private func updateThread(threadId: String, message: Message) async throws {
        let updateData: [String: Any] = [
            "lastMessageTimestamp": message.timestamp,
            "lastMessageContent": message.messageType == .song ? "🎵 Song" : message.content,
            "lastMessageType": message.messageType.rawValue,
            "unreadCountUser2": FieldValue.increment(Int64(1))
        ]

        try await db.collection("messageThreads").document(threadId).updateData(updateData)
    }

    func listenToMessages(threadId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("messages")
            .whereField("threadId", isEqualTo: threadId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap { try? $0.data(as: Message.self) }
                completion(messages)
            }
    }

    func markMessagesAsRead(threadId: String, userId: String) async throws {
        let messages = try await db.collection("messages")
            .whereField("threadId", isEqualTo: threadId)
            .whereField("recipientId", isEqualTo: userId)
            .whereField("read", isEqualTo: false)
            .getDocuments()

        let batch = db.batch()
        for document in messages.documents {
            batch.updateData(["read": true], forDocument: document.reference)
        }
        try await batch.commit()
    }

    // MARK: - Reactions

    func addReaction(messageId: String, userId: String, reaction: String) async throws {
        try await db.collection("messages").document(messageId).updateData([
            "reactions.\(userId)": reaction
        ])
    }
}
```

## Friend System & Vibestreaks

### Step 1: Friend Management Service

Add to `FirestoreService.swift`:

```swift
// MARK: - Friendships

func sendFriendRequest(from userId: String, to friendId: String) async throws {
    let friendshipData: [String: Any] = [
        "userId": userId,
        "friendId": friendId,
        "status": "pending",
        "initiatorId": userId,
        "vibestreak": 0,
        "compatibilityScore": 0,
        "sharedArtists": [],
        "createdAt": Timestamp()
    ]

    try await db.collection("friendships").addDocument(data: friendshipData)

    // Create notification for recipient
    try await createNotification(
        userId: friendId,
        type: "friendRequest",
        relatedId: userId,
        content: "sent you a friend request",
        title: "New Friend Request"
    )
}

func acceptFriendRequest(friendshipId: String) async throws {
    try await db.collection("friendships").document(friendshipId).updateData([
        "status": "accepted",
        "acceptedAt": Timestamp()
    ])

    // Calculate initial compatibility score (Cloud Function handles this)
    // Create notification for requester
    let friendship = try await db.collection("friendships").document(friendshipId).getDocument()
    if let data = friendship.data(),
       let initiatorId = data["initiatorId"] as? String {
        try await createNotification(
            userId: initiatorId,
            type: "friendAccepted",
            relatedId: friendshipId,
            content: "accepted your friend request",
            title: "Friend Request Accepted"
        )
    }
}

func getFriends(userId: String) async throws -> [Friendship] {
    let friendships = try await db.collection("friendships")
        .whereField("status", isEqualTo: "accepted")
        .whereFilter(Filter.orFilter([
            Filter.whereField("userId", isEqualTo: userId),
            Filter.whereField("friendId", isEqualTo: userId)
        ]))
        .getDocuments()

    return friendships.documents.compactMap { try? $0.data(as: Friendship.self) }
}

func searchUsers(query: String, excludeUserId: String) async throws -> [UserProfile] {
    let users = try await db.collection("users")
        .whereField("username", isGreaterThanOrEqualTo: query)
        .whereField("username", isLessThan: query + "\u{f8ff}")
        .limit(to: 20)
        .getDocuments()

    return users.documents
        .compactMap { try? $0.data(as: UserProfile.self) }
        .filter { $0.uid != excludeUserId }
}

// MARK: - Vibestreaks

private func recordInteraction(senderId: String, recipientId: String, type: String) async throws {
    // Find friendship
    let friendships = try await db.collection("friendships")
        .whereField("status", isEqualTo: "accepted")
        .whereFilter(Filter.orFilter([
            Filter.andFilter([
                Filter.whereField("userId", isEqualTo: senderId),
                Filter.whereField("friendId", isEqualTo: recipientId)
            ]),
            Filter.andFilter([
                Filter.whereField("userId", isEqualTo: recipientId),
                Filter.whereField("friendId", isEqualTo: senderId)
            ])
        ]))
        .getDocuments()

    guard let friendshipDoc = friendships.documents.first else { return }

    // Record interaction
    let interactionData: [String: Any] = [
        "friendshipId": friendshipDoc.documentID,
        "userId": senderId,
        "interactionType": type,
        "timestamp": Timestamp()
    ]

    try await db.collection("interactions").addDocument(data: interactionData)

    // Update friendship last interaction
    try await friendshipDoc.reference.updateData([
        "lastInteractionDate": Timestamp()
    ])

    // Cloud Function will calculate and update vibestreak
}

func listenToVibestreak(friendshipId: String, completion: @escaping (Int) -> Void) -> ListenerRegistration {
    return db.collection("friendships").document(friendshipId)
        .addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data(),
                  let streak = data["vibestreak"] as? Int else { return }
            completion(streak)
        }
}
```

## User Profiles (Spaces)

### Step 1: Profile Management

Add to `FirestoreService.swift`:

```swift
// MARK: - User Profiles

func getUserProfile(userId: String) async throws -> UserProfile {
    let document = try await db.collection("users").document(userId).getDocument()
    return try document.data(as: UserProfile.self)
}

func updateProfile(_ profile: UserProfile) async throws {
    guard let userId = profile.id else { return }

    var updatedProfile = profile
    updatedProfile.updatedAt = Date()

    try db.collection("users").document(userId).setData(from: updatedProfile, merge: true)
}

func updatePrivacySettings(userId: String, settings: UserProfile.PrivacySettings) async throws {
    try await db.collection("users").document(userId).updateData([
        "privacySettings": [
            "profileVisibility": settings.profileVisibility,
            "showNowPlaying": settings.showNowPlaying,
            "showListeningStats": settings.showListeningStats,
            "allowFriendRequests": settings.allowFriendRequests
        ]
    ])
}

func linkSpotifyAccount(userId: String, spotifyId: String) async throws {
    try await db.collection("users").document(userId).updateData([
        "spotifyId": spotifyId,
        "spotifyLinked": true
    ])
}
```

## Statistics & Competition

### Step 1: Stats Service

Create `vibes/Services/StatsService.swift`:

```swift
import Foundation
import FirebaseFirestore

class StatsService {
    static let shared = StatsService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Listening Stats

    func saveListeningStats(userId: String, date: Date, stats: ListeningStats) async throws {
        let dateString = formatDate(date)
        let docId = "\(userId)__\(dateString)"

        try db.collection("listeningStats").document(docId).setData(from: stats, merge: true)
    }

    func getListeningStats(userId: String, date: Date) async throws -> ListeningStats? {
        let dateString = formatDate(date)
        let docId = "\(userId)__\(dateString)"

        let document = try await db.collection("listeningStats").document(docId).getDocument()
        return try? document.data(as: ListeningStats.self)
    }

    func getWeeklyStats(userId: String, weekStart: Date) async throws -> [ListeningStats] {
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)!
        let startString = formatDate(weekStart)
        let endString = formatDate(weekEnd)

        let stats = try await db.collection("listeningStats")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startString)
            .whereField("date", isLessThan: endString)
            .getDocuments()

        return stats.documents.compactMap { try? $0.data(as: ListeningStats.self) }
    }

    // MARK: - Achievements

    func unlockAchievement(userId: String, type: String, metadata: [String: Any]) async throws {
        let docId = "\(userId)__\(type)"

        let achievementData: [String: Any] = [
            "userId": userId,
            "achievementType": type,
            "unlockedAt": Timestamp(),
            "progress": 100,
            "metadata": metadata
        ]

        try await db.collection("achievements").document(docId).setData(achievementData)

        // Create notification
        try await createNotification(
            userId: userId,
            type: "achievement",
            relatedId: docId,
            content: "You unlocked the \(type) achievement!",
            title: "Achievement Unlocked"
        )
    }

    func getAchievements(userId: String) async throws -> [Achievement] {
        let achievements = try await db.collection("achievements")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        return achievements.documents.compactMap { try? $0.data(as: Achievement.self) }
    }

    // MARK: - Weekly Recaps

    func createWeeklyRecap(userId: String, weekStart: Date, recap: WeeklyRecap) async throws {
        let dateString = formatDate(weekStart)
        let docId = "\(userId)__\(dateString)"

        try db.collection("weeklyRecaps").document(docId).setData(from: recap)
    }

    func getWeeklyRecap(userId: String, weekStart: Date) async throws -> WeeklyRecap? {
        let dateString = formatDate(weekStart)
        let docId = "\(userId)__\(dateString)"

        let document = try await db.collection("weeklyRecaps").document(docId).getDocument()
        return try? document.data(as: WeeklyRecap.self)
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func createNotification(userId: String, type: String, relatedId: String, content: String, title: String) async throws {
        let notificationData: [String: Any] = [
            "userId": userId,
            "notificationType": type,
            "relatedId": relatedId,
            "content": content,
            "title": title,
            "timestamp": Timestamp(),
            "read": false
        ]

        try await db.collection("notifications").addDocument(data: notificationData)
    }
}

struct ListeningStats: Codable {
    var userId: String
    var date: String
    var totalListeningTimeMs: Int
    var topArtists: [[String: Any]]
    var topSongs: [[String: Any]]
    var topGenres: [[String: Any]]
    var songsSent: Int
    var songsReceived: Int
    var uniqueArtistsListened: Int
    var updatedAt: Date
}

struct Achievement: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var achievementType: String
    var unlockedAt: Date
    var progress: Int
    var metadata: [String: Any]
}

struct WeeklyRecap: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var weekStart: String
    var weekEnd: String
    var topSongs: [[String: Any]]
    var topArtist: [String: Any]
    var totalListeningTimeMs: Int
    var topFriendInteractions: [[String: Any]]
    var shareableGraphicURL: String?
    var createdAt: Date
}
```

## Real-time Activity (Now Playing)

### Step 1: Now Playing Service

Add to `FirestoreService.swift`:

```swift
// MARK: - Now Playing

func updateNowPlaying(userId: String, track: NowPlayingTrack?) async throws {
    if let track = track {
        let trackData: [String: Any] = [
            "spotifyTrackId": track.id,
            "trackName": track.name,
            "artistName": track.artist,
            "albumArt": track.albumArt,
            "isPlaying": true,
            "timestamp": Timestamp(),
            "progressMs": track.progressMs,
            "durationMs": track.durationMs
        ]

        try await db.collection("nowPlaying").document(userId).setData(trackData)
    } else {
        // Clear now playing
        try await db.collection("nowPlaying").document(userId).delete()
    }
}

func getFriendsNowPlaying(friendIds: [String]) async throws -> [String: NowPlayingTrack] {
    var nowPlaying: [String: NowPlayingTrack] = [:]

    for friendId in friendIds {
        let document = try await db.collection("nowPlaying").document(friendId).getDocument()
        if let track = try? document.data(as: NowPlayingTrack.self) {
            nowPlaying[friendId] = track
        }
    }

    return nowPlaying
}

func listenToFriendsNowPlaying(friendIds: [String], completion: @escaping ([String: NowPlayingTrack]) -> Void) -> ListenerRegistration {
    // For real-time updates, we need to listen to each friend's document
    // In production, consider using a Cloud Function to aggregate this
    return db.collection("nowPlaying")
        .whereField(FieldPath.documentID(), in: friendIds)
        .addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            var nowPlaying: [String: NowPlayingTrack] = [:]
            for doc in documents {
                if let track = try? doc.data(as: NowPlayingTrack.self) {
                    nowPlaying[doc.documentID] = track
                }
            }
            completion(nowPlaying)
        }
}

struct NowPlayingTrack: Codable {
    var spotifyTrackId: String
    var trackName: String
    var artistName: String
    var albumArt: String
    var isPlaying: Bool
    var timestamp: Date
    var progressMs: Int
    var durationMs: Int
}
```

## Notifications

### Step 1: Notification Service

Add to `FirestoreService.swift`:

```swift
// MARK: - Notifications

func createNotification(userId: String, type: String, relatedId: String, content: String, title: String, imageURL: String? = nil) async throws {
    let notificationData: [String: Any] = [
        "userId": userId,
        "notificationType": type,
        "relatedId": relatedId,
        "content": content,
        "title": title,
        "imageURL": imageURL ?? "",
        "timestamp": Timestamp(),
        "read": false,
        "actionURL": generateDeepLink(type: type, relatedId: relatedId)
    ]

    try await db.collection("notifications").addDocument(data: notificationData)
}

func getNotifications(userId: String, limit: Int = 50) async throws -> [VibesNotification] {
    let notifications = try await db.collection("notifications")
        .whereField("userId", isEqualTo: userId)
        .order(by: "timestamp", descending: true)
        .limit(to: limit)
        .getDocuments()

    return notifications.documents.compactMap { try? $0.data(as: VibesNotification.self) }
}

func markNotificationAsRead(notificationId: String) async throws {
    try await db.collection("notifications").document(notificationId).updateData([
        "read": true
    ])
}

func listenToNotifications(userId: String, completion: @escaping ([VibesNotification]) -> Void) -> ListenerRegistration {
    return db.collection("notifications")
        .whereField("userId", isEqualTo: userId)
        .order(by: "timestamp", descending: true)
        .limit(to: 50)
        .addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let notifications = documents.compactMap { try? $0.data(as: VibesNotification.self) }
            completion(notifications)
        }
}

private func generateDeepLink(type: String, relatedId: String) -> String {
    switch type {
    case "message":
        return "vibes://thread/\(relatedId)"
    case "friendRequest":
        return "vibes://friends/requests"
    case "songRecommendation":
        return "vibes://song/\(relatedId)"
    case "vibestreakMilestone":
        return "vibes://friendship/\(relatedId)"
    case "achievement":
        return "vibes://stats/achievements"
    default:
        return "vibes://notifications"
    }
}

struct VibesNotification: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var notificationType: String
    var relatedId: String
    var content: String
    var title: String
    var imageURL: String?
    var timestamp: Date
    var read: Bool
    var actionURL: String
}
```

### Step 2: Push Notifications (FCM)

Create `vibes/Services/PushNotificationService.swift`:

```swift
import Foundation
import FirebaseMessaging

class PushNotificationService: NSObject, MessagingDelegate {
    static let shared = PushNotificationService()

    private override init() {
        super.init()
        Messaging.messaging().delegate = self
    }

    func updateFCMToken(userId: String) async {
        guard let token = Messaging.messaging().fcmToken else { return }

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .updateData(["fcmToken": token])
        } catch {
            print("Error updating FCM token: \(error)")
        }
    }

    // MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken,
              let userId = Auth.auth().currentUser?.uid else { return }

        Task {
            await updateFCMToken(userId: userId)
        }
    }
}
```

## Storage (Images & Graphics)

### Step 1: Storage Service

Create `vibes/Services/StorageService.swift`:

```swift
import Foundation
import FirebaseStorage
import UIKit

class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()

    private init() {}

    // MARK: - Profile Pictures

    func uploadProfilePicture(_ image: UIImage, userId: String) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImageData
        }

        let path = "users/\(userId)/profile.jpg"
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()

        // Update user profile
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .updateData(["profilePictureURL": downloadURL.absoluteString])

        return downloadURL
    }

    // MARK: - Weekly Recap Graphics

    func uploadRecapGraphic(_ image: UIImage, userId: String, weekStart: Date) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            throw StorageError.invalidImageData
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: weekStart)

        let path = "recaps/\(userId)/\(dateString).jpg"
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        return try await storageRef.downloadURL()
    }

    // MARK: - Delete Image

    func deleteImage(path: String) async throws {
        let storageRef = storage.reference().child(path)
        try await storageRef.delete()
    }

    // MARK: - Download Image

    func downloadImage(url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw StorageError.invalidImageData
        }
        return image
    }
}

enum StorageError: Error {
    case invalidImageData
    case uploadFailed
    case downloadFailed
}
```

## Security Rules

### Firestore Security Rules

1. Go to Firebase Console → Firestore Database → Rules
2. Replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isFriend(userId, friendId) {
      return exists(/databases/$(database)/documents/friendships/$(userId + '_' + friendId)) ||
             exists(/databases/$(database)/documents/friendships/$(friendId + '_' + userId));
    }

    // Users
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }

    // Friendships
    match /friendships/{friendshipId} {
      allow read: if isAuthenticated() &&
                     (resource.data.userId == request.auth.uid ||
                      resource.data.friendId == request.auth.uid);
      allow create: if isAuthenticated() &&
                       request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() &&
                       (resource.data.userId == request.auth.uid ||
                        resource.data.friendId == request.auth.uid);
      allow delete: if isAuthenticated() &&
                       (resource.data.userId == request.auth.uid ||
                        resource.data.friendId == request.auth.uid);
    }

    // Message Threads
    match /messageThreads/{threadId} {
      allow read: if isAuthenticated() &&
                     (resource.data.userId1 == request.auth.uid ||
                      resource.data.userId2 == request.auth.uid);
      allow create, update: if isAuthenticated();
    }

    // Messages
    match /messages/{messageId} {
      allow read: if isAuthenticated() &&
                     (resource.data.senderId == request.auth.uid ||
                      resource.data.recipientId == request.auth.uid);
      allow create: if isAuthenticated() &&
                       request.resource.data.senderId == request.auth.uid;
      allow update: if isAuthenticated() &&
                       (resource.data.senderId == request.auth.uid ||
                        resource.data.recipientId == request.auth.uid);
    }

    // Now Playing
    match /nowPlaying/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }

    // Notifications
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() &&
                     resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated();
      allow update: if isOwner(resource.data.userId);
    }

    // Listening Stats
    match /listeningStats/{statId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() &&
                      statId.matches(request.auth.uid + '__.*');
    }

    // Achievements
    match /achievements/{achievementId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() &&
                      achievementId.matches(request.auth.uid + '__.*');
    }

    // Weekly Recaps
    match /weeklyRecaps/{recapId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() &&
                      recapId.matches(request.auth.uid + '__.*');
    }

    // Interactions
    match /interactions/{interactionId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() &&
                       request.resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Click "Publish"

### Storage Security Rules

1. Go to Firebase Console → Storage → Rules
2. Replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile pictures
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Weekly recap graphics
    match /recaps/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click "Publish"

## Cloud Functions

Cloud Functions handle server-side logic that shouldn't run on the client.

### Step 1: Setup Cloud Functions

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Cloud Functions
firebase init functions

# Select TypeScript
# Select project: vibes
```

### Step 2: Key Cloud Functions

Create `functions/src/index.ts`:

```typescript
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// Calculate vibestreak daily
export const updateVibestreaks = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const friendships = await db.collection("friendships")
      .where("status", "==", "accepted")
      .get();

    const batch = db.batch();

    for (const friendship of friendships.docs) {
      const data = friendship.data();
      const friendshipId = friendship.id;

      // Check if both users interacted today
      const interactions = await db.collection("interactions")
        .where("friendshipId", "==", friendshipId)
        .where("timestamp", ">=", admin.firestore.Timestamp.fromDate(today))
        .get();

      const userIds = new Set(interactions.docs.map(doc => doc.data().userId));

      if (userIds.size === 2) {
        // Both users interacted - increment streak
        batch.update(friendship.ref, {
          vibestreak: admin.firestore.FieldValue.increment(1),
          lastInteractionDate: admin.firestore.Timestamp.now()
        });

        // Check for milestone
        const newStreak = (data.vibestreak || 0) + 1;
        if ([7, 30, 100, 365].includes(newStreak)) {
          // Create milestone notification for both users
          await createVibestreakMilestone(data.userId, data.friendId, newStreak, friendshipId);
        }
      } else if (data.lastInteractionDate) {
        const lastInteraction = data.lastInteractionDate.toDate();
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);

        if (lastInteraction < yesterday) {
          // Streak broken - reset
          batch.update(friendship.ref, {
            vibestreak: 0
          });
        }
      }
    }

    await batch.commit();
    return null;
  });

async function createVibestreakMilestone(userId: string, friendId: string, streak: number, friendshipId: string) {
  const batch = db.batch();

  const notification1 = db.collection("notifications").doc();
  batch.set(notification1, {
    userId: userId,
    notificationType: "vibestreakMilestone",
    relatedId: friendshipId,
    content: `You reached a ${streak}-day vibestreak!`,
    title: `${streak}-Day Streak!`,
    timestamp: admin.firestore.Timestamp.now(),
    read: false,
    actionURL: `vibes://friendship/${friendshipId}`
  });

  const notification2 = db.collection("notifications").doc();
  batch.set(notification2, {
    userId: friendId,
    notificationType: "vibestreakMilestone",
    relatedId: friendshipId,
    content: `You reached a ${streak}-day vibestreak!`,
    title: `${streak}-Day Streak!`,
    timestamp: admin.firestore.Timestamp.now(),
    read: false,
    actionURL: `vibes://friendship/${friendshipId}`
  });

  await batch.commit();
}

// Calculate music compatibility score
export const calculateCompatibility = functions.firestore
  .document("friendships/{friendshipId}")
  .onCreate(async (snap, context) => {
    const friendship = snap.data();
    const userId = friendship.userId;
    const friendId = friendship.friendId;

    // Get both users' profiles
    const [userDoc, friendDoc] = await Promise.all([
      db.collection("users").doc(userId).get(),
      db.collection("users").doc(friendId).get()
    ]);

    const user = userDoc.data();
    const friend = friendDoc.data();

    if (!user || !friend) return;

    // Calculate shared artists
    const userArtists = new Set(user.favoriteArtists || []);
    const friendArtists = friend.favoriteArtists || [];
    const sharedArtists = friendArtists.filter((artist: string) => userArtists.has(artist));

    // Simple compatibility calculation (can be enhanced with Spotify API)
    const totalArtists = userArtists.size + friendArtists.length - sharedArtists.length;
    const compatibilityScore = totalArtists > 0 ? (sharedArtists.length / totalArtists) * 100 : 0;

    // Update friendship
    await snap.ref.update({
      compatibilityScore: Math.round(compatibilityScore),
      sharedArtists: sharedArtists
    });
  });

// Send push notification when message is sent
export const sendMessageNotification = functions.firestore
  .document("messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const recipientId = message.recipientId;

    // Get recipient's FCM token
    const recipientDoc = await db.collection("users").doc(recipientId).get();
    const fcmToken = recipientDoc.data()?.fcmToken;

    if (!fcmToken) return;

    // Get sender's name
    const senderDoc = await db.collection("users").doc(message.senderId).get();
    const senderName = senderDoc.data()?.displayName || "Someone";

    const notification = {
      title: senderName,
      body: message.messageType === "song" ? "🎵 Sent you a song" : message.content
    };

    await admin.messaging().send({
      token: fcmToken,
      notification: notification,
      data: {
        threadId: message.threadId,
        type: "message"
      }
    });
  });

// Generate weekly recap
export const generateWeeklyRecap = functions.pubsub
  .schedule("every monday 00:00")
  .onRun(async (context) => {
    const users = await db.collection("users").get();

    for (const userDoc of users.docs) {
      const userId = userDoc.id;

      // Calculate week start
      const now = new Date();
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - 7);

      // Aggregate stats for the week
      // This would integrate with Spotify API to get actual listening data
      // For now, create placeholder

      const recap = {
        userId: userId,
        weekStart: formatDate(weekStart),
        weekEnd: formatDate(now),
        topSongs: [],
        topArtist: {},
        totalListeningTimeMs: 0,
        topFriendInteractions: [],
        createdAt: admin.firestore.Timestamp.now()
      };

      await db.collection("weeklyRecaps").doc(`${userId}__${formatDate(weekStart)}`).set(recap);

      // Send notification
      await db.collection("notifications").add({
        userId: userId,
        notificationType: "weeklyRecap",
        relatedId: `${userId}__${formatDate(weekStart)}`,
        content: "Your weekly recap is ready!",
        title: "vibes Weekly",
        timestamp: admin.firestore.Timestamp.now(),
        read: false,
        actionURL: "vibes://stats/recap"
      });
    }

    return null;
  });

function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}
```

### Step 3: Deploy Cloud Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:updateVibestreaks
```

## Testing

### Step 1: Use Firebase Emulator Suite

```bash
# Install emulators
firebase init emulators

# Select: Authentication, Firestore, Functions, Storage

# Start emulators
firebase emulators:start
```

### Step 2: Connect App to Emulators

Add to `vibesApp.swift` init:

```swift
#if DEBUG
func connectToEmulators() {
    let settings = Firestore.firestore().settings
    settings.host = "localhost:8080"
    settings.isSSLEnabled = false
    Firestore.firestore().settings = settings

    Auth.auth().useEmulator(withHost: "localhost", port: 9099)
    Storage.storage().useEmulator(withHost: "localhost", port: 9199)
}
#endif
```

### Step 3: Test Data

Create test users and seed data in emulator.

## Production Checklist

### Before Launch:

- [ ] Enable App Check for iOS
- [ ] Set up Firebase Analytics
- [ ] Configure Firebase Crashlytics
- [ ] Set up monitoring and alerts
- [ ] Review security rules
- [ ] Test all Cloud Functions
- [ ] Set up backups
- [ ] Configure rate limiting
- [ ] Test push notifications on physical devices
- [ ] Verify Spotify OAuth integration
- [ ] Load test with 1000+ concurrent users
- [ ] Set up staging environment

### Performance Optimization:

- [ ] Enable offline persistence
- [ ] Implement pagination for large lists
- [ ] Cache frequently accessed data
- [ ] Optimize Firestore indexes
- [ ] Compress images before upload
- [ ] Use batch writes where possible
- [ ] Implement proper error handling

## Cost Optimization

### Free Tier Limits:
- Firestore: 50K reads/day, 20K writes/day
- Storage: 5GB, 1GB/day download
- Cloud Functions: 2M invocations/month
- FCM: Unlimited

### Tips:
- Use real-time listeners efficiently (detach when not needed)
- Batch writes to reduce operations
- Cache data locally
- Optimize images before upload
- Use Cloud Functions for heavy computation

## Next Steps

1. ✅ Complete authentication implementation
2. ✅ Set up Firestore collections
3. ✅ Implement real-time messaging
4. ✅ Build friend system with vibestreaks
5. ✅ Create statistics tracking
6. ✅ Add push notifications
7. ⏭️ Integrate Spotify API (separate guide)
8. ⏭️ Implement AI playlist recommendations
9. ⏭️ Build UI according to docs/style.md
10. ⏭️ Test and deploy

---

**Firebase provides the complete backend infrastructure for vibes. This implementation supports all features from the PRD including messaging, friendships, vibestreaks, stats, real-time activity, and notifications.**
