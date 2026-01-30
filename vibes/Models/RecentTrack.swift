import Foundation

struct RecentTrack: Identifiable, Hashable {
    let id: String
    let track: UnifiedTrack
    let playedAt: Date

    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: playedAt, relativeTo: Date())
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RecentTrack, rhs: RecentTrack) -> Bool {
        lhs.id == rhs.id
    }
}
