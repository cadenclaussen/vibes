//
//  AuthManager.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isSpotifyLinked = false

    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private lazy var db = Firestore.firestore()

    private init() {
        registerAuthStateHandler()
    }

    private func registerAuthStateHandler() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil

            if let userId = user?.uid {
                Task {
                    await self?.checkSpotifyLink(userId: userId)
                }
            }
        }
    }

    private func checkSpotifyLink(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data(),
               let spotifyId = data["spotifyId"] as? String,
               !spotifyId.isEmpty {
                self.isSpotifyLinked = true
            } else {
                self.isSpotifyLinked = false
            }
        } catch {
            print("Error checking Spotify link: \(error.localizedDescription)")
            self.isSpotifyLinked = false
        }
    }

    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Email/Password Authentication

    func signUp(email: String, password: String, username: String) async throws {
        guard !username.isEmpty else {
            throw AuthError.invalidUsername
        }

        let usernameQuery = try await db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()

        guard usernameQuery.documents.isEmpty else {
            throw AuthError.usernameTaken
        }

        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        let userProfile = UserProfile(uid: result.user.uid, email: email, username: username)

        try db.collection("users").document(result.user.uid).setData(from: userProfile)
        self.user = result.user
        print("✅ User created successfully: \(username)")
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = result.user
        print("✅ User signed in: \(result.user.email ?? "unknown")")
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        self.user = nil
        self.isSpotifyLinked = false
        print("✅ User signed out")
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
        print("✅ Password reset email sent to: \(email)")
    }

    // MARK: - Delete Account

    func deleteAccount() async throws {
        guard let user = user else {
            throw AuthError.notAuthenticated
        }

        try await db.collection("users").document(user.uid).delete()

        try await user.delete()
        self.user = nil
        print("✅ Account deleted")
    }
}

enum AuthError: LocalizedError {
    case usernameTaken
    case invalidUsername
    case notAuthenticated
    case tokenExpired

    var errorDescription: String? {
        switch self {
        case .usernameTaken:
            return "Username is already taken"
        case .invalidUsername:
            return "Username cannot be empty"
        case .notAuthenticated:
            return "You must be signed in"
        case .tokenExpired:
            return "Session expired. Please sign in again"
        }
    }
}
