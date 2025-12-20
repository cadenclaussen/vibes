//
//  Message.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import Foundation
import FirebaseFirestore

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    var threadId: String
    var senderId: String
    var recipientId: String?  // Optional for group messages
    var messageType: MessageType

    // Text message fields
    var textContent: String?

    // Song message fields
    var spotifyTrackId: String?
    var songTitle: String?
    var songArtist: String?
    var albumArtUrl: String?
    var previewUrl: String?
    var duration: Int?  // Duration in seconds
    var caption: String?
    var rating: Int?

    // Reactions - stored as dictionary in Firestore with userId as key
    var reactions: [String: String]?

    // Metadata
    var timestamp: Date
    var read: Bool  // For 1-on-1 messages
    var readBy: [String]?  // For group messages - list of userIds who have read
    var isGroupMessage: Bool?  // Flag to distinguish group vs 1-on-1
    var senderName: String?  // Cached sender display name for group messages

    enum MessageType: String, Codable {
        case text
        case song
    }

    // Check if a user has read this group message
    func isReadBy(_ userId: String) -> Bool {
        return readBy?.contains(userId) ?? false
    }
}

struct MessageThread: Codable, Identifiable {
    @DocumentID var id: String?
    var userId1: String
    var userId2: String
    var lastMessageTimestamp: Date
    var lastMessageContent: String
    var lastMessageType: String
    var unreadCountUser1: Int
    var unreadCountUser2: Int
    var createdAt: Date
}
