//
//  ProfileView.swift
//  vibes
//
//  Profile tab - user identity and settings access.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var musicServiceManager = MusicServiceManager.shared
    @EnvironmentObject var authManager: AuthManager
    @Environment(AppRouter.self) private var router
    @StateObject private var friendsViewModel = FriendsViewModel()

    var body: some View {
        NavigationStack(path: Binding(
            get: { router.profilePath },
            set: { router.profilePath = $0 }
        )) {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if viewModel.profile != nil && !viewModel.isEditing {
                        ToolbarItem(placement: .primaryAction) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .imageScale(.large)
                                    .foregroundColor(Color(.label))
                            }
                        }
                    }
                    if viewModel.isEditing {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                viewModel.cancelEdit()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                HapticService.lightImpact()
                                Task {
                                    await viewModel.updateProfile()
                                    HapticService.success()
                                }
                            }
                            .disabled(viewModel.isLoading)
                        }
                    }
                }
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .settings:
                        SettingsView()
                    default:
                        EmptyView()
                    }
                }
        }
        .task {
            await viewModel.loadProfile()
            await loadFollowCounts()
        }
        .onDisappear {
            if viewModel.isEditing {
                Task {
                    await viewModel.updateProfile()
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let profile = viewModel.profile {
            profileContent(profile)
        } else {
            errorStateView
        }
    }

    private var errorStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Failed to load profile")
                .foregroundColor(Color(.secondaryLabel))
            Spacer()
        }
        .padding()
    }

    private func profileContent(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                profileHeader(profile)

                if !musicServiceManager.isAuthenticated {
                    setupCard
                }

                followSection

                if let error = viewModel.errorMessage {
                    errorSection(error)
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
        }
        .background(Color(.systemBackground))
        .refreshable {
            await viewModel.loadProfile()
            await loadFollowCounts()
        }
    }

    // MARK: - Profile Header

    private func profileHeader(_ profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(.tertiaryLabel))

            if viewModel.isEditing {
                TextField("Display Name", text: $viewModel.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 32)
            } else {
                Text(profile.displayName)
                    .font(.title)
                    .fontWeight(.bold)
            }

            Text("@\(profile.username)")
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))

            if !viewModel.isEditing {
                Button {
                    viewModel.toggleEditMode()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("Edit Profile")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Setup Card

    private var setupCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Connect Your Music")
                .font(.headline)

            Text("Connect Spotify or Apple Music to unlock personalized recommendations and discover what your friends are listening to.")
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)

            Button {
                router.goToSettings()
            } label: {
                HStack {
                    Image(systemName: "link")
                    Text("Connect in Settings")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .cardStyle()
    }

    // MARK: - Follow Section

    @State private var followerCount: Int = 0
    @State private var followingCount: Int = 0

    private var followSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friends")
                .font(.headline)

            HStack(spacing: 24) {
                VStack {
                    Text("\(followerCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("\(followingCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    // Navigate to add friends
                } label: {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Add")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(20)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    private func loadFollowCounts() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            let friends = try await FriendService.shared.fetchFriends()
            followingCount = friends.count
            followerCount = friends.count // For mutual friendships, these are the same
        } catch {
            print("Failed to load follow counts: \(error)")
        }
    }

    // MARK: - Error Section

    private func errorSection(_ error: String) -> some View {
        Text(error)
            .font(.caption)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .cardStyle()
    }
}

#Preview {
    ProfileView()
        .environment(AppRouter())
        .environmentObject(AuthManager.shared)
}
