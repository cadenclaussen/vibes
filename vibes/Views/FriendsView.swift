//
//  FriendsView.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import SwiftUI
import FirebaseAuth

struct FriendsView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = FriendsViewModel()
    @State private var showingAddFriend = false
    @State private var navigationPath = NavigationPath()
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool
    @Binding var navigateToFriend: FriendProfile?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            contentView
                .navigationTitle("Friends")
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
        .onChange(of: navigateToFriend) { _, friend in
            if let friend = friend {
                navigationPath.append(friend)
                navigateToFriend = nil
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.friends.isEmpty {
            ProgressView()
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    notificationsSection
                    pendingRequestsSection
                    friendsSection
                }
                .padding()
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Spacer()
            Button {
                showingAddFriend = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.badge.plus")
                    Text("Add Friend")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(20)
            }
        }
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("Notifications")
                    .font(.headline)

                if unreadCount > 0 {
                    Text(unreadCountText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        
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
                        NavigationLink(value: friend) {
                            friendRow(friend)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .cardStyle()
        
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

            if friend.activeVibestreak > 0 {
                HStack(spacing: 2) {
                    Text("\(friend.activeVibestreak)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    Text("🔥")
                        .font(.subheadline)
                }
            }

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

    private var unreadCount: Int {
        viewModel.notifications.filter { !$0.isRead }.count
    }

    private var unreadCountText: String {
        if unreadCount > 99 {
            return "99+"
        }
        return "\(unreadCount)"
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
    FriendsView(selectedTab: .constant(1), shouldEditProfile: .constant(false), navigateToFriend: .constant(nil))
        .environmentObject(AuthManager.shared)
}
