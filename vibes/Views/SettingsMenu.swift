//
//  SettingsMenu.swift
//  vibes
//
//  Created by Claude Code on 11/23/25.
//

import SwiftUI

struct SettingsMenu: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var selectedTab: Int
    @Binding var shouldEditProfile: Bool
    @State private var showingMenu = false

    var body: some View {
        Button {
            showingMenu = true
        } label: {
            Image(systemName: "person.circle.fill")
                .imageScale(.large)
                .foregroundColor(Color(.label))
        }
        .popover(isPresented: $showingMenu, arrowEdge: .top) {
            VStack(spacing: 0) {
                Button {
                    showingMenu = false
                    shouldEditProfile = true
                    selectedTab = 3
                } label: {
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundColor(Color(.label))
                        Text("Edit Profile")
                            .foregroundColor(Color(.label))
                        Spacer()
                    }
                    .padding()
                    .contentShape(Rectangle())
                }

                Divider()

                Button {
                    showingMenu = false
                    do {
                        try authManager.signOut()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Sign Out")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .contentShape(Rectangle())
                }
            }
            .frame(width: 200)
            .presentationCompactAdaptation(.popover)
        }
    }
}
