import Foundation

enum Constants {
    enum Keychain {
        static let spotifyAccessToken = "spotifyAccessToken"
        static let spotifyRefreshToken = "spotifyRefreshToken"
        static let spotifyExpirationDate = "spotifyExpirationDate"
        static let geminiApiKey = "geminiApiKey"
    }

    enum UserDefaults {
        static let hasCompletedTutorial = "hasCompletedTutorial"
        static let concertCity = "concertCity"
        static let concertRadius = "concertRadius"
    }

    enum Notification {
        static let spotifyAuthChanged = "spotifyAuthChanged"
        static let userProfileUpdated = "userProfileUpdated"
    }

    enum Firestore {
        static let users = "users"
        static let friendships = "friendships"
        static let songShares = "songShares"
        static let messages = "messages"
        static let messageThreads = "messageThreads"
        static let achievements = "achievements"
    }

    enum Spotify {
        static let clientId = "ac84e0cce87749f3bce04a8ad3f5542e"
        static let redirectUri = "vibes://callback"
        static let scopes = [
            "user-read-private",
            "user-read-email",
            "user-top-read",
            "user-library-read",
            "user-library-modify",
            "playlist-read-private",
            "playlist-read-collaborative",
            "playlist-modify-public",
            "playlist-modify-private"
        ]
    }

    enum Ticketmaster {
        static let apiKey = "YOUR_TICKETMASTER_API_KEY"
        static let baseURL = "https://app.ticketmaster.com/discovery/v2"
    }

    enum Gemini {
        static let baseURL = "https://generativelanguage.googleapis.com/v1beta"
        static let model = "gemini-pro"
    }

    enum iTunes {
        static let searchURL = "https://itunes.apple.com/search"
    }
}
