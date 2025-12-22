//
//  MessageThreadView.swift
//  vibes
//
//  Created by Claude Code on 11/24/25.
//

import SwiftUI

struct MessageThreadView: View {
    @StateObject private var viewModel: MessageThreadViewModel
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @Environment(\.dismiss) private var dismiss

    let friendUsername: String

    init(threadId: String, friendId: String, friendUsername: String, currentUserId: String) {
        self.friendUsername = friendUsername
        _viewModel = StateObject(wrappedValue: MessageThreadViewModel(
            threadId: threadId,
            otherUserId: friendId,
            currentUserId: currentUserId
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                isFromCurrentUser: message.senderId == viewModel.currentUserId,
                                currentUserId: viewModel.currentUserId,
                                onReactionAdded: { messageId, emoji in
                                    Task {
                                        await viewModel.addReaction(messageId: messageId, emoji: emoji)
                                    }
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.messages.count)
                    .padding()
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                }
                .onChange(of: viewModel.messages.count) {
                    scrollToBottom()
                }
            }

            // Message input
            MessageInputBar(
                text: $messageText,
                isSending: viewModel.isSending,
                onSend: sendMessage
            )
        }
        .navigationTitle("@\(friendUsername)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("@\(friendUsername)")
                        .font(.headline)
                    VibestreakView(streak: viewModel.activeVibestreak, size: .small)
                }
            }
        }
        .onAppear {
            viewModel.loadMessages()
        }
        .onDisappear {
            viewModel.cleanup()
            AudioPlayerService.shared.stop()
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        HapticService.lightImpact()
        Task {
            await viewModel.sendTextMessage(messageText)
            HapticService.success()
            messageText = ""
        }
    }

    private func scrollToBottom() {
        if let lastMessage = viewModel.messages.last {
            withAnimation {
                scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    let currentUserId: String
    let onReactionAdded: (String, String) -> Void

    @State private var showTimestamp = false

    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack(spacing: 8) {
                if isFromCurrentUser {
                    Spacer(minLength: 60)
                }

                VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 6) {
                    switch message.messageType {
                    case .text:
                        TextMessageBubble(
                            text: message.textContent ?? "",
                            isFromCurrentUser: isFromCurrentUser
                        )
                        .onTapGesture {
                            HapticService.lightImpact()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showTimestamp.toggle()
                            }
                        }
                    case .song:
                        SongMessageBubbleView(
                            message: message,
                            isFromCurrentUser: isFromCurrentUser,
                            currentUserId: currentUserId,
                            onReactionAdded: onReactionAdded
                        )
                    case .playlist:
                        PlaylistMessageBubbleView(
                            message: message,
                            isFromCurrentUser: isFromCurrentUser,
                            currentUserId: currentUserId,
                            onReactionAdded: onReactionAdded
                        )
                    }
                }

                if !isFromCurrentUser {
                    Spacer(minLength: 60)
                }
            }

            // Timestamp (shown on tap)
            if showTimestamp {
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }

        return formatter.string(from: date)
    }
}

// MARK: - Text Message Bubble
struct TextMessageBubble: View {
    let text: String
    let isFromCurrentUser: Bool

