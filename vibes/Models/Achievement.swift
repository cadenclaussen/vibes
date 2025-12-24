//
//  Achievement.swift
//  vibes
//
//  Models for the achievements system.
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
    let isSuperSecret: Bool
    let showsProgressCount: Bool

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
        if showsProgressCount {
            return "\(description) (\(progress.formatted()) total)"
        }
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
    let isSuperSecret: Bool
    let showsProgressCount: Bool

    init(
        id: String,
        name: String,
        description: String,
        icon: String,
        category: AchievementCategory,
        requirement: Int,
        isSecret: Bool = false,
        isSuperSecret: Bool = false,
        showsProgressCount: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.requirement = requirement
        self.isSecret = isSecret
        self.isSuperSecret = isSuperSecret
        self.showsProgressCount = showsProgressCount
    }
}
