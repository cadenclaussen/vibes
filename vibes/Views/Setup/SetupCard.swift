import SwiftUI

struct SetupCard: View {
    @Environment(SetupManager.self) private var setupManager

    private var progressText: String {
        if setupManager.isAllComplete {
            return "Setup Complete"
        } else {
            return "\(setupManager.completedCount)/3 complete"
        }
    }

    var body: some View {
        NavigationLink(value: SetupDestination.checklist) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Setup")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(progressText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Setup, \(progressText)")
    }
}

#Preview {
    SetupCard()
        .padding()
        .environment(SetupManager())
}
