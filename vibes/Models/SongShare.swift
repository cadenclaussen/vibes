import Foundation
import FirebaseFirestore

struct SongShare: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var senderId: String
    var senderUsername: String
    var senderProfilePicture: String?
    var recipientId: String? // nil = shared to all followers
    var spotifyTrackId: String
    var trackName: String
    var artistName: String
    var albumArtURL: String
    var previewURL: String?
    var message: String?
    var timestamp: Date

    init(
        id: String? = nil,
        senderId: String,
        senderUsername: String,
        senderProfilePicture: String? = nil,
        recipientId: String? = nil,
        spotifyTrackId: String,
        trackName: String,
        artistName: String,
        albumArtURL: String,
        previewURL: String? = nil,
        message: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.senderId = senderId
        self.senderUsername = senderUsername
        self.senderProfilePicture = senderProfilePicture
        self.recipientId = recipientId
        self.spotifyTrackId = spotifyTrackId
        self.trackName = trackName
        self.artistName = artistName
        self.albumArtURL = albumArtURL
        self.previewURL = previewURL
        self.message = message
        self.timestamp = timestamp
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SongShare, rhs: SongShare) -> Bool {
        lhs.id == rhs.id
    }
}
