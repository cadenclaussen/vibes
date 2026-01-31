import SwiftUI
import FirebaseAuth

struct FollowListView: View {
    @Environment(AppRouter.self) private var router
    @State var viewModel: FollowViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.users.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error, viewModel.users.isEmpty {
                ErrorView(
                    error: error,
                    retryAction: { Task { await viewModel.load() } }
                )
            } else if viewModel.users.isEmpty {
                EmptyStateView(
                    title: viewModel.mode == .followers ? "No Followers" : "Not Following Anyone",
                    message: viewModel.mode == .followers
                        ? "When people follow this account, they'll appear here."
                        : "Follow people to see their shared music.",
                    icon: viewModel.mode == .followers ? "person.2" : "person.badge.plus"
                )
            } else {
                List {
                    ForEach(viewModel.users) { user in
                        UserSearchRow(
                            user: user,
                            isFollowing: viewModel.isFollowing(user),
                            isCurrentUser: user.uid == AuthManager.shared.user?.uid,
                            onFollow: { await viewModel.follow(user) },
                            onUnfollow: { await viewModel.unfollow(user) },
                            onTap: {
                                router.navigateToUserProfile(user)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .navigationTitle("\(viewModel.title) (\(viewModel.users.count))")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    NavigationStack {
        FollowListView(
            viewModel: FollowViewModel(mode: .followers, userId: "test")
        )
    }
    .environment(AppRouter())
}
