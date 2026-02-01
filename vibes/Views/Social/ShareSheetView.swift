import SwiftUI

struct ShareSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ShareViewModel

    init(track: UnifiedTrack) {
        _viewModel = State(initialValue: ShareViewModel(track: track))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                trackHeader
                    .padding(.top)

                messageField

                Spacer()

                sendButton
            }
            .padding()
            .navigationTitle("Share Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
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
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.track.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(viewModel.track.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text("Sharing with all followers")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
    }

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add a message (optional)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("What do you think of this song?", text: $viewModel.message, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(3...6)
                .padding(12)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("\(viewModel.message.count)/140")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onChange(of: viewModel.message) { _, newValue in
            if newValue.count > 140 {
                viewModel.message = String(newValue.prefix(140))
            }
        }
    }

    private var sendButton: some View {
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
                Text("Share with Followers")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .disabled(!viewModel.canSend)
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
