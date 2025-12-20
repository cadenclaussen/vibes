# Profile Screen Implementation

## Part 1: Create Tab Navigation (Do This First)

Before implementing the profile screen, you need to set up the 4-tab navigation structure at the bottom of the screen.

### Step 0: Create MainTabView in ContentView.swift

Location: `vibes/ContentView.swift`

This creates the tab bar with 4 tabs: Search, Friends, Stats, and Profile.

```swift
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            SearchTab()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            FriendsTab()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }

            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

// Placeholder views for tabs we haven't built yet
struct SearchTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(.tertiaryLabel))

                Text("Under Construction")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This feature is coming soon")
                    .font(.body)
                    .foregroundColor(Color(.secondaryLabel))
            }
            .navigationTitle("Search")
        }
    }
}

struct FriendsTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(.tertiaryLabel))

                Text("Under Construction")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This feature is coming soon")
                    .font(.body)
                    .foregroundColor(Color(.secondaryLabel))
            }
            .navigationTitle("Friends")
        }
    }
}

struct StatsTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(.tertiaryLabel))

                Text("Under Construction")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This feature is coming soon")
                    .font(.body)
                    .foregroundColor(Color(.secondaryLabel))
            }
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
```

**Important Notes:**
- Each tab gets its own `NavigationStack` - this keeps navigation independent per tab
- Use `Label` for tab items - this provides both icon and text
- SF Symbols for icons: `magnifyingglass`, `person.2.fill`, `chart.bar.fill`, `person.fill`
- `ProfileView()` will be created in the steps below
- The other tabs are placeholders for now

### Testing Tab Navigation

After implementing Step 0:
1. Build and run the app
2. Sign in with a test account
3. Verify you see 4 tabs at the bottom
4. Tap each tab and verify it switches views
5. The Profile tab will show an error until you complete the steps below

---

## Part 2: Implement Profile Screen

Now that tab navigation is set up, let's build the Profile screen.

## Overview

Create a basic profile screen showing username, email, and favorite music genres. This is the MVP version - we'll add more features later.

## What to Build

A simple profile screen with:
- Profile picture placeholder (circular)
- Username display
- Email display
- Favorite music genres (tags)
- Sign out button
- Edit button (sheet modal)

## Step-by-Step Implementation

### Step 1: Create ProfileView.swift

Location: `vibes/Views/ProfileView.swift`

```swift
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showingEditSheet = false

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Profile")
                .toolbar {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
                .sheet(isPresented: $showingEditSheet) {
                    ProfileEditView(viewModel: viewModel)
                }
        }
        .task {
            await viewModel.loadProfile()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let profile = viewModel.profile {
            profileContent(profile)
        } else {
            Text("Failed to load profile")
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    private func profileContent(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader(profile)
                infoSection(profile)
                genresSection(profile)
                signOutButton
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }

    private func profileHeader(_ profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(.tertiaryLabel))

            Text(profile.displayName)
                .font(.title)
                .fontWeight(.bold)

            Text("@\(profile.username)")
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    private func infoSection(_ profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            infoRow(label: "Email", value: profile.email)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(Color(.secondaryLabel))

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(Color(.label))
        }
    }

    private func genresSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorite Genres")
                .font(.headline)

            if profile.musicTasteTags.isEmpty {
                Text("No genres added yet")
                    .font(.body)
                    .foregroundColor(Color(.tertiaryLabel))
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(profile.musicTasteTags, id: \.self) { genre in
                        Text(genre)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(16)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var signOutButton: some View {
        Button(action: {
            do {
                try authManager.signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }) {
            Text("Sign Out")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager.shared)
}
```

### Step 2: Create FlowLayout Helper

Location: `vibes/Views/FlowLayout.swift`

This creates a wrapping layout for genre tags.

```swift
import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
```

### Step 3: Create ProfileEditView.swift

Location: `vibes/Views/ProfileEditView.swift`

