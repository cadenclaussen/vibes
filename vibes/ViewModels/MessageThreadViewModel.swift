//
//  MessageThreadViewModel.swift
//  vibes
//
//  Created by Claude Code on 11/24/25.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class MessageThreadViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var friendship: Friendship?
    @Published var vibestreak: Int = 0
    @Published var streakLastUpdated: Date?
    @Published var isLoading = false
    @Published var isSending = false
    @Published var errorMessage: String?

    let threadId: String
    let otherUserId: String
    let currentUserId: String

    private var messageListener: ListenerRegistration?
    private var streakListener: ListenerRegistration?
    private let firestoreService = FirestoreService.shared

    // Returns 0 if streak has expired (not updated yesterday or today)
    var activeVibestreak: Int {
        guard vibestreak > 0, let lastUpdated = streakLastUpdated else {
            return 0
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastUpdateDay = calendar.startOfDay(for: lastUpdated)

        if lastUpdateDay == today || lastUpdateDay == yesterday {
            return vibestreak
        }
        return 0
    }

    init(threadId: String, otherUserId: String, currentUserId: String) {
        self.threadId = threadId
        self.otherUserId = otherUserId
        self.currentUserId = currentUserId
    }

    func loadMessages() {
        print("🎬 loadMessages() called for thread: \(threadId)")
        isLoading = true

        // Listen to messages
        messageListener = firestoreService.listenToMessages(threadId: threadId) { [weak self] messages in
            guard let self = self else {
                print("⚠️ self is nil in listener callback")
                return
            }
            print("📨 Received \(messages.count) messages for thread \(self.threadId)")
            messages.forEach { msg in
                print("  - ID: \(msg.id ?? "nil"), text: \(msg.textContent ?? "no-text"), sender: \(msg.senderId)")
            }

            // Update is already on main thread from FirestoreService
            self.messages = messages
            self.isLoading = false

            // Mark messages as read
            Task {
                try? await self.markMessagesAsRead()
            }
        }
        print("✅ Message listener set up for thread: \(threadId)")

        // Load vibestreak
        Task {
            await loadVibestreak()
        }
    }

    private func loadVibestreak() async {
        do {
            guard let friendshipData = try await firestoreService.getFriendship(
                userId1: currentUserId,
                userId2: otherUserId
            ) else { return }

            // Set initial streak values
            vibestreak = friendshipData.vibestreak
            streakLastUpdated = friendshipData.streakLastUpdated

            // Set up real-time listener for streak updates
            streakListener = firestoreService.listenToVibestreak(friendshipId: friendshipData.id) { [weak self] streak, lastUpdated in
                self?.vibestreak = streak
                self?.streakLastUpdated = lastUpdated
            }
        } catch {
            print("Failed to load vibestreak: \(error)")
        }
    }

    func sendTextMessage(_ text: String) async {
        guard !text.isEmpty else { return }

        print("🚀 Sending message: \(text)")
        isSending = true
        errorMessage = nil

        do {
            let message = Message(
                id: nil,
                threadId: threadId,
                senderId: currentUserId,
                recipientId: otherUserId,
                messageType: .text,
                textContent: text,
                spotifyTrackId: nil,
                songTitle: nil,
                songArtist: nil,
                albumArtUrl: nil,
                previewUrl: nil,
                duration: nil,
                caption: nil,
                rating: nil,
                reactions: nil,
                timestamp: Date(),
                read: false
            )

            print("📤 Sending to thread: \(threadId)")
            try await firestoreService.sendMessage(message)
            print("✅ Message sent successfully")
            isSending = false
        } catch {
            print("❌ Error sending message: \(error)")
            errorMessage = "Failed to send message: \(error.localizedDescription)"
            isSending = false
        }
    }

    func sendSongMessage(trackId: String, title: String, artist: String, albumArtUrl: String?, previewUrl: String?, duration: Int?, caption: String? = nil) async {
        isSending = true
        errorMessage = nil

        do {
            let message = Message(
                id: nil,
                threadId: threadId,
                senderId: currentUserId,
                recipientId: otherUserId,
                messageType: .song,
                textContent: nil,
                spotifyTrackId: trackId,
                songTitle: title,
                songArtist: artist,
                albumArtUrl: albumArtUrl,
                previewUrl: previewUrl,
                duration: duration,
                caption: caption,
                rating: nil,
                reactions: nil,
                timestamp: Date(),
                read: false
            )

            try await firestoreService.sendMessage(message)
            isSending = false
        } catch {
            errorMessage = "Failed to send song: \(error.localizedDescription)"
            isSending = false
        }
    }

    func addReaction(_ emoji: String, to message: Message) async {
        guard let messageId = message.id else { return }

        do {
            try await firestoreService.addReaction(messageId: messageId, userId: currentUserId, reaction: emoji)
        } catch {
            errorMessage = "Failed to add reaction: \(error.localizedDescription)"
        }
    }

    private func markMessagesAsRead() async {
        do {
            try await firestoreService.markMessagesAsRead(threadId: threadId, userId: currentUserId)
        } catch {
            print("Failed to mark messages as read: \(error.localizedDescription)")
        }
    }

    func cleanup() {
        print("🧹 Cleanup called for thread: \(threadId)")
        messageListener?.remove()
        streakListener?.remove()
        messageListener = nil
        streakListener = nil
        print("✅ Listeners removed for thread: \(threadId)")
    }

    deinit {
        print("🗑️ MessageThreadViewModel deinitialized for thread: \(threadId)")
    }
}
