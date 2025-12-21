//
//  SettingsMenu.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import SwiftUI

struct SettingsMenu: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool
    @State private var showingMenu = false
    @State private var showingDeleteAccount = false

    var body: some View {
        Button {
            showingMenu = true
        } label: {
            Image(systemName: "person.circle.fill")
                .imageScale(.large)
                .foregroundColor(Color(.label))
        }
        .popover(isPresented: $showingMenu, arrowEdge: .top) {
            VStack(spacing: 0) {
                Button {
                    showingMenu = false
                    selectedTab = 3
                } label: {
                    HStack {
                        Image(systemName: "gearshape")
                            .foregroundColor(Color(.label))
                        Text("Settings")
                            .foregroundColor(Color(.label))
                        Spacer()
                    }
                    .padding()
                    .contentShape(Rectangle())
                }

                Divider()

                Button {
                    showingMenu = false
                    showingDeleteAccount = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Delete Account")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .contentShape(Rectangle())
                }

                Divider()

                Button {
                    showingMenu = false
                    do {
                        try authManager.signOut()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Sign Out")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .contentShape(Rectangle())
                }
            }
            .frame(width: 200)
            .presentationCompactAdaptation(.popover)
        }
        .sheet(isPresented: $showingDeleteAccount) {
            DeleteAccountView()
        }
    }
}

// MARK: - Delete Account View

struct DeleteAccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var isDeleting = false
    @State private var errorMessage: String?
    @State private var showingConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("Delete Your Account")
                                .font(.headline)
                                .foregroundColor(.red)
                        }

                        Text("This action is permanent and cannot be undone. All your data will be deleted, including:")
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))

                        VStack(alignment: .leading, spacing: 4) {
                            bulletPoint("Your profile and settings")
                            bulletPoint("All messages and conversations")
                            bulletPoint("Friendships and vibestreaks")
                            bulletPoint("Shared songs and playlists")
                        }
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                    }
                }

                Section {
                    SecureField("Enter your password", text: $password)
                        .textContentType(.password)
                        .disabled(isDeleting)
                } header: {
                    Text("Confirm your password")
                } footer: {
                    Text("You must enter your password to confirm account deletion.")
                }

                if let error = errorMessage {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                }

                Section {
                    Button {
                        showingConfirmation = true
                    } label: {
                        if isDeleting {
                            HStack {
                                ProgressView()
                                Text("Deleting...")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("Delete My Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .listRowBackground(Color.red)
                    .disabled(password.isEmpty || isDeleting)
                }
            }
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isDeleting)
                }
            }
            .alert("Are you sure?", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("This will permanently delete your account and all associated data. This cannot be undone.")
            }
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }

    private func deleteAccount() async {
        isDeleting = true
        errorMessage = nil

        do {
            // Re-authenticate first
            try await authManager.reauthenticate(password: password)

            // Then delete account
            try await authManager.deleteAccount()

            // Dismiss will happen automatically as user is signed out
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isDeleting = false
    }
}
