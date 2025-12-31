import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    var buttonTitle: String?
    var action: (() -> Void)?

    init(
        title: String,
        message: String,
        icon: String = "tray",
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.buttonTitle = buttonTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let buttonTitle = buttonTitle, let action = action {
                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        title: "No Results",
        message: "Try a different search term",
        icon: "magnifyingglass",
        buttonTitle: "Clear Search"
    ) {
        print("Clear tapped")
    }
}
