//
//  ProfileEditView.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss

    @State private var displayName: String
    @State private var genreInput = ""
    @State private var musicTasteTags: [String]

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        _displayName = State(initialValue: viewModel.profile?.displayName ?? "")
        _musicTasteTags = State(initialValue: viewModel.profile?.musicTasteTags ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Display Name") {
                    TextField("Display Name", text: $displayName)
                }

                Section("Favorite Genres") {
                    ForEach(musicTasteTags, id: \.self) { genre in
                        HStack {
                            Text(genre)
                            Spacer()
                            Button(action: {
                                musicTasteTags.removeAll { $0 == genre }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    HStack {
                        TextField("Add genre", text: $genreInput)
                        Button(action: addGenre) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(genreInput.isEmpty)
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveProfile()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }

    private func addGenre() {
        let trimmed = genreInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !musicTasteTags.contains(trimmed) else { return }
        musicTasteTags.append(trimmed)
        genreInput = ""
    }

    private func saveProfile() async {
        guard var profile = viewModel.profile else { return }

        profile.displayName = displayName
        profile.musicTasteTags = musicTasteTags

        viewModel.profile = profile
        await viewModel.updateProfile()

        if viewModel.errorMessage == nil {
            dismiss()
        }
    }
}
