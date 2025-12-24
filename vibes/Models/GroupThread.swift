//
//  GroupThread.swift
//  vibes
//
//  Created by Claude Code on 12/21/25.
//

import Foundation
import FirebaseFirestore

struct GroupThread: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var creatorId: String?
    var participantIds: [String]
    var lastMessageTimestamp: Date
    var lastMessageContent: String
    var lastMessageType: String
    var lastMessageSenderId: String?
    var lastMessageSenderName: String?
    var createdAt: Date

    // Per-user unread counts (userId: count)
    var unreadCounts: [String: Int]

    func unreadCount(for userId: String) -> Int {
        unreadCounts[userId] ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case id, name, creatorId, participantIds, lastMessageTimestamp
        case lastMessageContent, lastMessageType, lastMessageSenderId
        case lastMessageSenderName, createdAt, unreadCounts
    }

    init(
        id: String? = nil,
        name: String,
        creatorId: String?,
        participantIds: [String],
        lastMessageTimestamp: Date,
        lastMessageContent: String,
        lastMessageType: String = "text",
        lastMessageSenderId: String?,
        lastMessageSenderName: String?,
        createdAt: Date,
        unreadCounts: [String: Int] = [:]
    ) {
        self.id = id
        self.name = name
        self.creatorId = creatorId
        self.participantIds = participantIds
        self.lastMessageTimestamp = lastMessageTimestamp
        self.lastMessageContent = lastMessageContent
        self.lastMessageType = lastMessageType
        self.lastMessageSenderId = lastMessageSenderId
        self.lastMessageSenderName = lastMessageSenderName
        self.createdAt = createdAt
        self.unreadCounts = unreadCounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        creatorId = try container.decodeIfPresent(String.self, forKey: .creatorId)
        participantIds = try container.decode([String].self, forKey: .participantIds)
        lastMessageTimestamp = try container.decode(Date.self, forKey: .lastMessageTimestamp)
        lastMessageContent = try container.decode(String.self, forKey: .lastMessageContent)
        lastMessageType = try container.decodeIfPresent(String.self, forKey: .lastMessageType) ?? "text"
        lastMessageSenderId = try container.decodeIfPresent(String.self, forKey: .lastMessageSenderId)
        lastMessageSenderName = try container.decodeIfPresent(String.self, forKey: .lastMessageSenderName)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        unreadCounts = try container.decodeIfPresent([String: Int].self, forKey: .unreadCounts) ?? [:]
    }
}

struct GroupMessage: Codable, Identifiable {
    @DocumentID var id: String?
    var groupId: String
    var senderId: String
    var senderName: String
    var messageType: String // "text" or "song"
    var textContent: String?
    var spotifyTrackId: String?
    var songTitle: String?
    var songArtist: String?
    var albumArtUrl: String?
    var previewUrl: String?
    var caption: String?
    var reactions: [String: [String]] = [:] // emoji: [userIds]
    var timestamp: Date

    var displayContent: String {
        if messageType == "song", let title = songTitle, let artist = songArtist {
            if let caption = caption, !caption.isEmpty {
                return "\(title) - \(artist): \"\(caption)\""
            }
            return "\(title) - \(artist)"
        }
        return textContent ?? ""
    }
}

// Info about a participant in a group
struct GroupParticipant: Identifiable {
    var id: String { friendProfile.id }
    let friendProfile: FriendProfile
    let isCreator: Bool
}
