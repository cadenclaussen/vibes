//
//  LocalAchievementStats.swift
//  vibes
//
//  Local stats tracking for achievements.
//

import Foundation
import FirebaseAuth

class LocalAchievementStats {
    static let shared = LocalAchievementStats()
    private let defaults = UserDefaults.standard
    private var currentUserId: String?

    func setCurrentUser(_ userId: String?) {
        currentUserId = userId
    }

    private func key(_ base: String) -> String {
        if let userId = currentUserId {
            return "\(base)_\(userId)"
        }
        if let firebaseUser = FirebaseAuth.Auth.auth().currentUser?.uid {
            currentUserId = firebaseUser
            return "\(base)_\(firebaseUser)"
        }
        return "\(base)_no_user"
    }

    private enum BaseKeys {
        static let songsAddedToPlaylists = "achievement_songsAddedToPlaylists"
        static let previewPlays = "achievement_previewPlays"
        static let artistsViewed = "achievement_artistsViewed"
        static let albumsViewed = "achievement_albumsViewed"
        static let searchQueries = "achievement_searchQueries"
        static let reactionsGiven = "achievement_reactionsGiven"
        static let aiPlaylistsCreated = "achievement_aiPlaylistsCreated"
        static let blendsCreated = "achievement_blendsCreated"
        static let uniqueArtistsShared = "achievement_uniqueArtistsShared"
        static let friendRequestsSent = "achievement_friendRequestsSent"
        static let messagesSent = "achievement_messagesSent"
        static let songMessagesSent = "achievement_songMessagesSent"
        static let conversationsStarted = "achievement_conversationsStarted"
        static let hasMidnightDrop = "achievement_hasMidnightDrop"
        static let hasEarlyBird = "achievement_hasEarlyBird"
        static let hasFridayFeeling = "achievement_hasFridayFeeling"
        static let hasNewYearsVibe = "achievement_hasNewYearsVibe"
        static let hasBoomerang = "achievement_hasBoomerang"
        static let hasSameWavelength = "achievement_hasSameWavelength"
        static let hasSoulmate = "achievement_hasSoulmate"
        static let hasGenreHopper = "achievement_hasGenreHopper"
        static let hasDeepCut = "achievement_hasDeepCut"
        static let fridaySongsDate = "achievement_fridaySongsDate"
        static let fridaySongsCount = "achievement_fridaySongsCount"
        static let receivedSongTrackIds = "achievement_receivedSongTrackIds"
        static let songsPassedAlong = "achievement_songsPassedAlong"
        static let monthlyPlayCounts = "achievement_monthlyPlayCounts"
        static let monthlyPlayCountsMonth = "achievement_monthlyPlayCountsMonth"
        static let hasContrarian = "achievement_hasContrarian"
        static let removedSongs = "achievement_removedSongs"
        static let hasResurrection = "achievement_hasResurrection"
    }

    // MARK: - Unique Artists Tracking

    var uniqueArtistsShared: [String] {
        get { defaults.stringArray(forKey: key(BaseKeys.uniqueArtistsShared)) ?? [] }
        set { defaults.set(newValue, forKey: key(BaseKeys.uniqueArtistsShared)) }
    }

    var uniqueArtistsCount: Int { uniqueArtistsShared.count }

    func trackArtistShared(_ artistName: String) {
        let normalized = artistName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        var artists = uniqueArtistsShared
        if !artists.contains(normalized) {
            artists.append(normalized)
            uniqueArtistsShared = artists
        }
    }

    // MARK: - Basic Stats

