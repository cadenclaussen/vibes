import SwiftUI
import UIKit

struct MusicServicePicker: View {
    @ObservedObject var manager = MusicServiceManager.shared
    var onServiceSelected: ((MusicServiceType) -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose your music service")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Connect your preferred streaming service to personalize your experience")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 16) {
                ServiceButton(
                    type: .spotify,
                    isSelected: manager.activeServiceType == .spotify
                ) {
                    manager.selectService(.spotify)
                    onServiceSelected?(.spotify)
                }

                ServiceButton(
                    type: .appleMusic,
                    isSelected: manager.activeServiceType == .appleMusic
                ) {
                    manager.selectService(.appleMusic)
                    onServiceSelected?(.appleMusic)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ServiceButton: View {
    let type: MusicServiceType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                serviceIcon
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? type.brandColor : .secondary)

                Text(type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? type.brandColor.opacity(0.15) : Color(.tertiarySystemFill))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? type.brandColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var serviceIcon: some View {
        switch type {
        case .spotify:
            Image(systemName: "waveform.circle.fill")
        case .appleMusic:
            Image(systemName: "applelogo")
        }
    }
}

struct MusicServiceAuthView: View {
    @ObservedObject var manager = MusicServiceManager.shared
    @State private var isAuthenticating = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            if manager.hasSelectedService {
                connectedServiceView
            } else {
                MusicServicePicker { type in
                    authenticateService(type)
                }
            }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private var connectedServiceView: some View {
        VStack(spacing: 16) {
            if manager.isAuthenticated {
                authenticatedView
            } else {
                notAuthenticatedView
            }
        }
    }

    private var authenticatedView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: manager.serviceIcon)
                    .foregroundColor(manager.serviceColor)
                Text(manager.serviceName)
                    .font(.headline)

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.tertiarySystemFill))
            .cornerRadius(12)

            if let profile = manager.userProfile {
                HStack {
                    Text("Connected as")
                        .foregroundColor(.secondary)
                    Text(profile.displayName ?? "User")
                        .fontWeight(.medium)
                }
                .font(.subheadline)
            }

            Button(action: {
                manager.signOut()
            }) {
                Text("Disconnect")
                    .foregroundColor(.red)
            }
            .padding(.top, 8)
        }
    }

    private var notAuthenticatedView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: manager.serviceIcon)
                    .foregroundColor(manager.serviceColor)
                Text(manager.serviceName)
                    .font(.headline)

                Spacer()

                Text("Not connected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.tertiarySystemFill))
            .cornerRadius(12)

            Button(action: {
                if let serviceType = manager.activeServiceType {
                    authenticateService(serviceType)
                }
            }) {
                HStack {
                    if isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(isAuthenticating ? "Connecting..." : "Connect \(manager.serviceName)")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(manager.serviceColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isAuthenticating)

            Button(action: {
                manager.clearServiceSelection()
            }) {
                Text("Choose a different service")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func authenticateService(_ type: MusicServiceType) {
        isAuthenticating = true
        errorMessage = nil

        Task {
            do {
                if type == .spotify {
                    if let url = manager.getSpotifyAuthorizationURL() {
                        await UIApplication.shared.open(url)
                    }
                } else {
                    try await manager.authenticate()
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isAuthenticating = false
        }
    }
}

struct CompactMusicServiceStatus: View {
    @ObservedObject var manager = MusicServiceManager.shared

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: manager.serviceIcon)
                .foregroundColor(manager.serviceColor)

            Text(manager.serviceName)
                .font(.subheadline)

            Spacer()

            if manager.isAuthenticated {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            } else {
                Text("Not connected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        MusicServicePicker()
        Divider()
        MusicServiceAuthView()
    }
    .padding()
}
