//
//  StorageService.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import Foundation
import FirebaseStorage
import UIKit

class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()

    private init() {}

    // MARK: - Profile Picture Upload

    func uploadProfilePicture(userId: String, imageData: Data) async throws -> String {
        let resizedData = resizeImage(imageData, maxSize: 500)

        let storageRef = storage.reference()
        let profilePicRef = storageRef.child("profile_pictures/\(userId).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await profilePicRef.putDataAsync(resizedData, metadata: metadata)

        let downloadURL = try await profilePicRef.downloadURL()
        return downloadURL.absoluteString
    }

    func deleteProfilePicture(userId: String) async throws {
        let storageRef = storage.reference()
        let profilePicRef = storageRef.child("profile_pictures/\(userId).jpg")

        do {
            try await profilePicRef.delete()
        } catch {
            // Ignore if file doesn't exist
            print("Profile picture delete error (may not exist): \(error)")
        }
    }

    // MARK: - Image Processing

    private func resizeImage(_ imageData: Data, maxSize: CGFloat) -> Data {
        guard let image = UIImage(data: imageData) else {
            return imageData
        }

        let size = image.size
        let aspectRatio = size.width / size.height

        var newWidth: CGFloat
        var newHeight: CGFloat

        if size.width > size.height {
            newWidth = min(size.width, maxSize)
            newHeight = newWidth / aspectRatio
        } else {
            newHeight = min(size.height, maxSize)
            newWidth = newHeight * aspectRatio
        }

        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage?.jpegData(compressionQuality: 0.8) ?? imageData
    }
}
