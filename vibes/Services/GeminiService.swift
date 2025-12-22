import Foundation
import CryptoKit
import Combine

@MainActor
class GeminiService: ObservableObject {
    static let shared = GeminiService()

    @Published var isConfigured = false

    private let keychainManager = KeychainManager.shared
    private var apiKey: String?
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    // Rate limiting
    private let maxDailyRequests = 50 // Gemini free tier is generous
    private var dailyRequestCount = 0
    private var lastRequestDate: Date?

    // Caching
    private let playlistCacheTTL: TimeInterval = 24 * 60 * 60 // 24 hours
    private let blendCacheTTL: TimeInterval = 7 * 24 * 60 * 60 // 7 days

    private init() {
        checkConfiguration()
        loadDailyRequestCount()
    }

    // MARK: - Configuration

    func checkConfiguration() {
        do {
            apiKey = try keychainManager.retrieveGeminiAPIKey()
            isConfigured = true
        } catch {
            isConfigured = false
            apiKey = nil
        }
    }

    func configure(apiKey: String) throws {
        try keychainManager.saveGeminiAPIKey(apiKey)
        self.apiKey = apiKey
        isConfigured = true
    }

    func removeConfiguration() throws {
        try keychainManager.deleteGeminiAPIKey()
        apiKey = nil
        isConfigured = false
    }

    // MARK: - Rate Limiting

    private func loadDailyRequestCount() {
        let defaults = UserDefaults.standard
        let savedDate = defaults.object(forKey: "aiLastRequestDate") as? Date
        let savedCount = defaults.integer(forKey: "aiDailyRequestCount")

        if let date = savedDate, Calendar.current.isDateInToday(date) {
            dailyRequestCount = savedCount
            lastRequestDate = date
        } else {
            dailyRequestCount = 0
            lastRequestDate = nil
        }
    }

    private func incrementRequestCount() {
        dailyRequestCount += 1
        lastRequestDate = Date()
        let defaults = UserDefaults.standard
        defaults.set(lastRequestDate, forKey: "aiLastRequestDate")
        defaults.set(dailyRequestCount, forKey: "aiDailyRequestCount")
    }

    func canMakeRequest() -> Bool {
        loadDailyRequestCount()
        return dailyRequestCount < maxDailyRequests
    }

    func remainingRequests() -> Int {
        loadDailyRequestCount()
        return max(0, maxDailyRequests - dailyRequestCount)
    }

    // MARK: - Themed Playlist Generation

    func generateThemedPlaylists(profile: MusicProfile) async throws -> [PlaylistSuggestion] {
        // Check cache first
        if let cached = loadCachedPlaylists(for: profile), !cached.cache.isExpired {
            return cached.suggestions
        }

        guard isConfigured, apiKey != nil else {
            throw GeminiError.notConfigured
        }

        guard canMakeRequest() else {
            throw GeminiError.dailyLimitReached
        }

        let prompt = """
        You are a music curator AI for the vibes app. Analyze this music profile and generate 4 unique themed playlist suggestions.

        Rules:
        1. Suggest real songs that exist on Spotify
        2. Include a mix of familiar tracks (70%) and discoveries (30%)
        3. Consider mood, tempo, and genre coherence
        4. Provide brief, insightful reasoning for each suggestion
        5. Keep themes creative but achievable

        User Profile:
        - Top Artists: \(profile.topArtists.joined(separator: ", "))
        - Top Tracks: \(profile.topTracks.joined(separator: ", "))
        - Genres: \(profile.genres.joined(separator: ", "))
        - Recently Played: \(profile.recentTracks.joined(separator: ", "))

        Generate playlists for different contexts (e.g., morning routine, workout, focus, late night, road trip, dinner party, study session, relaxation).

        Respond with ONLY valid JSON, no markdown or explanation:
        {
          "suggestions": [
            {
              "id": "unique-id",
              "theme": "string",
              "description": "1-2 sentences describing the vibe",
              "suggestedSongs": [
                {
                  "id": "unique-id",
                  "trackName": "string",
                  "artistName": "string",
                  "reason": "brief reason why this fits"
                }
              ],
              "moodTags": ["string"],
              "reasoning": "why this theme fits the user"
            }
          ]
        }

        Include exactly 15 songs per playlist. Keep responses concise.
        """

        let response = try await makeRequest(prompt: prompt)
        incrementRequestCount()

        guard let responseData = response.data(using: .utf8) else {
            throw GeminiError.invalidResponse
        }

        do {
            let playlistResponse = try JSONDecoder().decode(PlaylistSuggestionsResponse.self, from: responseData)
            // Cache the result
            saveCachedPlaylists(playlistResponse.suggestions, for: profile)
            return playlistResponse.suggestions
        } catch {
            print("JSON Decode Error: \(error)")
            print("Response was: \(response.prefix(500))")
            throw error
        }
    }

