import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var isSigningIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Logo and title
            VStack(spacing: 16) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)

                Text("vibes")
                    .font(.system(size: 48, weight: .bold, design: .rounded))

                Text("Discover and share music with friends")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Sign in button
            VStack(spacing: 16) {
                if isSigningIn {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(height: 50)
                } else {
                    GoogleSignInButton(
                        viewModel: GoogleSignInButtonViewModel(
                            scheme: .dark,
                            style: .wide,
                            state: .normal
                        )
                    ) {
                        signIn()
                    }
                    .frame(maxWidth: 280, minHeight: 50)
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Spacer()

            // Terms
            Text("By signing in, you agree to our Terms of Service and Privacy Policy")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
        .padding()
    }

    private func signIn() {
        isSigningIn = true
        errorMessage = nil

        Task {
            do {
                try await authManager.signInWithGoogle()
            } catch {
                errorMessage = error.localizedDescription
            }
            isSigningIn = false
        }
    }
}

#Preview {
    AuthView()
        .environment(AuthManager.shared)
}
