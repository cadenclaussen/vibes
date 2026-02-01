import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SpotifyRemoteService.self) private var spotifyRemote
    let user: UserProfile

    @State private var followerCount = 0
    @State private var followingCount = 0
    @State private var isFollowing = false
    @State private var isLoading = true
    @State private var isFollowLoading = false
    @State private var sharedSongs: [SongShare] = []
    @State private var isLoadingShares = false
    @State private var isMuted = false
    @State private var isMuteLoading = false

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

                // Shared songs section
                sharedSongsSection
            }
            .padding(.top, 20)
        }
        .navigationTitle("@\(user.username)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if user.uid != AuthManager.shared.user?.uid {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            Task { await toggleMute() }
                        } label: {
                            if isMuteLoading {
                                Label("Loading...", systemImage: "hourglass")
                            } else if isMuted {
                                Label("Unmute", systemImage: "speaker.wave.2")
                            } else {
                                Label("Mute", systemImage: "speaker.slash")
                            }
                        }
                        .disabled(isMuteLoading)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .task {
            await loadData()
            await loadSharedSongs()
        }
    }

    private var sharedSongsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shared Songs")
                .font(.headline)
                .padding(.horizontal)

            if isLoadingShares {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
            } else if sharedSongs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("No shared songs yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(sharedSongs) { share in
                        SongShareCard(share: share) {
                            navigateToSender(share: share)
                        }
                        Divider()
                    }
                }
            }
        }
    }

    private func navigateToSender(share: SongShare) {
        // Don't navigate if tapping on same user's profile
        guard share.senderId != user.uid else { return }

        let senderProfile = UserProfile(
            uid: share.senderId,
            email: "",
            username: share.senderUsername,
            displayName: share.senderUsername,
            profilePictureURL: share.senderProfilePicture
        )
        router.navigateToUserProfile(senderProfile)
    }

    private func loadSharedSongs() async {
        isLoadingShares = true
        do {
            sharedSongs = try await socialService.getUserShares(userId: user.uid, limit: 50)
        } catch {
            // Silently fail
        }
        isLoadingShares = false
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

            // Muted indicator
            if isMuted {
                Label("Muted", systemImage: "speaker.slash.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.secondary)
                    .clipShape(Capsule())
            }

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
            Task {
                if isFollowing {
                    await unfollow()
                } else {
                    await follow()
                }
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
    }

    private func loadData() async {
        isLoading = true

        async let followerTask = socialService.getFollowerCount(for: user.uid)
        async let followingTask = socialService.getFollowingCount(for: user.uid)
        async let isFollowingTask = socialService.isFollowing(userId: user.uid)
        async let isMutedTask = socialService.isMuted(userId: user.uid)

        do {
            followerCount = try await followerTask
            followingCount = try await followingTask
            isFollowing = try await isFollowingTask
            isMuted = try await isMutedTask
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

    private func toggleMute() async {
        isMuteLoading = true
        do {
            if isMuted {
                try await socialService.unmute(userId: user.uid)
                isMuted = false
            } else {
                try await socialService.mute(userId: user.uid)
                isMuted = true
            }
        } catch {
            print("Mute error: \(error)")
        }
        isMuteLoading = false
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
    .environment(SpotifyRemoteService.shared)
}
