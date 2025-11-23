//
//  FriendNotification.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import Foundation
import FirebaseFirestore

struct FriendNotification: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let type: NotificationType
    let fromUserId: String
    let fromUsername: String
    let message: String
    let createdAt: Date
    let isRead: Bool

    enum NotificationType: String, Codable {
        case friendRequest
        case friendAccepted
        case newMessage
        case milestone
    }
}
