//
//  ContentView.swift
//  vibes
//
//  Created by Caden Claussen on 11/22/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                homeView
            } else {
                AuthView()
            }
        }
    }

    private var homeView: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to vibes")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("You're signed in!")
                    .font(.body)

                if let email = authManager.user?.email {
                    Text("Email: \(email)")
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }

                Button("Sign Out") {
                    do {
                        try authManager.signOut()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }
                .font(.headline)
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
