import SwiftUI
import SafariServices

struct SpotifyAuthView: View {
    @StateObject private var spotifyService = SpotifyService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingSafari = false
    @State private var authURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if spotifyService.isAuthenticated {
                    authenticatedView
                } else {
                    unauthenticatedView
                }
            }
            .padding()
            .navigationTitle("Connect Spotify")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingSafari) {
            if let url = authURL {
                SafariView(url: url) { callbackURL in
                    handleCallback(callbackURL)
                }
            }
        }
    }

    private var unauthenticatedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 12) {
                Text("Connect Your Spotify Account")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Access your playlists and share music with friends")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }

            Button {
                connectSpotify()
            } label: {
                HStack {
                    Image(systemName: "music.note")
                    Text("Connect to Spotify")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            Text("You'll be redirected to Spotify to authorize this app")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var authenticatedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 12) {
                Text("Spotify Connected")
                    .font(.title2)
                    .fontWeight(.bold)

                if let profile = spotifyService.userProfile {
                    Text(profile.displayName ?? "User")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            Button {
                spotifyService.signOut()
                dismiss()
            } label: {
                Text("Disconnect Spotify")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
            }
        }
    }

    private func connectSpotify() {
        guard let url = spotifyService.getAuthorizationURL() else {
            errorMessage = "Failed to generate authorization URL"
            return
        }

        authURL = url
        showingSafari = true
    }

    private func handleCallback(_ url: URL) {
        showingSafari = false

        Task {
            do {
                try await spotifyService.handleAuthorizationCallback(url: url)
                dismiss()
            } catch {
                errorMessage = "Authentication failed: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Safari View Controller Wrapper

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    let onCallback: (URL) -> Void

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safari = SFSafariViewController(url: url)
        safari.delegate = context.coordinator
        return safari
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCallback: onCallback)
    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let onCallback: (URL) -> Void

        init(onCallback: @escaping (URL) -> Void) {
            self.onCallback = onCallback
        }

        func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
            if URL.absoluteString.starts(with: "vibes://") {
                onCallback(URL)
                controller.dismiss(animated: true)
            }
        }
    }
}
