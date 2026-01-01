import SwiftUI

struct GeminiSetupView: View {
    @Environment(SetupManager.self) private var setupManager
    @Environment(\.dismiss) private var dismiss

    @State private var apiKey = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false

    private let googleAIStudioURL = URL(string: "https://aistudio.google.com/apikey")!

    private var existingKeyMasked: String? {
        guard let key = KeychainManager.shared.getGeminiApiKey() else { return nil }
        if key.count > 8 {
            let prefix = String(key.prefix(4))
            let suffix = String(key.suffix(4))
            return "\(prefix)...\(suffix)"
        }
        return "****"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                instructionsSection
                linkSection
                inputSection

                if setupManager.isGeminiComplete {
                    deleteSection
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Gemini API Key")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.purple)

            Text("Gemini AI")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding(.top, 20)
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How to get your API key")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                numberedStep(1, "Open Google AI Studio (link below)")
                numberedStep(2, "Sign in with your Google account")
                numberedStep(3, "Click 'Create API Key'")
                numberedStep(4, "Copy the key and paste it here")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text("The API key is free to create and use.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var linkSection: some View {
        Link(destination: googleAIStudioURL) {
            HStack {
                Image(systemName: "arrow.up.right.square")
                Text("Open Google AI Studio")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundStyle(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel("Open Google AI Studio in browser")
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let masked = existingKeyMasked {
                Text("Current key: \(masked)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            SecureField("Paste your API key", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
                .autocorrectionDisabled()

            Button {
                saveApiKey()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(setupManager.isGeminiComplete ? "Update Key" : "Save Key")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(apiKey.isEmpty ? Color.gray : Color.purple)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(apiKey.isEmpty || isLoading)
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            deleteApiKey()
        } label: {
            Text("Remove API Key")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func numberedStep(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .fontWeight(.medium)
            Text(text)
        }
    }

    private func saveApiKey() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await APIValidationService.shared.validateGeminiKey(apiKey)
                try KeychainManager.shared.saveGeminiApiKey(apiKey)
                await MainActor.run {
                    isLoading = false
                    setupManager.refresh()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func deleteApiKey() {
        try? KeychainManager.shared.delete(key: .geminiApiKey)
        setupManager.refresh()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        GeminiSetupView()
            .environment(SetupManager())
    }
}
