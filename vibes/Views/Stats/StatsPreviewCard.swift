import SwiftUI

struct StatsPreviewCard: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthManager.self) private var authManager
    let viewModel: StatsViewModel

    var body: some View {
        Button {
            router.navigateToStats()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Your Stats")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if !authManager.isSpotifyLinked {
                    noSpotifyContent
                } else if viewModel.isLoadingPreview {
                    loadingContent
                } else if viewModel.previewArtists.isEmpty {
                    emptyContent
                } else {
                    artistsPreview
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .task {
            if authManager.isSpotifyLinked && viewModel.previewArtists.isEmpty {
                await viewModel.loadPreview()
            }
        }
    }

    private var noSpotifyContent: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Connect Spotify")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text("See your top artists and songs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var loadingContent: some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 48, height: 48)
            }
            Spacer()
        }
    }

    private var emptyContent: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("Listen to some music first")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    private var artistsPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(viewModel.previewArtists) { artist in
                    AsyncImage(url: URL(string: artist.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color(.tertiarySystemFill))
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                }
                Spacer()
            }

            Text(viewModel.previewArtists.map { $0.name }.joined(separator: ", "))
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text("Your top artists this month")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack {
        StatsPreviewCard(viewModel: StatsViewModel())
            .padding()
    }
    .environment(AppRouter())
    .environment(AuthManager.shared)
}
