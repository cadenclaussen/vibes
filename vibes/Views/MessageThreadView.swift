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
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                isFromCurrentUser: message.senderId == viewModel.currentUserId
                            )
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                }
                .onChange(of: viewModel.messages.count) { _ in
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
                    if viewModel.activeVibestreak > 0 {
                        Text("🔥 \(viewModel.activeVibestreak)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadMessages()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        Task {
            await viewModel.sendTextMessage(messageText)
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

    var body: some View {
        HStack(spacing: 8) {
            if isFromCurrentUser {
                Spacer()
            }

            if message.messageType == .text {
                Text(message.textContent ?? "")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(16)
            } else {
                SongMessageBubbleView(message: message, isFromCurrentUser: isFromCurrentUser)
            }

            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

// MARK: - Song Message Bubble View
struct SongMessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    @ObservedObject var audioPlayer = AudioPlayerService.shared

    private var trackId: String {
        message.spotifyTrackId ?? message.id ?? UUID().uuidString
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

    var body: some View {
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
        .cornerRadius(16)
        .frame(maxWidth: 280)
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

// MARK: - Message Input Bar
struct MessageInputBar: View {
    @Binding var text: String
    let isSending: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Plus button for song sharing (placeholder)
            Button {
                // TODO: Open song search
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }

            // Text input
            TextField("Type a message...", text: $text)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.send)
                .onSubmit {
                    if canSend && !isSending {
                        onSend()
                    }
                }
                .disabled(isSending)

            // Send button
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(canSend ? .blue : .gray)
            }
            .disabled(!canSend || isSending)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5),
            alignment: .top
        )
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
