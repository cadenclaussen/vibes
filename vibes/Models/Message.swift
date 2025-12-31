import Foundation
import FirebaseFirestore

struct Message: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var threadId: String
    var senderId: String
    var senderUsername: String
    var content: MessageContent
    var timestamp: Date
    var isRead: Bool

    enum MessageContent: Codable, Hashable {
        case text(String)
        case song(SongShare)

        enum CodingKeys: String, CodingKey {
            case type
            case text
            case song
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case "text":
                let text = try container.decode(String.self, forKey: .text)
                self = .text(text)
            case "song":
                let song = try container.decode(SongShare.self, forKey: .song)
                self = .song(song)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Unknown message type: \(type)"
                )
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .text(let text):
                try container.encode("text", forKey: .type)
                try container.encode(text, forKey: .text)
            case .song(let song):
                try container.encode("song", forKey: .type)
                try container.encode(song, forKey: .song)
            }
        }
    }

    init(
        id: String? = nil,
        threadId: String,
        senderId: String,
        senderUsername: String,
        content: MessageContent,
        timestamp: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.threadId = threadId
        self.senderId = senderId
        self.senderUsername = senderUsername
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

struct MessageThread: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var participants: [String] // User IDs
    var participantUsernames: [String: String] // uid -> username
    var lastMessage: String?
    var lastMessageTimestamp: Date?
    var unreadCount: [String: Int] // uid -> unread count

    init(
        id: String? = nil,
        participants: [String],
        participantUsernames: [String: String] = [:],
        lastMessage: String? = nil,
        lastMessageTimestamp: Date? = nil,
        unreadCount: [String: Int] = [:]
    ) {
        self.id = id
        self.participants = participants
        self.participantUsernames = participantUsernames
        self.lastMessage = lastMessage
        self.lastMessageTimestamp = lastMessageTimestamp
        self.unreadCount = unreadCount
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MessageThread, rhs: MessageThread) -> Bool {
        lhs.id == rhs.id
    }

    func otherParticipantId(currentUserId: String) -> String? {
        participants.first { $0 != currentUserId }
    }

    func otherParticipantUsername(currentUserId: String) -> String? {
        guard let otherId = otherParticipantId(currentUserId: currentUserId) else { return nil }
        return participantUsernames[otherId]
    }
}