    var songsAddedToPlaylists: Int {
        get { defaults.integer(forKey: key(BaseKeys.songsAddedToPlaylists)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.songsAddedToPlaylists)) }
    }

    var previewPlays: Int {
        get { defaults.integer(forKey: key(BaseKeys.previewPlays)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.previewPlays)) }
    }

    var artistsViewed: Int {
        get { defaults.integer(forKey: key(BaseKeys.artistsViewed)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.artistsViewed)) }
    }

    var albumsViewed: Int {
        get { defaults.integer(forKey: key(BaseKeys.albumsViewed)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.albumsViewed)) }
    }

    var searchQueries: Int {
        get { defaults.integer(forKey: key(BaseKeys.searchQueries)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.searchQueries)) }
    }

    var reactionsGiven: Int {
        get { defaults.integer(forKey: key(BaseKeys.reactionsGiven)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.reactionsGiven)) }
    }

    var aiPlaylistsCreated: Int {
        get { defaults.integer(forKey: key(BaseKeys.aiPlaylistsCreated)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.aiPlaylistsCreated)) }
    }

    var blendsCreated: Int {
        get { defaults.integer(forKey: key(BaseKeys.blendsCreated)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.blendsCreated)) }
    }

    var friendRequestsSent: Int {
        get { defaults.integer(forKey: key(BaseKeys.friendRequestsSent)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.friendRequestsSent)) }
    }

    var messagesSent: Int {
        get { defaults.integer(forKey: key(BaseKeys.messagesSent)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.messagesSent)) }
    }

    var songMessagesSent: Int {
        get { defaults.integer(forKey: key(BaseKeys.songMessagesSent)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.songMessagesSent)) }
    }

    // MARK: - Conversations Tracking

    private var conversationFriendIds: [String] {
        get { defaults.stringArray(forKey: key(BaseKeys.conversationsStarted)) ?? [] }
        set { defaults.set(newValue, forKey: key(BaseKeys.conversationsStarted)) }
    }

    var conversationsCount: Int { conversationFriendIds.count }

    func trackConversation(with friendId: String) {
        var ids = conversationFriendIds
        if !ids.contains(friendId) {
            ids.append(friendId)
            conversationFriendIds = ids
        }
    }

    // MARK: - Secret Achievement Triggers

    var hasMidnightDrop: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasMidnightDrop)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasMidnightDrop)) }
    }

    var hasEarlyBird: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasEarlyBird)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasEarlyBird)) }
    }

    var hasFridayFeeling: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasFridayFeeling)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasFridayFeeling)) }
    }

    var hasNewYearsVibe: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasNewYearsVibe)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasNewYearsVibe)) }
    }

    var hasBoomerang: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasBoomerang)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasBoomerang)) }
    }

    var hasSameWavelength: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasSameWavelength)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasSameWavelength)) }
    }

    var hasSoulmate: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasSoulmate)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasSoulmate)) }
    }

    var hasGenreHopper: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasGenreHopper)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasGenreHopper)) }
    }

    var hasDeepCut: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasDeepCut)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasDeepCut)) }
    }

    // MARK: - Butterfly Effect Tracking

    private var receivedSongTrackIds: Set<String> {
        get {
            let arr = defaults.stringArray(forKey: key(BaseKeys.receivedSongTrackIds)) ?? []
            return Set(arr)
        }
        set { defaults.set(Array(newValue), forKey: key(BaseKeys.receivedSongTrackIds)) }
    }

    var songsPassedAlong: Int {
        get { defaults.integer(forKey: key(BaseKeys.songsPassedAlong)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.songsPassedAlong)) }
    }

    func trackReceivedSong(trackId: String) {
        var ids = receivedSongTrackIds
        ids.insert(trackId)
        receivedSongTrackIds = ids
    }

    func checkButterflyEffect(trackId: String) {
        if receivedSongTrackIds.contains(trackId) {
            songsPassedAlong += 1
            checkLocalAchievements()
        }
    }

    // MARK: - The Contrarian Tracking

    private var monthlyPlayCounts: [String: Int] {
        get {
            guard let data = defaults.data(forKey: key(BaseKeys.monthlyPlayCounts)),
                  let dict = try? JSONDecoder().decode([String: Int].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: key(BaseKeys.monthlyPlayCounts))
            }
        }
    }

    private var monthlyPlayCountsMonth: Int {
        get { defaults.integer(forKey: key(BaseKeys.monthlyPlayCountsMonth)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.monthlyPlayCountsMonth)) }
    }

    var hasContrarian: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasContrarian)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasContrarian)) }
    }

    func trackSongPlay(trackId: String, popularity: Int) {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())

        if monthlyPlayCountsMonth != currentMonth {
            monthlyPlayCounts = [:]
            monthlyPlayCountsMonth = currentMonth
        }

        var counts = monthlyPlayCounts
        counts[trackId, default: 0] += 1
        monthlyPlayCounts = counts

        if let topTrack = counts.max(by: { $0.value < $1.value }),
           topTrack.key == trackId,
           topTrack.value >= 10,
           popularity < 20 {
            hasContrarian = true
            checkLocalAchievements()
        }
    }

    // MARK: - The Resurrection Tracking

    private var removedSongs: [String: Date] {
        get {
            guard let data = defaults.data(forKey: key(BaseKeys.removedSongs)),
                  let dict = try? JSONDecoder().decode([String: Date].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: key(BaseKeys.removedSongs))
            }
        }
    }

    var hasResurrection: Bool {
        get { defaults.bool(forKey: key(BaseKeys.hasResurrection)) }
        set { defaults.set(newValue, forKey: key(BaseKeys.hasResurrection)) }
    }

    func trackSongRemoved(trackId: String) {
        var removed = removedSongs
        removed[trackId] = Date()
        removedSongs = removed
    }

    func checkResurrection(trackId: String) {
        if let removalDate = removedSongs[trackId] {
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            if removalDate < sixMonthsAgo {
                hasResurrection = true
                var removed = removedSongs
                removed.removeValue(forKey: trackId)
                removedSongs = removed
                checkLocalAchievements()
            }
        }
    }

    // MARK: - Time-Based Tracking

    func trackSongSharedOnFriday() {
        let calendar = Calendar.current
        let now = Date()
        guard calendar.component(.weekday, from: now) == 6 else { return }

        let today = calendar.startOfDay(for: now)
        let storedDate = defaults.object(forKey: key(BaseKeys.fridaySongsDate)) as? Date

        if let storedDate = storedDate, calendar.isDate(storedDate, inSameDayAs: today) {
            let count = defaults.integer(forKey: key(BaseKeys.fridaySongsCount)) + 1
            defaults.set(count, forKey: key(BaseKeys.fridaySongsCount))
            if count >= 10 {
                hasFridayFeeling = true
            }
        } else {
            defaults.set(today, forKey: key(BaseKeys.fridaySongsDate))
            defaults.set(1, forKey: key(BaseKeys.fridaySongsCount))
        }
    }

    func checkTimeBasedAchievements() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)

        if hour < 5 {
            hasEarlyBird = true
        }

        if hour == 0 && minute == 0 {
            hasMidnightDrop = true
        }

        if month == 1 && day == 1 {
            hasNewYearsVibe = true
        }
    }

    // MARK: - Clear All Data

    func clearAllData() {
        songsAddedToPlaylists = 0
        previewPlays = 0
        artistsViewed = 0
        albumsViewed = 0
        searchQueries = 0
        reactionsGiven = 0
        aiPlaylistsCreated = 0
        blendsCreated = 0
        friendRequestsSent = 0
        messagesSent = 0
        songMessagesSent = 0
        uniqueArtistsShared = []
        conversationFriendIds = []
        hasMidnightDrop = false
        hasEarlyBird = false
        hasFridayFeeling = false
        hasNewYearsVibe = false
        hasBoomerang = false
        hasSameWavelength = false
        hasSoulmate = false
        hasGenreHopper = false
        hasDeepCut = false
        defaults.removeObject(forKey: key(BaseKeys.fridaySongsDate))
        defaults.removeObject(forKey: key(BaseKeys.fridaySongsCount))
        songsPassedAlong = 0
        defaults.removeObject(forKey: key(BaseKeys.receivedSongTrackIds))
        defaults.removeObject(forKey: key(BaseKeys.monthlyPlayCounts))
        monthlyPlayCountsMonth = 0
        hasContrarian = false
        defaults.removeObject(forKey: key(BaseKeys.removedSongs))
        hasResurrection = false
        cachedSongsShared = 0
        cachedPlaylistsShared = 0
        cachedFriendsCount = 0
        cachedMaxVibestreak = 0
        cachedReactionsReceived = 0
        cachedGenresCount = 0
        cachedIsSpotifyConnected = false
        cachedIsAIConfigured = false
        currentUserId = nil
    }

    // MARK: - Achievement Checking

    @MainActor
    func checkLocalAchievements() {
        var stats = AchievementStats()
        stats.loadLocalStats()
        stats.loadCachedFirestoreStats()
        let achievements = stats.buildAchievements()
        AchievementNotificationService.shared.checkForNewAchievements(achievements)
    }

    @MainActor
    func loadAndCacheFirestoreStats() async {
        guard let userId = currentUserId ?? FirebaseAuth.Auth.auth().currentUser?.uid else {
            return
        }

        do {
            let firestoreStats = try await FirestoreService.shared.getAchievementStats(userId: userId)
            let profile = try? await FirestoreService.shared.getUserProfile(userId: userId)
            let genresCount = profile?.musicTasteTags.count ?? 0
            let isSpotifyConnected = SpotifyService.shared.isAuthenticated
            let isAIConfigured = !(UserDefaults.standard.string(forKey: "gemini_api_key") ?? "").isEmpty

            cacheFirestoreStats(
                songsShared: firestoreStats.songsShared,
                playlistsShared: firestoreStats.playlistsShared,
                friendsCount: firestoreStats.friendsCount,
                maxVibestreak: firestoreStats.maxVibestreak,
                reactionsReceived: firestoreStats.reactionsReceived,
                genresCount: genresCount,
                isSpotifyConnected: isSpotifyConnected,
                isAIConfigured: isAIConfigured
            )

            var stats = AchievementStats()
            stats.songsShared = firestoreStats.songsShared
            stats.playlistsShared = firestoreStats.playlistsShared
            stats.friendsCount = firestoreStats.friendsCount
            stats.maxVibestreak = firestoreStats.maxVibestreak
            stats.reactionsReceived = firestoreStats.reactionsReceived
            stats.genresCount = genresCount
            stats.isSpotifyConnected = isSpotifyConnected
            stats.isAIConfigured = isAIConfigured
            stats.loadLocalStats()

            let achievements = stats.buildAchievements()
            AchievementNotificationService.shared.syncAchievementsOnSignIn(achievements)
        } catch {
            print("Failed to load Firestore stats for achievements: \(error)")
        }
    }

    // MARK: - Cached Firestore Stats

    private enum CachedFirestoreKeys {
        static let songsShared = "cached_firestore_songsShared"
        static let playlistsShared = "cached_firestore_playlistsShared"
        static let friendsCount = "cached_firestore_friendsCount"
        static let maxVibestreak = "cached_firestore_maxVibestreak"
        static let reactionsReceived = "cached_firestore_reactionsReceived"
        static let genresCount = "cached_firestore_genresCount"
        static let isSpotifyConnected = "cached_firestore_isSpotifyConnected"
        static let isAIConfigured = "cached_firestore_isAIConfigured"
    }

    var cachedSongsShared: Int {
        get { defaults.integer(forKey: key(CachedFirestoreKeys.songsShared)) }
        set { defaults.set(newValue, forKey: key(CachedFirestoreKeys.songsShared)) }
    }

    var cachedPlaylistsShared: Int {
        get { defaults.integer(forKey: key(CachedFirestoreKeys.playlistsShared)) }
        set { defaults.set(newValue, forKey: key(CachedFirestoreKeys.playlistsShared)) }
    }

    var cachedFriendsCount: Int {
        get { defaults.integer(forKey: key(CachedFirestoreKeys.friendsCount)) }
        set { defaults.set(newValue, forKey: key(CachedFirestoreKeys.friendsCount)) }
    }

    var cachedMaxVibestreak: Int {
        get { defaults.integer(forKey: key(CachedFirestoreKeys.maxVibestreak)) }
        set { defaults.set(newValue, forKey: key(CachedFirestoreKeys.maxVibestreak)) }
    }

    var cachedReactionsReceived: Int {
        get { defaults.integer(forKey: key(CachedFirestoreKeys.reactionsReceived)) }
        set { defaults.set(newValue, forKey: key(CachedFirestoreKeys.reactionsReceived)) }
    }

    var cachedGenresCount: Int {
        get { defaults.integer(forKey: key(CachedFirestoreKeys.genresCount)) }
        set { defaults.set(newValue, forKey: key(CachedFirestoreKeys.genresCount)) }
    }

    var cachedIsSpotifyConnected: Bool {
        get { defaults.bool(forKey: key(CachedFirestoreKeys.isSpotifyConnected)) }
        set { defaults.set(newValue, forKey: key(CachedFirestoreKeys.isSpotifyConnected)) }
    }

    var cachedIsAIConfigured: Bool {
        get { defaults.bool(forKey: key(CachedFirestoreKeys.isAIConfigured)) }
        set { defaults.set(newValue, forKey: key(CachedFirestoreKeys.isAIConfigured)) }
    }

    func cacheFirestoreStats(
        songsShared: Int,
        playlistsShared: Int,
        friendsCount: Int,
        maxVibestreak: Int,
        reactionsReceived: Int,
        genresCount: Int,
        isSpotifyConnected: Bool,
        isAIConfigured: Bool
    ) {
        cachedSongsShared = songsShared
        cachedPlaylistsShared = playlistsShared
        cachedFriendsCount = friendsCount
        cachedMaxVibestreak = maxVibestreak
        cachedReactionsReceived = reactionsReceived
        cachedGenresCount = genresCount
        cachedIsSpotifyConnected = isSpotifyConnected
        cachedIsAIConfigured = isAIConfigured
    }
}

