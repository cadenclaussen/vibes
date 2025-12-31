//
//  FeedView.swift
//  vibes
//
//  Feed tab - shows songs shared with you and friend activity.
//

import SwiftUI
import FirebaseAuth

struct FeedView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = FeedViewModel()
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @State private var showingSendSong = false

    var body: some View {
        NavigationStack(path: Binding(
            get: { router.feedPath },
            set: { router.feedPath = $0 }
        )) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    headerSection
                    quickActionsSection

                    if !viewModel.shares.isEmpty || viewModel.isLoadingShares {
                        sharesSection
                    }

                    if !viewModel.friendActivity.isEmpty || viewModel.isLoadingActivity {
                        friendActivitySection
                    }

                    if viewModel.shares.isEmpty && viewModel.friendActivity.isEmpty && !viewModel.isLoading {
                        emptyStateSection
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
                    friendUsername: friend.username,
                    currentUserId: Auth.auth().currentUser?.uid ?? ""
                )
            }
        }
        .task {
            await viewModel.loadAllData()
        }
        .onDisappear {
            audioPlayer.stop()
        }
        .sheet(isPresented: $showingSendSong) {
            SearchAndSendView()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Feed")
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    quickActionButton(
                        icon: "paperplane.fill",
                        title: "Send Song",
                        color: .blue
                    ) {
                        showingSendSong = true
                    }

                    quickActionButton(
                        icon: "magnifyingglass",
                        title: "Search",
                        color: .green
                    ) {
                        router.goToSearch()
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

    // MARK: - Shares Section

    private var sharesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "music.note")
                    .foregroundColor(.blue)
                Text("Shared With You")
                    .font(.headline)
            }

            if viewModel.isLoadingShares && viewModel.shares.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 100)
                .cardStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.shares) { share in
                        ShareRow(share: share, onTap: {
                            if let friend = share.sender {
                                router.navigate(to: .chat(friend))
                            }
                        })

                        if share.id != viewModel.shares.last?.id {
                            Divider()
                                .padding(.leading, 72)
                        }
                    }
                }
                .padding()
                .cardStyle()
            }
        }
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

    private func activityRow(_ activity: FriendActivityItem) -> some View {
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

    private func activityIcon(for type: FriendActivityItem.ActivityType) -> String {
        switch type {
        case .sharedSong: return "music.note"
        case .newFriend: return "person.badge.plus"
        }
    }

    private func activityColor(for type: FriendActivityItem.ActivityType) -> Color {
        switch type {
        case .sharedSong: return .green
        case .newFriend: return .purple
        }
    }

    private func activityDescription(_ activity: FriendActivityItem) -> String {
        switch activity.activityType {
        case .sharedSong:
            if let song = activity.songTitle, let artist = activity.artistName {
                return "shared \(song) by \(artist)"
            }
            return "shared a song"
        case .newFriend:
            return "is now your friend"
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Empty State

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundColor(Color(.tertiaryLabel))

            Text("No activity yet")
                .font(.headline)

            Text("Add friends and share songs to see activity here!")
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Share Row

struct ShareRow: View {
    let share: SongShare
    let onTap: () -> Void
    @StateObject private var audioPlayer = AudioPlayerService.shared

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if let imageUrl = share.albumArtUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.tertiarySystemFill))
                    }
                    .frame(width: 56, height: 56)
                    .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 56, height: 56)
                        .cornerRadius(8)
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundColor(.secondary)
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(share.senderName ?? "A friend")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        + Text(" shared")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(share.songTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(share.songArtist)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let previewUrl = share.previewUrl {
                    Button {
                        audioPlayer.playUrl(previewUrl, trackId: share.id)
                    } label: {
                        Image(systemName: audioPlayer.currentTrackId == share.id && audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search and Send View

struct SearchAndSendView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router
    @StateObject private var musicServiceManager = MusicServiceManager.shared
    @State private var searchText = ""
    @State private var searchResults: [UnifiedTrack] = []
    @State private var isSearching = false
    @State private var trackToSend: UnifiedTrack?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding()

                if !musicServiceManager.isAuthenticated {
                    notConnectedView
                } else if isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    emptyResultsView
                } else if searchResults.isEmpty {
                    searchPromptView
                } else {
                    resultsList
                }
            }
            .navigationTitle("Send a Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $trackToSend) { track in
                FriendPickerView(
                    unifiedTrack: track,
                    previewUrl: track.previewUrl,
                    onSongSent: { friend in
                        dismiss()
                    }
                )
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search songs...", text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit {
                    search()
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    searchResults = []
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

    private var notConnectedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundColor(Color(.tertiaryLabel))

            Text("Connect a music service to search songs")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Go to Settings") {
                dismiss()
                router.goToSettings()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundColor(Color(.tertiaryLabel))

            Text("No results found")
                .font(.headline)

            Text("Try a different search term")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var searchPromptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(Color(.tertiaryLabel))

            Text("Search for a song to share")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultsList: some View {
        List(searchResults) { track in
            Button {
                trackToSend = track
            } label: {
                HStack(spacing: 12) {
                    if let imageUrl = track.album.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle().fill(Color(.tertiarySystemFill))
                        }
                        .frame(width: 44, height: 44)
                        .cornerRadius(4)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.name)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Text(track.artists.map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }

    private func search() {
        guard !searchText.isEmpty else { return }

        isSearching = true
        Task {
            do {
                let service = musicServiceManager.currentService
                searchResults = try await service.searchTracks(query: searchText, limit: 20)
            } catch {
                print("Search failed: \(error)")
            }
            isSearching = false
        }
    }
}

#Preview {
    FeedView()
        .environment(AppRouter())
        .environmentObject(AuthManager.shared)
}
