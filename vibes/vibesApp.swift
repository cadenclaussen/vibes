import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // Configure Google Sign-In with client ID from Firebase
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        return true
    }
}

@main
struct vibesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var router = AppRouter()
    @State private var setupManager = SetupManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(AuthManager.shared)
                .environment(router)
                .environment(setupManager)
                .environment(SpotifyRemoteService.shared)
                .onOpenURL { url in
                    // Handle Google Sign-In callback
                    if GIDSignIn.sharedInstance.handle(url) {
                        return
                    }
                    // Handle Spotify callback
                    if url.scheme == "vibes" {
                        SpotifyRemoteService.shared.handleOpenURL(url)
                    }
                }
        }
    }
}

struct RootView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if authManager.isLoading {
                LoadingView()
            } else if authManager.isAuthenticated {
                if authManager.needsTutorial {
                    TutorialView()
                } else {
                    ContentView()
                }
            } else {
                AuthView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // Refresh Spotify token if expired when app becomes active
                Task {
                    await refreshSpotifyTokenIfNeeded()
                }
            case .background:
                spotifyRemote.pause()
            default:
                break
            }
        }
        .task {
            // Refresh token on initial app launch
            await refreshSpotifyTokenIfNeeded()
        }
    }

    private func refreshSpotifyTokenIfNeeded() async {
        // Only refresh if user has connected Spotify
        guard KeychainManager.shared.getSpotifyRefreshToken() != nil else { return }

        // Check if token is expired or expiring soon
        if KeychainManager.shared.isSpotifyTokenExpired() {
            do {
                try await SpotifyAuthService.shared.refreshAccessToken()
            } catch {
                // Token refresh failed - user will be prompted to reconnect when they try to use Spotify features
                print("Spotify token refresh failed: \(error)")
            }
        }
    }
}