// MARK: - Achievement Stats

struct AchievementStats {
    var songsShared: Int = 0
    var uniqueArtistsShared: Int = 0
    var friendsCount: Int = 0
    var friendRequestsSent: Int = 0
    var blendsCreated: Int = 0
    var maxVibestreak: Int = 0
    var isSpotifyConnected: Bool = false
    var playlistsShared: Int = 0
    var genresCount: Int = 0
    var songsAddedToPlaylists: Int = 0
    var messagesSent: Int = 0
    var conversationsCount: Int = 0
    var songMessagesSent: Int = 0
    var reactionsGiven: Int = 0
    var reactionsReceived: Int = 0
    var isAIConfigured: Bool = false
    var aiPlaylistsCreated: Int = 0
    var previewPlays: Int = 0
    var artistsViewed: Int = 0
    var albumsViewed: Int = 0
    var searchQueries: Int = 0

    var hasMidnightDrop: Bool = false
    var hasEarlyBird: Bool = false
    var hasFridayFeeling: Bool = false
    var hasNewYearsVibe: Bool = false
    var hasBoomerang: Bool = false
    var hasSameWavelength: Bool = false
    var hasSoulmate: Bool = false
    var hasGenreHopper: Bool = false
    var hasDeepCut: Bool = false

    var songsPassedAlong: Int = 0
    var hasContrarian: Bool = false
    var hasResurrection: Bool = false

