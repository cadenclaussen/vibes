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
    @StateObject private var viewModel = ChatsViewModel()
    @State private var showingAddFriend = false
    @State private var navigationPath = NavigationPath()
    @State private var selectedFriendForBlend: FriendProfile?
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool

    var body: some View {
        NavigationStack(path: $navigationPath) {
            contentView
                .navigationTitle("Chats")
                .navigationDestination(for: FriendProfile.self) { friend in
                    if let currentUserId = authManager.user?.uid {
                        MessageThreadContainer(
                            friendId: friend.id,
                            friendUsername: friend.username,
                            currentUserId: currentUserId
                        )
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        SettingsMenu(selectedTab: $selectedTab, shouldEditProfile: $shouldEditProfile)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingAddFriend = true
                        } label: {
                            Image(systemName: "person.badge.plus")
                                .imageScale(.large)
                        }
                    }
                }
                .sheet(isPresented: $showingAddFriend) {
                    AddFriendView(viewModel: viewModel.friendsViewModel)
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
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.allChats.isEmpty {
            ProgressView()
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    nowPlayingSection
                    notificationsSection
                    pendingRequestsSection
                    chatsSection
                }
                .padding()
            }
        }
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
                                navigationPath.append(friend)
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
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private var chatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conversations")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.allChats.isEmpty {
                emptyStateView(text: "No conversations yet. Add friends to start chatting!")
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.allChats) { chat in
                        Button {
                            navigationPath.append(chat.friend)
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

                        if chat.id != viewModel.allChats.last?.id {
                            Divider()
                                .padding(.leading, 64)
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

#Preview {
    ChatsView(selectedTab: .constant(1), shouldEditProfile: .constant(false))
        .environmentObject(AuthManager.shared)
}
