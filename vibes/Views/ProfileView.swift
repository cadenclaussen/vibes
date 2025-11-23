//
//  ProfileView.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showingEditSheet = false

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Profile")
                .toolbar {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
                .sheet(isPresented: $showingEditSheet) {
                    ProfileEditView(viewModel: viewModel)
                }
        }
        .task {
            await viewModel.loadProfile()
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
            signOutButton
        }
        .padding()
    }

    private func profileContent(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader(profile)
                infoSection(profile)
                genresSection(profile)
                signOutButton
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }

    private func profileHeader(_ profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(.tertiaryLabel))

            Text(profile.displayName)
                .font(.title)
                .fontWeight(.bold)

            Text("@\(profile.username)")
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    private func infoSection(_ profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            infoRow(label: "Email", value: profile.email)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(Color(.secondaryLabel))

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(Color(.label))
        }
    }

    private func genresSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorite Genres")
                .font(.headline)

            if profile.musicTasteTags.isEmpty {
                Text("No genres added yet")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(profile.musicTasteTags, id: \.self) { genre in
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var signOutButton: some View {
        Button(action: {
            do {
                try authManager.signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }) {
            Text("Sign Out")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager.shared)
}
