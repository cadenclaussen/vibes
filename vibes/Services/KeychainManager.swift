import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case itemNotFound
        case invalidData
    }

    // MARK: - Save

    func save(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            try update(key: key, value: value)
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }

    // MARK: - Retrieve

    func retrieve(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unknown(status)
        }

        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return value
    }

    // MARK: - Update

    func update(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }

    // MARK: - Delete

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }

    // MARK: - Convenience Methods for Spotify Tokens

    func saveSpotifyAccessToken(_ token: String) throws {
        try save(key: "spotifyAccessToken", value: token)
    }

    func retrieveSpotifyAccessToken() throws -> String {
        try retrieve(key: "spotifyAccessToken")
    }

    func saveSpotifyRefreshToken(_ token: String) throws {
        try save(key: "spotifyRefreshToken", value: token)
    }

    func retrieveSpotifyRefreshToken() throws -> String {
        try retrieve(key: "spotifyRefreshToken")
    }

    func deleteSpotifyTokens() throws {
        try? delete(key: "spotifyAccessToken")
        try? delete(key: "spotifyRefreshToken")
    }

    func saveTokenExpiration(_ date: Date) throws {
        let timestamp = String(date.timeIntervalSince1970)
        try save(key: "spotifyTokenExpiration", value: timestamp)
    }

    func retrieveTokenExpiration() throws -> Date {
        let timestamp = try retrieve(key: "spotifyTokenExpiration")
        guard let timeInterval = TimeInterval(timestamp) else {
            throw KeychainError.invalidData
        }
        return Date(timeIntervalSince1970: timeInterval)
    }

    func isTokenExpired() -> Bool {
        do {
            let expirationDate = try retrieveTokenExpiration()
            return Date() >= expirationDate
        } catch {
            return true
        }
    }

    // MARK: - Convenience Methods for OpenAI API Key

    func saveOpenAIAPIKey(_ key: String) throws {
        try save(key: "openAIAPIKey", value: key)
    }

    func retrieveOpenAIAPIKey() throws -> String {
        try retrieve(key: "openAIAPIKey")
    }

    func deleteOpenAIAPIKey() throws {
        try delete(key: "openAIAPIKey")
    }

    func hasOpenAIAPIKey() -> Bool {
        do {
            _ = try retrieveOpenAIAPIKey()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Convenience Methods for Gemini API Key

    func saveGeminiAPIKey(_ key: String) throws {
        try save(key: "geminiAPIKey", value: key)
    }

    func retrieveGeminiAPIKey() throws -> String {
        try retrieve(key: "geminiAPIKey")
    }

    func deleteGeminiAPIKey() throws {
        try delete(key: "geminiAPIKey")
    }

    func hasGeminiAPIKey() -> Bool {
        do {
            _ = try retrieveGeminiAPIKey()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Convenience Methods for Ticketmaster API Key

    func saveTicketmasterAPIKey(_ key: String) throws {
        try save(key: "ticketmasterAPIKey", value: key)
    }

    func retrieveTicketmasterAPIKey() throws -> String {
        try retrieve(key: "ticketmasterAPIKey")
    }

    func deleteTicketmasterAPIKey() throws {
        try delete(key: "ticketmasterAPIKey")
    }

    func hasTicketmasterAPIKey() -> Bool {
        do {
            _ = try retrieveTicketmasterAPIKey()
            return true
        } catch {
            return false
        }
    }
}
