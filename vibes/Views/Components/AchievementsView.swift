//
//  AchievementsView.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    let isUnlocked: Bool
    let progress: Int
    let isSecret: Bool

    var progressPercentage: Double {
        guard requirement > 0 else { return 1.0 }
        return min(Double(progress) / Double(requirement), 1.0)
    }

    var displayName: String {
        if isSecret && !isUnlocked { return "?????" }
        return name
    }

    var displayDescription: String {
        if isSecret && !isUnlocked { return "Hidden achievement" }
        return description
    }

    var displayIcon: String {
        if isSecret && !isUnlocked { return "questionmark" }
        return icon
    }
}

enum AchievementCategory: String, CaseIterable {
    case sharing = "Sharing"
    case social = "Social"
    case streak = "Streaks"
    case discovery = "Discovery"
    case messaging = "Messaging"
    case reactions = "Reactions"
    case ai = "AI"
    case listening = "Listening"

    var color: Color {
        switch self {
        case .sharing: return .blue
        case .social: return .green
        case .streak: return .orange
        case .discovery: return .purple
        case .messaging: return .pink
        case .reactions: return .yellow
        case .ai: return .cyan
        case .listening: return .indigo
        }
    }
}

struct AchievementDefinition {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    let isSecret: Bool

    init(id: String, name: String, description: String, icon: String, category: AchievementCategory, requirement: Int, isSecret: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.requirement = requirement
        self.isSecret = isSecret
    }

