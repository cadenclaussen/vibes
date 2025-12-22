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
    var creatorId: String
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
    var reactions: [String: [String]] // emoji: [userIds]
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
