import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
@MainActor
final class ArtistFollowService {
    static let shared = ArtistFollowService()

    private let db = Firestore.firestore()
    private var cachedFollowedArtists: [FollowedArtist]?
    private var cachedArtistIds: Set<String> = []

    private init() {}

    // MARK: - Follow Operations

    func followArtist(_ artist: UnifiedArtist) async throws {
        guard let userId = AuthManager.shared.user?.uid else {
            throw VibesError.notAuthenticated
        }

        let followedArtist = FollowedArtist(from: artist)

        try await db.collection(Constants.Firestore.users)
            .document(userId)
            .collection(Constants.Firestore.followedArtists)
            .document(artist.id)
            .setData([
                "artistId": followedArtist.artistId,
                "artistName": followedArtist.artistName,
                "artistImageURL": followedArtist.artistImageURL as Any,
                "followedAt": Timestamp(date: followedArtist.followedAt)
            ])

        // Update cache
        cachedArtistIds.insert(artist.id)
        cachedFollowedArtists?.append(followedArtist)
    }

    func unfollowArtist(_ artistId: String) async throws {
        guard let userId = AuthManager.shared.user?.uid else {
            throw VibesError.notAuthenticated
        }

        try await db.collection(Constants.Firestore.users)
            .document(userId)
            .collection(Constants.Firestore.followedArtists)
            .document(artistId)
            .delete()

        // Update cache
        cachedArtistIds.remove(artistId)
        cachedFollowedArtists?.removeAll { $0.artistId == artistId }
    }

    func isFollowing(artistId: String) async -> Bool {
        // Check cache first - if we've loaded the list, use it
        if cachedFollowedArtists != nil {
            return cachedArtistIds.contains(artistId)
        }

        guard let userId = AuthManager.shared.user?.uid else {
            return false
        }

        do {
            let doc = try await db.collection(Constants.Firestore.users)
                .document(userId)
                .collection(Constants.Firestore.followedArtists)
                .document(artistId)
                .getDocument()

            return doc.exists
        } catch {
            return false
        }
    }

    func getFollowedArtists() async throws -> [FollowedArtist] {
        // Return cache if available
        if let cached = cachedFollowedArtists {
            return cached
        }

        guard let userId = AuthManager.shared.user?.uid else {
            return []
        }

        let snapshot = try await db.collection(Constants.Firestore.users)
            .document(userId)
            .collection(Constants.Firestore.followedArtists)
            .order(by: "followedAt", descending: false)
            .getDocuments()

        let artists = snapshot.documents.compactMap { doc -> FollowedArtist? in
            let data = doc.data()
            guard let artistId = data["artistId"] as? String,
                  let artistName = data["artistName"] as? String,
                  let timestamp = data["followedAt"] as? Timestamp else {
                return nil
            }

            return FollowedArtist(
                artistId: artistId,
                artistName: artistName,
                artistImageURL: data["artistImageURL"] as? String,
                followedAt: timestamp.dateValue()
            )
        }

        // Update cache
        cachedFollowedArtists = artists
        cachedArtistIds = Set(artists.map { $0.artistId })

        return artists
    }

    func getFollowedArtistsAsRanked() async throws -> [RankedArtist] {
        let followed = try await getFollowedArtists()
        return followed.enumerated().map { index, artist in
            artist.toRankedArtist(rank: index + 1)
        }
    }

    func getFollowedArtistCount() async throws -> Int {
        guard let userId = AuthManager.shared.user?.uid else {
            return 0
        }

        let snapshot = try await db.collection(Constants.Firestore.users)
            .document(userId)
            .collection(Constants.Firestore.followedArtists)
            .count
            .getAggregation(source: .server)

        return Int(truncating: snapshot.count)
    }

    // MARK: - Cache Management

    func clearCache() {
        cachedFollowedArtists = nil
        cachedArtistIds = []
    }

    func refreshCache() async throws {
        cachedFollowedArtists = nil
        cachedArtistIds = []
        _ = try await getFollowedArtists()
    }
}
