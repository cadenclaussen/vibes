//
//  GroupThreadView.swift
//  vibes
//
//  Created by Claude Code on 12/21/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct GroupThreadView: View {
    let group: GroupThread
    let currentUserId: String

    @StateObject private var viewModel: GroupThreadViewModel
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showingGroupInfo = false
    @Environment(\.dismiss) private var dismiss

    private var isCreator: Bool {
        group.creatorId == currentUserId && currentUserId.isEmpty == false
    }

    init(group: GroupThread, currentUserId: String) {
        self.group = group
        self.currentUserId = currentUserId
        _viewModel = StateObject(wrappedValue: GroupThreadViewModel(
            groupId: group.id ?? "",
            currentUserId: currentUserId,
            creatorId: group.creatorId ?? "",
            participantIds: group.participantIds,
            createdAt: group.createdAt
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            GroupMessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == currentUserId,
                                groupId: group.id ?? "",
                                currentUserId: currentUserId
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear { scrollProxy = proxy }
                .onChange(of: viewModel.messages.count) { _, _ in
                    scrollToBottom()
                }
            }

            Divider()

            // Input bar
            HStack(spacing: 12) {
                TextField("Message", text: $messageText)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(20)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button {
                    showingGroupInfo = true
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.groupName.isEmpty ? group.name : viewModel.groupName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .task {
            await viewModel.markAsRead()
        }
        .onDisappear {
            viewModel.cleanup()
            AudioPlayerService.shared.stop()
        }
        .sheet(isPresented: $showingGroupInfo) {
            GroupInfoView(
                viewModel: viewModel,
                isCreator: isCreator,
                onDelete: {
                    dismiss()
                }
            )
        }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messageText = ""
        HapticService.lightImpact()

        Task {
            await viewModel.sendMessage(text)
            scrollToBottom()
        }
    }

    private func scrollToBottom() {
        guard let lastId = viewModel.messages.last?.id else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            scrollProxy?.scrollTo(lastId, anchor: .bottom)
        }
    }
}

// MARK: - Group Info View

struct GroupInfoView: View {
    @ObservedObject var viewModel: GroupThreadViewModel
    let isCreator: Bool
    let onDelete: () -> Void

    @State private var editedGroupName = ""
    @State private var isEditingName = false
    @State private var isUpdatingName = false
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Group name section
                Section {
                    if isEditingName {
                        HStack {
                            TextField("Group name", text: $editedGroupName)
                                .textFieldStyle(.plain)

                            Button {
                                saveGroupName()
                            } label: {
                                if isUpdatingName {
                                    ProgressView()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .disabled(editedGroupName.trimmingCharacters(in: .whitespaces).isEmpty || isUpdatingName)

                            Button {
                                isEditingName = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        HStack {
                            Text(viewModel.groupName)
                                .font(.title2)
                                .fontWeight(.semibold)

                            Spacer()

                            if isCreator {
                                Button {
                                    editedGroupName = viewModel.groupName
                                    isEditingName = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.purple)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Group Name")
                }

                // Members section
                Section {
                    if viewModel.isLoadingMembers {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        ForEach(viewModel.members) { participant in
                            HStack(spacing: 12) {
                                // Profile picture
                                if let photoUrl = participant.friendProfile.profilePictureURL,
                                   let url = URL(string: photoUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle()
                                            .fill(Color(.tertiarySystemFill))
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color(.tertiarySystemFill))
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Text(String(participant.friendProfile.displayName.prefix(1)).uppercased())
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                        }
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(participant.friendProfile.displayName)
                                            .font(.body)

                                        if participant.isCreator {
                                            Text("Moderator")
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.purple.opacity(0.2))
                                                .foregroundColor(.purple)
                                                .cornerRadius(4)
                                        }
                                    }

                                    Text("@\(participant.friendProfile.username)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                        }
                    }
                } header: {
                    Text("\(viewModel.members.count) Members")
                }

                // Group info section
                Section {
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(viewModel.createdAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Info")
                }

                // Moderator actions
                if isCreator {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Group")
                            }
                        }
                        .disabled(isDeleting)
                    } header: {
                        Text("Moderator Actions")
                    }
                }
            }
            .navigationTitle("Group Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Group?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteGroup()
                }
            } message: {
                Text("This will permanently delete the group and all messages. This action cannot be undone.")
            }
        }
    }

    private func saveGroupName() {
        let newName = editedGroupName.trimmingCharacters(in: .whitespaces)
        guard !newName.isEmpty else { return }

        isUpdatingName = true
        HapticService.lightImpact()

        Task {
            let success = await viewModel.updateGroupName(newName)
            if success {
                HapticService.success()
                isEditingName = false
            }
            isUpdatingName = false
        }
    }

    private func deleteGroup() {
        isDeleting = true
        HapticService.warning()

        Task {
            let success = await viewModel.deleteGroup()
            if success {
                HapticService.success()
                dismiss()
                onDelete()
            } else {
                isDeleting = false
            }
        }
    }
}

// MARK: - Group Message Bubble

struct GroupMessageBubble: View {
    let message: GroupMessage
    let isFromCurrentUser: Bool
    let groupId: String
    let currentUserId: String

    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @ObservedObject var spotifyService = SpotifyService.shared
    @State private var showPlaylistPicker = false
    @State private var showFriendPicker = false

    private var trackId: String {
        message.id ?? message.spotifyTrackId ?? UUID().uuidString
    }

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrackId == trackId
    }

    private var isPlaying: Bool {
        isCurrentTrack && audioPlayer.isPlaying
    }

    private var hasPreview: Bool {
        message.previewUrl != nil
    }

    private var trackUri: String? {
        guard let spotifyTrackId = message.spotifyTrackId else { return nil }
        return "spotify:track:\(spotifyTrackId)"
    }

    private var trackForSharing: Track? {
        guard let spotifyTrackId = message.spotifyTrackId else { return nil }
        let album = Album(
            id: "",
            name: "",
            images: message.albumArtUrl.map { [SpotifyImage(url: $0, height: nil, width: nil)] } ?? [],
            releaseDate: "",
            totalTracks: 0,
            uri: ""
        )
        return Track(
            id: spotifyTrackId,
            name: message.songTitle ?? "Unknown",
            artists: [Artist(id: "", name: message.songArtist ?? "Unknown", uri: "", externalUrls: nil, images: nil, genres: nil, followers: nil, popularity: nil)],
            album: album,
            durationMs: 0,
            explicit: false,
            popularity: 0,
            previewUrl: message.previewUrl,
            uri: "spotify:track:\(spotifyTrackId)",
            externalUrls: ExternalUrls(spotify: "https://open.spotify.com/track/\(spotifyTrackId)")
        )
    }

    private var reactionsList: [(emoji: String, count: Int, hasUserReacted: Bool)] {
        return message.reactions.map { (emoji: $0.key, count: $0.value.count, hasUserReacted: $0.value.contains(currentUserId)) }.sorted { $0.count > $1.count }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isFromCurrentUser { Spacer() }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isFromCurrentUser {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if message.messageType == "song" {
                    songBubble
                } else {
                    textBubble
                }

                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !isFromCurrentUser { Spacer() }
        }
    }

    private var textBubble: some View {
        Text(message.textContent ?? "")
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isFromCurrentUser ? Color.blue : Color(.tertiarySystemFill))
            .foregroundColor(isFromCurrentUser ? .white : .primary)
            .cornerRadius(18)
    }

    private var songBubble: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    if let artUrl = message.albumArtUrl, let url = URL(string: artUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color(.tertiarySystemFill)
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(6)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(message.songTitle ?? "Unknown")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Text(message.songArtist ?? "Unknown")
                            .font(.caption)
                            .foregroundColor(isFromCurrentUser ? .white.opacity(0.8) : .secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    playButton
                }

                if let caption = message.caption, !caption.isEmpty {
                    Text(caption)
                        .font(.subheadline)
                }
            }
            .padding(10)
            .background(isFromCurrentUser ? Color.blue.opacity(0.9) : Color(.tertiarySystemFill))
            .foregroundColor(isFromCurrentUser ? .white : .primary)
            .cornerRadius(14)
            .frame(maxWidth: 260)
            .contextMenu {
                Button { addReaction("🔥") } label: { Label("🔥 Fire", systemImage: "flame") }
                Button { addReaction("❤️") } label: { Label("❤️ Love", systemImage: "heart") }
                Button { addReaction("💯") } label: { Label("💯 100", systemImage: "hand.thumbsup") }
                Button { addReaction("😐") } label: { Label("😐 Meh", systemImage: "face.smiling") }

                Divider()

                if trackForSharing != nil {
                    Button {
                        HapticService.lightImpact()
                        showFriendPicker = true
                    } label: {
                        Label("Send to Friend", systemImage: "paperplane")
                    }
                }

                if spotifyService.isAuthenticated && trackUri != nil {
                    Button {
                        HapticService.lightImpact()
                        showPlaylistPicker = true
                    } label: {
                        Label("Add to Playlist", systemImage: "plus.circle")
                    }
                }

                if let spotifyTrackId = message.spotifyTrackId {
                    Button {
                        HapticService.lightImpact()
                        if let url = URL(string: "https://open.spotify.com/track/\(spotifyTrackId)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Open in Spotify", systemImage: "arrow.up.right")
                    }
                }
            }

            if !reactionsList.isEmpty {
                HStack(spacing: 4) {
                    ForEach(reactionsList.prefix(4), id: \.emoji) { reaction in
                        Button {
                            addReaction(reaction.emoji)
                        } label: {
                            Text("\(reaction.emoji)\(reaction.count > 1 ? " \(reaction.count)" : "")")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(reaction.hasUserReacted ? Color.blue.opacity(0.2) : Color(.tertiarySystemFill))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(reaction.hasUserReacted ? Color.blue : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .sheet(isPresented: $showPlaylistPicker) {
            if let uri = trackUri {
                PlaylistPickerView(
                    trackUri: uri,
                    trackName: message.songTitle ?? "Unknown Song",
                    artistName: message.songArtist ?? "Unknown Artist",
                    albumArtUrl: message.albumArtUrl,
                    onAdded: {}
                )
            }
        }
        .sheet(isPresented: $showFriendPicker) {
            if let track = trackForSharing {
                FriendPickerView(track: track, previewUrl: message.previewUrl)
            }
        }
    }

    private func addReaction(_ emoji: String) {
        HapticService.selectionChanged()
        guard let messageId = message.id else { return }
        Task {
            try? await FirestoreService.shared.addGroupReaction(
                groupId: groupId,
                messageId: messageId,
                userId: currentUserId,
                emoji: emoji
            )
        }
    }

    private var playButton: some View {
        Button {
            HapticService.lightImpact()
            if let previewUrl = message.previewUrl {
                audioPlayer.playUrl(previewUrl, trackId: trackId)
            }
        } label: {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(hasPreview ? (isFromCurrentUser ? .white : .blue) : .gray)
        }
        .disabled(!hasPreview)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: message.timestamp)
    }
}

// MARK: - ViewModel

@MainActor
class GroupThreadViewModel: ObservableObject {
    @Published var messages: [GroupMessage] = []
    @Published var isLoading = false
    @Published var groupName: String = ""
    @Published var members: [GroupParticipant] = []
    @Published var isLoadingMembers = false
    let createdAt: Date

    private let groupId: String
    private let currentUserId: String
    private let creatorId: String
    private let participantIds: [String]
    private let firestoreService = FirestoreService.shared
    private var listener: ListenerRegistration?
    private var groupListener: ListenerRegistration?
    private var currentUserName: String?

    init(groupId: String, currentUserId: String, creatorId: String, participantIds: [String], createdAt: Date) {
        self.groupId = groupId
        self.currentUserId = currentUserId
        self.creatorId = creatorId
        self.participantIds = participantIds
        self.createdAt = createdAt
        setupListener()
        setupGroupListener()
        loadCurrentUserName()
        loadMembers()
    }

    private func loadMembers() {
        isLoadingMembers = true
        Task {
            var loadedMembers: [GroupParticipant] = []
            for userId in participantIds {
                do {
                    let profile = try await firestoreService.getUserProfile(userId: userId)
                    let friendProfile = FriendProfile(from: profile)
                    let participant = GroupParticipant(
                        friendProfile: friendProfile,
                        isCreator: userId == creatorId
                    )
                    loadedMembers.append(participant)
                } catch {
                    print("Failed to load profile for \(userId): \(error)")
                }
            }
            // Sort so creator is first
            loadedMembers.sort { $0.isCreator && !$1.isCreator }
            members = loadedMembers
            isLoadingMembers = false
        }
    }

    private func setupGroupListener() {
        groupListener = Firestore.firestore().collection("groupThreads").document(groupId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let name = snapshot?.data()?["name"] as? String {
                    self?.groupName = name
                }
            }
    }

    private func setupListener() {
        listener = firestoreService.listenToGroupMessages(groupId: groupId) { [weak self] messages in
            self?.messages = messages
        }
    }

    private func loadCurrentUserName() {
        Task {
            do {
                let profile = try await firestoreService.getUserProfile(userId: currentUserId)
                currentUserName = profile.displayName
            } catch {
                currentUserName = "You"
            }
        }
    }

    func sendMessage(_ content: String) async {
        do {
            try await firestoreService.sendGroupMessage(
                groupId: groupId,
                senderId: currentUserId,
                senderName: currentUserName ?? "You",
                content: content
            )
            // Track for achievements
            LocalAchievementStats.shared.messagesSent += 1
            LocalAchievementStats.shared.checkLocalAchievements()
        } catch {
            print("Failed to send message: \(error)")
        }
    }

    func markAsRead() async {
        do {
            try await firestoreService.markGroupMessagesAsRead(groupId: groupId, userId: currentUserId)
        } catch {
            print("Failed to mark as read: \(error)")
        }
    }

    func updateGroupName(_ newName: String) async -> Bool {
        do {
            try await firestoreService.updateGroupName(
                groupId: groupId,
                newName: newName,
                requesterId: currentUserId
            )
            return true
        } catch {
            print("Failed to update group name: \(error)")
            return false
        }
    }

    func deleteGroup() async -> Bool {
        do {
            try await firestoreService.deleteGroup(
                groupId: groupId,
                requesterId: currentUserId
            )
            return true
        } catch {
            print("Failed to delete group: \(error)")
            return false
        }
    }

    func cleanup() {
        listener?.remove()
        groupListener?.remove()
        listener = nil
        groupListener = nil
    }

    deinit {
        listener?.remove()
        groupListener?.remove()
    }
}

#Preview {
    NavigationStack {
        GroupThreadView(
            group: GroupThread(
                id: "test",
                name: "Music Lovers",
                creatorId: "user1",
                participantIds: ["user1", "user2", "user3"],
                lastMessageTimestamp: Date(),
                lastMessageContent: "Hey everyone!",
                lastMessageType: "text",
                lastMessageSenderId: "user2",
                lastMessageSenderName: "Jane",
                createdAt: Date(),
                unreadCounts: [:]
            ),
            currentUserId: "user1"
        )
    }
}
