import SwiftUI

struct ArtistFollowButton: View {
    let artist: UnifiedArtist

    @State private var isFollowing = false
    @State private var isLoading = true

    private let artistFollowService = ArtistFollowService.shared

    var body: some View {
        Button {
            Task {
                await toggleFollow()
            }
        } label: {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: isFollowing ? "checkmark" : "plus")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Text(isFollowing ? "Following" : "Follow")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isFollowing ? Color(.secondarySystemBackground) : Color.accentColor)
            .foregroundColor(isFollowing ? .primary : .white)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityLabel(isFollowing ? "Following \(artist.name)" : "Follow \(artist.name)")
        .accessibilityHint(isFollowing ? "Double tap to unfollow" : "Double tap to follow")
        .task {
            await loadFollowState()
        }
    }

    private func loadFollowState() async {
        isLoading = true
        isFollowing = await artistFollowService.isFollowing(artistId: artist.id)
        isLoading = false
    }

    private func toggleFollow() async {
        let wasFollowing = isFollowing

        // Optimistic update
        isFollowing.toggle()

        do {
            if wasFollowing {
                try await artistFollowService.unfollowArtist(artist.id)
            } else {
                try await artistFollowService.followArtist(artist)
            }
        } catch {
            isFollowing = wasFollowing
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ArtistFollowButton(
            artist: UnifiedArtist(
                id: "123",
                name: "Taylor Swift",
                imageURL: nil
            )
        )

        ArtistFollowButton(
            artist: UnifiedArtist(
                id: "456",
                name: "The Weeknd",
                imageURL: nil
            )
        )
    }
    .padding()
}