    static let all: [AchievementDefinition] = [
        // MARK: - Sharing achievements (8 total)
        AchievementDefinition(
            id: "first_share",
            name: "First Vibe",
            description: "Share your first song",
            icon: "music.note",
            category: .sharing,
            requirement: 1
        ),
        AchievementDefinition(
            id: "share_10",
            name: "Vibe Spreader",
            description: "Share 10 songs",
            icon: "music.note.list",
            category: .sharing,
            requirement: 10
        ),
        AchievementDefinition(
            id: "share_50",
            name: "DJ Mode",
            description: "Share 50 songs",
            icon: "waveform",
            category: .sharing,
            requirement: 50
        ),
        AchievementDefinition(
            id: "share_100",
            name: "Curator",
            description: "Share 100 songs",
            icon: "star.fill",
            category: .sharing,
            requirement: 100
        ),
        AchievementDefinition(
            id: "share_250",
            name: "Vibesetter",
            description: "Share 250 songs",
            icon: "music.quarternote.3",
            category: .sharing,
            requirement: 250
        ),
        AchievementDefinition(
            id: "share_500",
            name: "Music Maven",
            description: "Share 500 songs",
            icon: "guitars.fill",
            category: .sharing,
            requirement: 500
        ),
        AchievementDefinition(
            id: "share_1000",
            name: "Vibe Legend",
            description: "Share 1000 songs",
            icon: "trophy.fill",
            category: .sharing,
            requirement: 1000
        ),
        AchievementDefinition(
            id: "unique_artists_25",
            name: "Diverse Taste",
            description: "Share songs from 25 different artists",
            icon: "person.wave.2.fill",
            category: .sharing,
            requirement: 25
        ),

        // MARK: - Social achievements (10 total)
        AchievementDefinition(
            id: "first_friend",
            name: "Connected",
            description: "Add your first friend",
            icon: "person.fill.badge.plus",
            category: .social,
            requirement: 1
        ),
        AchievementDefinition(
            id: "friends_5",
            name: "Circle",
            description: "Have 5 friends",
            icon: "person.2.fill",
            category: .social,
            requirement: 5
        ),
        AchievementDefinition(
            id: "friends_10",
            name: "Crew",
            description: "Have 10 friends",
            icon: "person.3.fill",
            category: .social,
            requirement: 10
        ),
        AchievementDefinition(
            id: "friends_25",
            name: "Squad",
            description: "Have 25 friends",
            icon: "person.3.sequence.fill",
            category: .social,
            requirement: 25
        ),
        AchievementDefinition(
            id: "friends_50",
            name: "Popular",
            description: "Have 50 friends",
            icon: "figure.socialdance",
            category: .social,
            requirement: 50
        ),
        AchievementDefinition(
            id: "friends_100",
            name: "Influencer",
            description: "Have 100 friends",
            icon: "star.circle.fill",
            category: .social,
            requirement: 100
        ),
        AchievementDefinition(
            id: "friend_requests_sent_5",
            name: "Outgoing",
            description: "Send 5 friend requests",
            icon: "paperplane.fill",
            category: .social,
            requirement: 5
        ),
        AchievementDefinition(
            id: "friend_requests_sent_25",
            name: "Networker",
            description: "Send 25 friend requests",
            icon: "network",
            category: .social,
            requirement: 25
        ),
        AchievementDefinition(
            id: "first_blend",
            name: "Blend Beginner",
            description: "Create your first Friend Blend",
            icon: "arrow.triangle.merge",
            category: .social,
            requirement: 1
        ),
        AchievementDefinition(
            id: "blends_10",
            name: "Blend Master",
            description: "Create 10 Friend Blends",
            icon: "arrow.triangle.branch",
            category: .social,
            requirement: 10
        ),

        // MARK: - Streak achievements (8 total)
        AchievementDefinition(
            id: "streak_3",
            name: "Getting Started",
            description: "Maintain a 3-day vibestreak",
            icon: "flame",
            category: .streak,
            requirement: 3
        ),
        AchievementDefinition(
            id: "streak_7",
            name: "Week Warrior",
            description: "Maintain a 7-day vibestreak",
            icon: "flame",
            category: .streak,
            requirement: 7
        ),
        AchievementDefinition(
            id: "streak_14",
            name: "Fortnight Focus",
            description: "Maintain a 14-day vibestreak",
            icon: "flame.fill",
            category: .streak,
            requirement: 14
        ),
        AchievementDefinition(
            id: "streak_30",
            name: "Monthly Maven",
            description: "Maintain a 30-day vibestreak",
            icon: "flame.fill",
            category: .streak,
            requirement: 30
        ),
        AchievementDefinition(
            id: "streak_60",
            name: "Two Month Titan",
            description: "Maintain a 60-day vibestreak",
            icon: "flame.circle",
            category: .streak,
            requirement: 60
        ),
        AchievementDefinition(
            id: "streak_100",
            name: "Centurion",
            description: "Maintain a 100-day vibestreak",
            icon: "flame.circle.fill",
            category: .streak,
            requirement: 100
        ),
        AchievementDefinition(
            id: "streak_180",
            name: "Half Year Hero",
            description: "Maintain a 180-day vibestreak",
            icon: "sun.max.fill",
            category: .streak,
            requirement: 180
        ),
        AchievementDefinition(
            id: "streak_365",
            name: "Legendary",
            description: "Maintain a 365-day vibestreak",
            icon: "crown.fill",
            category: .streak,
            requirement: 365
        ),

        // MARK: - Discovery achievements (10 total)
        AchievementDefinition(
            id: "spotify_connect",
            name: "Tuned In",
            description: "Connect Spotify",
            icon: "antenna.radiowaves.left.and.right",
            category: .discovery,
            requirement: 1
        ),
        AchievementDefinition(
            id: "playlist_share",
            name: "Playlist Pro",
            description: "Share a playlist",
            icon: "list.bullet.rectangle",
            category: .discovery,
            requirement: 1
        ),
        AchievementDefinition(
            id: "playlist_share_5",
            name: "Playlist Pusher",
            description: "Share 5 playlists",
            icon: "list.bullet.rectangle.fill",
            category: .discovery,
            requirement: 5
        ),
        AchievementDefinition(
            id: "playlist_share_25",
            name: "Playlist Legend",
            description: "Share 25 playlists",
            icon: "rectangle.stack.fill",
            category: .discovery,
            requirement: 25
        ),
        AchievementDefinition(
            id: "genres_3",
            name: "Explorer",
            description: "Have 3 favorite genres",
            icon: "music.mic",
            category: .discovery,
            requirement: 3
        ),
        AchievementDefinition(
            id: "genres_5",
            name: "Eclectic",
            description: "Have 5 favorite genres",
            icon: "music.mic",
            category: .discovery,
            requirement: 5
        ),
        AchievementDefinition(
            id: "genres_10",
            name: "Music Encyclopedia",
            description: "Have 10 favorite genres",
            icon: "books.vertical.fill",
            category: .discovery,
            requirement: 10
        ),
        AchievementDefinition(
            id: "songs_added_10",
            name: "Playlist Builder",
            description: "Add 10 songs to playlists",
            icon: "plus.circle",
            category: .discovery,
            requirement: 10
        ),
        AchievementDefinition(
            id: "songs_added_50",
            name: "Playlist Architect",
            description: "Add 50 songs to playlists",
            icon: "plus.circle.fill",
            category: .discovery,
            requirement: 50
        ),
        AchievementDefinition(
            id: "songs_added_100",
            name: "Playlist Engineer",
            description: "Add 100 songs to playlists",
            icon: "rectangle.stack.badge.plus",
            category: .discovery,
            requirement: 100
        ),

        // MARK: - Messaging achievements (10 total)
        AchievementDefinition(
            id: "first_message",
            name: "Ice Breaker",
            description: "Send your first message",
            icon: "bubble.left.fill",
            category: .messaging,
            requirement: 1
        ),
        AchievementDefinition(
            id: "messages_10",
            name: "Chatterbox",
            description: "Send 10 messages",
            icon: "bubble.left.and.bubble.right",
            category: .messaging,
            requirement: 10
        ),
        AchievementDefinition(
            id: "messages_50",
            name: "Conversationalist",
            description: "Send 50 messages",
            icon: "bubble.left.and.bubble.right.fill",
            category: .messaging,
            requirement: 50
        ),
        AchievementDefinition(
            id: "messages_100",
            name: "Social Butterfly",
            description: "Send 100 messages",
            icon: "message.fill",
            category: .messaging,
            requirement: 100
        ),
        AchievementDefinition(
            id: "messages_500",
            name: "Talk Show Host",
            description: "Send 500 messages",
            icon: "mic.fill",
            category: .messaging,
            requirement: 500
        ),
        AchievementDefinition(
            id: "messages_1000",
            name: "Chatter Champion",
            description: "Send 1000 messages",
            icon: "megaphone.fill",
            category: .messaging,
            requirement: 1000
        ),
        AchievementDefinition(
            id: "conversations_3",
            name: "Social Starter",
            description: "Chat with 3 different friends",
            icon: "person.2.wave.2",
            category: .messaging,
            requirement: 3
        ),
        AchievementDefinition(
            id: "conversations_10",
            name: "Connector",
            description: "Chat with 10 different friends",
            icon: "person.2.wave.2.fill",
            category: .messaging,
            requirement: 10
        ),
        AchievementDefinition(
            id: "song_messages_25",
            name: "Track Dealer",
            description: "Send 25 song messages",
            icon: "music.note.tv",
            category: .messaging,
            requirement: 25
        ),
        AchievementDefinition(
            id: "song_messages_100",
            name: "Music Dealer",
            description: "Send 100 song messages",
            icon: "music.note.tv.fill",
            category: .messaging,
            requirement: 100
        ),

        // MARK: - Reactions achievements (8 total)
        AchievementDefinition(
            id: "first_reaction",
            name: "Expressive",
            description: "Give your first reaction",
            icon: "hand.thumbsup",
            category: .reactions,
            requirement: 1
        ),
        AchievementDefinition(
            id: "reactions_10",
            name: "Reactor",
            description: "Give 10 reactions",
            icon: "hand.thumbsup.fill",
            category: .reactions,
            requirement: 10
        ),
        AchievementDefinition(
            id: "reactions_50",
            name: "Reaction King",
            description: "Give 50 reactions",
            icon: "hands.clap.fill",
            category: .reactions,
            requirement: 50
        ),
        AchievementDefinition(
            id: "reactions_100",
            name: "Emoji Master",
            description: "Give 100 reactions",
            icon: "face.smiling.inverse",
            category: .reactions,
            requirement: 100
        ),
        AchievementDefinition(
            id: "reactions_500",
            name: "Reaction Legend",
            description: "Give 500 reactions",
            icon: "sparkles",
            category: .reactions,
            requirement: 500
        ),

        // MARK: - AI achievements (5 total)
        AchievementDefinition(
            id: "first_ai_playlist",
            name: "AI Curious",
            description: "Create your first AI playlist",
            icon: "wand.and.stars",
            category: .ai,
            requirement: 1
        ),
        AchievementDefinition(
            id: "ai_playlists_5",
            name: "AI Enthusiast",
            description: "Create 5 AI playlists",
            icon: "wand.and.stars.inverse",
            category: .ai,
            requirement: 5
        ),
        AchievementDefinition(
            id: "ai_playlists_10",
            name: "AI Power User",
            description: "Create 10 AI playlists",
            icon: "brain.head.profile",
            category: .ai,
            requirement: 10
        ),
        AchievementDefinition(
            id: "ai_playlists_25",
            name: "AI Maestro",
            description: "Create 25 AI playlists",
            icon: "brain",
            category: .ai,
            requirement: 25
        ),
        AchievementDefinition(
            id: "ai_playlists_50",
            name: "AI Overlord",
            description: "Create 50 AI playlists",
            icon: "brain.fill",
            category: .ai,
            requirement: 50
        ),

        // MARK: - Listening achievements (10 total)
        AchievementDefinition(
            id: "preview_plays_10",
            name: "Sampler",
            description: "Play 10 song previews",
            icon: "play.circle",
            category: .listening,
            requirement: 10
        ),
        AchievementDefinition(
            id: "preview_plays_50",
            name: "Music Taster",
            description: "Play 50 song previews",
            icon: "play.circle.fill",
            category: .listening,
            requirement: 50
        ),
        AchievementDefinition(
            id: "preview_plays_100",
            name: "Preview Master",
            description: "Play 100 song previews",
            icon: "play.square.fill",
            category: .listening,
            requirement: 100
        ),
        AchievementDefinition(
            id: "preview_plays_500",
            name: "Audio Addict",
            description: "Play 500 song previews",
            icon: "headphones.circle.fill",
            category: .listening,
            requirement: 500
        ),
        AchievementDefinition(
            id: "artists_viewed_10",
            name: "Artist Explorer",
            description: "View 10 artist profiles",
            icon: "music.mic.circle",
            category: .listening,
            requirement: 10
        ),
        AchievementDefinition(
            id: "artists_viewed_50",
            name: "Artist Stalker",
            description: "View 50 artist profiles",
            icon: "music.mic.circle.fill",
            category: .listening,
            requirement: 50
        ),
        AchievementDefinition(
            id: "albums_viewed_10",
            name: "Album Browser",
            description: "View 10 albums",
            icon: "square.stack",
            category: .listening,
            requirement: 10
        ),
        AchievementDefinition(
            id: "albums_viewed_50",
            name: "Album Collector",
            description: "View 50 albums",
            icon: "square.stack.fill",
            category: .listening,
            requirement: 50
        ),
        AchievementDefinition(
            id: "search_queries_25",
            name: "Searcher",
            description: "Search 25 times",
            icon: "magnifyingglass",
            category: .listening,
            requirement: 25
        ),
        AchievementDefinition(
            id: "search_queries_100",
            name: "Music Detective",
            description: "Search 100 times",
            icon: "magnifyingglass.circle.fill",
            category: .listening,
            requirement: 100
        ),

        // MARK: - Secret achievements (16 total) - Hidden until unlocked
        AchievementDefinition(
            id: "secret_collector",
            name: "The Collector",
            description: "Unlock 50 other achievements",
            icon: "medal.fill",
            category: .discovery,
            requirement: 50,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_social_royalty",
            name: "Social Royalty",
            description: "Have 250 friends",
            icon: "crown.fill",
            category: .social,
            requirement: 250,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_night_owl",
            name: "Night Owl",
            description: "Play 1000 song previews",
            icon: "moon.stars.fill",
            category: .listening,
            requirement: 1000,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_reaction_machine",
            name: "Reaction Machine",
            description: "Give 1000 reactions",
            icon: "bolt.heart.fill",
            category: .reactions,
            requirement: 1000,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_eternal_vibe",
            name: "Eternal Vibe",
            description: "Maintain a 500-day vibestreak",
            icon: "infinity",
            category: .streak,
            requirement: 500,
            isSecret: true
        ),

        // Time-based secrets
        AchievementDefinition(
            id: "secret_midnight_drop",
            name: "Midnight Drop",
            description: "Share a song at exactly midnight",
            icon: "clock.fill",
            category: .sharing,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_early_bird",
            name: "Early Bird",
            description: "Use the app before 5 AM",
            icon: "sunrise.fill",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_friday_feeling",
            name: "Friday Feeling",
            description: "Share 10 songs on a single Friday",
            icon: "party.popper.fill",
            category: .sharing,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_new_years_vibe",
            name: "New Year's Vibe",
            description: "Share a song on January 1st",
            icon: "sparkles",
            category: .sharing,
            requirement: 1,
            isSecret: true
        ),

        // Social secrets
        AchievementDefinition(
            id: "secret_boomerang",
            name: "Boomerang",
            description: "Receive back a song you originally shared",
            icon: "arrow.uturn.backward.circle.fill",
            category: .social,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_same_wavelength",
            name: "Same Wavelength",
            description: "Send the same song as a friend within 24 hours",
            icon: "waveform.path",
            category: .social,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_soulmate",
            name: "Soulmate",
            description: "Create a Friend Blend with 90%+ compatibility",
            icon: "heart.text.square.fill",
            category: .social,
            requirement: 1,
            isSecret: true
        ),

        // Discovery secrets
        AchievementDefinition(
            id: "secret_genre_hopper",
            name: "Genre Hopper",
            description: "Share songs from 8 different genres in one day",
            icon: "shuffle",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_deep_cut",
            name: "Deep Cut",
            description: "Share an obscure song with under 100K plays",
            icon: "diamond.fill",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),

        // Meta secrets
        AchievementDefinition(
            id: "secret_completionist",
            name: "Completionist",
            description: "Unlock every non-secret achievement",
            icon: "checkmark.seal.fill",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_secret_keeper",
            name: "Secret Keeper",
            description: "Unlock all other secret achievements",
            icon: "lock.open.fill",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),
    ]
}

