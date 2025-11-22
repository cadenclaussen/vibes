//
//  AuthView.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            formContent
                .navigationTitle(viewModel.isSignUpMode ? "Sign Up" : "Sign In")
        }
    }

    private var formContent: some View {
        Form {
            authFieldsSection
            actionButtonSection
            if let errorMessage = viewModel.errorMessage {
                errorSection(errorMessage)
            }
            toggleModeSection
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
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