    mutating func loadLocalStats() {
        let local = LocalAchievementStats.shared
        songsAddedToPlaylists = local.songsAddedToPlaylists
        previewPlays = local.previewPlays
        artistsViewed = local.artistsViewed
        albumsViewed = local.albumsViewed
        searchQueries = local.searchQueries
        reactionsGiven = local.reactionsGiven
        aiPlaylistsCreated = local.aiPlaylistsCreated
        blendsCreated = local.blendsCreated
        uniqueArtistsShared = local.uniqueArtistsCount
        friendRequestsSent = local.friendRequestsSent
        messagesSent = local.messagesSent
        songMessagesSent = local.songMessagesSent
        conversationsCount = local.conversationsCount
        hasMidnightDrop = local.hasMidnightDrop
        hasEarlyBird = local.hasEarlyBird
        hasFridayFeeling = local.hasFridayFeeling
        hasNewYearsVibe = local.hasNewYearsVibe
        hasBoomerang = local.hasBoomerang
        hasSameWavelength = local.hasSameWavelength
        hasSoulmate = local.hasSoulmate
        hasGenreHopper = local.hasGenreHopper
        hasDeepCut = local.hasDeepCut
        songsPassedAlong = local.songsPassedAlong
        hasContrarian = local.hasContrarian
        hasResurrection = local.hasResurrection
    }