struct AchievementBadge: View {
    let achievement: Achievement

    private var isHidden: Bool {
        achievement.isSecret && !achievement.isUnlocked
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? achievement.category.color.opacity(0.2)
                          : Color(.tertiarySystemFill))
                    .frame(width: 60, height: 60)

                if !achievement.isUnlocked && !isHidden {
                    Circle()
                        .trim(from: 0, to: achievement.progressPercentage)
                        .stroke(achievement.category.color.opacity(0.5), lineWidth: 3)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                }

                Image(systemName: achievement.displayIcon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked
                                     ? achievement.category.color
                                     : Color(.tertiaryLabel))
            }

            Text(achievement.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .lineLimit(1)

            if !achievement.isUnlocked && !isHidden {
                Text("\(achievement.progress)/\(achievement.requirement)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 80)
    }
}

struct AchievementRow: View {
    let achievement: Achievement

    private var isHidden: Bool {
        achievement.isSecret && !achievement.isUnlocked
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? achievement.category.color.opacity(0.2)
                          : Color(.tertiarySystemFill))
                    .frame(width: 50, height: 50)

                if !achievement.isUnlocked && !isHidden {
                    Circle()
                        .trim(from: 0, to: achievement.progressPercentage)
                        .stroke(achievement.category.color.opacity(0.5), lineWidth: 2)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                }

                Image(systemName: achievement.displayIcon)
                    .font(.title3)
                    .foregroundColor(achievement.isUnlocked
                                     ? achievement.category.color
                                     : Color(.tertiaryLabel))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.displayName)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)

                Text(achievement.displayDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if !isHidden {
                Text("\(achievement.progress)/\(achievement.requirement)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct AchievementsGridView: View {
    let achievements: [Achievement]
    var showAll: Bool = false

    var displayedAchievements: [Achievement] {
        // Show completed achievements only
        let unlocked = achievements.filter { $0.isUnlocked }
        if showAll {
            return unlocked
        }
        return Array(unlocked.prefix(8))
    }

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(displayedAchievements) { achievement in
                AchievementBadge(achievement: achievement)
            }
        }
    }
}

