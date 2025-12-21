import SwiftUI

struct AISettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var geminiService = GeminiService.shared
    @State private var apiKey = ""
    @State private var isKeyVisible = false
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                apiKeySection
                statusSection
                aboutSection
            }
            .navigationTitle("AI Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your Gemini API key has been saved securely.")
            }
        }
    }

    private var apiKeySection: some View {
        Section {
            if geminiService.isConfigured {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("API Key Configured")
                        .foregroundColor(Color(.label))
                    Spacer()
                }

                Button(role: .destructive) {
                    removeAPIKey()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Remove API Key")
                    }
                }
            } else {
                HStack {
                    if isKeyVisible {
                        TextField("AIza...", text: $apiKey)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("AIza...", text: $apiKey)
                            .textContentType(.password)
                    }

                    Button {
                        isKeyVisible.toggle()
                    } label: {
                        Image(systemName: isKeyVisible ? "eye.slash" : "eye")
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }

                Button {
                    saveAPIKey()
                } label: {
                    if isSaving {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Saving...")
                        }
                    } else {
                        Text("Save API Key")
                    }
                }
                .disabled(apiKey.isEmpty || isSaving)
            }

            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        } header: {
            Text("Google Gemini API Key")
        } footer: {
            if !geminiService.isConfigured {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Get your free API key from:")
                    Link("aistudio.google.com/apikey", destination: URL(string: "https://aistudio.google.com/apikey")!)
                        .font(.caption)
                }
            }
        }
    }

    private var statusSection: some View {
        Section {
            HStack {
                Text("Status")
                Spacer()
                if geminiService.isConfigured {
                    Text("Active")
                        .foregroundColor(.green)
                } else {
                    Text("Not configured")
                        .foregroundColor(Color(.secondaryLabel))
                }
            }

            HStack {
                Text("Daily Requests")
                Spacer()
                Text("\(geminiService.remainingRequests()) remaining")
                    .foregroundColor(Color(.secondaryLabel))
            }

            if geminiService.isConfigured {
                Button {
                    geminiService.clearCache()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Clear Recommendation Cache")
                    }
                }
            }
        } header: {
            Text("Usage")
        }
    }

    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                featureRow(
                    icon: "wand.and.stars",
                    title: "AI Playlist Ideas",
                    description: "Get personalized themed playlists based on your listening history"
                )

                featureRow(
                    icon: "person.2.fill",
                    title: "Friend Blend",
                    description: "Create playlists that blend your taste with a friend's"
                )
            }
        } header: {
            Text("Features")
        } footer: {
            Text("AI features use Google Gemini to analyze your music taste. The free tier includes 1,500 requests per day.")
                .font(.caption)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }

    private func saveAPIKey() {
        guard !apiKey.isEmpty else { return }

        isSaving = true
        errorMessage = nil

        do {
            try geminiService.configure(apiKey: apiKey)
            apiKey = ""
            showSuccess = true
        } catch {
            errorMessage = "Failed to save API key: \(error.localizedDescription)"
        }

        isSaving = false
    }

    private func removeAPIKey() {
        do {
            try geminiService.removeConfiguration()
        } catch {
            errorMessage = "Failed to remove API key: \(error.localizedDescription)"
        }
    }
}
