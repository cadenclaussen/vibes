import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.vibes.app"

    enum Key: String, CaseIterable {
        case spotifyAccessToken
        case spotifyRefreshToken
        case spotifyExpirationDate
        case geminiApiKey
        case ticketmasterApiKey
    }

    private init() {}

    func save(_ value: String, for key: Key) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        // Delete existing item first
        try? delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func retrieve(key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    func delete(key: Key) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    func clearAll() throws {
        for key in Key.allCases {
            try? delete(key: key)
        }
    }

    // Convenience methods for specific tokens
    func saveSpotifyTokens(accessToken: String, refreshToken: String, expirationDate: Date) throws {
        try save(accessToken, for: .spotifyAccessToken)
        try save(refreshToken, for: .spotifyRefreshToken)
        try save(String(expirationDate.timeIntervalSince1970), for: .spotifyExpirationDate)
    }

    func saveSpotifyAccessToken(_ token: String) throws {
        try save(token, for: .spotifyAccessToken)
    }

    func getSpotifyAccessToken() -> String? {
        retrieve(key: .spotifyAccessToken)
    }

    func saveSpotifyRefreshToken(_ token: String) throws {
        try save(token, for: .spotifyRefreshToken)
    }

    func getSpotifyRefreshToken() -> String? {
        retrieve(key: .spotifyRefreshToken)
    }

    func saveSpotifyExpirationDate(_ date: Date) throws {
        try save(String(date.timeIntervalSince1970), for: .spotifyExpirationDate)
    }

    func getSpotifyExpirationDate() -> Date? {
        guard let dateString = retrieve(key: .spotifyExpirationDate),
              let timestamp = Double(dateString) else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }

    func isSpotifyTokenExpired() -> Bool {
        guard let expirationDate = getSpotifyExpirationDate() else {
            return true
        }
        // Consider expired if less than 5 minutes remaining
        return expirationDate.timeIntervalSinceNow < 300
    }

    func saveGeminiApiKey(_ key: String) throws {
        try save(key, for: .geminiApiKey)
    }

    func getGeminiApiKey() -> String? {
        retrieve(key: .geminiApiKey)
    }

    func clearSpotifyTokens() throws {
        try delete(key: .spotifyAccessToken)
        try delete(key: .spotifyRefreshToken)
        try delete(key: .spotifyExpirationDate)
    }

    func saveTicketmasterApiKey(_ key: String) throws {
        try save(key, for: .ticketmasterApiKey)
    }

    func getTicketmasterApiKey() -> String? {
        retrieve(key: .ticketmasterApiKey)
    }

    func clearTicketmasterApiKey() throws {
        try delete(key: .ticketmasterApiKey)
    }
}

enum KeychainError: LocalizedError {
    case encodingFailed
    case saveFailed(OSStatus)
    case deleteFailed(OSStatus)
    case retrieveFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data for keychain"
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        case .retrieveFailed(let status):
            return "Failed to retrieve from keychain: \(status)"
        }
    }
}
