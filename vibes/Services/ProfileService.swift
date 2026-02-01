import SwiftUI
import FirebaseStorage
import FirebaseFirestore

@Observable
@MainActor
final class ProfileService {
    static let shared = ProfileService()

    private let storage = Storage.storage()
    private let db = Firestore.firestore()

    private init() {}

    func uploadProfilePicture(_ image: UIImage, userId: String) async throws -> String {
        // Resize and compress image
        guard let imageData = image.jpegData(compressionQuality: 0.8, maxDimension: 400) else {
            throw ProfileError.imageProcessingFailed
        }

        // Upload to Firebase Storage
        let storageRef = storage.reference().child("users/\(userId)/profile.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)

        // Get download URL with retry (handles propagation delay)
        var lastError: Error?
        for attempt in 1...3 {
            do {
                let downloadURL = try await storageRef.downloadURL()
                return downloadURL.absoluteString
            } catch {
                lastError = error
                if attempt < 3 {
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                }
            }
        }

        throw lastError ?? ProfileError.uploadFailed
    }

    func updateProfile(
        userId: String,
        displayName: String,
        bio: String?,
        profilePictureURL: String? = nil
    ) async throws {
        var data: [String: Any] = [
            "displayName": displayName,
            "updatedAt": Timestamp(date: Date())
        ]

        // Bio can be empty string or nil
        if let bio = bio, !bio.isEmpty {
            data["bio"] = bio
        } else {
            data["bio"] = FieldValue.delete()
        }

        // Only update profile picture if provided
        if let url = profilePictureURL {
            data["profilePictureURL"] = url
        }

        try await db.collection(Constants.Firestore.users)
            .document(userId)
            .updateData(data)
    }

    func deleteProfilePicture(userId: String) async throws {
        let storageRef = storage.reference().child("users/\(userId)/profile.jpg")
        try await storageRef.delete()
    }
}

enum ProfileError: LocalizedError {
    case imageProcessingFailed
    case uploadFailed
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process image"
        case .uploadFailed:
            return "Failed to upload profile picture"
        case .notAuthenticated:
            return "You must be signed in to update your profile"
        }
    }
}
