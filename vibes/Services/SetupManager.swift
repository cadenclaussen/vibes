import Foundation

@Observable
class SetupManager {
    private let keychain = KeychainManager.shared
    private var refreshTrigger = false

    var isSpotifyComplete: Bool {
        _ = refreshTrigger
        return keychain.getSpotifyAccessToken() != nil
    }

    var isGeminiComplete: Bool {
        _ = refreshTrigger
        return keychain.getGeminiApiKey() != nil
    }

    var isTicketmasterComplete: Bool {
        _ = refreshTrigger
        return keychain.getTicketmasterApiKey() != nil &&
            UserDefaults.standard.string(forKey: "concertCity") != nil
    }

    var completedCount: Int {
        [isSpotifyComplete, isGeminiComplete, isTicketmasterComplete]
            .filter { $0 }.count
    }

    var isAllComplete: Bool {
        completedCount == 3
    }

    var concertCity: String? {
        UserDefaults.standard.string(forKey: "concertCity")
    }

    init() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name(Constants.Notification.spotifyAuthChanged),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
    }

    func refresh() {
        refreshTrigger.toggle()
    }

    func saveConcertCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: "concertCity")
        refresh()
    }

    func clearConcertCity() {
        UserDefaults.standard.removeObject(forKey: "concertCity")
        refresh()
    }
}
