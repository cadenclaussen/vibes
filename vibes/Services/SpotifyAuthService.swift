import Foundation
import AuthenticationServices
import Combine
import CryptoKit

enum SpotifyAuthError: LocalizedError {
    case invalidURL
    case noCodeInCallback
    case tokenExchangeFailed(String)
    case networkError(Error)
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid authorization URL."
        case .noCodeInCallback:
            return "No authorization code received from Spotify."
        case .tokenExchangeFailed(let message):
            return "Token exchange failed: \(message)"
        case .networkError:
            return "Network error. Please check your internet connection."
        case .notAuthenticated:
            return "Not authenticated with Spotify."
        }
    }
}

@MainActor
class SpotifyAuthService: NSObject, ObservableObject {
    static let shared = SpotifyAuthService()

    @Published var isAuthenticating = false

    private var codeVerifier: String?
    private var authSession: ASWebAuthenticationSession?
    private var authContinuation: CheckedContinuation<String, Error>?

    private let tokenURL = "https://accounts.spotify.com/api/token"
    private let authURL = "https://accounts.spotify.com/authorize"

    private override init() {
        super.init()
    }

    func startAuthorization() async throws {
        isAuthenticating = true
        defer { isAuthenticating = false }

        let verifier = generateCodeVerifier()
        codeVerifier = verifier
        let challenge = generateCodeChallenge(verifier: verifier)

        guard let authorizationURL = buildAuthorizationURL(codeChallenge: challenge) else {
            throw SpotifyAuthError.invalidURL
        }

        let code = try await performWebAuthentication(url: authorizationURL)
        try await exchangeCodeForTokens(code: code, codeVerifier: verifier)
    }

    func handleCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            authContinuation?.resume(throwing: SpotifyAuthError.noCodeInCallback)
            authContinuation = nil
            return
        }

        authContinuation?.resume(returning: code)
        authContinuation = nil
    }

    func refreshAccessToken() async throws {
        guard let refreshToken = KeychainManager.shared.getSpotifyRefreshToken() else {
            throw SpotifyAuthError.notAuthenticated
        }

        let parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": Constants.Spotify.clientId
        ]

        do {
            let tokens = try await performTokenRequest(parameters: parameters)
            try saveTokens(tokens)
        } catch let error as SpotifyAuthError {
            // If refresh token is revoked/invalid, clear stored tokens
            if case .tokenExchangeFailed(let message) = error,
               message.lowercased().contains("revoked") || message.lowercased().contains("invalid") {
                disconnect()
            }
            throw error
        }
    }

    func disconnect() {
        try? KeychainManager.shared.delete(key: .spotifyAccessToken)
        try? KeychainManager.shared.delete(key: .spotifyRefreshToken)
        try? KeychainManager.shared.delete(key: .spotifyExpirationDate)
        NotificationCenter.default.post(
            name: Notification.Name(Constants.Notification.spotifyAuthChanged),
            object: nil
        )
    }

    var isAuthenticated: Bool {
        KeychainManager.shared.getSpotifyAccessToken() != nil
    }

    func getValidAccessToken() async throws -> String {
        if let expirationDate = KeychainManager.shared.getSpotifyExpirationDate(),
           expirationDate < Date() {
            try await refreshAccessToken()
        }

        guard let token = KeychainManager.shared.getSpotifyAccessToken() else {
            throw SpotifyAuthError.notAuthenticated
        }

        return token
    }

    private func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncodedString()
    }

    private func generateCodeChallenge(verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash).base64URLEncodedString()
    }

    private func buildAuthorizationURL(codeChallenge: String) -> URL? {
        var components = URLComponents(string: authURL)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.Spotify.clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: Constants.Spotify.redirectUri),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "scope", value: Constants.Spotify.scopes.joined(separator: " "))
        ]
        return components?.url
    }

    private func performWebAuthentication(url: URL) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            authContinuation = continuation

            authSession = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "vibes"
            ) { [weak self] callbackURL, error in
                if let error = error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        self?.authContinuation?.resume(throwing: CancellationError())
                    } else {
                        self?.authContinuation?.resume(throwing: SpotifyAuthError.networkError(error))
                    }
                    self?.authContinuation = nil
                    return
                }

                if let callbackURL = callbackURL {
                    self?.handleCallback(url: callbackURL)
                }
            }

            authSession?.presentationContextProvider = self
            authSession?.prefersEphemeralWebBrowserSession = false
            authSession?.start()
        }
    }

    private func exchangeCodeForTokens(code: String, codeVerifier: String) async throws {
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": Constants.Spotify.redirectUri,
            "client_id": Constants.Spotify.clientId,
            "code_verifier": codeVerifier
        ]

        let tokens = try await performTokenRequest(parameters: parameters)
        try saveTokens(tokens)

        NotificationCenter.default.post(
            name: Notification.Name(Constants.Notification.spotifyAuthChanged),
            object: nil
        )
    }

    private func performTokenRequest(parameters: [String: String]) async throws -> TokenResponse {
        guard let url = URL(string: tokenURL) else {
            throw SpotifyAuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyAuthError.tokenExchangeFailed("Invalid response")
            }

            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data) {
                    throw SpotifyAuthError.tokenExchangeFailed(errorResponse.errorDescription)
                }
                throw SpotifyAuthError.tokenExchangeFailed("HTTP \(httpResponse.statusCode)")
            }

            return try JSONDecoder().decode(TokenResponse.self, from: data)
        } catch let error as SpotifyAuthError {
            throw error
        } catch {
            throw SpotifyAuthError.networkError(error)
        }
    }

    private func saveTokens(_ tokens: TokenResponse) throws {
        try KeychainManager.shared.saveSpotifyAccessToken(tokens.accessToken)

        if let refreshToken = tokens.refreshToken {
            try KeychainManager.shared.saveSpotifyRefreshToken(refreshToken)
        }

        let expirationDate = Date().addingTimeInterval(TimeInterval(tokens.expiresIn))
        try KeychainManager.shared.saveSpotifyExpirationDate(expirationDate)
    }
}

extension SpotifyAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}

private struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

private struct SpotifyErrorResponse: Decodable {
    let error: String
    let errorDescription: String

    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
