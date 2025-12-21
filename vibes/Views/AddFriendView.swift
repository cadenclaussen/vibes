//
//  AddFriendView.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import SwiftUI

struct AddFriendView: View {
    @ObservedObject var viewModel: FriendsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var username = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter your friend's username")
                    .font(.headline)
                    .foregroundColor(Color(.secondaryLabel))

                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(.horizontal)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        HapticService.lightImpact()
                        Task {
                            await viewModel.sendFriendRequest(username: username)
                            if viewModel.errorMessage == nil {
                                HapticService.success()
                                dismiss()
                            } else {
                                HapticService.error()
                            }
                        }
                    }
                    .disabled(username.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}
