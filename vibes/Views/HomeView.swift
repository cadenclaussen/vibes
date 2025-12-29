//
//  HomeView.swift
//  vibes
//
//  Home tab - personalized hub with greeting, quick actions, and recent activity.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var friendsViewModel = FriendsViewModel()
    @StateObject private var musicServiceManager = MusicServiceManager.shared
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @State private var showingNewChat = false
    @State private var showingBlend = false

    var body: some View {
        NavigationStack(path: Binding(
            get: { router.homePath },
            set: { router.homePath = $0 }
        )) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    headerSection
                    quickActionsSection

                    if !viewModel.recentChats.isEmpty || viewModel.isLoadingChats {
                        recentChatsSection
                    }

                    if !viewModel.friendActivity.isEmpty || viewModel.isLoadingActivity {
                        friendActivitySection
                    }

                    if viewModel.todaysPick != nil || viewModel.isLoadingPick {
                        todaysPickSection
                    }

                    if !viewModel.vibestreakReminders.isEmpty {
                        vibestreakSection
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.loadAllData()
            }
            .navigationDestination(for: FriendProfile.self) { friend in
                MessageThreadContainer(
                    friendId: friend.id,
                    friendUsername: friend.displayName,
                    currentUserId: Auth.auth().currentUser?.uid ?? ""
                )
            }
        }
        .task {
            await viewModel.loadAllData()
        }
        .onChange(of: router.shouldShowNewChat) { _, shouldShow in
            if shouldShow {
                showingNewChat = true
                router.shouldShowNewChat = false
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
        .sheet(isPresented: $showingNewChat) {
            AddFriendView(viewModel: friendsViewModel)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(viewModel.greeting), \(viewModel.userName)")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    quickActionButton(
                        icon: "magnifyingglass",
                        title: "Search",
                        color: .blue
                    ) {
                        router.goToSearch()
                    }

                    quickActionButton(
                        icon: "plus.message",
                        title: "New Chat",
                        color: .green
                    ) {
                        showingNewChat = true
                    }

                    if GeminiService.shared.isConfigured {
                        quickActionButton(
                            icon: "wand.and.stars",
                            title: "AI Blend",
                            color: .purple
                        ) {
                            router.goToBlend()
                        }
                    }

                    quickActionButton(
                        icon: "person.2",
                        title: "Friends",
                        color: .orange
                    ) {
                        router.goToChats()
                    }
                }
            }
        }
    }

    private func quickActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent Chats Section

    private var recentChatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Chats")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    router.goToChats()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            if viewModel.isLoadingChats && viewModel.recentChats.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 80)
                .cardStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.recentChats) { chat in
                        Button {
                            router.navigate(to: .chat(chat.friend))
                        } label: {
                            recentChatRow(chat)
                        }
                        .buttonStyle(.plain)

                        if chat.id != viewModel.recentChats.last?.id {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .padding()
                .cardStyle()
            }
        }
    }

    private func recentChatRow(_ chat: RecentChat) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(Color(.tertiaryLabel))

            VStack(alignment: .leading, spacing: 4) {
                Text(chat.friend.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                if let lastMessage = chat.lastMessage {
                    Text(lastMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(timeAgo(chat.lastMessageDate))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Friend Activity Section

    private var friendActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friend Activity")
                .font(.headline)

            if viewModel.isLoadingActivity && viewModel.friendActivity.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 80)
                .cardStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.friendActivity) { activity in
                        activityRow(activity)

                        if activity.id != viewModel.friendActivity.last?.id {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
                .padding()
                .cardStyle()
            }
        }
    }

    private func activityRow(_ activity: FriendActivity) -> some View {
        HStack(spacing: 12) {
            Image(systemName: activityIcon(for: activity.activityType))
                .font(.title3)
                .foregroundColor(activityColor(for: activity.activityType))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.friendName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(activityDescription(activity))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(timeAgo(activity.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    private func activityIcon(for type: FriendActivity.ActivityType) -> String {
        switch type {
        case .sharedSong: return "music.note"
        case .sentMessage: return "bubble.left"
        case .newFriend: return "person.badge.plus"
        }
    }

    private func activityColor(for type: FriendActivity.ActivityType) -> Color {
        switch type {
        case .sharedSong: return .green
        case .sentMessage: return .blue
        case .newFriend: return .purple
        }
    }

    private func activityDescription(_ activity: FriendActivity) -> String {
        switch activity.activityType {
        case .sharedSong:
            if let song = activity.songTitle, let artist = activity.artistName {
                return "shared \(song) by \(artist)"
            }
            return "shared a song"
        case .sentMessage:
            return "sent you a message"
        case .newFriend:
            return "is now your friend"
        }
    }

    // MARK: - Today's Pick Section

    private var todaysPickSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Today's Pick")
                    .font(.headline)
            }

            if viewModel.isLoadingPick {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 100)
                .cardStyle()
            } else if let track = viewModel.todaysPick {
                todaysPickCard(track)
            }
        }
    }

    private func todaysPickCard(_ track: UnifiedTrack) -> some View {
        HStack(spacing: 16) {
            if let imageUrl = track.album.imageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.tertiarySystemFill))
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(track.artists.map { $0.name }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text("Recommended for you")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            Spacer()

            if let previewUrl = track.previewUrl {
                Button {
                    audioPlayer.playUrl(previewUrl, trackId: track.id)
                } label: {
                    Image(systemName: audioPlayer.currentTrackId == track.id && audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    // MARK: - Vibestreak Section

    private var vibestreakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Vibestreak Reminders")
                    .font(.headline)
            }

            VStack(spacing: 8) {
                ForEach(viewModel.vibestreakReminders) { reminder in
                    vibestreakReminderRow(reminder)
                }
            }
        }
    }

    private func vibestreakReminderRow(_ reminder: VibestreakReminder) -> some View {
        Button {
            router.navigate(to: .chat(reminder.friend))
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Keep your streak with \(reminder.friend.displayName)!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text("\(reminder.currentStreak) day streak - \(reminder.hoursRemaining)h remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
        .environmentObject(AuthManager.shared)
}
