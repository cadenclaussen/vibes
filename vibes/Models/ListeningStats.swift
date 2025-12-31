import Foundation

struct ListeningStats: Codable {
    var topArtists: [UnifiedArtist]
    var topTracks: [UnifiedTrack]
    var topGenres: [GenreStat]
    var recentlyPlayed: [UnifiedTrack]
    var totalMinutesListened: Int?
    var timeRange: TimeRange

    enum TimeRange: String, Codable, CaseIterable {
        case shortTerm = "short_term"  // ~4 weeks
        case mediumTerm = "medium_term" // ~6 months
        case longTerm = "long_term"    // All time

        var displayName: String {
            switch self {
            case .shortTerm: return "This Month"
            case .mediumTerm: return "Last 6 Months"
            case .longTerm: return "All Time"
            }
        }
    }

    struct GenreStat: Codable, Identifiable {
        var id: String { genre }
        var genre: String
        var count: Int
        var percentage: Double

        init(genre: String, count: Int, percentage: Double) {
            self.genre = genre
            self.count = count
            self.percentage = percentage
        }
    }

    init(
        topArtists: [UnifiedArtist] = [],
        topTracks: [UnifiedTrack] = [],
        topGenres: [GenreStat] = [],
        recentlyPlayed: [UnifiedTrack] = [],
        totalMinutesListened: Int? = nil,
        timeRange: TimeRange = .shortTerm
    ) {
        self.topArtists = topArtists
        self.topTracks = topTracks
        self.topGenres = topGenres
        self.recentlyPlayed = recentlyPlayed
        self.totalMinutesListened = totalMinutesListened
        self.timeRange = timeRange
    }
}
