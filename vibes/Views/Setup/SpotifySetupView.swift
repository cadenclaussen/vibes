import SwiftUI

struct SpotifySetupView: View {
    @Environment(SetupManager.self) private var setupManager
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @State private var isConnecting = false
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                instructionsSection

                if setupManager.isSpotifyComplete {
                    connectedSection
                } else {
                    connectSection
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Connect Spotify")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Spotify")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding(.top, 20)
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Why connect Spotify?")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Access your music library and playlists")
                bulletPoint("Get personalized recommendations")
                bulletPoint("Share songs with friends")
                bulletPoint("View your listening stats")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var connectSection: some View {
        Button {
            connectSpotify()
        } label: {
            HStack {
                if isConnecting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "link")
                }
                Text("Connect with Spotify")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isConnecting)
    }

    private var connectedSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Connected")
                    .fontWeight(.medium)
            }
            .font(.headline)

            Button(role: .destructive) {
                disconnectSpotify()
            } label: {
                Text("Disconnect")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }

    private func connectSpotify() {
        isConnecting = true
        errorMessage = nil

        Task {
            do {
                try await SpotifyAuthService.shared.startAuthorization()
                try await authManager.updateSpotifyLinked(true)
                await MainActor.run {
                    isConnecting = false
                    setupManager.refresh()
                    dismiss()
                }
            } catch is CancellationError {
                await MainActor.run {
                    isConnecting = false
                }
            } catch {
                await MainActor.run {
                    isConnecting = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func disconnectSpotify() {
        SpotifyAuthService.shared.disconnect()
        Task {
            try? await authManager.updateSpotifyLinked(false)
        }
        setupManager.refresh()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SpotifySetupView()
            .environment(SetupManager())
            .environment(AuthManager.shared)
    }
}
