import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

@Observable
@MainActor
final class AuthManager {
    static let shared = AuthManager()

    var user: FirebaseAuth.User?
    var userProfile: UserProfile?
    var isAuthenticated = false
    var isLoading = true
    var needsTutorial = false
    var error: Error?

    var isSpotifyLinked: Bool {
        userProfile?.spotifyLinked ?? false
    }

    var isGeminiConfigured: Bool {
        userProfile?.geminiKeyConfigured ?? false
    }

    private var authStateListener: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    private let keychain = KeychainManager.shared

    private init() {
        setupAuthStateListener()
    }

    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isAuthenticated = user != nil
                if let user = user {
                    await self?.loadUserProfile(userId: user.uid)
                } else {
                    self?.userProfile = nil
                }
                self?.isLoading = false
            }
        }
    }

    // MARK: - Google Sign In

    func signInWithGoogle() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingIdToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false

        if isNewUser {
            try await createUserProfile(for: authResult.user, googleUser: result.user)
            needsTutorial = true
        } else {
            await loadUserProfile(userId: authResult.user.uid)
            // Check if user has completed tutorial
            let hasCompletedTutorial = UserDefaults.standard.bool(
                forKey: Constants.UserDefaults.hasCompletedTutorial
            )
            needsTutorial = !hasCompletedTutorial
        }
    }

    private func createUserProfile(for firebaseUser: FirebaseAuth.User, googleUser: GIDGoogleUser) async throws {
        let username = generateUsername(from: googleUser.profile?.email ?? firebaseUser.email ?? "user")

        let profile = UserProfile(
            id: firebaseUser.uid,
            uid: firebaseUser.uid,
            email: googleUser.profile?.email ?? firebaseUser.email ?? "",
            username: username,
            displayName: googleUser.profile?.name ?? firebaseUser.displayName ?? "User",
            profilePictureURL: googleUser.profile?.imageURL(withDimension: 200)?.absoluteString,
            spotifyLinked: false,
            geminiKeyConfigured: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        try await db.collection(Constants.Firestore.users)
            .document(firebaseUser.uid)
            .setData(try Firestore.Encoder().encode(profile))

        self.userProfile = profile
    }

    private func generateUsername(from email: String) -> String {
        let base = email.components(separatedBy: "@").first ?? "user"
        let cleaned = base.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "", options: .regularExpression)
        let random = String(Int.random(in: 1000...9999))
        return "\(cleaned)\(random)"
    }

    // MARK: - Profile Management

    func loadUserProfile(userId: String) async {
        do {
            let document = try await db.collection(Constants.Firestore.users)
                .document(userId)
                .getDocument()

            if document.exists {
                self.userProfile = try document.data(as: UserProfile.self)
            }
        } catch {
            self.error = error
        }
    }

    func updateProfile(_ profile: UserProfile) async throws {
        guard let userId = user?.uid else {
            throw VibesError.notAuthenticated
        }

        var updatedProfile = profile
        updatedProfile.updatedAt = Date()

        try await db.collection(Constants.Firestore.users)
            .document(userId)
            .setData(try Firestore.Encoder().encode(updatedProfile), merge: true)

        self.userProfile = updatedProfile
    }

    func updateSpotifyLinked(_ linked: Bool) async throws {
        guard var profile = userProfile else {
            throw VibesError.notAuthenticated
        }
        profile.spotifyLinked = linked
        try await updateProfile(profile)
    }

    func updateGeminiConfigured(_ configured: Bool) async throws {
        guard var profile = userProfile else {
            throw VibesError.notAuthenticated
        }
        profile.geminiKeyConfigured = configured
        try await updateProfile(profile)
    }

    func completeTutorial() {
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.hasCompletedTutorial)
        needsTutorial = false
    }

    func resetTutorial() {
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.hasCompletedTutorial)
        needsTutorial = true
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        try keychain.clearAll()
        userProfile = nil
        isAuthenticated = false
        needsTutorial = false
    }

    // MARK: - Delete Account

    func deleteAccount() async throws {
        guard let userId = user?.uid else {
            throw VibesError.notAuthenticated
        }

        // Delete user data from Firestore
        try await deleteUserData(userId: userId)

        // Delete Firebase Auth account
        try await user?.delete()

        // Clear local data
        try keychain.clearAll()
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.hasCompletedTutorial)

        userProfile = nil
        isAuthenticated = false
    }

    private func deleteUserData(userId: String) async throws {
        let batch = db.batch()

        // Delete user profile
        let userRef = db.collection(Constants.Firestore.users).document(userId)
        batch.deleteDocument(userRef)

        // Delete friendships where user is follower
        let followerQuery = db.collection(Constants.Firestore.friendships)
            .whereField("followerId", isEqualTo: userId)
        let followerDocs = try await followerQuery.getDocuments()
        for doc in followerDocs.documents {
            batch.deleteDocument(doc.reference)
        }

        // Delete friendships where user is being followed
        let followingQuery = db.collection(Constants.Firestore.friendships)
            .whereField("followingId", isEqualTo: userId)
        let followingDocs = try await followingQuery.getDocuments()
        for doc in followingDocs.documents {
            batch.deleteDocument(doc.reference)
        }

        // Delete song shares
        let sharesQuery = db.collection(Constants.Firestore.songShares)
            .whereField("senderId", isEqualTo: userId)
        let sharesDocs = try await sharesQuery.getDocuments()
        for doc in sharesDocs.documents {
            batch.deleteDocument(doc.reference)
        }

        try await batch.commit()
    }
}

enum AuthError: LocalizedError {
    case noRootViewController
    case missingIdToken
    case signInFailed

    var errorDescription: String? {
        switch self {
        case .noRootViewController:
            return "Unable to find root view controller"
        case .missingIdToken:
            return "Failed to get ID token from Google"
        case .signInFailed:
            return "Sign in failed. Please try again."
        }
    }
}