    // MARK: - Friend Blend Generation

    func generateFriendBlend(user1Profile: MusicProfile, user2Profile: MusicProfile, user2Name: String) async throws -> BlendResult {
        // Check cache first
        if let cached = loadCachedBlend(for: user1Profile, user2Profile: user2Profile), !cached.cache.isExpired {
            return cached.blend
        }

        guard isConfigured, apiKey != nil else {
            throw GeminiError.notConfigured
        }

        guard canMakeRequest() else {
            throw GeminiError.dailyLimitReached
        }

        let prompt = """
        You are a music curator AI that creates personalized music blends between two friends. Analyze both users' music preferences and recommend songs that would appeal to both of them.

        Rules:
        1. Suggest real songs that exist on Spotify
        2. Find the musical overlap and bridge different tastes
        3. Higher blend scores for songs both would definitely enjoy
        4. Lower scores for songs that bridge their tastes but might be new to one
        5. Be creative with the blend name based on their combined tastes

        User 1 (You) Profile:
        - Top Artists: \(user1Profile.topArtists.joined(separator: ", "))
        - Top Tracks: \(user1Profile.topTracks.joined(separator: ", "))
        - Genres: \(user1Profile.genres.joined(separator: ", "))

        User 2 (\(user2Name)) Profile:
        - Top Artists: \(user2Profile.topArtists.joined(separator: ", "))
        - Top Tracks: \(user2Profile.topTracks.joined(separator: ", "))
        - Genres: \(user2Profile.genres.joined(separator: ", "))

        Find songs that:
        1. Both users would enjoy (high blend score)
        2. Bridge their different tastes (medium blend score)
        3. Introduce crossover discoveries

        Respond with ONLY valid JSON, no markdown or explanation:
        {
          "blendName": "creative name for this blend based on their combined tastes",
          "recommendations": [
            {
              "id": "unique-id",
              "trackName": "string",
              "artistName": "string",
              "blendScore": 0.0-1.0,
              "user1Affinity": "why you would like this",
              "user2Affinity": "why \(user2Name) would like this"
            }
          ],
          "blendAnalysis": "brief analysis of their musical compatibility"
        }

        Suggest 15-20 songs sorted by blend score (highest first).
        """

        let response = try await makeRequest(prompt: prompt)
        incrementRequestCount()

        guard let responseData = response.data(using: .utf8) else {
            throw GeminiError.invalidResponse
        }

        let blendResult = try JSONDecoder().decode(BlendResult.self, from: responseData)
        saveCachedBlend(blendResult, for: user1Profile, user2Profile: user2Profile)
        return blendResult
    }

    // MARK: - Personalized Recommendations

    private let recommendationsCacheTTL: TimeInterval = 12 * 60 * 60 // 12 hours

