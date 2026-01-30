import SwiftUI

struct DiscoverMusicView: View {
    @State private var viewModel = DiscoverMusicViewModel()
    @State private var showingSettings = false
    @Environment(AppRouter.self) private var router

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else if viewModel.songQueue.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle("Discover Music")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            PopularitySettingsSheet(
                maxPopularity: $viewModel.maxPopularity,
                onApply: {
                    showingSettings = false
                    Task {
                        await viewModel.retry()
                    }
                }
            )
            .presentationDetents([.height(280)])
        }
        .task {
            await viewModel.loadInitialRecommendations()
        }
        .onDisappear {
            viewModel.clearSession()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Finding songs you'll love...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView {
            Label(
                errorTitle(for: error),
                systemImage: errorIcon(for: error)
            )
        } description: {
            Text(errorDescription(for: error))
        } actions: {
            if viewModel.isSpotifyError {
                Button("Connect Spotify") {
                    router.navigateToSpotifySetup()
                }
                .buttonStyle(.borderedProminent)
            } else if viewModel.isFilterTooStrict {
                Button("Adjust Settings") {
                    showingSettings = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Try Again") {
                    Task {
                        await viewModel.retry()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Recommendations",
            systemImage: "sparkles",
            description: Text("We couldn't find any songs to recommend right now. Try again later.")
        )
    }

    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.visibleSongs) { track in
                    SongDiscoveryCard(
                        track: track,
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.25)) {
                                viewModel.dismissSong(track)
                            }
                        },
                        onAddToPlaylist: {
                            router.presentPlaylistPicker(for: track)
                            // dismiss after adding
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    viewModel.dismissSong(track)
                                }
                            }
                        },
                        onSendToFriend: {
                            router.presentUserPicker(for: track)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    // MARK: - Error Helpers

    private func errorTitle(for error: Error) -> String {
        if viewModel.isSpotifyError {
            return "Spotify Not Connected"
        }
        if viewModel.isFilterTooStrict {
            return "No Songs Found"
        }
        if viewModel.hasNoSeedData {
            return "No Listening History"
        }
        return "Something Went Wrong"
    }

    private func errorIcon(for error: Error) -> String {
        if viewModel.isSpotifyError {
            return "link.badge.plus"
        }
        if viewModel.isFilterTooStrict {
            return "slider.horizontal.3"
        }
        if viewModel.hasNoSeedData {
            return "music.note"
        }
        return "exclamationmark.triangle"
    }

    private func errorDescription(for error: Error) -> String {
        if let discoverError = error as? DiscoverMusicError {
            return discoverError.recoverySuggestion ?? discoverError.localizedDescription
        }
        return error.localizedDescription
    }
}

// MARK: - Popularity Settings Sheet

private struct PopularitySettingsSheet: View {
    @Binding var maxPopularity: Int
    let onApply: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Obscurity Level")
                        .font(.headline)

                    Text(obscurityLabel)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(obscurityColor)
                }

                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { Double(100 - maxPopularity) },
                            set: { maxPopularity = 100 - Int($0) }
                        ),
                        in: 0...70,
                        step: 10
                    )
                    .tint(obscurityColor)

                    HStack {
                        Text("Popular")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Hidden Gems")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                Text("Higher obscurity finds lesser-known tracks from your favorite artists.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Find Songs") {
                    onApply()
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Discovery Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var obscurityLabel: String {
        let level = 100 - maxPopularity
        switch level {
        case 0...10: return "Mainstream"
        case 11...30: return "Popular"
        case 31...50: return "Less Known"
        case 51...70: return "Hidden Gems"
        default: return "Ultra Obscure"
        }
    }

    private var obscurityColor: Color {
        let level = 100 - maxPopularity
        switch level {
        case 0...10: return .blue
        case 11...30: return .green
        case 31...50: return .orange
        default: return .purple
        }
    }
}

#Preview {
    NavigationStack {
        DiscoverMusicView()
    }
    .environment(AppRouter())
}