    mutating func loadCachedFirestoreStats() {
        let local = LocalAchievementStats.shared
        songsShared = local.cachedSongsShared
        playlistsShared = local.cachedPlaylistsShared
        friendsCount = local.cachedFriendsCount
        maxVibestreak = local.cachedMaxVibestreak
        reactionsReceived = local.cachedReactionsReceived
        genresCount = local.cachedGenresCount
        isSpotifyConnected = local.cachedIsSpotifyConnected
        isAIConfigured = local.cachedIsAIConfigured
    }

    private var achievementsUnlockedCount: Int {
        var count = 0
        if songsShared >= 1 { count += 1 }
        if songsShared >= 10 { count += 1 }
        if songsShared >= 50 { count += 1 }
        if songsShared >= 100 { count += 1 }
        if songsShared >= 250 { count += 1 }
        if songsShared >= 500 { count += 1 }
        if songsShared >= 1000 { count += 1 }
        if uniqueArtistsShared >= 25 { count += 1 }
        if friendsCount >= 1 { count += 1 }
        if friendsCount >= 5 { count += 1 }
        if friendsCount >= 10 { count += 1 }
        if friendsCount >= 25 { count += 1 }
        if friendsCount >= 50 { count += 1 }
        if friendsCount >= 100 { count += 1 }
        if friendRequestsSent >= 5 { count += 1 }
        if friendRequestsSent >= 25 { count += 1 }
        if blendsCreated >= 1 { count += 1 }
        if blendsCreated >= 10 { count += 1 }
        if maxVibestreak >= 3 { count += 1 }
        if maxVibestreak >= 7 { count += 1 }
        if maxVibestreak >= 14 { count += 1 }
        if maxVibestreak >= 30 { count += 1 }
        if maxVibestreak >= 60 { count += 1 }
        if maxVibestreak >= 100 { count += 1 }
        if maxVibestreak >= 180 { count += 1 }
        if maxVibestreak >= 365 { count += 1 }
        if isSpotifyConnected { count += 1 }
        if playlistsShared >= 1 { count += 1 }
        if playlistsShared >= 5 { count += 1 }
        if playlistsShared >= 25 { count += 1 }
        if genresCount >= 3 { count += 1 }
        if genresCount >= 5 { count += 1 }
        if genresCount >= 10 { count += 1 }
        if songsAddedToPlaylists >= 10 { count += 1 }
        if songsAddedToPlaylists >= 50 { count += 1 }
        if songsAddedToPlaylists >= 100 { count += 1 }
        if messagesSent >= 1 { count += 1 }
        if messagesSent >= 10 { count += 1 }
        if messagesSent >= 50 { count += 1 }
        if messagesSent >= 100 { count += 1 }
        if messagesSent >= 500 { count += 1 }
        if messagesSent >= 1000 { count += 1 }
        if conversationsCount >= 3 { count += 1 }
        if conversationsCount >= 10 { count += 1 }
        if songMessagesSent >= 25 { count += 1 }
        if songMessagesSent >= 100 { count += 1 }
        if reactionsGiven >= 1 { count += 1 }
        if reactionsGiven >= 10 { count += 1 }
        if reactionsGiven >= 50 { count += 1 }
        if reactionsGiven >= 100 { count += 1 }
        if reactionsGiven >= 500 { count += 1 }
        if reactionsReceived >= 10 { count += 1 }
        if reactionsReceived >= 50 { count += 1 }
        if reactionsReceived >= 100 { count += 1 }
        if isAIConfigured { count += 1 }
        if aiPlaylistsCreated >= 1 { count += 1 }
        if aiPlaylistsCreated >= 5 { count += 1 }
        if aiPlaylistsCreated >= 10 { count += 1 }
        if aiPlaylistsCreated >= 25 { count += 1 }
        if aiPlaylistsCreated >= 50 { count += 1 }
        if previewPlays >= 10 { count += 1 }
        if previewPlays >= 50 { count += 1 }
        if previewPlays >= 100 { count += 1 }
        if previewPlays >= 500 { count += 1 }
        if artistsViewed >= 10 { count += 1 }
        if artistsViewed >= 50 { count += 1 }
        if albumsViewed >= 10 { count += 1 }
        if albumsViewed >= 50 { count += 1 }
        if searchQueries >= 25 { count += 1 }
        if searchQueries >= 100 { count += 1 }
        return count
    }

