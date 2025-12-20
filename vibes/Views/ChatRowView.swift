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
            // Avatar
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(.tertiaryLabel))

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
                    Text(chat.lastMessage.isEmpty ? "No messages yet" : chat.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(1)

                    Spacer()

                    HStack(spacing: 8) {
                        // Vibestreak
                        VibestreakView(streak: chat.vibestreak, size: .small)

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
            vibestreak: 5
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
            vibestreak: 0
        ))
    }
    .background(Color(.secondarySystemBackground))
}
