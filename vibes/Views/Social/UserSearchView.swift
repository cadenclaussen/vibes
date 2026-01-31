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
                if viewModel.isLoading {
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
                } else if viewModel.results.isEmpty && !viewModel.searchQuery.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "No Results",
                        message: "No users found for \"\(viewModel.searchQuery)\"",
                        icon: "person.slash"
                    )
                    Spacer()
                } else if viewModel.results.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "Find People",
                        message: "Search for friends by name or username",
                        icon: "person.2"
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.results) { user in
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
            }
        }
    }
}

#Preview {
    UserSearchView()
        .environment(AppRouter())
}
