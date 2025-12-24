//
//  ConcertSettingsView.swift
//  vibes
//
//  Created by Claude Code on 12/24/25.
//

import SwiftUI

struct ConcertSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var ticketmasterService = TicketmasterService.shared
    @State private var apiKey = ""
    @State private var city = ""
    @State private var isKeyVisible = false
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                apiKeySection
                locationSection
                statusSection
                aboutSection
            }
            .navigationTitle("Concert Discovery")
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
                Text("Your settings have been saved.")
            }
            .onAppear {
                city = ticketmasterService.userCity
            }
        }
    }

    private var apiKeySection: some View {
        Section {
            if ticketmasterService.isConfigured {
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
                        TextField("Your API key", text: $apiKey)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Your API key", text: $apiKey)
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
            Text("Ticketmaster API Key")
        } footer: {
            if !ticketmasterService.isConfigured {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Get your free API key from:")
                    Link("developer.ticketmaster.com", destination: URL(string: "https://developer.ticketmaster.com/products-and-docs/apis/getting-started/")!)
                        .font(.caption)
                }
            }
        }
    }

    private var locationSection: some View {
        Section {
            TextField("City name (e.g., New York)", text: $city)
                .autocapitalization(.words)

            Button {
                saveCity()
            } label: {
                Text("Save Location")
            }
            .disabled(city.isEmpty)
        } header: {
            Text("Your Location")
        } footer: {
            Text("Enter your city to find concerts near you. We'll search for events within 60 days.")
        }
    }

    private var statusSection: some View {
        Section {
            HStack {
                Text("API Status")
                Spacer()
                if ticketmasterService.isConfigured {
                    Text("Active")
                        .foregroundColor(.green)
                } else {
                    Text("Not configured")
                        .foregroundColor(Color(.secondaryLabel))
                }
            }

            HStack {
                Text("Location")
                Spacer()
                if ticketmasterService.userCity.isEmpty {
                    Text("Not set")
                        .foregroundColor(Color(.secondaryLabel))
                } else {
                    Text(ticketmasterService.userCity)
                        .foregroundColor(Color(.label))
                }
            }
        } header: {
            Text("Status")
        }
    }

    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                featureRow(
                    icon: "ticket.fill",
                    title: "Discover Concerts",
                    description: "See upcoming shows from your top Spotify artists"
                )

                featureRow(
                    icon: "location.fill",
                    title: "Local Events",
                    description: "Find concerts happening in your city"
                )

                featureRow(
                    icon: "cart.fill",
                    title: "Buy Tickets",
                    description: "Tap any concert to purchase tickets on Ticketmaster"
                )
            }
        } header: {
            Text("Features")
        } footer: {
            Text("Concert data is provided by Ticketmaster. The free API tier includes 5,000 requests per day.")
                .font(.caption)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
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
            try ticketmasterService.configure(apiKey: apiKey)
            apiKey = ""
            showSuccess = true
        } catch {
            errorMessage = "Failed to save API key: \(error.localizedDescription)"
        }

        isSaving = false
    }

    private func saveCity() {
        ticketmasterService.setUserCity(city)
        showSuccess = true
    }

    private func removeAPIKey() {
        do {
            try ticketmasterService.removeConfiguration()
        } catch {
            errorMessage = "Failed to remove API key: \(error.localizedDescription)"
        }
    }
}
