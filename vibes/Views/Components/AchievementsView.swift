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

    var progressPercentage: Double {
        guard requirement > 0 else { return 1.0 }
        return min(Double(progress) / Double(requirement), 1.0)
    }
}

enum AchievementCategory: String, CaseIterable {
    case sharing = "Sharing"
    case social = "Social"
    case streak = "Streaks"
    case discovery = "Discovery"

    var color: Color {
        switch self {
        case .sharing: return .blue
        case .social: return .green
        case .streak: return .orange
        case .discovery: return .purple
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

    static let all: [AchievementDefinition] = [
        // Sharing achievements
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

        // Social achievements
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

        // Streak achievements
        AchievementDefinition(
            id: "streak_7",
            name: "Week Warrior",
            description: "Maintain a 7-day vibestreak",
            icon: "flame",
            category: .streak,
            requirement: 7
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
            id: "streak_100",
            name: "Centurion",
            description: "Maintain a 100-day vibestreak",
            icon: "flame.circle.fill",
            category: .streak,
            requirement: 100
        ),
        AchievementDefinition(
            id: "streak_365",
            name: "Legendary",
            description: "Maintain a 365-day vibestreak",
            icon: "crown.fill",
            category: .streak,
            requirement: 365
        ),

        // Discovery achievements
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
            id: "genres_5",
            name: "Eclectic",
            description: "Have 5 favorite genres",
            icon: "music.mic",
            category: .discovery,
            requirement: 5
        ),
    ]
}

struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? achievement.category.color.opacity(0.2)
                          : Color(.tertiarySystemFill))
                    .frame(width: 60, height: 60)

                if !achievement.isUnlocked {
                    Circle()
                        .trim(from: 0, to: achievement.progressPercentage)
                        .stroke(achievement.category.color.opacity(0.5), lineWidth: 3)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                }

                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked
                                     ? achievement.category.color
                                     : Color(.tertiaryLabel))
            }

            Text(achievement.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .lineLimit(1)

            if !achievement.isUnlocked {
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

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? achievement.category.color.opacity(0.2)
                          : Color(.tertiarySystemFill))
                    .frame(width: 50, height: 50)

                if !achievement.isUnlocked {
                    Circle()
                        .trim(from: 0, to: achievement.progressPercentage)
                        .stroke(achievement.category.color.opacity(0.5), lineWidth: 2)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                }

                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundColor(achievement.isUnlocked
                                     ? achievement.category.color
                                     : Color(.tertiaryLabel))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)

                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
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
        if showAll {
            return achievements
        }
        let unlocked = achievements.filter { $0.isUnlocked }
        let locked = achievements.filter { !$0.isUnlocked }
        return Array((unlocked + locked).prefix(6))
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
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
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

struct AchievementStats {
    var songsShared: Int = 0
    var friendsCount: Int = 0
    var maxVibestreak: Int = 0
    var isSpotifyConnected: Bool = false
    var playlistsShared: Int = 0
    var genresCount: Int = 0

    func buildAchievements() -> [Achievement] {
        AchievementDefinition.all.map { def in
            let progress: Int
            let isUnlocked: Bool

            switch def.id {
            case "first_share", "share_10", "share_50", "share_100":
                progress = songsShared
                isUnlocked = songsShared >= def.requirement
            case "first_friend", "friends_5", "friends_10", "friends_25":
                progress = friendsCount
                isUnlocked = friendsCount >= def.requirement
            case "streak_7", "streak_30", "streak_100", "streak_365":
                progress = maxVibestreak
                isUnlocked = maxVibestreak >= def.requirement
            case "spotify_connect":
                progress = isSpotifyConnected ? 1 : 0
                isUnlocked = isSpotifyConnected
            case "playlist_share":
                progress = playlistsShared
                isUnlocked = playlistsShared >= def.requirement
            case "genres_5":
                progress = genresCount
                isUnlocked = genresCount >= def.requirement
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
                progress: progress
            )
        }
    }
}

#Preview {
    let stats = AchievementStats(
        songsShared: 15,
        friendsCount: 3,
        maxVibestreak: 12,
        isSpotifyConnected: true,
        playlistsShared: 0,
        genresCount: 4
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
