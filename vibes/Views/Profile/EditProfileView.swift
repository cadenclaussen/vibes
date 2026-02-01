import SwiftUI
import PhotosUI
import FirebaseAuth

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager

    let onSave: () async -> Void

    @State private var displayName: String
    @State private var bio: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isSaving = false
    @State private var error: Error?
    @State private var showError = false

    private let profileService = ProfileService.shared
    private let maxDisplayNameLength = 50
    private let maxBioLength = 160

    init(profile: UserProfile, onSave: @escaping () async -> Void) {
        _displayName = State(initialValue: profile.displayName)
        _bio = State(initialValue: profile.bio ?? "")
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                // Profile picture section
                Section {
                    profilePictureSection
                }

                // Display name section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Display Name", text: $displayName)
                            .textContentType(.name)
                            .onChange(of: displayName) { _, newValue in
                                if newValue.count > maxDisplayNameLength {
                                    displayName = String(newValue.prefix(maxDisplayNameLength))
                                }
                            }
                        HStack {
                            Spacer()
                            Text("\(displayName.count)/\(maxDisplayNameLength)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Display Name")
                }

                // Bio section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Tell others about yourself...", text: $bio, axis: .vertical)
                            .lineLimit(3...6)
                            .onChange(of: bio) { _, newValue in
                                if newValue.count > maxBioLength {
                                    bio = String(newValue.prefix(maxBioLength))
                                }
                            }
                        HStack {
                            Spacer()
                            Text("\(bio.count)/\(maxBioLength)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Bio")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task { await saveProfile() }
                        }
                        .disabled(!canSave)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(error?.localizedDescription ?? "An error occurred")
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    await loadImage(from: newValue)
                }
            }
            .interactiveDismissDisabled(isSaving)
        }
    }

    private var profilePictureSection: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    profileImageView
                }

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text("Change Photo")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentColor)
                }
            }
            Spacer()
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private var profileImageView: some View {
        if let selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color(.separator), lineWidth: 1)
                }
                .overlay(alignment: .bottomTrailing) {
                    editBadge
                }
        } else if let url = authManager.userProfile?.profilePictureURL,
                  let imageURL = URL(string: url) {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                placeholderImage
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(alignment: .bottomTrailing) {
                editBadge
            }
        } else {
            placeholderImage
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(alignment: .bottomTrailing) {
                    editBadge
                }
        }
    }

    private var placeholderImage: some View {
        Circle()
            .fill(Color(.tertiarySystemFill))
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
            }
    }

    private var editBadge: some View {
        Image(systemName: "camera.fill")
            .font(.caption)
            .foregroundStyle(.white)
            .padding(6)
            .background(Color.accentColor)
            .clipShape(Circle())
    }

    private var canSave: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            // Silently fail - user can try again
        }
    }

    private func saveProfile() async {
        guard let userId = authManager.user?.uid else {
            error = ProfileError.notAuthenticated
            showError = true
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            var profilePictureURL: String?

            // Upload new image if selected
            if let image = selectedImage {
                profilePictureURL = try await profileService.uploadProfilePicture(image, userId: userId)
            }

            // Update profile in Firestore
            try await profileService.updateProfile(
                userId: userId,
                displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
                profilePictureURL: profilePictureURL
            )

            // Reload profile in AuthManager
            await authManager.loadUserProfile(userId: userId)

            // Notify parent
            await onSave()

            dismiss()
        } catch {
            self.error = error
            showError = true
        }
    }
}

#Preview {
    EditProfileView(
        profile: UserProfile(
            uid: "1",
            email: "test@example.com",
            username: "testuser",
            displayName: "Test User",
            bio: "Music lover"
        ),
        onSave: {}
    )
    .environment(AuthManager.shared)
}
