import SwiftUI

struct TicketmasterSetupView: View {
    @Environment(SetupManager.self) private var setupManager
    @Environment(\.dismiss) private var dismiss

    @State private var apiKey = ""
    @State private var city = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false

    private let ticketmasterURL = URL(string: "https://developer.ticketmaster.com/")!

    private var existingKeyMasked: String? {
        guard let key = KeychainManager.shared.getTicketmasterApiKey() else { return nil }
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

                if setupManager.isTicketmasterComplete {
                    deleteSection
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Ticketmaster")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let existingCity = setupManager.concertCity {
                city = existingCity
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "ticket")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Ticketmaster")
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
                numberedStep(1, "Open Ticketmaster Developer Portal (link below)")
                numberedStep(2, "Create an account or sign in")
                numberedStep(3, "Go to 'My Apps' and create a new app")
                numberedStep(4, "Copy the Consumer Key (API key)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text("The API key is free for personal use.")
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
        Link(destination: ticketmasterURL) {
            HStack {
                Image(systemName: "arrow.up.right.square")
                Text("Open Ticketmaster Developer Portal")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundStyle(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel("Open Ticketmaster Developer Portal in browser")
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let masked = existingKeyMasked {
                    Text("Current key: \(masked)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SecureField("Paste your API key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .autocorrectionDisabled()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Your City")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("Enter your city (e.g., San Francisco)", text: $city)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()

                Text("We'll find concerts in and around this city")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                saveSettings()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(setupManager.isTicketmasterComplete ? "Update Settings" : "Save Settings")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSave ? Color.orange : Color.gray)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canSave || isLoading)
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            deleteSettings()
        } label: {
            Text("Remove Ticketmaster Settings")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var canSave: Bool {
        let hasNewKey = !apiKey.isEmpty
        let hasCity = !city.isEmpty
        let hasExistingKey = KeychainManager.shared.getTicketmasterApiKey() != nil
        return (hasNewKey || hasExistingKey) && hasCity
    }

    private func numberedStep(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .fontWeight(.medium)
            Text(text)
        }
    }

    private func saveSettings() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let keyToValidate = apiKey.isEmpty
                    ? KeychainManager.shared.getTicketmasterApiKey()
                    : apiKey

                if let key = keyToValidate {
                    try await APIValidationService.shared.validateTicketmasterKey(key)
                }

                if !apiKey.isEmpty {
                    try KeychainManager.shared.saveTicketmasterApiKey(apiKey)
                }
                setupManager.saveConcertCity(city)

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

    private func deleteSettings() {
        try? KeychainManager.shared.clearTicketmasterApiKey()
        setupManager.clearConcertCity()
        setupManager.refresh()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        TicketmasterSetupView()
            .environment(SetupManager())
    }
}
