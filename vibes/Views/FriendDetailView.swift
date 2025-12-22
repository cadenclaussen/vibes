//
//  FriendDetailView.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import SwiftUI

struct FriendDetailView: View {
    let friend: FriendProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                genresSection
            }
            .padding()
        }
        .navigationTitle(friend.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(.tertiaryLabel))

            Text(friend.displayName)
                .font(.title)
                .fontWeight(.bold)

            Text("@\(friend.username)")
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorite Genres")
                .font(.headline)

            if friend.musicTasteTags.isEmpty {
                Text("No genres added")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(friend.musicTasteTags, id: \.self) { genre in
                        Text(genre)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(16)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
        
    }
}
