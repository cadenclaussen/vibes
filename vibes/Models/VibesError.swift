import Foundation

enum VibesError: LocalizedError {
    case notAuthenticated
    case spotifyNotConnected
    case geminiNotConfigured
    case networkError(Error)
    case firestoreError(Error)
    case spotifyError(Error)
    case invalidData
    case userNotFound
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue"
        case .spotifyNotConnected:
            return "Connect Spotify to use this feature"
        case .geminiNotConfigured:
            return "Add your Gemini API key in Settings"
        case .networkError:
            return "Network connection failed. Please try again."
        case .firestoreError(let error):
            return error.localizedDescription
        case .spotifyError(let error):
            return error.localizedDescription
        case .invalidData:
            return "Something went wrong. Please try again."
        case .userNotFound:
            return "User not found"
        case .permissionDenied:
            return "You don't have permission to perform this action"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notAuthenticated:
            return "Sign in with Google to continue"
        case .spotifyNotConnected:
            return "Go to Settings to connect your Spotify account"
        case .geminiNotConfigured:
            return "Go to Settings to add your Gemini API key"
        case .networkError:
            return "Check your internet connection and try again"
        default:
            return nil
        }
    }
}
