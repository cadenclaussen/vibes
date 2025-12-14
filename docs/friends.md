# Friends Tab Implementation Guide

## Overview

This guide provides step-by-step instructions for implementing the Friends tab with notifications. The Friends tab is a core feature that enables social interactions through friend management and activity notifications.

## MVP Features

For the initial version, we'll implement:

1. **Notifications section** (at top) - Shows recent activity and friend requests
2. **Friend list** - Displays all friends with basic info
3. **Add friend** - Search and send friend requests by username
4. **Friend requests** - Accept or decline incoming requests
5. **Friend profile** - View basic friend info (tap on friend)

**Out of scope for MVP:**
- Messaging and song sharing (future feature)
- Vibestreaks (future feature)
- Real-time "Now Playing" (future feature)
- Music taste compatibility scores (future feature)
- AI recommendations (future feature)

---

## Data Models

### Friend Model

```swift
import Foundation
import FirebaseFirestore

struct Friend: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let friendId: String
    let status: FriendStatus
    let createdAt: Date

    enum FriendStatus: String, Codable {
        case pending
        case accepted
        case declined
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case friendId
        case status
        case createdAt
    }
}
```

### FriendNotification Model

```swift
import Foundation
import FirebaseFirestore

struct FriendNotification: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let type: NotificationType
    let fromUserId: String
    let fromUsername: String
    let message: String
    let createdAt: Date
    let isRead: Bool

    enum NotificationType: String, Codable {
        case friendRequest
        case friendAccepted
        case newMessage
        case milestone
    }
}
```

### FriendProfile Model

```swift
import Foundation

struct FriendProfile: Codable, Identifiable {
    let id: String
    let username: String
    let displayName: String
    let email: String
    let musicTasteTags: [String]

    init(from userProfile: UserProfile) {
        self.id = userProfile.uid
        self.username = userProfile.username
        self.displayName = userProfile.displayName
        self.email = userProfile.email
        self.musicTasteTags = userProfile.musicTasteTags
    }
}
```

---

## Firestore Structure

```
users/{userId}
  - uid: String
  - username: String
  - displayName: String
  - email: String
  - musicTasteTags: [String]
  - ...

friendships/{friendshipId}
  - userId: String (requester)
  - friendId: String (recipient)
  - status: String (pending, accepted, declined)
  - createdAt: Timestamp

notifications/{notificationId}
  - userId: String (recipient)
  - type: String (friendRequest, friendAccepted, etc.)
  - fromUserId: String
  - fromUsername: String
  - message: String
  - createdAt: Timestamp
  - isRead: Bool
```

---

## Implementation Steps

### Step 1: Create Friend Service

Create `vibes/Services/FriendService.swift`:

```swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendService {
    static let shared = FriendService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Friend Requests

    func sendFriendRequest(toUsername: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let usersRef = db.collection("users")
        let snapshot = try await usersRef.whereField("username", isEqualTo: toUsername).getDocuments()

        guard let targetUser = snapshot.documents.first else {
            throw NSError(domain: "FriendService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        let targetUserId = targetUser.documentID

        if targetUserId == currentUserId {
            throw NSError(domain: "FriendService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cannot send friend request to yourself"])
        }

        let existingFriendship = try await checkExistingFriendship(userId: currentUserId, friendId: targetUserId)
        if existingFriendship != nil {
            throw NSError(domain: "FriendService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Friend request already exists"])
        }

        let friendship = Friend(
            userId: currentUserId,
            friendId: targetUserId,
            status: .pending,
            createdAt: Date()
        )

        try db.collection("friendships").document().setData(from: friendship)

        let currentUserProfile = try await fetchUserProfile(userId: currentUserId)
        try await createNotification(
            userId: targetUserId,
            type: .friendRequest,
            fromUserId: currentUserId,
            fromUsername: currentUserProfile.username,
            message: "\(currentUserProfile.displayName) sent you a friend request"
        )
    }

    func acceptFriendRequest(friendshipId: String) async throws {
        let friendshipRef = db.collection("friendships").document(friendshipId)
        try await friendshipRef.updateData(["status": Friend.FriendStatus.accepted.rawValue])

        let friendshipDoc = try await friendshipRef.getDocument()
        guard let friendship = try? friendshipDoc.data(as: Friend.self) else { return }

        let currentUserProfile = try await fetchUserProfile(userId: friendship.friendId)
        try await createNotification(
            userId: friendship.userId,
            type: .friendAccepted,
            fromUserId: friendship.friendId,
            fromUsername: currentUserProfile.username,
            message: "\(currentUserProfile.displayName) accepted your friend request"
        )
    }

    func declineFriendRequest(friendshipId: String) async throws {
        try await db.collection("friendships").document(friendshipId).delete()
    }

    func removeFriend(friendshipId: String) async throws {
        try await db.collection("friendships").document(friendshipId).delete()
    }

    // MARK: - Fetch Friends

    func fetchFriends() async throws -> [FriendProfile] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let friendshipsRef = db.collection("friendships")

        let sentRequests = try await friendshipsRef
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: Friend.FriendStatus.accepted.rawValue)
            .getDocuments()

        let receivedRequests = try await friendshipsRef
            .whereField("friendId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: Friend.FriendStatus.accepted.rawValue)
            .getDocuments()

        var friendIds: [String] = []
        friendIds.append(contentsOf: sentRequests.documents.compactMap { try? $0.data(as: Friend.self)?.friendId })
        friendIds.append(contentsOf: receivedRequests.documents.compactMap { try? $0.data(as: Friend.self)?.userId })

        var friendProfiles: [FriendProfile] = []
        for friendId in friendIds {
            if let profile = try? await fetchUserProfile(userId: friendId) {
                friendProfiles.append(FriendProfile(from: profile))
            }
        }

        return friendProfiles
    }

    func fetchPendingRequests() async throws -> [(friendship: Friend, profile: FriendProfile)] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let snapshot = try await db.collection("friendships")
            .whereField("friendId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: Friend.FriendStatus.pending.rawValue)
            .getDocuments()

        var requests: [(friendship: Friend, profile: FriendProfile)] = []

        for document in snapshot.documents {
            if let friendship = try? document.data(as: Friend.self),
               let userProfile = try? await fetchUserProfile(userId: friendship.userId) {
                requests.append((friendship, FriendProfile(from: userProfile)))
            }
        }

        return requests
    }

    // MARK: - Notifications

    func fetchNotifications() async throws -> [FriendNotification] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FriendService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: currentUserId)
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: FriendNotification.self) }
    }

    func markNotificationAsRead(notificationId: String) async throws {
        try await db.collection("notifications").document(notificationId).updateData(["isRead": true])
    }

    // MARK: - Helper Methods

    private func checkExistingFriendship(userId: String, friendId: String) async throws -> Friend? {
        let sentRequest = try await db.collection("friendships")
            .whereField("userId", isEqualTo: userId)
            .whereField("friendId", isEqualTo: friendId)
            .getDocuments()

        if let doc = sentRequest.documents.first {
            return try? doc.data(as: Friend.self)
        }

        let receivedRequest = try await db.collection("friendships")
            .whereField("userId", isEqualTo: friendId)
            .whereField("friendId", isEqualTo: userId)
            .getDocuments()

        if let doc = receivedRequest.documents.first {
            return try? doc.data(as: Friend.self)
        }

        return nil
    }

    private func fetchUserProfile(userId: String) async throws -> UserProfile {
        let doc = try await db.collection("users").document(userId).getDocument()
        guard let profile = try? doc.data(as: UserProfile.self) else {
            throw NSError(domain: "FriendService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
        }
        return profile
    }

    private func createNotification(userId: String, type: FriendNotification.NotificationType, fromUserId: String, fromUsername: String, message: String) async throws {
        let notification = FriendNotification(
            userId: userId,
            type: type,
            fromUserId: fromUserId,
            fromUsername: fromUsername,
            message: message,
            createdAt: Date(),
            isRead: false
        )
        try db.collection("notifications").document().setData(from: notification)
    }
}
```

### Step 2: Create FriendsViewModel

Create `vibes/ViewModels/FriendsViewModel.swift`:

