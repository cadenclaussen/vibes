//
//  CreateGroupView.swift
//  vibes
//
//  Created by Claude Code on 12/21/25.
//

import SwiftUI
import Combine
import FirebaseAuth

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateGroupViewModel()
    @State private var groupName = ""
    @State private var isCreating = false
    @State private var showingDuplicateAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Group name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Group Name")
                        .font(.headline)

                    TextField("Enter group name", text: $groupName)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(10)
                }
                .padding()

                Divider()

                // Selected friends
                if !viewModel.selectedFriends.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected (\(viewModel.selectedFriends.count))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.selectedFriends) { friend in
                                    SelectedFriendChip(friend: friend) {
                                        viewModel.toggleSelection(friend)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)

                    Divider()
                }

                // Friends list
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Friends")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if viewModel.friends.isEmpty {
                        Spacer()
                        Text("No friends to add")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.friends) { friend in
                                FriendSelectionRow(
                                    friend: friend,
                                    isSelected: viewModel.isSelected(friend)
                                ) {
                                    viewModel.toggleSelection(friend)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGroup()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canCreate || isCreating)
                }
            }
            .task {
                await viewModel.loadFriends()
            }
            .alert(isPresented: $showingDuplicateAlert) {
                duplicateAlert
            }
        }
    }

    private var canCreate: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty &&
        viewModel.selectedFriends.count >= 1
    }

    private func createGroup() {
        guard canCreate else { return }
        isCreating = true
        HapticService.lightImpact()

        Task {
            let result = await viewModel.createGroup(name: groupName.trimmingCharacters(in: .whitespaces))
            switch result {
            case .success:
                HapticService.success()
                dismiss()
            case .alreadyExists:
                HapticService.warning()
                showingDuplicateAlert = true
                isCreating = false
            case .failure:
                isCreating = false
            }
        }
    }
}

extension CreateGroupView {
    var duplicateAlert: Alert {
        Alert(
            title: Text("Group Already Exists"),
            message: Text("A group with these exact members already exists. You can find it in your Groups list."),
            dismissButton: .default(Text("OK"))
        )
    }
}

struct SelectedFriendChip: View {
    let friend: FriendProfile
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(friend.displayName)
                .font(.subheadline)
                .lineLimit(1)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemFill))
        .clipShape(Capsule())
    }
}

struct FriendSelectionRow: View {
    let friend: FriendProfile
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                if let urlString = friend.profilePictureURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    Text("@\(friend.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .font(.title2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

@MainActor
class CreateGroupViewModel: ObservableObject {
    @Published var friends: [FriendProfile] = []
    @Published var selectedFriends: [FriendProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let friendService = FriendService.shared
    private let firestoreService = FirestoreService.shared

    func loadFriends() async {
        isLoading = true
        do {
            friends = try await friendService.fetchFriends()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func isSelected(_ friend: FriendProfile) -> Bool {
        selectedFriends.contains { $0.id == friend.id }
    }

    func toggleSelection(_ friend: FriendProfile) {
        HapticService.selectionChanged()
        if isSelected(friend) {
            selectedFriends.removeAll { $0.id == friend.id }
        } else {
            selectedFriends.append(friend)
        }
    }

    func createGroup(name: String) async -> CreateGroupResult {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return .failure("Not authenticated")
        }

        let participantIds = selectedFriends.map { $0.id }

        do {
            let groupId = try await firestoreService.createGroup(
                name: name,
                creatorId: currentUserId,
                participantIds: participantIds
            )
            return .success(groupId: groupId)
        } catch let error as FirestoreService.GroupError {
            switch error {
            case .alreadyExists:
                return .alreadyExists
            case .notAuthorized:
                return .failure(error.localizedDescription)
            }
        } catch {
            errorMessage = error.localizedDescription
            return .failure(error.localizedDescription)
        }
    }

    enum CreateGroupResult {
        case success(groupId: String)
        case alreadyExists
        case failure(String)
    }
}

#Preview {
    CreateGroupView()
}
