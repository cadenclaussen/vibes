//
//  ProfileViewModel.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isEditing = false

    @Published var displayName = ""
    @Published var bio = ""
    @Published var profileTheme = ""
    @Published var musicTasteTags: [String] = []

    private let firestoreService = FirestoreService.shared
    private let authManager = AuthManager.shared

    func loadProfile() async {
        guard let userId = authManager.user?.uid else {
            errorMessage = "Not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            profile = try await firestoreService.getUserProfile(userId: userId)
            populateFields()
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func updateProfile() async {
        guard var updatedProfile = profile else { return }

        updatedProfile.displayName = displayName
        updatedProfile.bio = bio
        updatedProfile.profileTheme = profileTheme
        updatedProfile.musicTasteTags = musicTasteTags

        isLoading = true
        errorMessage = nil

        do {
            try await firestoreService.updateProfile(updatedProfile)
            profile = updatedProfile
            isEditing = false
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func updatePrivacySettings(_ settings: UserProfile.PrivacySettings) async {
        guard let userId = authManager.user?.uid else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await firestoreService.updatePrivacySettings(userId: userId, settings: settings)
            profile?.privacySettings = settings
        } catch {
            errorMessage = "Failed to update privacy settings: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func toggleEditMode() {
        isEditing.toggle()
        if isEditing {
            populateFields()
        } else {
            errorMessage = nil
        }
    }

    func cancelEdit() {
        isEditing = false
        populateFields()
        errorMessage = nil
    }

    private func populateFields() {
        guard let profile = profile else { return }
        displayName = profile.displayName
        bio = profile.bio ?? ""
        profileTheme = profile.profileTheme ?? ""
        musicTasteTags = profile.musicTasteTags
    }
}
