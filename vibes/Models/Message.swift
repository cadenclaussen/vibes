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
    var recipientId: String
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
    var read: Bool

    enum MessageType: String, Codable {
        case text
        case song
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
