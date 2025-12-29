//
//  ChatsView.swift
//  vibes
//
//  Created by Claude Code on 12/19/25.
//

import SwiftUI
import FirebaseAuth

struct ChatsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(AppRouter.self) private var router
    @StateObject private var viewModel = ChatsViewModel()
    @State private var showingAddFriend = false
    @State private var showingCreateGroup = false
    @State private var selectedFriendForBlend: FriendProfile?
    @State private var searchText = ""

    private var filteredChats: [ChatItem] {
        if searchText.isEmpty {
            return viewModel.allChats
        }
        let query = searchText.lowercased()
        return viewModel.allChats.filter { chat in
            chat.friend.displayName.lowercased().contains(query) ||
            chat.friend.username.lowercased().contains(query)
        }
    }

    private var filteredGroups: [GroupThread] {
        if searchText.isEmpty {
            return viewModel.groupThreads
        }
        let query = searchText.lowercased()
        return viewModel.groupThreads.filter { $0.name.lowercased().contains(query) }
    }

    var body: some View {
        @Bindable var router = router

        return NavigationStack(path: $router.chatsPath) {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: FriendProfile.self) { friend in
                    if let currentUserId = authManager.user?.uid {
                        MessageThreadContainer(
                            friendId: friend.id,
                            friendUsername: friend.username,
                            currentUserId: currentUserId
                        )
                    }
                }
                .navigationDestination(for: GroupThread.self) { group in
                    if let currentUserId = authManager.user?.uid {
                        GroupThreadView(group: group, currentUserId: currentUserId)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack(spacing: 16) {
                            Button {
                                showingAddFriend = true
                            } label: {
                                Image(systemName: "person.badge.plus")
                                    .imageScale(.large)
                            }

                            Button {
                                showingCreateGroup = true
                            } label: {
                                Image(systemName: "person.3.fill")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddFriend) {
                    AddFriendView(viewModel: viewModel.friendsViewModel)
                }
                .sheet(isPresented: $showingCreateGroup) {
                    CreateGroupView()
                }
                .sheet(item: $selectedFriendForBlend) { friend in
                    NavigationStack {
                        FriendBlendView(friend: friend)
                            .environmentObject(authManager)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Done") {
                                        selectedFriendForBlend = nil
                                    }
                                }
                            }
                    }
                }
        }
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.loadData()
        }
        .onChange(of: router.shouldShowNewChat) { _, shouldShow in
            if shouldShow {
                showingAddFriend = true
                router.shouldShowNewChat = false
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.allChats.isEmpty {
            ProgressView()
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Chats")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    searchBar
                    if searchText.isEmpty {
                        nowPlayingSection
                        notificationsSection
                        pendingRequestsSection
                    }
                    groupsSection
                    chatsSection
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search friends...", text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    HapticService.lightImpact()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.tertiarySystemFill))
        .cornerRadius(10)
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("Notifications")
                    .font(.headline)

                if unreadNotificationCount > 0 {
                    Text(unreadNotificationCountText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }
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
        .cardStyle()
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
                .cardStyle()
            }
        }
    }

    private func pendingRequestRow(_ request: (friendship: Friendship, profile: FriendProfile)) -> some View {
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
                    HapticService.lightImpact()
                    Task {
                        await viewModel.acceptFriendRequest(friendshipId: request.friendship.id ?? "")
                        HapticService.success()
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .imageScale(.large)
                }

                Button {
                    HapticService.lightImpact()
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

    @ViewBuilder
    private var nowPlayingSection: some View {
        if !viewModel.friendsNowPlaying.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .foregroundColor(.green)
                    Text("Now Playing")
                        .font(.headline)
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.friendsNowPlaying) { friend in
                            NowPlayingCard(friend: friend) {
                                router.chatsPath.append(friend)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.friendsNowPlaying.count)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .cardStyle()
        }
    }

    private var chatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(searchText.isEmpty ? "Conversations" : "Results")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.allChats.isEmpty {
                emptyStateView(text: "No conversations yet. Add friends to start chatting!")
            } else if filteredChats.isEmpty {
                emptyStateView(text: "No friends matching \"\(searchText)\"")
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredChats) { chat in
                        Button {
                            searchText = ""
                            router.chatsPath.append(chat.friend)
                        } label: {
                            ChatRowView(chat: chat)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button {
                                HapticService.lightImpact()
                                selectedFriendForBlend = chat.friend
                            } label: {
                                Label("Create Music Blend", systemImage: "wand.and.stars")
                            }
                        }

                        if chat.id != filteredChats.last?.id {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .cardStyle()
    }

    @ViewBuilder
    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.purple)
                Text("Groups")
                    .font(.headline)

                Spacer()

                Button {
                    showingCreateGroup = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.purple)
                }
            }
            .padding(.horizontal)

            if filteredGroups.isEmpty {
                if searchText.isEmpty {
                    VStack(spacing: 8) {
                        Text("No groups yet")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text("Tap + to create a group chat")
                            .font(.caption)
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                } else {
                    emptyStateView(text: "No groups matching \"\(searchText)\"")
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredGroups) { group in
                        Button {
                            searchText = ""
                            router.chatsPath.append(group)
                        } label: {
                            GroupRowView(group: group, currentUserId: authManager.user?.uid ?? "")
                        }
                        .buttonStyle(.plain)

                        if group.id != filteredGroups.last?.id {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .cardStyle()
    }

    private func emptyStateView(text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(Color(.tertiaryLabel))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }

    private var unreadNotificationCount: Int {
        viewModel.notifications.filter { !$0.isRead }.count
    }

    private var unreadNotificationCountText: String {
        if unreadNotificationCount > 99 {
            return "99+"
        }
        return "\(unreadNotificationCount)"
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

// MARK: - Now Playing Card

struct NowPlayingCard: View {
    let friend: FriendProfile
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    if let albumArt = friend.nowPlayingAlbumArt,
                       let url = URL(string: albumArt) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color(.tertiarySystemFill)
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                    } else {
                        Color(.tertiarySystemFill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .overlay {
                                Image(systemName: "music.note")
                                    .foregroundColor(.secondary)
                            }
                    }

                    // Animated equalizer
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { index in
                            SoundWaveBar(delay: Double(index) * 0.1)
                        }
                    }
                    .padding(4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(4)
                    .padding(4)
                }

                VStack(spacing: 2) {
                    Text(friend.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if let trackName = friend.nowPlayingTrackName {
                        Text(trackName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .frame(width: 90)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chat Item (for DM display)

struct ChatItem: Identifiable {
    let id: String
    let name: String
    let lastMessage: String
    let timestamp: Date
    let unreadCount: Int
    let friend: FriendProfile
    let vibestreak: Int
    let vibestreakCompletedToday: Bool
    let compatibility: CompatibilityResult?

    var displayTime: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(timestamp) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: timestamp)
        } else if calendar.isDateInYesterday(timestamp) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: timestamp)
        }
    }
}

// MARK: - Group Row View

struct GroupRowView: View {
    let group: GroupThread
    let currentUserId: String

    var body: some View {
        HStack(spacing: 12) {
            // Group avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.6), .blue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: "person.3.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(group.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    Text(displayTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    if let senderName = group.lastMessageSenderName, !group.lastMessageContent.isEmpty {
                        Text("\(senderName): \(group.lastMessageContent)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("No messages yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if unreadCount > 0 {
                        Text(unreadCount > 99 ? "99+" : "\(unreadCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple)
                            .clipShape(Capsule())
                    }
                }
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .imageScale(.small)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private var unreadCount: Int {
        group.unreadCount(for: currentUserId)
    }

    private var displayTime: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(group.lastMessageTimestamp) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: group.lastMessageTimestamp)
        } else if calendar.isDateInYesterday(group.lastMessageTimestamp) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: group.lastMessageTimestamp)
        }
    }
}

#Preview {
    ChatsView()
        .environment(AppRouter())
        .environmentObject(AuthManager.shared)
}
