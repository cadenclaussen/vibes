# Authentication Guide for vibes

## Overview

vibes supports three authentication methods:
1. **Email/Password** - Traditional sign-up with Firebase
2. **Google Sign-In** - OAuth with Google account
3. **Spotify OAuth** - Required for music integration

All methods use Firebase Authentication as the backend, with Spotify OAuth as an additional required step after initial authentication.

---

## Architecture

```
User Sign-In Flow:
┌──────────────────┐
│  Launch App      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Firebase Auth    │────▶│  Create Account  │
│ (Email or Google)│     │  with Firebase   │
└────────┬─────────┘     └──────────────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│  Spotify OAuth   │────▶│   Link Spotify   │
│   (Required)     │     │    to Account    │
└────────┬─────────┘     └──────────────────┘
         │
         ▼
┌──────────────────┐
│   vibes Home     │
└──────────────────┘
```

---

## 1. Firebase Authentication Setup

### Installation

Add Firebase to your Xcode project using Swift Package Manager:

1. In Xcode: `File > Add Packages`
2. Add Firebase repository: `https://github.com/firebase/firebase-ios-sdk`
3. Select packages:
   - `FirebaseAuth`
   - `FirebaseFirestore` (for database)
   - `FirebaseCore`

### Firebase Configuration

1. Create Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Download `GoogleService-Info.plist`
3. Add to Xcode project root
4. Initialize Firebase in `App.swift`:

```swift
import SwiftUI
import FirebaseCore

@main
struct vibesApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Enable Authentication Methods

In Firebase Console:
1. Go to Authentication > Sign-in method
2. Enable:
   - Email/Password
   - Google
3. Configure OAuth redirect URLs

---

## 2. Email/Password Authentication

### Sign Up

```swift
import FirebaseAuth

func signUpWithEmail(email: String, password: String) async throws -> User? {
    do {
        let authResult = try await Auth.auth().createUser(
            withEmail: email,
            password: password
        )
        return authResult.user
    } catch {
        print("Sign up error: \\(error.localizedDescription)")
        throw error
    }
}
```

### Sign In

```swift
func signInWithEmail(email: String, password: String) async throws -> User? {
    do {
        let authResult = try await Auth.auth().signIn(
            withEmail: email,
            password: password
        )
        return authResult.user
    } catch {
        print("Sign in error: \\(error.localizedDescription)")
        throw error
    }
}
```

### Password Reset

```swift
func resetPassword(email: String) async throws {
    try await Auth.auth().sendPasswordReset(withEmail: email)
}
```

### SwiftUI View Example

```swift
struct EmailAuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textContentType(isSignUp ? .newPassword : .password)
                .textFieldStyle(.roundedBorder)

            Button(isSignUp ? "Sign Up" : "Sign In") {
                Task {
                    do {
                        if isSignUp {
                            _ = try await signUpWithEmail(email: email, password: password)
                        } else {
                            _ = try await signInWithEmail(email: email, password: password)
                        }
                        // Navigate to Spotify OAuth
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(isSignUp ? "Already have an account?" : "Create account") {
                isSignUp.toggle()
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
}
```

---

## 3. Google Sign-In

### Setup

1. Install Google Sign-In SDK:

```swift
// Add to Package.swift or use SPM
dependencies: [
    .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0")
]
```

2. Get OAuth Client ID from [Google Cloud Console](https://console.cloud.google.com):
   - Create project
   - Enable Google Sign-In
   - Create OAuth 2.0 Client ID (iOS type)
   - Download `GoogleService-Info.plist`

3. Add URL Scheme to Xcode:
   - Target > Info > URL Types
   - Add reversed client ID (from `GoogleService-Info.plist`)
   - Example: `com.googleusercontent.apps.123456789-abcdefg`

### Implementation

```swift
import GoogleSignIn
import FirebaseAuth

class AuthViewModel: ObservableObject {
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google Sign-In error: \\(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            // Authenticate with Firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase auth error: \\(error.localizedDescription)")
                    return
                }
                // Success - navigate to Spotify OAuth
                print("Successfully signed in with Google")
            }
        }
    }

    func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("Restore sign-in error: \\(error.localizedDescription)")
                return
            }
            // User is signed in
        }
    }
}
```

### SwiftUI View

```swift
import GoogleSignInSwift

