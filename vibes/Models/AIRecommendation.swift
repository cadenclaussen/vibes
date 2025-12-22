import Foundation

// MARK: - Music Profile (Input to AI)

struct MusicProfile: Codable {
    let topArtists: [String]
    let topTracks: [String]
    let genres: [String]
    let recentTracks: [String]
    let musicTasteTags: [String]

    static func from(
        artists: [Artist],
        tracks: [Track],
        recentTracks: [Track],
        tags: [String] = []
    ) -> MusicProfile {
        let artistNames = artists.prefix(10).map { $0.name }
        let trackNames = tracks.prefix(20).map { "\($0.name) by \($0.artists.first?.name ?? "")" }
        let recentNames = recentTracks.prefix(20).map { "\($0.name) by \($0.artists.first?.name ?? "")" }
        let allGenres = artists.compactMap { $0.genres }.flatMap { $0 }
        let uniqueGenres = Array(Set(allGenres)).prefix(10)

        return MusicProfile(
            topArtists: Array(artistNames),
            topTracks: Array(trackNames),
            genres: Array(uniqueGenres),
            recentTracks: Array(recentNames),
            musicTasteTags: tags
        )
    }
}

// MARK: - Playlist Suggestion (AI Output)

struct PlaylistSuggestion: Codable, Identifiable {
    let id: String
    let theme: String
    let description: String
    let suggestedSongs: [SongSuggestion]
    let moodTags: [String]
    let reasoning: String

    init(
        id: String = UUID().uuidString,
        theme: String,
        description: String,
        suggestedSongs: [SongSuggestion],
        moodTags: [String],
        reasoning: String
    ) {
        self.id = id
        self.theme = theme
        self.description = description
        self.suggestedSongs = suggestedSongs
        self.moodTags = moodTags
        self.reasoning = reasoning
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        self.theme = try container.decode(String.self, forKey: .theme)
        self.description = try container.decode(String.self, forKey: .description)
        self.suggestedSongs = (try? container.decode([SongSuggestion].self, forKey: .suggestedSongs)) ?? []
        self.moodTags = (try? container.decode([String].self, forKey: .moodTags)) ?? []
        self.reasoning = (try? container.decode(String.self, forKey: .reasoning)) ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case id, theme, description, suggestedSongs, moodTags, reasoning
    }
}

struct SongSuggestion: Codable, Identifiable {
    let id: String
    let trackName: String
    let artistName: String
    let reason: String

    var searchQuery: String {
        "\(trackName) \(artistName)"
    }

    init(
        id: String = UUID().uuidString,
        trackName: String,
        artistName: String,
        reason: String
    ) {
        self.id = id
        self.trackName = trackName
        self.artistName = artistName
        self.reason = reason
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        self.trackName = try container.decode(String.self, forKey: .trackName)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        self.reason = (try? container.decode(String.self, forKey: .reason)) ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case id, trackName, artistName, reason
    }
}

// MARK: - Friend Blend (AI Output)

struct BlendRecommendation: Codable, Identifiable {
    let id: String
    let trackName: String
    let artistName: String
    let blendScore: Double
    let user1Affinity: String
    let user2Affinity: String

    var searchQuery: String {
        "\(trackName) \(artistName)"
    }

    init(
        id: String = UUID().uuidString,
        trackName: String,
        artistName: String,
        blendScore: Double,
        user1Affinity: String,
        user2Affinity: String
    ) {
        self.id = id
        self.trackName = trackName
        self.artistName = artistName
        self.blendScore = blendScore
        self.user1Affinity = user1Affinity
        self.user2Affinity = user2Affinity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        self.trackName = try container.decode(String.self, forKey: .trackName)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        // Handle blendScore as either Double or Int
        if let doubleScore = try? container.decode(Double.self, forKey: .blendScore) {
            self.blendScore = doubleScore
        } else if let intScore = try? container.decode(Int.self, forKey: .blendScore) {
            self.blendScore = Double(intScore)
        } else {
            self.blendScore = 0.5
        }
        self.user1Affinity = (try? container.decode(String.self, forKey: .user1Affinity)) ?? ""
        self.user2Affinity = (try? container.decode(String.self, forKey: .user2Affinity)) ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case id, trackName, artistName, blendScore, user1Affinity, user2Affinity
    }
}

struct BlendResult: Codable {
    let blendName: String
    let recommendations: [BlendRecommendation]
    let blendAnalysis: String
}