```swift
import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss

    @State private var displayName: String
    @State private var genreInput = ""
    @State private var musicTasteTags: [String]

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        _displayName = State(initialValue: viewModel.profile?.displayName ?? "")
        _musicTasteTags = State(initialValue: viewModel.profile?.musicTasteTags ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Display Name") {
                    TextField("Display Name", text: $displayName)
                }

                Section("Favorite Genres") {
                    ForEach(musicTasteTags, id: \.self) { genre in
                        HStack {
                            Text(genre)
                            Spacer()
                            Button(action: {
                                musicTasteTags.removeAll { $0 == genre }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    HStack {
                        TextField("Add genre", text: $genreInput)
                        Button(action: addGenre) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(genreInput.isEmpty)
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveProfile()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }

    private func addGenre() {
        let trimmed = genreInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !musicTasteTags.contains(trimmed) else { return }
        musicTasteTags.append(trimmed)
        genreInput = ""
    }

    private func saveProfile() async {
        guard var profile = viewModel.profile else { return }

        profile.displayName = displayName
        profile.musicTasteTags = musicTasteTags

        await viewModel.updateProfile()

        if viewModel.errorMessage == nil {
            dismiss()
        }
    }
}
```

### Step 4: Update ProfileViewModel.swift

The existing ProfileViewModel needs a small update to handle the profile update properly.

Location: `vibes/ViewModels/ProfileViewModel.swift`

Update the `updateProfile()` method to accept the full profile:

```swift
func updateProfile() async {
    guard let profile = profile else { return }

    isLoading = true
    errorMessage = nil

    do {
        try await firestoreService.updateProfile(profile)
        isEditing = false
    } catch {
        errorMessage = "Failed to update profile: \(error.localizedDescription)"
    }

    isLoading = false
}
```

### Step 5: Update FirestoreService.swift

Ensure the updateProfile method exists in FirestoreService.

Location: `vibes/Services/FirestoreService.swift`

Add this method if it doesn't exist:

```swift
func updateProfile(_ profile: UserProfile) async throws {
    guard let userId = profile.id else {
        throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile ID is nil"])
    }

    var updatedProfile = profile
    updatedProfile.updatedAt = Date()

    try db.collection("users").document(userId).setData(from: updatedProfile, merge: true)
}
```

### Step 6: Verify Tab Navigation

Location: `vibes/ContentView.swift`

**Note:** Tab navigation should already be set up from Step 0 at the beginning of this guide. If you skipped Step 0, go back and implement it first.

Verify that:
- `ContentView.swift` has `MainTabView` with 4 tabs
- `ProfileView()` is the 4th tab
- Each tab has its own `NavigationStack`
- Tab icons are using SF Symbols

### Step 7: Update Xcode Project

Add the new files to the Xcode project:

1. In Xcode, right-click on `vibes/Views/` folder
2. Select "Add Files to vibes..."
3. Add:
   - `ProfileView.swift`
   - `ProfileEditView.swift`
   - `FlowLayout.swift`

Or let Xcode auto-detect them when you build.

### Step 8: Test the Implementation

1. Build and run the app
2. Sign in with a test account
3. Navigate to Profile tab
4. Verify you see username and email
5. Tap Edit button
6. Add some genres (e.g., "Rock", "Jazz", "Hip Hop")
7. Tap Save
8. Verify genres appear on profile
9. Test Sign Out button

## Style Guidelines Applied

- Uses NavigationStack (not NavigationView)
- Dynamic Type fonts (.title, .headline, .body, .caption)
- Semantic colors (Color(.systemBackground), Color(.secondaryLabel))
- 4-space indentation
- Guard statements for early returns
- Private computed properties for subviews
- Form with .grouped style for editing
- 8pt grid spacing (8, 12, 16, 24)

## Future Enhancements

Once this works, we can add:
- Profile picture upload
- Bio section
- Favorite artists from Spotify
- Privacy settings
- More profile customization options

## Troubleshooting

**Profile not loading?**
- Check that user is authenticated
- Verify Firestore has user document
- Check console for error messages

**Genres not saving?**
- Verify FirestoreService.updateProfile() method exists
- Check Firestore rules allow user to update their document
- Look for error messages in viewModel.errorMessage

**Sheet not dismissing?**
- Check that dismiss() is being called
- Verify no errors during save