struct AchievementsListView: View {
    let achievements: [Achievement]
    @State private var selectedCategory: AchievementCategory?

    var filteredAchievements: [Achievement] {
        var filtered: [Achievement]
        if let category = selectedCategory {
            filtered = achievements.filter { $0.category == category }
        } else {
            filtered = achievements
        }
        // Sort: incomplete first, completed at bottom
        let locked = filtered.filter { !$0.isUnlocked }
        let unlocked = filtered.filter { $0.isUnlocked }
        return locked + unlocked
    }

    var body: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryPill(nil, label: "All")
                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        categoryPill(category, label: category.rawValue)
                    }
                }
                .padding(.horizontal)
            }

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredAchievements) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func categoryPill(_ category: AchievementCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            selectedCategory = category
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? (category?.color ?? Color.blue) : Color(.tertiarySystemFill))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Local Achievement Stats Tracking

class LocalAchievementStats {
    static let shared = LocalAchievementStats()
    private let defaults = UserDefaults.standard

    private enum Keys {
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
    }

    // Unique artists tracking (stored as array of artist names)
    var uniqueArtistsShared: [String] {
        get { defaults.stringArray(forKey: Keys.uniqueArtistsShared) ?? [] }
        set { defaults.set(newValue, forKey: Keys.uniqueArtistsShared) }
    }

