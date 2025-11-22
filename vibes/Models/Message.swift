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
    var content: String
    var caption: String?
    var rating: Int?
    var reactions: [String: String]
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
