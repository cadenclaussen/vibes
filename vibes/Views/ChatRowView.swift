//
//  ChatRowView.swift
//  vibes
//
//  Created by Claude Code on 12/19/25.
//

import SwiftUI

struct ChatRowView: View {
    let chat: ChatItem

    var body: some View {
        HStack(spacing: 12) {
            // Avatar with online indicator
            ZStack(alignment: .bottomTrailing) {
                avatarView
                    .frame(width: 50, height: 50)

                if chat.friend.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: 2, y: 2)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name)
                        .font(.headline)
                        .foregroundColor(Color(.label))
                        .lineLimit(1)

                    Spacer()

                    Text(chat.displayTime)
                        .font(.caption)
                        .foregroundColor(Color(.tertiaryLabel))
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chat.lastMessage.isEmpty ? "No messages yet" : chat.lastMessage)
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))
                            .lineLimit(1)

                        if let lastSeenText = chat.friend.lastSeenText, !chat.friend.isOnline {
                            Text(lastSeenText)
                                .font(.caption2)
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        // Compatibility badge
                        if let compatibility = chat.compatibility, compatibility.score > 0 {
                            CompatibilityBadge(compatibility: compatibility)
                        }

                        // Vibestreak
                        VibestreakView(streak: chat.vibestreak, completedToday: chat.vibestreakCompletedToday, size: .small)

                        // Unread badge
                        if chat.unreadCount > 0 {
                            Text(chat.unreadCount > 99 ? "99+" : "\(chat.unreadCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Image(systemName: "chevron.right")
                .foregroundColor(Color(.tertiaryLabel))
                .imageScale(.small)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var avatarView: some View {
        if let urlString = chat.friend.profilePictureURL,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                case .failure, .empty:
                    placeholderAvatar
                @unknown default:
                    placeholderAvatar
                }
            }
        } else {
            placeholderAvatar
        }
    }

    private var placeholderAvatar: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(Color(.tertiaryLabel))
    }
}

#Preview {
    VStack(spacing: 0) {
        ChatRowView(chat: ChatItem(
            id: "1",
            name: "John Doe",
            lastMessage: "Hey, check out this song!",
            timestamp: Date(),
            unreadCount: 3,
            friend: FriendProfile(
                from: UserProfile(uid: "1", email: "john@test.com", username: "johndoe")
            ),
            vibestreak: 5,
            vibestreakCompletedToday: true,
            compatibility: CompatibilityResult(score: 85, sharedArtists: ["Taylor Swift"], sharedGenres: ["Pop"])
        ))
        Divider()
        ChatRowView(chat: ChatItem(
            id: "2",
            name: "Jane Smith",
            lastMessage: "Thanks for sharing!",
            timestamp: Date().addingTimeInterval(-3600),
            unreadCount: 0,
            friend: FriendProfile(
                from: UserProfile(uid: "2", email: "jane@test.com", username: "janesmith")
            ),
            vibestreak: 7,
            vibestreakCompletedToday: false,
            compatibility: CompatibilityResult(score: 45, sharedArtists: [], sharedGenres: ["Rock"])
        ))
    }
    .cardStyle()
}

// MARK: - Compatibility Badge

struct CompatibilityBadge: View {
    let compatibility: CompatibilityResult

    private var badgeColor: Color {
        switch compatibility.level {
        case .high: return .green
        case .medium: return .orange
        case .low: return .gray
        }
    }

    private var iconName: String {
        switch compatibility.level {
        case .high: return "flame.fill"
        case .medium: return "star.fill"
        case .low: return "sparkle"
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: iconName)
                .font(.system(size: 8))
            Text("\(compatibility.score)%")
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(badgeColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(badgeColor.opacity(0.15))
        .clipShape(Capsule())
    }
}
