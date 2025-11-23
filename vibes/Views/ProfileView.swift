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
    @Binding var shouldEditProfile: Bool
    @State private var genreInput = ""

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Profile")
                .toolbar {
                    if viewModel.profile != nil {
                        toolbarContent
                    }
                }
        }
        .task {
            await viewModel.loadProfile()
        }
        .onChange(of: shouldEditProfile) { _, newValue in
            if newValue && !viewModel.isEditing {
                viewModel.toggleEditMode()
                shouldEditProfile = false
            }
        }
        .onDisappear {
            if viewModel.isEditing {
                Task {
                    await viewModel.updateProfile()
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if viewModel.isEditing {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    viewModel.cancelEdit()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        await viewModel.updateProfile()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                SettingsMenu(selectedTab: .constant(3), shouldEditProfile: $shouldEditProfile)
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
            VStack(spacing: 24) {
                profileHeader(profile)
                infoSection(profile)
                genresSection(profile)

                if let error = viewModel.errorMessage {
                    errorSection(error)
                }
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

            if viewModel.isEditing {
                editingGenresView
            } else {
                displayGenresView(profile)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func displayGenresView(_ profile: UserProfile) -> some View {
        Group {
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
    }

    private var editingGenresView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.musicTasteTags.isEmpty {
                Text("No genres added yet")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.musicTasteTags, id: \.self) { genre in
                        HStack(spacing: 4) {
                            Text(genre)
                                .font(.caption)
                            Button(action: {
                                viewModel.musicTasteTags.removeAll { $0 == genre }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(16)
                    }
                }
            }

            HStack {
                TextField("Add genre", text: $genreInput)
                    .textFieldStyle(.roundedBorder)
                Button(action: addGenre) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(genreInput.isEmpty)
            }
        }
    }

    private func errorSection(_ error: String) -> some View {
        Text(error)
            .font(.caption)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }

    private func addGenre() {
        let trimmed = genreInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !viewModel.musicTasteTags.contains(trimmed) else { return }
        viewModel.musicTasteTags.append(trimmed)
        genreInput = ""
    }
}

#Preview {
    ProfileView(shouldEditProfile: .constant(false))
        .environmentObject(AuthManager.shared)
}