    var uniqueArtistsCount: Int {
        uniqueArtistsShared.count
    }

    func trackArtistShared(_ artistName: String) {
        let normalized = artistName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        var artists = uniqueArtistsShared
        if !artists.contains(normalized) {
            artists.append(normalized)
            uniqueArtistsShared = artists
        }
    }

    var songsAddedToPlaylists: Int {
        get { defaults.integer(forKey: Keys.songsAddedToPlaylists) }
        set { defaults.set(newValue, forKey: Keys.songsAddedToPlaylists) }
    }

    var previewPlays: Int {
        get { defaults.integer(forKey: Keys.previewPlays) }
        set { defaults.set(newValue, forKey: Keys.previewPlays) }
    }

    var artistsViewed: Int {
        get { defaults.integer(forKey: Keys.artistsViewed) }
        set { defaults.set(newValue, forKey: Keys.artistsViewed) }
    }

    var albumsViewed: Int {
        get { defaults.integer(forKey: Keys.albumsViewed) }
        set { defaults.set(newValue, forKey: Keys.albumsViewed) }
    }

    var searchQueries: Int {
        get { defaults.integer(forKey: Keys.searchQueries) }
        set { defaults.set(newValue, forKey: Keys.searchQueries) }
    }

    var reactionsGiven: Int {
        get { defaults.integer(forKey: Keys.reactionsGiven) }
        set { defaults.set(newValue, forKey: Keys.reactionsGiven) }
    }

    var aiPlaylistsCreated: Int {
        get { defaults.integer(forKey: Keys.aiPlaylistsCreated) }
        set { defaults.set(newValue, forKey: Keys.aiPlaylistsCreated) }
    }

