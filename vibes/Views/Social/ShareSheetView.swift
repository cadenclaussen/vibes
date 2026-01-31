import SwiftUI

struct ShareSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ShareViewModel

    init(track: UnifiedTrack) {
        _viewModel = State(initialValue: ShareViewModel(track: track))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Track info header
                trackHeader
                    .padding()

                Divider()

                // Message field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a message (optional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("What do you think of this song?", text: $viewModel.message, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(3...5)
                        .padding(12)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Text("\(viewModel.message.count)/140")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .onChange(of: viewModel.message) { _, newValue in
                    if newValue.count > 140 {
                        viewModel.message = String(newValue.prefix(140))
                    }
                }

                Divider()

                // Recipients
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.following.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "No One to Share With",
                        message: "Follow people to share music with them",
                        icon: "person.badge.plus"
                    )
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Send to:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 12)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.following) { user in
                                    recipientRow(user)
                                    Divider()
                                        .padding(.leading, 60)
                                }
                            }
                        }
                    }
                }

                // Send button
                Button {
                    Task {
                        try? await viewModel.send()
                    }
                } label: {
                    if viewModel.isSending {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    } else {
                        Text(viewModel.selectedCount > 0 ? "Send (\(viewModel.selectedCount))" : "Select Recipients")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(viewModel.canSend ? Color.accentColor : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .disabled(!viewModel.canSend)
                .padding()
            }
            .navigationTitle("Share Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.load()
            }
            .onChange(of: viewModel.didSend) { _, didSend in
                if didSend {
                    dismiss()
                }
            }
        }
    }

    private var trackHeader: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: viewModel.track.albumArtURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.tertiarySystemFill))
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.track.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(viewModel.track.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    private func recipientRow(_ user: UserProfile) -> some View {
        Button {
            viewModel.toggleSelection(user)
        } label: {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: viewModel.isSelected(user) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(viewModel.isSelected(user) ? Color.accentColor : Color.secondary)

                // Profile picture
                AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color(.tertiarySystemFill))
                        .overlay {
                            Text(user.displayName.prefix(1).uppercased())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                // Name
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text("@\(user.username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ShareSheetView(
        track: UnifiedTrack(
            id: "1",
            name: "Bohemian Rhapsody",
            artistName: "Queen",
            albumName: "A Night at the Opera",
            albumArtURL: nil,
            previewURL: nil,
            durationMs: 354000,
            isExplicit: false
        )
    )
}
