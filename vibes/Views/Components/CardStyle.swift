//
//  CardStyle.swift
//  vibes
//
//  Created by Claude Code on 12/21/25.
//

import SwiftUI

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.3)
                    : Color.black.opacity(0.08),
                radius: colorScheme == .dark ? 4 : 6,
                x: 0,
                y: colorScheme == .dark ? 2 : 3
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