    var body: some View {
        Text(text)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
            .foregroundColor(isFromCurrentUser ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Song Message Bubble View
struct SongMessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    let currentUserId: String
    let onReactionAdded: (String, String) -> Void

    @ObservedObject var audioPlayer = AudioPlayerService.shared
    @ObservedObject var spotifyService = SpotifyService.shared
    @State private var showPlaylistPicker = false
    @State private var showFriendPicker = false
    @State private var showTimestamp = false

    private var trackId: String {
        // Use message ID for uniqueness so duplicate songs are tracked independently
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
        guard let trackId = message.spotifyTrackId else { return nil }
        return "spotify:track:\(trackId)"
    }

    private var reactionsList: [(userId: String, emoji: String)] {
        guard let reactions = message.reactions else { return [] }
        return reactions.map { (userId: $0.key, emoji: $0.value) }
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

    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 6) {
            // Main song card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    albumArtView

                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.songTitle ?? "Unknown Song")
                            .font(.headline)
                            .lineLimit(1)

                        Text(message.songArtist ?? "Unknown Artist")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                        if let duration = message.duration {
                            Text(formatDuration(duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    playButton
                }

                if let caption = message.caption, !caption.isEmpty {
                    Text(caption)
                        .font(.body)
                        .padding(.top, 4)
                }
            }
            .padding(12)
            .background(isFromCurrentUser ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(maxWidth: 280)
            .onTapGesture {
                HapticService.lightImpact()
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTimestamp.toggle()
                }
            }
            .contextMenu {
                // Reaction options
                Menu {
                    Button { addReaction("🔥") } label: { Text("🔥 Fire") }
                    Button { addReaction("❤️") } label: { Text("❤️ Love") }
                    Button { addReaction("💯") } label: { Text("💯 100") }
                    Button { addReaction("😐") } label: { Text("😐 Meh") }
                } label: {
                    Label("React", systemImage: "face.smiling")
                }

                if trackForSharing != nil {
                    Button {
                        HapticService.lightImpact()
                        showFriendPicker = true
                    } label: {
                        Label("Send to Friend", systemImage: "paperplane")
                    }
                }

                // Add to playlist option
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

            // Reactions display
            if !reactionsList.isEmpty {
                ReactionsDisplayView(reactions: reactionsList, isFromCurrentUser: isFromCurrentUser)
            }

            // Timestamp
            if showTimestamp {
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
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
        if let messageId = message.id {
            onReactionAdded(messageId, emoji)
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }

        return formatter.string(from: date)
    }

    private var albumArtView: some View {
        ZStack(alignment: .bottom) {
            Group {
                if let albumArtUrl = message.albumArtUrl, let url = URL(string: albumArtUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure, .empty:
                            albumPlaceholder
                        @unknown default:
                            albumPlaceholder
                        }
                    }
                } else {
                    albumPlaceholder
                }
            }
            .frame(width: 60, height: 60)

            // Progress bar at bottom when playing
            if isCurrentTrack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * audioPlayer.playbackProgress, height: 3)
                }
                .frame(height: 3)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(width: 60, height: 60)
        .cornerRadius(8)
        .clipped()
    }

    private var albumPlaceholder: some View {
        Image(systemName: "music.note")
            .font(.title)
            .frame(width: 60, height: 60)
            .background(Color.gray.opacity(0.2))
    }

    private var playButton: some View {
        Button {
            HapticService.lightImpact()
            if let previewUrl = message.previewUrl {
                audioPlayer.playUrl(previewUrl, trackId: trackId)
            }
        } label: {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(hasPreview ? .blue : .gray)
        }
        .disabled(!hasPreview)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Playlist Message Bubble View
struct PlaylistMessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    let currentUserId: String
    let onReactionAdded: (String, String) -> Void

    @State private var showTimestamp = false
    @State private var showPlaylistDetail = false

    private var reactionsList: [(userId: String, emoji: String)] {
        guard let reactions = message.reactions else { return [] }
        return reactions.map { (userId: $0.key, emoji: $0.value) }
    }

    private var playlist: Playlist? {
        guard let playlistId = message.playlistId else { return nil }
        return Playlist(
            id: playlistId,
            name: message.playlistName ?? "Unknown Playlist",
            description: nil,
            images: message.playlistImageUrl.map { [SpotifyImage(url: $0, height: nil, width: nil)] },
            owner: PlaylistOwner(id: "", displayName: message.playlistOwnerName),
            tracks: PlaylistTracksInfo(total: message.playlistTrackCount ?? 0),
            isPublic: nil,
            collaborative: nil,
            uri: "spotify:playlist:\(playlistId)",
            externalUrls: nil
        )
    }

    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 6) {
            // Main playlist card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    playlistArtView

                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.playlistName ?? "Unknown Playlist")
                            .font(.headline)
                            .lineLimit(2)

                        if let ownerName = message.playlistOwnerName {
                            Text("by \(ownerName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        if let trackCount = message.playlistTrackCount {
                            Text("\(trackCount) tracks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(isFromCurrentUser ? Color.green.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(maxWidth: 280)
            .onTapGesture {
                HapticService.lightImpact()
                if playlist != nil {
                    showPlaylistDetail = true
                }
            }
            .contextMenu {
                Menu {
                    Button { addReaction("🔥") } label: { Text("🔥 Fire") }
                    Button { addReaction("❤️") } label: { Text("❤️ Love") }
                    Button { addReaction("💯") } label: { Text("💯 100") }
                    Button { addReaction("😐") } label: { Text("😐 Meh") }
                } label: {
                    Label("React", systemImage: "face.smiling")
                }
            }

            // Reactions display
            if !reactionsList.isEmpty {
                ReactionsDisplayView(reactions: reactionsList, isFromCurrentUser: isFromCurrentUser)
            }

            // Timestamp
            if showTimestamp {
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .sheet(isPresented: $showPlaylistDetail) {
            if let playlist = playlist {
                NavigationStack {
                    PlaylistDetailView(playlist: playlist)
                }
            }
        }
    }

    private var playlistArtView: some View {
        Group {
            if let imageUrl = message.playlistImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        playlistPlaceholder
                    @unknown default:
                        playlistPlaceholder
                    }
                }
            } else {
                playlistPlaceholder
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var playlistPlaceholder: some View {
        Image(systemName: "music.note.list")
            .font(.title)
            .frame(width: 60, height: 60)
            .background(Color.green.opacity(0.2))
    }

    private func addReaction(_ emoji: String) {
        HapticService.selectionChanged()
        if let messageId = message.id {
            onReactionAdded(messageId, emoji)
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }

        return formatter.string(from: date)
    }
}

// MARK: - Message Input Bar
struct MessageInputBar: View {
    @Binding var text: String
    let isSending: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $text)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.tertiarySystemFill))
                .cornerRadius(20)
                .submitLabel(.send)
                .onSubmit {
                    if canSend && !isSending {
                        onSend()
                    }
                }
                .disabled(isSending)

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundColor(canSend ? .blue : .gray)
            }
            .disabled(!canSend || isSending)
        }
        .padding()
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Message Thread Container
struct MessageThreadContainer: View {
    let friendId: String
    let friendUsername: String
    let currentUserId: String