    func generatePersonalizedRecommendations(profile: MusicProfile, count: Int = 10, avoidSongs: [String] = []) async throws -> (recommendations: [AIRecommendedSong], refreshReason: String) {
        // Only use cache for initial load (count >= 10) and no avoid list
        if count >= 10, avoidSongs.isEmpty, let cached = loadCachedRecommendations(for: profile), !cached.cache.isExpired {
            return (cached.recommendations, cached.refreshReason)
        }

        guard isConfigured, apiKey != nil else {
            throw GeminiError.notConfigured
        }

        guard canMakeRequest() else {
            throw GeminiError.dailyLimitReached
        }

        let songCount = max(3, min(count, 40)) // Between 3 and 40
        let avoidSection = avoidSongs.isEmpty ? "" : """

        IMPORTANT - Do NOT suggest any of these songs (the user has already dismissed them):
        \(avoidSongs.joined(separator: "\n"))

        """
        let prompt = """
        You are a music discovery AI for the vibes app. Analyze this user's music profile and recommend new songs they would love but might not have discovered yet.

        Rules:
        1. Suggest REAL songs that exist on Spotify
        2. Focus on discovery - suggest songs the user probably hasn't heard
        3. Mix of new releases (last 2 years) and hidden gems (older but underrated)
        4. Each recommendation should have a clear reason why it fits their taste
        5. Connect each recommendation to something specific in their profile (artist, genre, or track)
        6. High match scores (0.85-1.0) for very close matches, lower (0.6-0.84) for exploratory picks
        \(avoidSection)
        User Profile:
        - Top Artists: \(profile.topArtists.joined(separator: ", "))
        - Top Tracks: \(profile.topTracks.joined(separator: ", "))
        - Genres: \(profile.genres.joined(separator: ", "))
        - Recently Played: \(profile.recentTracks.joined(separator: ", "))

        Respond with ONLY valid JSON, no markdown or explanation:
        {
          "recommendations": [
            {
              "id": "unique-id",
              "trackName": "string",
              "artistName": "string",
              "reason": "brief personal reason why they'd love this (1 sentence)",
              "matchScore": 0.0-1.0,
              "basedOn": "Because you like [specific artist/genre/track from their profile]"
            }
          ],
          "refreshReason": "brief summary of what's driving these recommendations"
        }

        Recommend exactly \(songCount) songs, sorted by match score (highest first).
        """

        let response = try await makeRequest(prompt: prompt)
        incrementRequestCount()

        guard let responseData = response.data(using: .utf8) else {
            throw GeminiError.invalidResponse
        }

        do {
            let recommendationsResponse = try JSONDecoder().decode(AIRecommendationsResponse.self, from: responseData)
            // Cache the result
            saveCachedRecommendations(recommendationsResponse.recommendations, refreshReason: recommendationsResponse.refreshReason, for: profile)
            return (recommendationsResponse.recommendations, recommendationsResponse.refreshReason)
        } catch {
            print("JSON Decode Error: \(error)")
            print("Response was: \(response.prefix(500))")
            throw error
        }
    }

    private func loadCachedRecommendations(for profile: MusicProfile) -> CachedAIRecommendations? {
        let hash = profileHash(profile)
        let key = "aiRecs_\(hash)"

        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        return try? JSONDecoder().decode(CachedAIRecommendations.self, from: data)
    }

    private func saveCachedRecommendations(_ recommendations: [AIRecommendedSong], refreshReason: String, for profile: MusicProfile) {
        let hash = profileHash(profile)
        let key = "aiRecs_\(hash)"

        let cache = CachedRecommendation(
            timestamp: Date(),
            profileHash: hash,
            expiresAt: Date().addingTimeInterval(recommendationsCacheTTL)
        )

        let cached = CachedAIRecommendations(cache: cache, recommendations: recommendations, refreshReason: refreshReason)

        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: - API Request

    private func makeRequest(prompt: String) async throws -> String {
        guard let apiKey = apiKey else {
            throw GeminiError.notConfigured
        }

        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw GeminiError.networkError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let geminiRequest = GeminiRequest(
            contents: [
                GeminiContent(parts: [GeminiPart(text: prompt)])
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.7,
                maxOutputTokens: 8192
            )
        )

        request.httpBody = try JSONEncoder().encode(geminiRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.networkError("Invalid response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 400:
            if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                throw GeminiError.networkError(errorResponse.error.message)
            }
            throw GeminiError.invalidAPIKey
        case 403:
            throw GeminiError.invalidAPIKey
        case 429:
            throw GeminiError.rateLimitExceeded
        default:
            if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                throw GeminiError.networkError(errorResponse.error.message)
            }
            throw GeminiError.networkError("Request failed with status \(httpResponse.statusCode)")
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let content = geminiResponse.candidates?.first?.content.parts.first?.text else {
            throw GeminiError.invalidResponse
        }

        // Clean up response - remove markdown code blocks if present
        return cleanJsonResponse(content)
    }

    private func cleanJsonResponse(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove markdown code blocks
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }

        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }

        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        // Find the JSON object - look for first { and last }
        if let startIndex = cleaned.firstIndex(of: "{"),
           let endIndex = cleaned.lastIndex(of: "}") {
            cleaned = String(cleaned[startIndex...endIndex])
        }

