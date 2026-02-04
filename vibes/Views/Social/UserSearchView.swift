import SwiftUI
import FirebaseAuth

struct UserSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router
    @State private var viewModel = UserSearchViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search by name or username...", text: $viewModel.searchQuery)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.searchQuery) { _, _ in
                            viewModel.search()
                        }

                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            viewModel.searchQuery = ""
                            viewModel.results = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()

                Divider()

                // Results
                if viewModel.isLoading || viewModel.isLoadingAllUsers {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    ErrorView(
                        error: error,
                        retryAction: { viewModel.search() }
                    )
                    Spacer()
                } else if viewModel.displayedUsers.isEmpty && !viewModel.searchQuery.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "No Results",
                        message: "No users found for \"\(viewModel.searchQuery)\"",
                        icon: "person.slash"
                    )
                    Spacer()
                } else if viewModel.displayedUsers.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "No Users Yet",
                        message: "Be the first to invite friends!",
                        icon: "person.2"
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.displayedUsers) { user in
                                UserSearchRow(
                                    user: user,
                                    isFollowing: viewModel.isFollowing(user),
                                    isCurrentUser: user.uid == AuthManager.shared.user?.uid,
                                    onFollow: { await viewModel.follow(user) },
                                    onUnfollow: { await viewModel.unfollow(user) },
                                    onTap: {
                                        dismiss()
                                        router.navigateToUserProfile(user)
                                    }
                                )
                                .padding(.horizontal)

                                Divider()
                                    .padding(.leading, 74)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Find People")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadFollowingIds()
                await viewModel.loadAllUsers()
            }
        }
    }
}

#Preview {
    UserSearchView()
        .environment(AppRouter())
}