struct GoogleSignInButton: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        VStack {
            // Official Google Sign-In button
            GoogleSignInButton(scheme: .dark, style: .wide, state: .normal) {
                authViewModel.signInWithGoogle()
            }
            .frame(height: 50)
        }
        .onAppear {
            authViewModel.restorePreviousSignIn()
        }
    }
}
```

---

## 4. Spotify OAuth Integration

### Setup

1. Register app at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Get:
   - Client ID
   - Client Secret (store securely, DO NOT commit)
3. Add Redirect URI: `vibes://spotify-callback`

### Authorization Code Flow with PKCE (Recommended)

PKCE (Proof Key for Code Exchange) is the most secure method for mobile apps.

#### Install Spotify SDK

**Option 1: Using SpotifyAPI (Recommended)**
```swift
dependencies: [
    .package(url: "https://github.com/Peter-Schorn/SpotifyAPI.git", from: "2.2.0")
]
```

**Option 2: Using Official Spotify iOS SDK**
```swift
dependencies: [
    .package(url: "https://github.com/spotify/ios-sdk", from: "1.2.0")
]
```

#### Implementation with PKCE

```swift
import SpotifyWebAPI

class SpotifyAuthManager: ObservableObject {
    static let shared = SpotifyAuthManager()

    let spotify = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: "YOUR_CLIENT_ID"
        )
    )

    @Published var isAuthorized = false

    private init() {
        // Check for saved authorization
        if spotify.authorizationManager.isAuthorized {
            isAuthorized = true
        }
    }

    func authorize() {
        let scopes: Set<Scope> = [
            .userReadEmail,
            .userReadPrivate,
            .playlistReadPrivate,
            .playlistReadCollaborative,
            .playlistModifyPublic,
            .playlistModifyPrivate,
            .userLibraryRead,
            .userTopRead,
            .userReadRecentlyPlayed,
            .userReadCurrentlyPlaying,
            .userReadPlaybackState
        ]

        spotify.authorizationManager.authorize(
            scopes: scopes,
            showDialog: false
        )
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                self.isAuthorized = true
            case .failure(let error):
                print("Authorization error: \\(error)")
            }
        })
        .store(in: &cancellables)
    }

    func handleURL(_ url: URL) {
        spotify.authorizationManager.handleURL(url)
    }
}
```

#### Handle Redirect in App

```swift
@main
struct vibesApp: App {
    @StateObject private var spotifyAuth = SpotifyAuthManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    spotifyAuth.handleURL(url)
                }
        }
    }
}
```

#### Add URL Scheme

In `Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>vibes</string>
        </array>
    </dict>
</array>
```

### Required Spotify Scopes

For vibes features:

```swift
let requiredScopes: Set<Scope> = [
    // User Profile
    .userReadEmail,
    .userReadPrivate,

    // Playlists
    .playlistReadPrivate,
    .playlistReadCollaborative,
    .playlistModifyPublic,
    .playlistModifyPrivate,

    // Library
    .userLibraryRead,
    .userLibraryModify,

    // Listening History & Stats
    .userTopRead,
    .userReadRecentlyPlayed,

    // Currently Playing
    .userReadCurrentlyPlaying,
    .userReadPlaybackState
]
```

---

## 5. Token Management & Security

### Secure Storage (iOS Keychain)

```swift
import Security

class KeychainManager {
    static func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    static func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
```

### Token Refresh

```swift
class TokenManager {
    func refreshSpotifyToken() async throws {
        // SpotifyAPI handles this automatically
        try await SpotifyAuthManager.shared.spotify.authorizationManager.refreshTokens()
    }

    func refreshFirebaseToken() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.notAuthenticated
        }

        try await user.getIDTokenForcingRefresh(true)
    }
}
```