    private var totalNonSecretAchievements: Int { 60 }

    private var secretAchievementsUnlockedCount: Int {
        var count = 0
        if achievementsUnlockedCount >= 50 { count += 1 }
        if friendsCount >= 250 { count += 1 }
        if previewPlays >= 1000 { count += 1 }
        if reactionsGiven >= 1000 { count += 1 }
        if maxVibestreak >= 500 { count += 1 }
        if hasMidnightDrop { count += 1 }
        if hasEarlyBird { count += 1 }
        if hasFridayFeeling { count += 1 }
        if hasNewYearsVibe { count += 1 }
        if hasBoomerang { count += 1 }
        if hasSameWavelength { count += 1 }
        if hasSoulmate { count += 1 }
        if hasGenreHopper { count += 1 }
        if hasDeepCut { count += 1 }
        if achievementsUnlockedCount >= totalNonSecretAchievements { count += 1 }
        if songsPassedAlong >= 5 { count += 1 }
        if hasContrarian { count += 1 }
        if hasResurrection { count += 1 }
        return count
    }

    private var totalSecretAchievementsExcludingKeeper: Int { 18 }

    func buildAchievements() -> [Achievement] {
        AchievementDefinition.all.map { def in
            let progress: Int
            let isUnlocked: Bool

            switch def.id {
            case "first_share", "share_10", "share_50", "share_100", "share_250", "share_500", "share_1000":
                progress = songsShared
                isUnlocked = songsShared >= def.requirement
            case "unique_artists_25":
                progress = uniqueArtistsShared
                isUnlocked = uniqueArtistsShared >= def.requirement
            case "first_friend", "friends_5", "friends_10", "friends_25", "friends_50", "friends_100":
                progress = friendsCount
                isUnlocked = friendsCount >= def.requirement
            case "friend_requests_sent_5", "friend_requests_sent_25":
                progress = friendRequestsSent
                isUnlocked = friendRequestsSent >= def.requirement
            case "first_blend", "blends_10":
                progress = blendsCreated
                isUnlocked = blendsCreated >= def.requirement
            case "streak_3", "streak_7", "streak_14", "streak_30", "streak_60", "streak_100", "streak_180", "streak_365":
                progress = maxVibestreak
                isUnlocked = maxVibestreak >= def.requirement
            case "spotify_connect":
                progress = isSpotifyConnected ? 1 : 0
                isUnlocked = isSpotifyConnected
            case "playlist_share", "playlist_share_5", "playlist_share_25":
                progress = playlistsShared
                isUnlocked = playlistsShared >= def.requirement
            case "genres_3", "genres_5", "genres_10":
                progress = genresCount
                isUnlocked = genresCount >= def.requirement
            case "songs_added_10", "songs_added_50", "songs_added_100":
                progress = songsAddedToPlaylists
                isUnlocked = songsAddedToPlaylists >= def.requirement
            case "first_message", "messages_10", "messages_50", "messages_100", "messages_500", "messages_1000":
                progress = messagesSent
                isUnlocked = messagesSent >= def.requirement
            case "conversations_3", "conversations_10":
                progress = conversationsCount
                isUnlocked = conversationsCount >= def.requirement
            case "song_messages_25", "song_messages_100":
                progress = songMessagesSent
                isUnlocked = songMessagesSent >= def.requirement
            case "first_reaction", "reactions_10", "reactions_50", "reactions_100", "reactions_500":
                progress = reactionsGiven
                isUnlocked = reactionsGiven >= def.requirement
            case "first_ai_playlist", "ai_playlists_5", "ai_playlists_10", "ai_playlists_25", "ai_playlists_50":
                progress = aiPlaylistsCreated
                isUnlocked = aiPlaylistsCreated >= def.requirement
            case "preview_plays_10", "preview_plays_50", "preview_plays_100", "preview_plays_500":
                progress = previewPlays
                isUnlocked = previewPlays >= def.requirement
            case "artists_viewed_10", "artists_viewed_50":
                progress = artistsViewed
                isUnlocked = artistsViewed >= def.requirement
            case "albums_viewed_10", "albums_viewed_50":
                progress = albumsViewed
                isUnlocked = albumsViewed >= def.requirement
            case "search_queries_25", "search_queries_100":
                progress = searchQueries
                isUnlocked = searchQueries >= def.requirement
            case "secret_collector":
                progress = achievementsUnlockedCount
                isUnlocked = achievementsUnlockedCount >= def.requirement
            case "secret_social_royalty":
                progress = friendsCount
                isUnlocked = friendsCount >= def.requirement
            case "secret_night_owl":
                progress = previewPlays
                isUnlocked = previewPlays >= def.requirement
            case "secret_reaction_machine":
                progress = reactionsGiven
                isUnlocked = reactionsGiven >= def.requirement
            case "secret_eternal_vibe":
                progress = maxVibestreak
                isUnlocked = maxVibestreak >= def.requirement
            case "secret_midnight_drop":
                progress = hasMidnightDrop ? 1 : 0
                isUnlocked = hasMidnightDrop
            case "secret_early_bird":
                progress = hasEarlyBird ? 1 : 0
                isUnlocked = hasEarlyBird
            case "secret_friday_feeling":
                progress = hasFridayFeeling ? 1 : 0
                isUnlocked = hasFridayFeeling
            case "secret_new_years_vibe":
                progress = hasNewYearsVibe ? 1 : 0
                isUnlocked = hasNewYearsVibe
            case "secret_boomerang":
                progress = hasBoomerang ? 1 : 0
                isUnlocked = hasBoomerang
            case "secret_same_wavelength":
                progress = hasSameWavelength ? 1 : 0
                isUnlocked = hasSameWavelength
            case "secret_soulmate":
                progress = hasSoulmate ? 1 : 0
                isUnlocked = hasSoulmate
            case "secret_genre_hopper":
                progress = hasGenreHopper ? 1 : 0
                isUnlocked = hasGenreHopper
            case "secret_deep_cut":
                progress = hasDeepCut ? 1 : 0
                isUnlocked = hasDeepCut
            case "secret_completionist":
                progress = achievementsUnlockedCount
                isUnlocked = achievementsUnlockedCount >= totalNonSecretAchievements
            case "secret_secret_keeper":
                progress = secretAchievementsUnlockedCount
                isUnlocked = secretAchievementsUnlockedCount >= totalSecretAchievementsExcludingKeeper
            case "secret_butterfly_effect":
                progress = songsPassedAlong
                isUnlocked = songsPassedAlong >= def.requirement
            case "secret_contrarian":
                progress = hasContrarian ? 1 : 0
                isUnlocked = hasContrarian
            case "secret_resurrection":
                progress = hasResurrection ? 1 : 0
                isUnlocked = hasResurrection
            default:
                progress = 0
                isUnlocked = false
            }

            return Achievement(
                id: def.id,
                name: def.name,
                description: def.description,
                icon: def.icon,
                category: def.category,
                requirement: def.requirement,
                isUnlocked: isUnlocked,
                progress: progress,
                isSecret: def.isSecret,
                isSuperSecret: def.isSuperSecret,
                showsProgressCount: def.showsProgressCount
            )
        }
    }
}
