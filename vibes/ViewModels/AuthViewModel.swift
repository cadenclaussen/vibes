//
//  AuthViewModel.swift
//  vibes
//
//  Created by Claude Code on 11/22/25.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSignUpMode = false

    private let authManager = AuthManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        authManager.$isAuthenticated
            .sink { [weak self] _ in
                self?.clearFields()
            }
            .store(in: &cancellables)
    }

    func signUp() async {
        guard validateSignUpFields() else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authManager.signUp(email: email, password: password, username: username)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signIn() async {
        guard validateSignInFields() else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() {
        do {
            try authManager.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPassword() async {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authManager.resetPassword(email: email)
            errorMessage = "Password reset email sent"
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleMode() {
        isSignUpMode.toggle()
        errorMessage = nil
    }

    private func validateSignUpFields() -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Email is required"
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Password is required"
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }

        guard !username.isEmpty else {
            errorMessage = "Username is required"
            return false
        }

        guard username.count >= 3 else {
            errorMessage = "Username must be at least 3 characters"
            return false
        }

        return true
    }

    private func validateSignInFields() -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Email is required"
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Password is required"
            return false
        }

        return true
    }

    private func clearFields() {
        email = ""
        password = ""
        username = ""
        errorMessage = nil
    }
}
