import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    @Environment(AppRouter.self) private var router
    let user: UserProfile

    @State private var followerCount = 0
    @State private var followingCount = 0
    @State private var isFollowing = false
    @State private var isLoading = true
    @State private var isFollowLoading = false
    @State private var showUnfollowConfirm = false

    private let socialService = SocialService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                profileHeader

                // Follow counts
                followCounts

                // Follow button
                if user.uid != AuthManager.shared.user?.uid {
                    followButton
                }

                Divider()
                    .padding(.horizontal)

                // Placeholder for future content (shared songs, etc.)
                VStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("Shared songs coming soon")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
            }
            .padding(.top, 20)
        }
        .navigationTitle("@\(user.username)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadData()
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
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
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())

            // Display name
            Text(user.displayName)
                .font(.title2)
                .fontWeight(.bold)

            // Bio
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }

    private var followCounts: some View {
        HStack(spacing: 40) {
            Button {
                router.navigateToFollowers(for: user.uid)
            } label: {
                VStack(spacing: 4) {
                    if isLoading {
                        ProgressView()
                            .frame(height: 24)
                    } else {
                        Text("\(followerCount)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    Text("Followers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            Button {
                router.navigateToFollowing(for: user.uid)
            } label: {
                VStack(spacing: 4) {
                    if isLoading {
                        ProgressView()
                            .frame(height: 24)
                    } else {
                        Text("\(followingCount)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    Text("Following")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var followButton: some View {
        Button {
            if isFollowing {
                showUnfollowConfirm = true
            } else {
                Task { await follow() }
            }
        } label: {
            if isFollowLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            } else {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.headline)
                    .foregroundStyle(isFollowing ? Color.primary : Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(isFollowing ? Color(.tertiarySystemFill) : Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .confirmationDialog(
            "Unfollow @\(user.username)?",
            isPresented: $showUnfollowConfirm,
            titleVisibility: .visible
        ) {
            Button("Unfollow", role: .destructive) {
                Task { await unfollow() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func loadData() async {
        isLoading = true

        async let followerTask = socialService.getFollowerCount(for: user.uid)
        async let followingTask = socialService.getFollowingCount(for: user.uid)
        async let isFollowingTask = socialService.isFollowing(userId: user.uid)

        do {
            followerCount = try await followerTask
            followingCount = try await followingTask
            isFollowing = try await isFollowingTask
        } catch {
            // Silently fail - show 0 counts
        }

        isLoading = false
    }

    private func follow() async {
        isFollowLoading = true
        do {
            try await socialService.follow(userId: user.uid)
            isFollowing = true
            followerCount += 1
        } catch {
            // Silently fail
        }
        isFollowLoading = false
    }

    private func unfollow() async {
        isFollowLoading = true
        do {
            try await socialService.unfollow(userId: user.uid)
            isFollowing = false
            followerCount = max(0, followerCount - 1)
        } catch {
            // Silently fail
        }
        isFollowLoading = false
    }
}

#Preview {
    NavigationStack {
        UserProfileView(
            user: UserProfile(
                uid: "1",
                email: "john@example.com",
                username: "johnsmith",
                displayName: "John Smith",
                bio: "Music lover and vinyl collector"
            )
        )
    }
    .environment(AppRouter())
}