    @State private var threadId: String?
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let firestoreService = FirestoreService.shared

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading conversation...")
            } else if let errorMessage = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if let threadId = threadId {
                MessageThreadView(
                    threadId: threadId,
                    friendId: friendId,
                    friendUsername: friendUsername,
                    currentUserId: currentUserId
                )
            }
        }
        .task {
            await loadOrCreateThread()
        }
    }

    private func loadOrCreateThread() async {
        do {
            threadId = try await firestoreService.getOrCreateThread(
                userId1: currentUserId,
                userId2: friendId
            )
            isLoading = false
        } catch {
            errorMessage = "Failed to load conversation: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

// MARK: - Reaction Picker View
struct ReactionPickerView: View {
    let currentReaction: String?
    let onReactionSelected: (String) -> Void

    private let reactions = ["🔥", "❤️", "💯", "😐"]

    var body: some View {
        VStack(spacing: 16) {
            Text("React to this song")
                .font(.headline)
                .padding(.top, 8)

            HStack(spacing: 24) {
                ForEach(reactions, id: \.self) { emoji in
                    Button {
                        HapticService.selectionChanged()
                        onReactionSelected(emoji)
                    } label: {
                        Text(emoji)
                            .font(.system(size: 36))
                            .padding(8)
                            .background(
                                currentReaction == emoji
                                    ? Color.blue.opacity(0.2)
                                    : Color.clear
                            )
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Reactions Display View
struct ReactionsDisplayView: View {
    let reactions: [(userId: String, emoji: String)]
    let isFromCurrentUser: Bool

    private var groupedReactions: [(emoji: String, count: Int)] {
        var counts: [String: Int] = [:]
        for reaction in reactions {
            counts[reaction.emoji, default: 0] += 1
        }
        return counts.map { (emoji: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(groupedReactions, id: \.emoji) { reaction in
                HStack(spacing: 2) {
                    Text(reaction.emoji)
                        .font(.caption)
                    if reaction.count > 1 {
                        Text("\(reaction.count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: reactions.count)
    }
}

#Preview {
    NavigationStack {
        MessageThreadView(
            threadId: "preview-thread",
            friendId: "friend-id",
            friendUsername: "johndoe",
            currentUserId: "current-user-id"
        )
    }
}