    var blendsCreated: Int {
        get { defaults.integer(forKey: Keys.blendsCreated) }
        set { defaults.set(newValue, forKey: Keys.blendsCreated) }
    }

    var friendRequestsSent: Int {
        get { defaults.integer(forKey: Keys.friendRequestsSent) }
        set { defaults.set(newValue, forKey: Keys.friendRequestsSent) }
    }

    var messagesSent: Int {
        get { defaults.integer(forKey: Keys.messagesSent) }
        set { defaults.set(newValue, forKey: Keys.messagesSent) }
    }

    var songMessagesSent: Int {
        get { defaults.integer(forKey: Keys.songMessagesSent) }
        set { defaults.set(newValue, forKey: Keys.songMessagesSent) }
    }

    // Conversations tracking (stored as array of friend IDs messaged)
    private var conversationFriendIds: [String] {
        get { defaults.stringArray(forKey: Keys.conversationsStarted) ?? [] }
        set { defaults.set(newValue, forKey: Keys.conversationsStarted) }
    }

    var conversationsCount: Int {
        conversationFriendIds.count
    }

    func trackConversation(with friendId: String) {
        var ids = conversationFriendIds
        if !ids.contains(friendId) {
            ids.append(friendId)
            conversationFriendIds = ids
        }
    }

    // Secret achievement triggers
    var hasMidnightDrop: Bool {
        get { defaults.bool(forKey: Keys.hasMidnightDrop) }
        set { defaults.set(newValue, forKey: Keys.hasMidnightDrop) }
    }

    var hasEarlyBird: Bool {
        get { defaults.bool(forKey: Keys.hasEarlyBird) }
        set { defaults.set(newValue, forKey: Keys.hasEarlyBird) }
    }

    var hasFridayFeeling: Bool {
        get { defaults.bool(forKey: Keys.hasFridayFeeling) }
        set { defaults.set(newValue, forKey: Keys.hasFridayFeeling) }
    }

    var hasNewYearsVibe: Bool {
        get { defaults.bool(forKey: Keys.hasNewYearsVibe) }
        set { defaults.set(newValue, forKey: Keys.hasNewYearsVibe) }
    }

    var hasBoomerang: Bool {
        get { defaults.bool(forKey: Keys.hasBoomerang) }
        set { defaults.set(newValue, forKey: Keys.hasBoomerang) }
    }

    var hasSameWavelength: Bool {
        get { defaults.bool(forKey: Keys.hasSameWavelength) }
        set { defaults.set(newValue, forKey: Keys.hasSameWavelength) }
    }

    var hasSoulmate: Bool {
        get { defaults.bool(forKey: Keys.hasSoulmate) }
        set { defaults.set(newValue, forKey: Keys.hasSoulmate) }
    }

    var hasGenreHopper: Bool {
        get { defaults.bool(forKey: Keys.hasGenreHopper) }
        set { defaults.set(newValue, forKey: Keys.hasGenreHopper) }
    }

    var hasDeepCut: Bool {
        get { defaults.bool(forKey: Keys.hasDeepCut) }
        set { defaults.set(newValue, forKey: Keys.hasDeepCut) }
    }

    // Helper for Friday Feeling tracking
    func trackSongSharedOnFriday() {
        let calendar = Calendar.current
        let now = Date()
        guard calendar.component(.weekday, from: now) == 6 else { return } // Friday = 6

        let today = calendar.startOfDay(for: now)
        let storedDate = defaults.object(forKey: Keys.fridaySongsDate) as? Date

        if let storedDate = storedDate, calendar.isDate(storedDate, inSameDayAs: today) {
            let count = defaults.integer(forKey: Keys.fridaySongsCount) + 1
            defaults.set(count, forKey: Keys.fridaySongsCount)
            if count >= 10 {
                hasFridayFeeling = true
            }
        } else {
            defaults.set(today, forKey: Keys.fridaySongsDate)
            defaults.set(1, forKey: Keys.fridaySongsCount)
        }
    }

    // Helper for time-based achievements
    func checkTimeBasedAchievements() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)

        // Early Bird - before 5 AM
        if hour < 5 {
            hasEarlyBird = true
        }

        // Midnight Drop - exactly midnight (12:00 AM, within first minute)
        if hour == 0 && minute == 0 {
            hasMidnightDrop = true
        }

        // New Year's Vibe - January 1st
        if month == 1 && day == 1 {
            hasNewYearsVibe = true
        }
    }

    // Clear all local achievement stats (for account deletion)
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
        defaults.removeObject(forKey: Keys.fridaySongsDate)
        defaults.removeObject(forKey: Keys.fridaySongsCount)
    }
}

struct AchievementStats {
    // Sharing
    var songsShared: Int = 0
    var uniqueArtistsShared: Int = 0

