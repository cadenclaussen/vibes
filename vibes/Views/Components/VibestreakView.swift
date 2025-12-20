//
//  VibestreakView.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI

enum StreakTier {
    case none       // 0 days
    case starter    // 1-6 days - gray
    case bronze     // 7-29 days - bronze
    case silver     // 30-99 days - silver
    case gold       // 100-364 days - gold
    case legendary  // 365+ days - animated

    init(days: Int) {
        switch days {
        case 0:
            self = .none
        case 1...6:
            self = .starter
        case 7...29:
            self = .bronze
        case 30...99:
            self = .silver
        case 100...364:
            self = .gold
        default:
            self = .legendary
        }
    }

    var color: Color {
        switch self {
        case .none:
            return .clear
        case .starter:
            return Color(.systemGray)
        case .bronze:
            return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver:
            return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold:
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .legendary:
            return Color(red: 1.0, green: 0.5, blue: 0.0)
        }
    }

    var iconName: String {
        switch self {
        case .legendary:
            return "flame.fill"
        default:
            return "flame"
        }
    }

    var glowColor: Color? {
        switch self {
        case .gold:
            return Color.yellow.opacity(0.3)
        case .legendary:
            return Color.orange.opacity(0.5)
        default:
            return nil
        }
    }
}

struct VibestreakView: View {
    let streak: Int
    var size: StreakSize = .medium

    enum StreakSize {
        case small   // For chat list
        case medium  // For message header
        case large   // For profile display

        var fontSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .title3
            }
        }

        var iconSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .title2
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
            case .medium: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }

    private var tier: StreakTier {
        StreakTier(days: streak)
    }

    var body: some View {
        if streak > 0 {
            HStack(spacing: 3) {
                streakIcon
                Text("\(streak)")
                    .font(size.fontSize)
                    .fontWeight(.semibold)
            }
            .foregroundColor(tier.color)
            .padding(size.padding)
            .background(backgroundView)
        }
    }

    @ViewBuilder
    private var streakIcon: some View {
        if tier == .legendary {
            AnimatedFlameIcon(size: size.iconSize)
        } else {
            Image(systemName: tier.iconName)
                .font(size.iconSize)
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if let glowColor = tier.glowColor {
            Capsule()
                .fill(glowColor)
        }
    }
}

struct AnimatedFlameIcon: View {
    let size: Font
    @State private var isAnimating = false

    var body: some View {
        Image(systemName: "flame.fill")
            .font(size)
            .scaleEffect(isAnimating ? 1.15 : 1.0)
            .animation(
                .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// Large display version for profile
struct VibestreakBadgeView: View {
    let streak: Int
    let friendName: String?

    private var tier: StreakTier {
        StreakTier(days: streak)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(tier.color.opacity(0.2))
                    .frame(width: 80, height: 80)

                if tier == .legendary {
                    Circle()
                        .stroke(tier.color, lineWidth: 3)
                        .frame(width: 80, height: 80)
                        .scaleEffect(1.1)
                        .opacity(0.5)
                }

                VStack(spacing: 2) {
                    if tier == .legendary {
                        AnimatedFlameIcon(size: .title)
                            .foregroundColor(tier.color)
                    } else {
                        Image(systemName: tier.iconName)
                            .font(.title)
                            .foregroundColor(tier.color)
                    }

                    Text("\(streak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(tier.color)
                }
            }

            if let name = friendName {
                Text("with \(name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(tierLabel)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(tier.color)
                .textCase(.uppercase)
        }
    }

    private var tierLabel: String {
        switch tier {
        case .none: return ""
        case .starter: return "Starter"
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        case .legendary: return "Legendary"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Streak Tiers").font(.headline)

        HStack(spacing: 16) {
            VStack {
                VibestreakView(streak: 3, size: .small)
                Text("Starter").font(.caption2)
            }
            VStack {
                VibestreakView(streak: 14, size: .small)
                Text("Bronze").font(.caption2)
            }
            VStack {
                VibestreakView(streak: 45, size: .small)
                Text("Silver").font(.caption2)
            }
            VStack {
                VibestreakView(streak: 150, size: .small)
                Text("Gold").font(.caption2)
            }
            VStack {
                VibestreakView(streak: 400, size: .small)
                Text("Legendary").font(.caption2)
            }
        }

        Divider()

        Text("Medium Size").font(.headline)
        VibestreakView(streak: 100, size: .medium)

        Divider()

        Text("Large Badge").font(.headline)
        VibestreakBadgeView(streak: 365, friendName: "John")
    }
    .padding()
}
