//
//  ConcertSettingsView.swift
//  vibes
//
//  Simple city selection for concert discovery.
//

import SwiftUI

struct ConcertSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var ticketmasterService = TicketmasterService.shared
    @State private var city = ""
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                locationSection
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
            .alert("Saved", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your city has been saved.")
            }
            .onAppear {
                city = ticketmasterService.userCity
            }
        }
    }

    private var locationSection: some View {
        Section {
            TextField("City name (e.g., New York)", text: $city)
                .autocapitalization(.words)
                .submitLabel(.done)
                .onSubmit {
                    saveCity()
                }

            Button {
                saveCity()
            } label: {
                Text("Save")
            }
            .disabled(city.isEmpty)
        } header: {
            Text("Your City")
        } footer: {
            Text("Enter your city to find concerts from your top artists nearby.")
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

    private func saveCity() {
        guard !city.isEmpty else { return }
        ticketmasterService.setUserCity(city)
        showSuccess = true
    }
}
