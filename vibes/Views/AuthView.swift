//
//  AuthView.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showingForgotPassword = false

    var body: some View {
        NavigationStack {
            formContent
                .navigationTitle(viewModel.isSignUpMode ? "Sign Up" : "Sign In")
                .sheet(isPresented: $showingForgotPassword) {
                    ForgotPasswordView(viewModel: viewModel)
                }
        }
    }

    private var formContent: some View {
        Form {
            authFieldsSection
            actionButtonSection
            if !viewModel.isSignUpMode {
                forgotPasswordSection
            }
            if let errorMessage = viewModel.errorMessage {
                errorSection(errorMessage)
            }
            toggleModeSection
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }

    private var forgotPasswordSection: some View {
        Section {
            Button {
                showingForgotPassword = true
            } label: {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var authFieldsSection: some View {
        Section {
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $viewModel.password)
                .textContentType(viewModel.isSignUpMode ? .newPassword : .password)

            if viewModel.isSignUpMode {
                TextField("Username", text: $viewModel.username)
                    .textContentType(.username)
                    .autocapitalization(.none)
            }
        }
    }

    private var actionButtonSection: some View {
        Section {
            Button(action: {
                Task {
                    if viewModel.isSignUpMode {
                        await viewModel.signUp()
                    } else {
                        await viewModel.signIn()
                    }
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(viewModel.isSignUpMode ? "Create Account" : "Sign In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(viewModel.isLoading)
        }
    }

    private func errorSection(_ message: String) -> some View {
        Section {
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
        }
    }

    private var toggleModeSection: some View {
        Section {
            Button(action: {
                viewModel.toggleMode()
            }) {
                Text(viewModel.isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var isSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }

                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(isLoading)
                }

                Section {
                    Button {
                        Task {
                            await sendResetEmail()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Send Reset Link")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(email.isEmpty || isLoading)
                }

                if let message = message {
                    Section {
                        HStack {
                            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(isSuccess ? .green : .red)
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(isSuccess ? .green : .red)
                        }
                    }
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sendResetEmail() async {
        guard !email.isEmpty else {
            message = "Please enter your email address"
            isSuccess = false
            return
        }

        isLoading = true
        message = nil

        do {
            try await AuthManager.shared.resetPassword(email: email)
            message = "Password reset email sent. Check your inbox."
            isSuccess = true
        } catch {
            message = error.localizedDescription
            isSuccess = false
        }

        isLoading = false
    }
}