// MARK: - API Response Wrappers

struct PlaylistSuggestionsResponse: Codable {
    let suggestions: [PlaylistSuggestion]
}

// MARK: - Cache Entry

struct CachedRecommendation: Codable {
    let timestamp: Date
    let profileHash: String
    let expiresAt: Date

    var isExpired: Bool {
        Date() >= expiresAt
    }
}

struct CachedPlaylistSuggestions: Codable {
    let cache: CachedRecommendation
    let suggestions: [PlaylistSuggestion]
}

struct CachedBlendResult: Codable {
    let cache: CachedRecommendation
    let blend: BlendResult
}

// MARK: - OpenAI Error

enum OpenAIError: LocalizedError {
    case notConfigured
    case invalidAPIKey
    case rateLimitExceeded
    case invalidResponse
    case networkError(String)
    case quotaExceeded
    case dailyLimitReached

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "OpenAI API key not configured. Add your key in Settings."
        case .invalidAPIKey:
            return "Invalid API key. Please check your OpenAI settings."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again in a few minutes."
        case .invalidResponse:
            return "Invalid response from AI. Please try again."
        case .networkError(let message):
            return message
        case .quotaExceeded:
            return "API quota exceeded. Please check your OpenAI account."
        case .dailyLimitReached:
            return "Daily AI generation limit reached. Try again tomorrow."
        }
    }
}

// MARK: - OpenAI API Models

struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIChatMessage]
    let temperature: Double
    let maxTokens: Int
    let responseFormat: ResponseFormat?

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case responseFormat = "response_format"
    }

    struct ResponseFormat: Codable {
        let type: String
    }
}

struct OpenAIChatMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIChatResponse: Codable {
    let id: String
    let choices: [Choice]
    let usage: Usage?

    struct Choice: Codable {
        let message: Message
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }

        struct Message: Codable {
            let role: String
            let content: String
        }
    }

    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

struct OpenAIErrorResponse: Codable {
    let error: ErrorDetail

    struct ErrorDetail: Codable {
        let message: String
        let type: String
        let code: String?
    }
}

// MARK: - Resolved Track (Spotify Track with AI Suggestion)

struct ResolvedSong: Identifiable {
    let id: String
    let suggestion: SongSuggestion
    let track: Track?
    let previewUrl: String?

    var isResolved: Bool {
        track != nil
    }
}

struct ResolvedBlendSong: Identifiable {
    let id: String
    let recommendation: BlendRecommendation
    let track: Track?
    let previewUrl: String?

    var isResolved: Bool {
        track != nil
    }
}

// MARK: - AI Personalized Recommendation

struct AIRecommendedSong: Codable, Identifiable {
    let id: String
    let trackName: String
    let artistName: String
    let reason: String
    let matchScore: Double
    let basedOn: String

    var searchQuery: String {
        "\(trackName) \(artistName)"
    }

    init(
        id: String = UUID().uuidString,
        trackName: String,
        artistName: String,
        reason: String,
        matchScore: Double,
        basedOn: String
    ) {
        self.id = id
        self.trackName = trackName
        self.artistName = artistName
        self.reason = reason
        self.matchScore = matchScore
        self.basedOn = basedOn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        self.trackName = try container.decode(String.self, forKey: .trackName)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        self.reason = (try? container.decode(String.self, forKey: .reason)) ?? ""
        if let doubleScore = try? container.decode(Double.self, forKey: .matchScore) {
            self.matchScore = doubleScore
        } else if let intScore = try? container.decode(Int.self, forKey: .matchScore) {
            self.matchScore = Double(intScore)
        } else {
            self.matchScore = 0.8
        }
        self.basedOn = (try? container.decode(String.self, forKey: .basedOn)) ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case id, trackName, artistName, reason, matchScore, basedOn
    }
}

struct AIRecommendationsResponse: Codable {
    let recommendations: [AIRecommendedSong]
    let refreshReason: String
}

struct CachedAIRecommendations: Codable {
    let cache: CachedRecommendation
    let recommendations: [AIRecommendedSong]
    let refreshReason: String
}

struct ResolvedAIRecommendation: Identifiable {
    let id: String
    let recommendation: AIRecommendedSong
    let track: Track?
    let previewUrl: String?

    var isResolved: Bool {
        track != nil
    }
}