```swift
import Foundation

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [FriendProfile] = []
    @Published var pendingRequests: [(friendship: Friend, profile: FriendProfile)] = []
    @Published var notifications: [FriendNotification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let friendService = FriendService.shared

    func loadFriends() async {
        isLoading = true
        errorMessage = nil

        do {
            friends = try await friendService.fetchFriends()
        } catch {
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func loadPendingRequests() async {
        do {
            pendingRequests = try await friendService.fetchPendingRequests()
        } catch {
            errorMessage = "Failed to load requests: \(error.localizedDescription)"
        }
    }

    func loadNotifications() async {
        do {
            notifications = try await friendService.fetchNotifications()
        } catch {
            errorMessage = "Failed to load notifications: \(error.localizedDescription)"
        }
    }

    func sendFriendRequest(username: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await friendService.sendFriendRequest(toUsername: username)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func acceptFriendRequest(friendshipId: String) async {
        do {
            try await friendService.acceptFriendRequest(friendshipId: friendshipId)
            await loadFriends()
            await loadPendingRequests()
            await loadNotifications()
        } catch {
            errorMessage = "Failed to accept request: \(error.localizedDescription)"
        }
    }

    func declineFriendRequest(friendshipId: String) async {
        do {
            try await friendService.declineFriendRequest(friendshipId: friendshipId)
            await loadPendingRequests()
            await loadNotifications()
        } catch {
            errorMessage = "Failed to decline request: \(error.localizedDescription)"
        }
    }

    func removeFriend(friendshipId: String) async {
        do {
            try await friendService.removeFriend(friendshipId: friendshipId)
            await loadFriends()
        } catch {
            errorMessage = "Failed to remove friend: \(error.localizedDescription)"
        }
    }

    func markNotificationAsRead(notificationId: String) async {
        do {
            try await friendService.markNotificationAsRead(notificationId: notificationId)
            await loadNotifications()
        } catch {
            print("Failed to mark notification as read: \(error.localizedDescription)")
        }
    }
}
```

### Step 3: Create AddFriendView

Create `vibes/Views/AddFriendView.swift`:

```swift
import SwiftUI

struct AddFriendView: View {
    @ObservedObject var viewModel: FriendsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var username = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter your friend's username")
                    .font(.headline)
                    .foregroundColor(Color(.secondaryLabel))

                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(.horizontal)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        Task {
                            await viewModel.sendFriendRequest(username: username)
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(username.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}
```

### Step 4: Create FriendDetailView

Create `vibes/Views/FriendDetailView.swift`:

```swift
import SwiftUI

struct FriendDetailView: View {
    let friend: FriendProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                infoSection
                genresSection
            }
            .padding()
        }
        .navigationTitle(friend.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(.tertiaryLabel))

            Text(friend.displayName)
                .font(.title)
                .fontWeight(.bold)

            Text("@\(friend.username)")
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    private var infoSection: some View {
        VStack(spacing: 12) {
            infoRow(label: "Email", value: friend.email)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(Color(.secondaryLabel))

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(Color(.label))
        }
    }

    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorite Genres")
                .font(.headline)

            if friend.musicTasteTags.isEmpty {
                Text("No genres added")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(friend.musicTasteTags, id: \.self) { genre in
                        Text(genre)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(16)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
```

### Step 5: Create FriendsView

Replace the placeholder in `vibes/ContentView.swift` with `vibes/Views/FriendsView.swift`:

```swift
import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var showingAddFriend = false

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Friends")
                .toolbar {
                    Button {
                        showingAddFriend = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
                .sheet(isPresented: $showingAddFriend) {
                    AddFriendView(viewModel: viewModel)
                }
        }
        .task {
            await loadData()
        }
        .refreshable {
            await loadData()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.friends.isEmpty {
            ProgressView()
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    notificationsSection
                    pendingRequestsSection
                    friendsSection
                }
                .padding()
            }
        }
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.notifications.isEmpty {
                emptyStateView(text: "No notifications")
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.notifications.prefix(5)) { notification in
                        notificationRow(notification)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func notificationRow(_ notification: FriendNotification) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconForNotificationType(notification.type))
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(notification.message)
                    .font(.body)
                    .foregroundColor(notification.isRead ? Color(.secondaryLabel) : Color(.label))

                Text(timeAgoString(from: notification.createdAt))
                    .font(.caption)
                    .foregroundColor(Color(.tertiaryLabel))
            }

            Spacer()

            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            Task {
                await viewModel.markNotificationAsRead(notificationId: notification.id ?? "")
            }
        }
    }

    private var pendingRequestsSection: some View {
        Group {
            if !viewModel.pendingRequests.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Friend Requests")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 8) {
                        ForEach(viewModel.pendingRequests, id: \.friendship.id) { request in
                            pendingRequestRow(request)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    private func pendingRequestRow(_ request: (friendship: Friend, profile: FriendProfile)) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(Color(.tertiaryLabel))

            VStack(alignment: .leading, spacing: 2) {
                Text(request.profile.displayName)
                    .font(.headline)
                Text("@\(request.profile.username)")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    Task {
                        await viewModel.acceptFriendRequest(friendshipId: request.friendship.id ?? "")
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .imageScale(.large)
                }

                Button {
                    Task {
                        await viewModel.declineFriendRequest(friendshipId: request.friendship.id ?? "")
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .imageScale(.large)
                }
            }
        }
        .padding(.horizontal)
    }

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friends")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.friends.isEmpty {
                emptyStateView(text: "No friends yet. Tap + to add friends!")
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.friends) { friend in
                        NavigationLink(destination: FriendDetailView(friend: friend)) {
                            friendRow(friend)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func friendRow(_ friend: FriendProfile) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(Color(.tertiaryLabel))

            VStack(alignment: .leading, spacing: 2) {
                Text(friend.displayName)
                    .font(.headline)
                    .foregroundColor(Color(.label))
                Text("@\(friend.username)")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(Color(.tertiaryLabel))
                .imageScale(.small)
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }

    private func emptyStateView(text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(Color(.tertiaryLabel))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }

    private func loadData() async {
        await viewModel.loadFriends()
        await viewModel.loadPendingRequests()
        await viewModel.loadNotifications()
    }

    private func iconForNotificationType(_ type: FriendNotification.NotificationType) -> String {
        switch type {
        case .friendRequest:
            return "person.badge.plus"
        case .friendAccepted:
            return "checkmark.circle"
        case .newMessage:
            return "message"
        case .milestone:
            return "star.fill"
        }
    }

    private func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))

        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours)h ago"
        } else {
            let days = seconds / 86400
            return "\(days)d ago"
        }
    }
}

#Preview {
    FriendsView()
}
```

### Step 6: Update ContentView

Update `vibes/ContentView.swift` to use the new FriendsView:

```swift
// Replace the Friends tab placeholder with:
NavigationStack {
    FriendsView()
}
.tabItem {
    Label("Friends", systemImage: "person.2")
}
```

---

## Testing Checklist

- [ ] Build project successfully
- [ ] Launch app on simulator
- [ ] Navigate to Friends tab
- [ ] Verify three sections appear: Notifications, Friend Requests, Friends
- [ ] Tap + button to add friend
- [ ] Enter a username and send friend request
- [ ] Verify error handling for invalid username
- [ ] Create second test account to accept friend request
- [ ] Accept friend request and verify it appears in Friends list
- [ ] Tap on friend to view friend detail page
- [ ] Verify friend profile displays correctly
- [ ] Test pull-to-refresh functionality
- [ ] Verify notifications section shows recent activity

---

## Future Enhancements

After MVP is complete, consider adding:

1. **Messaging** - Tap friend to open message thread
2. **Vibestreaks** - Daily engagement tracking with friends
3. **Now Playing** - Real-time friend listening activity
4. **Compatibility Scores** - Music taste matching percentage
5. **AI Recommendations** - Personalized new music suggestions
6. **Search Friends** - Search bar for finding friends in large lists
7. **Remove Friend** - Swipe to delete or remove friend action
8. **Block User** - Block and report functionality

---

## Notes

- All code follows `docs/style.md` guidelines (MVVM, semantic colors, Dynamic Type)
- Uses Firebase Firestore for data persistence
- Implements proper error handling and loading states
- Pull-to-refresh support for updating data
- Navigation uses NavigationStack (iOS 16+)
- Time-ago formatting for notifications (e.g., "2h ago", "3d ago")