---

## 6. Complete Authentication Flow

### AuthenticationManager

```swift
import FirebaseAuth
import SpotifyWebAPI

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isFirebaseAuthenticated = false
    @Published var isSpotifyAuthenticated = false

    var isFullyAuthenticated: Bool {
        isFirebaseAuthenticated && isSpotifyAuthenticated
    }

    init() {
        // Listen for Firebase auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isFirebaseAuthenticated = user != nil
        }

        // Check Spotify auth status
        isSpotifyAuthenticated = SpotifyAuthManager.shared.isAuthorized
    }

    // MARK: - Email/Password

    func signUpWithEmail(email: String, password: String, username: String) async throws {
        let authResult = try await Auth.auth().createUser(
            withEmail: email,
            password: password
        )

        // Update display name
        let changeRequest = authResult.user.createProfileChangeRequest()
        changeRequest.displayName = username
        try await changeRequest.commitChanges()

        // Create user document in Firestore
        try await createUserDocument(
            uid: authResult.user.uid,
            email: email,
            username: username
        )

        // Navigate to Spotify auth
    }

    // MARK: - Google Sign-In

    func signInWithGoogle() async throws {
        // Implementation from section 3
    }

    // MARK: - Spotify

    func authenticateSpotify() {
        SpotifyAuthManager.shared.authorize()
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        SpotifyAuthManager.shared.spotify.authorizationManager.deauthorize()
        isSpotifyAuthenticated = false
    }

    // MARK: - Helper

    private func createUserDocument(uid: String, email: String, username: String) async throws {
        // Create user in Firestore with initial data
        let userData: [String: Any] = [
            "uid": uid,
            "email": email,
            "username": username,
            "createdAt": Timestamp(),
            "spotifyLinked": false
        ]

        try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .setData(userData)
    }
}
```

### Onboarding View Flow

```swift
enum AuthState {
    case notAuthenticated
    case firebaseAuthenticated
    case fullyAuthenticated
}

struct OnboardingView: View {
    @StateObject private var authManager = AuthenticationManager()

    var authState: AuthState {
        if authManager.isFullyAuthenticated {
            return .fullyAuthenticated
        } else if authManager.isFirebaseAuthenticated {
            return .firebaseAuthenticated
        } else {
            return .notAuthenticated
        }
    }

    var body: some View {
        switch authState {
        case .notAuthenticated:
            InitialAuthView()
        case .firebaseAuthenticated:
            SpotifyAuthView()
        case .fullyAuthenticated:
            MainTabView()
        }
    }
}
```

---

## 7. Security Best Practices

### DO:
- ✅ Store tokens in iOS Keychain
- ✅ Use HTTPS for all API calls
- ✅ Implement token refresh logic
- ✅ Use PKCE for Spotify OAuth
- ✅ Validate tokens on backend
- ✅ Implement rate limiting
- ✅ Use Firebase Security Rules
- ✅ Hash passwords (Firebase handles this)
- ✅ Enable App Attest for iOS

### DON'T:
- ❌ Store client secrets in app
- ❌ Commit credentials to Git
- ❌ Use plain HTTP
- ❌ Store tokens in UserDefaults
- ❌ Share tokens between users
- ❌ Ignore token expiration
- ❌ Skip input validation
- ❌ Log sensitive data

### Environment Variables

Use Xcode configuration files for sensitive data:

```swift
// Config.xcconfig
SPOTIFY_CLIENT_ID = your_client_id_here

// Access in code
if let clientID = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_ID") as? String {
    // Use client ID
}
```

---

## 8. Testing

### Firebase Local Emulator

```bash
# Install Firebase tools
npm install -g firebase-tools

# Initialize emulators
firebase init emulators

# Start emulators
firebase emulators:start
```

### Test Users

