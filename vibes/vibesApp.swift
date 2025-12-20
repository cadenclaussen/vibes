//
//  vibesApp.swift
//  vibes
//
//  Created by Caden Claussen on 11/22/25.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth
import FirebaseMessaging

@main
struct vibesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
        print("✅ Firebase app name: \(FirebaseApp.app()?.name ?? "unknown")")
    }

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthManager.shared)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        guard let userId = AuthManager.shared.user?.uid else { return }

        Task {
            do {
                switch phase {
                case .active:
                    try await FirestoreService.shared.setUserOnline(userId: userId)
                case .inactive, .background:
                    try await FirestoreService.shared.setUserOffline(userId: userId)
                @unknown default:
                    break
                }
            } catch {
                print("Failed to update presence: \(error)")
            }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "vibes" else { return }

        Task {
            do {
                try await SpotifyService.shared.handleAuthorizationCallback(url: url)
                print("✅ Spotify authentication successful")
            } catch {
                print("❌ Spotify authentication failed: \(error)")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("✅ AppDelegate: didFinishLaunching called")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("✅ Notification permission granted: \(granted)")
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ Device registered for remote notifications")
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNS token set for Firebase Messaging")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
