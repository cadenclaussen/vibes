import SwiftUI

struct UserSearchRow: View {
    let user: UserProfile
    let isFollowing: Bool
    let isCurrentUser: Bool
    var onFollow: () async -> Void
    var onUnfollow: () async -> Void
    var onTap: (() -> Void)?

    @State private var isLoading = false
    @State private var showUnfollowConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            // Profile picture
            AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .overlay {
                        Text(user.displayName.prefix(1).uppercased())
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            // Name and username
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Follow button (hide for current user)
            if !isCurrentUser {
                Button {
                    if isFollowing {
                        showUnfollowConfirm = true
                    } else {
                        Task {
                            isLoading = true
                            await onFollow()
                            isLoading = false
                        }
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(width: 80, height: 32)
                    } else {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(isFollowing ? Color.primary : Color.white)
                            .frame(width: 80, height: 32)
                            .background(isFollowing ? Color(.tertiarySystemFill) : Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
                .buttonStyle(.plain)
                .confirmationDialog(
                    "Unfollow @\(user.username)?",
                    isPresented: $showUnfollowConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Unfollow", role: .destructive) {
                        Task {
                            isLoading = true
                            await onUnfollow()
                            isLoading = false
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    VStack {
        UserSearchRow(
            user: UserProfile(
                uid: "1",
                email: "john@example.com",
                username: "johnsmith",
                displayName: "John Smith"
            ),
            isFollowing: false,
            isCurrentUser: false,
            onFollow: {},
            onUnfollow: {}
        )

        UserSearchRow(
            user: UserProfile(
                uid: "2",
                email: "jane@example.com",
                username: "janedoe",
                displayName: "Jane Doe"
            ),
            isFollowing: true,
            isCurrentUser: false,
            onFollow: {},
            onUnfollow: {}
        )
    }
    .padding()
}