Create test accounts:
- Email: `test@vibes.com` / Password: `TestPass123!`
- Google: Use Google's test accounts
- Spotify: Create Spotify test account

### Unit Tests

```swift
import XCTest
@testable import vibes

class AuthenticationTests: XCTestCase {
    var authManager: AuthenticationManager!

    override func setUp() {
        super.setUp()
        authManager = AuthenticationManager()
    }

    func testEmailSignUp() async throws {
        try await authManager.signUpWithEmail(
            email: "test@example.com",
            password: "TestPass123!",
            username: "testuser"
        )

        XCTAssertTrue(authManager.isFirebaseAuthenticated)
    }

    func testSignOut() throws {
        try authManager.signOut()
        XCTAssertFalse(authManager.isFirebaseAuthenticated)
    }
}
```

---

## 9. Error Handling

```swift
enum AuthError: LocalizedError {
    case notAuthenticated
    case tokenExpired
    case spotifyNotLinked
    case networkError
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to continue"
        case .tokenExpired:
            return "Session expired. Please sign in again"
        case .spotifyNotLinked:
            return "Please connect your Spotify account"
        case .networkError:
            return "Network connection failed"
        case .invalidCredentials:
            return "Invalid email or password"
        }
    }
}
```

---

## 10. Resources & Documentation

### Official Documentation
- [Firebase Authentication (iOS)](https://firebase.google.com/docs/auth/ios/start)
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios/sign-in)
- [Spotify iOS SDK](https://developer.spotify.com/documentation/ios/getting-started)
- [Spotify OAuth Guide](https://developer.spotify.com/documentation/general/guides/authorization/)

### Third-Party Libraries
- [SpotifyAPI (Swift)](https://github.com/Peter-Schorn/SpotifyAPI)
- [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift)

### Tutorials
- [Firebase Auth with SwiftUI](https://medium.com/firebase-developers/firebase-authentication-in-swiftui-part-3-80be99dbc63d)
- [Spotify OAuth in iOS](https://medium.com/swlh/authenticate-with-spotify-in-ios-ae6612ecca91)
- [Google Sign-In SwiftUI](https://www.toni-develops.com/2024/01/04/adding-google-sign-in-in-ios-with-swiftui/)

### Community Resources
- [Firebase iOS Quickstart](https://github.com/firebase/quickstart-ios/blob/main/authentication/README.md)
- [Google Sign-In SwiftUI Demo](https://github.com/WesCSK/SwiftUI-Firebase-Authenticate-Using-Google-Sign-In)
- [Spotify iOS SDK Examples](https://github.com/spotify/ios-sdk/blob/master/DemoProjects/README.md)

---

## Summary Checklist

### Before Development:
- [ ] Create Firebase project
- [ ] Create Google Cloud project (for Google Sign-In)
- [ ] Register app in Spotify Developer Dashboard
- [ ] Configure OAuth redirect URIs
- [ ] Set up environment variables/config files

### Implementation:
- [ ] Install Firebase SDK
- [ ] Install Google Sign-In SDK
- [ ] Install Spotify SDK (SpotifyAPI recommended)
- [ ] Implement Firebase email/password auth
- [ ] Implement Google Sign-In
- [ ] Implement Spotify OAuth with PKCE
- [ ] Set up Keychain storage
- [ ] Implement token refresh
- [ ] Add error handling
- [ ] Create onboarding flow

### Testing:
- [ ] Test email sign-up/sign-in
- [ ] Test Google Sign-In
- [ ] Test Spotify OAuth
- [ ] Test token refresh
- [ ] Test sign-out
- [ ] Test with Firebase emulator
- [ ] Verify Keychain storage

### Security:
- [ ] Never commit client secrets
- [ ] Use PKCE for Spotify
- [ ] Store tokens in Keychain
- [ ] Implement token refresh
- [ ] Add input validation
- [ ] Set up Firebase Security Rules
- [ ] Enable App Attest

---

**Authentication is the foundation of vibes. Follow this guide for secure, seamless user authentication!**
