//
//  AchievementsView.swift
//  vibes
//
//  Achievement view components.
//

import SwiftUI

// MARK: - Achievement Badge

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

                if achievement.isSecret && achievement.isUnlocked {
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }

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

// MARK: - Achievement Row

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

                if achievement.isSecret && achievement.isUnlocked {
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 50, height: 50)
                }

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
                HStack(spacing: 4) {
                    Text(achievement.displayName)
                        .font(.headline)
                        .foregroundColor(achievement.isUnlocked ? .primary : .secondary)

                    if achievement.isSecret && achievement.isUnlocked {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }

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
        .cardStyle()
        .overlay(
            Group {
                if achievement.isSecret && achievement.isUnlocked {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                }
            }
        )
    }
}

// MARK: - Achievements Grid View

struct AchievementsGridView: View {
    let achievements: [Achievement]
    var showAll: Bool = false

    var displayedAchievements: [Achievement] {
        let unlocked = achievements.filter { $0.isUnlocked && (!$0.isSuperSecret || $0.isUnlocked) }
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

// MARK: - Achievements List View

struct AchievementsListView: View {
    let achievements: [Achievement]
    @State private var selectedCategory: AchievementCategory?

    var filteredAchievements: [Achievement] {
        var filtered = achievements.filter { !$0.isSuperSecret || $0.isUnlocked }

        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
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

// MARK: - Achievement Banner View

struct AchievementBannerView: View {
    let achievement: Achievement
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isSecret ? Color.yellow.opacity(0.3) : achievement.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)

                if achievement.isSecret {
                    Circle()
                        .stroke(Color.yellow, lineWidth: 2)
                        .frame(width: 50, height: 50)
                }

                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isSecret ? .yellow : achievement.category.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.isSecret ? "Secret Achievement Unlocked!" : "Achievement Unlocked!")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(achievement.isSecret ? .yellow : .secondary)

                Text(achievement.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: achievement.isSecret ? "star.fill" : "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(achievement.isSecret ? .yellow : .green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: achievement.isSecret ? .yellow.opacity(0.3) : .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.isSecret ? Color.yellow : achievement.category.color.opacity(0.3), lineWidth: achievement.isSecret ? 2 : 1)
        )
        .overlay(
            Group {
                if achievement.isSecret {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.3), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .mask(RoundedRectangle(cornerRadius: 16))
                }
            }
        )
        .padding(.horizontal)
        .onAppear {
            if achievement.isSecret {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmerOffset = 400
                }
            }
        }
    }
}

// MARK: - Achievement Banner Overlay

struct AchievementBannerOverlay: View {
    @ObservedObject var notificationService = AchievementNotificationService.shared

    var body: some View {
        VStack {
            if notificationService.isShowingBanner, let achievement = notificationService.currentBanner {
                AchievementBannerView(achievement: achievement)
                    .padding(.horizontal, 16)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