    // Social
    var friendsCount: Int = 0
    var friendRequestsSent: Int = 0
    var blendsCreated: Int = 0

    // Streaks
    var maxVibestreak: Int = 0

    // Discovery
    var isSpotifyConnected: Bool = false
    var playlistsShared: Int = 0
    var genresCount: Int = 0
    var songsAddedToPlaylists: Int = 0

    // Messaging
    var messagesSent: Int = 0
    var conversationsCount: Int = 0
    var songMessagesSent: Int = 0

    // Reactions
    var reactionsGiven: Int = 0
    var reactionsReceived: Int = 0

    // AI
    var isAIConfigured: Bool = false
    var aiPlaylistsCreated: Int = 0

    // Listening
    var previewPlays: Int = 0
    var artistsViewed: Int = 0
    var albumsViewed: Int = 0
    var searchQueries: Int = 0

    // Secret achievement triggers (set by app when conditions are met)
    var hasMidnightDrop: Bool = false
    var hasEarlyBird: Bool = false
    var hasFridayFeeling: Bool = false
    var hasNewYearsVibe: Bool = false
    var hasBoomerang: Bool = false
    var hasSameWavelength: Bool = false
    var hasSoulmate: Bool = false
    var hasGenreHopper: Bool = false
    var hasDeepCut: Bool = false

    // Load local stats from UserDefaults
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
    }

    // Computed property to count unlocked non-secret achievements
    private var achievementsUnlockedCount: Int {
        var count = 0
        // Sharing
        if songsShared >= 1 { count += 1 }
        if songsShared >= 10 { count += 1 }
        if songsShared >= 50 { count += 1 }
        if songsShared >= 100 { count += 1 }
        if songsShared >= 250 { count += 1 }
        if songsShared >= 500 { count += 1 }
        if songsShared >= 1000 { count += 1 }
        if uniqueArtistsShared >= 25 { count += 1 }
        // Social
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
        // Streaks
        if maxVibestreak >= 3 { count += 1 }
        if maxVibestreak >= 7 { count += 1 }
        if maxVibestreak >= 14 { count += 1 }
        if maxVibestreak >= 30 { count += 1 }
        if maxVibestreak >= 60 { count += 1 }
        if maxVibestreak >= 100 { count += 1 }
        if maxVibestreak >= 180 { count += 1 }
        if maxVibestreak >= 365 { count += 1 }
        // Discovery
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
        // Messaging
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
        // Reactions
        if reactionsGiven >= 1 { count += 1 }
        if reactionsGiven >= 10 { count += 1 }
        if reactionsGiven >= 50 { count += 1 }
        if reactionsGiven >= 100 { count += 1 }
        if reactionsGiven >= 500 { count += 1 }
        if reactionsReceived >= 10 { count += 1 }
        if reactionsReceived >= 50 { count += 1 }
        if reactionsReceived >= 100 { count += 1 }
        // AI
        if isAIConfigured { count += 1 }
        if aiPlaylistsCreated >= 1 { count += 1 }
        if aiPlaylistsCreated >= 5 { count += 1 }
        if aiPlaylistsCreated >= 10 { count += 1 }
        if aiPlaylistsCreated >= 25 { count += 1 }
        if aiPlaylistsCreated >= 50 { count += 1 }
        // Listening
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

    // Total non-secret achievements (for Completionist)
    private var totalNonSecretAchievements: Int { 60 }

    // Count of unlocked secret achievements (excluding Secret Keeper itself)
    private var secretAchievementsUnlockedCount: Int {
        var count = 0
        if achievementsUnlockedCount >= 50 { count += 1 } // The Collector
        if friendsCount >= 250 { count += 1 } // Social Royalty
        if previewPlays >= 1000 { count += 1 } // Night Owl
        if reactionsGiven >= 1000 { count += 1 } // Reaction Machine
        if maxVibestreak >= 500 { count += 1 } // Eternal Vibe
        if hasMidnightDrop { count += 1 }
        if hasEarlyBird { count += 1 }
        if hasFridayFeeling { count += 1 }
        if hasNewYearsVibe { count += 1 }
        if hasBoomerang { count += 1 }
        if hasSameWavelength { count += 1 }
        if hasSoulmate { count += 1 }
        if hasGenreHopper { count += 1 }
        if hasDeepCut { count += 1 }
        if achievementsUnlockedCount >= totalNonSecretAchievements { count += 1 } // Completionist
        return count
    }

    // Total secret achievements excluding Secret Keeper
    private var totalSecretAchievementsExcludingKeeper: Int { 15 }

    func buildAchievements() -> [Achievement] {
        AchievementDefinition.all.map { def in
            let progress: Int
            let isUnlocked: Bool

            switch def.id {
            // Sharing
            case "first_share", "share_10", "share_50", "share_100", "share_250", "share_500", "share_1000":
                progress = songsShared
                isUnlocked = songsShared >= def.requirement
            case "unique_artists_25":
                progress = uniqueArtistsShared
                isUnlocked = uniqueArtistsShared >= def.requirement

            // Social - friends
            case "first_friend", "friends_5", "friends_10", "friends_25", "friends_50", "friends_100":
                progress = friendsCount
                isUnlocked = friendsCount >= def.requirement
            case "friend_requests_sent_5", "friend_requests_sent_25":
                progress = friendRequestsSent
                isUnlocked = friendRequestsSent >= def.requirement
            case "first_blend", "blends_10":
                progress = blendsCreated
                isUnlocked = blendsCreated >= def.requirement

            // Streaks
            case "streak_3", "streak_7", "streak_14", "streak_30", "streak_60", "streak_100", "streak_180", "streak_365":
                progress = maxVibestreak
                isUnlocked = maxVibestreak >= def.requirement

            // Discovery
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

            // Messaging
            case "first_message", "messages_10", "messages_50", "messages_100", "messages_500", "messages_1000":
                progress = messagesSent
                isUnlocked = messagesSent >= def.requirement
            case "conversations_3", "conversations_10":
                progress = conversationsCount
                isUnlocked = conversationsCount >= def.requirement
            case "song_messages_25", "song_messages_100":
                progress = songMessagesSent
                isUnlocked = songMessagesSent >= def.requirement

            // Reactions
            case "first_reaction", "reactions_10", "reactions_50", "reactions_100", "reactions_500":
                progress = reactionsGiven
                isUnlocked = reactionsGiven >= def.requirement

            // AI
            case "first_ai_playlist", "ai_playlists_5", "ai_playlists_10", "ai_playlists_25", "ai_playlists_50":
                progress = aiPlaylistsCreated
                isUnlocked = aiPlaylistsCreated >= def.requirement

            // Listening
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

            // Secret achievements - stat-based
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

            // Secret achievements - time-based triggers
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

            // Secret achievements - social triggers
            case "secret_boomerang":
                progress = hasBoomerang ? 1 : 0
                isUnlocked = hasBoomerang
            case "secret_same_wavelength":
                progress = hasSameWavelength ? 1 : 0
                isUnlocked = hasSameWavelength
            case "secret_soulmate":
                progress = hasSoulmate ? 1 : 0
                isUnlocked = hasSoulmate

            // Secret achievements - discovery triggers
            case "secret_genre_hopper":
                progress = hasGenreHopper ? 1 : 0
                isUnlocked = hasGenreHopper
            case "secret_deep_cut":
                progress = hasDeepCut ? 1 : 0
                isUnlocked = hasDeepCut

            // Secret achievements - meta
            case "secret_completionist":
                progress = achievementsUnlockedCount
                isUnlocked = achievementsUnlockedCount >= totalNonSecretAchievements
            case "secret_secret_keeper":
                progress = secretAchievementsUnlockedCount
                isUnlocked = secretAchievementsUnlockedCount >= totalSecretAchievementsExcludingKeeper

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
                isSecret: def.isSecret
            )
        }
    }
}