        return cleaned
    }

    // MARK: - Caching

    private func profileHash(_ profile: MusicProfile) -> String {
        let data = (profile.topArtists + profile.topTracks).joined(separator: "|")
        let hash = SHA256.hash(data: Data(data.utf8))
        return hash.compactMap { String(format: "%02x", $0) }.joined().prefix(16).description
    }

    private func blendHash(_ profile1: MusicProfile, _ profile2: MusicProfile) -> String {
        let data1 = profileHash(profile1)
        let data2 = profileHash(profile2)
        let sorted = [data1, data2].sorted().joined(separator: "_")
        return sorted
    }

    private func loadCachedPlaylists(for profile: MusicProfile) -> CachedPlaylistSuggestions? {
        let hash = profileHash(profile)
        let key = "playlist_\(hash)"

        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        return try? JSONDecoder().decode(CachedPlaylistSuggestions.self, from: data)
    }

    private func saveCachedPlaylists(_ suggestions: [PlaylistSuggestion], for profile: MusicProfile) {
        let hash = profileHash(profile)
        let key = "playlist_\(hash)"

        let cache = CachedRecommendation(
            timestamp: Date(),
            profileHash: hash,
            expiresAt: Date().addingTimeInterval(playlistCacheTTL)
        )

        let cached = CachedPlaylistSuggestions(cache: cache, suggestions: suggestions)

        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadCachedBlend(for profile1: MusicProfile, user2Profile profile2: MusicProfile) -> CachedBlendResult? {
        let hash = blendHash(profile1, profile2)
        let key = "blend_\(hash)"

        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        return try? JSONDecoder().decode(CachedBlendResult.self, from: data)
    }

    private func saveCachedBlend(_ blend: BlendResult, for profile1: MusicProfile, user2Profile profile2: MusicProfile) {
        let hash = blendHash(profile1, profile2)
        let key = "blend_\(hash)"

        let cache = CachedRecommendation(
            timestamp: Date(),
            profileHash: hash,
            expiresAt: Date().addingTimeInterval(blendCacheTTL)
        )

        let cached = CachedBlendResult(cache: cache, blend: blend)

        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func clearRecommendationsCache(for profile: MusicProfile) {
        let hash = profileHash(profile)
        let key = "aiRecs_\(hash)"
        UserDefaults.standard.removeObject(forKey: key)
    }

    func clearCache() {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys.filter {
            $0.hasPrefix("playlist_") || $0.hasPrefix("blend_") || $0.hasPrefix("aiRecs_")
        }
        keys.forEach { defaults.removeObject(forKey: $0) }
    }

    // Clear all user data (for account deletion)
    func clearUserData() {
        // Remove API key from Keychain
        try? keychainManager.deleteGeminiAPIKey()
        apiKey = nil
        isConfigured = false

        // Clear rate limiting data
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "aiLastRequestDate")
        defaults.removeObject(forKey: "aiDailyRequestCount")
        dailyRequestCount = 0
        lastRequestDate = nil

        // Clear cache
        clearCache()
    }
}

// MARK: - Gemini API Models

struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double
    let maxOutputTokens: Int
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

struct GeminiErrorResponse: Codable {
    let error: GeminiErrorDetail
}

struct GeminiErrorDetail: Codable {
    let message: String
    let status: String?
}

// MARK: - Error Types

enum GeminiError: LocalizedError {
    case notConfigured
    case invalidAPIKey
    case rateLimitExceeded
    case quotaExceeded
    case dailyLimitReached
    case networkError(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Gemini API key not configured. Add your key in Settings > AI Features."
        case .invalidAPIKey:
            return "Invalid Gemini API key. Please check your key in Settings."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        case .quotaExceeded:
            return "API quota exceeded. Check your Google Cloud billing."
        case .dailyLimitReached:
            return "Daily AI generation limit reached. Try again tomorrow."
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from AI service."
        }
    }
}
