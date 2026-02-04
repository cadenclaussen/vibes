import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var isSigningIn = false
    @State private var errorMessage: String?
    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                headerSection

                formSection

                dividerSection

                googleSignInSection

                termsSection

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)

            Text("vibes")
                .font(.system(size: 42, weight: .bold, design: .rounded))

            Text("Discover and share music with friends")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            Picker("Mode", selection: $isSignUpMode) {
                Text("Sign In").tag(false)
                Text("Sign Up").tag(true)
            }
            .pickerStyle(.segmented)

            if isSignUpMode {
                TextField("Display Name", text: $displayName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .autocorrectionDisabled()
            }

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(isSignUpMode ? .newPassword : .password)

            if isSignUpMode {
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: submitForm) {
                if isSigningIn {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(isSignUpMode ? "Create Account" : "Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(formIsValid ? Color.accentColor : Color.gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(!formIsValid || isSigningIn)
        }
    }

    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
            Text("or")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
        }
    }

    private var googleSignInSection: some View {
        VStack(spacing: 12) {
            if isSigningIn {
                ProgressView()
                    .frame(height: 50)
            } else {
                GoogleSignInButton(
                    viewModel: GoogleSignInButtonViewModel(
                        scheme: .dark,
                        style: .wide,
                        state: .normal
                    )
                ) {
                    signInWithGoogle()
                }
                .frame(maxWidth: .infinity, minHeight: 50)
            }
        }
    }

    private var termsSection: some View {
        Text("By signing in, you agree to our Terms of Service and Privacy Policy")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }

    private var formIsValid: Bool {
        let emailValid = email.contains("@") && email.contains(".")
        let passwordValid = password.count >= 6

        if isSignUpMode {
            let nameValid = !displayName.trimmingCharacters(in: .whitespaces).isEmpty
            let passwordsMatch = password == confirmPassword
            return emailValid && passwordValid && nameValid && passwordsMatch
        } else {
            return emailValid && passwordValid
        }
    }

    private func submitForm() {
        isSigningIn = true
        errorMessage = nil

        Task {
            do {
                if isSignUpMode {
                    try await authManager.signUpWithEmail(
                        email: email.trimmingCharacters(in: .whitespaces),
                        password: password,
                        displayName: displayName.trimmingCharacters(in: .whitespaces)
                    )
                } else {
                    try await authManager.signInWithEmail(
                        email: email.trimmingCharacters(in: .whitespaces),
                        password: password
                    )
                }
            } catch {
                errorMessage = mapFirebaseError(error)
            }
            isSigningIn = false
        }
    }

    private func signInWithGoogle() {
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

    private func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case 17008:
            return "Invalid email address format"
        case 17009:
            return "Incorrect password"
        case 17011:
            return "No account found with this email"
        case 17026:
            return "Password must be at least 6 characters"
        case 17007:
            return "An account already exists with this email"
        default:
            return error.localizedDescription
        }
    }
}

#Preview {
    AuthView()
        .environment(AuthManager.shared)
}