// MARK: - Achievement Banner View

struct AchievementBannerView: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.category.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked!")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text(achievement.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.category.color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - Achievement Banner Overlay

struct AchievementBannerOverlay: View {
    @ObservedObject var notificationService = AchievementNotificationService.shared

    var body: some View {
        VStack {
            if notificationService.isShowingBanner, let achievement = notificationService.currentBanner {
                AchievementBannerView(achievement: achievement)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000)
            }

            Spacer()
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: notificationService.isShowingBanner)
    }
}

#Preview {
    let stats = AchievementStats(
        songsShared: 15,
        uniqueArtistsShared: 8,
        friendsCount: 3,
        friendRequestsSent: 6,
        blendsCreated: 2,
        maxVibestreak: 12,
        isSpotifyConnected: true,
        playlistsShared: 2,
        genresCount: 4,
        songsAddedToPlaylists: 25,
        messagesSent: 45,
        conversationsCount: 5,
        songMessagesSent: 12,
        reactionsGiven: 30,
        reactionsReceived: 15,
        isAIConfigured: true,
        aiPlaylistsCreated: 3,
        previewPlays: 75,
        artistsViewed: 20,
        albumsViewed: 8,
        searchQueries: 40
    )
    let achievements = stats.buildAchievements()

    return ScrollView {
        VStack(spacing: 24) {
            Text("Badges").font(.headline)
            AchievementsGridView(achievements: achievements)
                .padding()

            Divider()

            Text("All Achievements").font(.headline)
            AchievementsListView(achievements: achievements)
        }
    }
}
