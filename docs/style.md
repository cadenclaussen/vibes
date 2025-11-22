# iOS App Style Guide

## Architecture

- Use MVVM (Model-View-ViewModel) pattern for SwiftUI apps
- Separate concerns: Views for UI, ViewModels for business logic, Models for data
- Keep views simple and focused on presentation
- Use dependency injection for testability
- Follow Apple's Human Interface Guidelines

## SwiftUI Code Style

### View Structure

- Order SwiftUI properties by type: @State, @Binding, @ObservedObject, @EnvironmentObject, then regular properties
- Keep view body under 10 lines; extract subviews if longer
- Use private properties and methods unless they need to be public
- Group related modifiers together
- Apply layout modifiers (padding, frame) before styling modifiers (background, foreground)

Example:
```swift
struct ContentView: View {
    @State private var isPresented = false
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack {
            headerView
            contentList
        }
        .padding()
        .background(Color.white)
    }

    private var headerView: some View {
        Text("Header")
            .font(.headline)
    }

    private var contentList: some View {
        List(viewModel.items) { item in
            Text(item.name)
        }
    }
}
```

### Naming Conventions

- Use clear, descriptive names that reveal intent
- Views: Noun + "View" suffix (e.g., `ProfileView`, `SettingsView`)
- ViewModels: Noun + "ViewModel" suffix (e.g., `ProfileViewModel`)
- Models: Singular nouns (e.g., `User`, `Item`)
- Functions: Verb phrases (e.g., `fetchData()`, `handleSubmit()`)
- Boolean properties: Use "is", "has", "should" prefix (e.g., `isLoading`, `hasError`)

### State Management

- Use @State for simple, local view state
- Use @Binding to share state between parent and child views
- Use @ObservedObject or @StateObject for complex state with ObservableObject
- Use @EnvironmentObject for app-wide shared state
- Keep state as local as possible; only lift state when necessary

### Code Organization

- One view per file unless views are tightly coupled
- Group files by feature, not by type
- Structure: Models, ViewModels, Views, Services, Utilities
- Use extensions to organize code by functionality

### Performance

- Use lazy stacks (LazyVStack, LazyHStack) for long lists
- Avoid expensive computations in view body; use computed properties or methods
- Use @ViewBuilder for conditional view logic
- Prefer lightweight views; extract heavy components

## Swift Language Style

### General

- Follow Swift API Design Guidelines
- Use Swift's type inference; avoid redundant type annotations
- Prefer structs over classes unless reference semantics needed
- Use optionals appropriately; avoid force unwrapping (!)
- Use guard for early returns
- Prefer immutability (let) over mutability (var)

### Error Handling

- Use Swift's native error handling (do-try-catch)
- Create custom error types when appropriate
- Provide clear error messages
- Handle errors at appropriate levels

Example:
```swift
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed
}

func fetchData() async throws -> [Item] {
    guard let url = URL(string: endpoint) else {
        throw NetworkError.invalidURL
    }

    let (data, _) = try await URLSession.shared.data(from: url)

    guard !data.isEmpty else {
        throw NetworkError.noData
    }

    return try JSONDecoder().decode([Item].self, from: data)
}
```

### Async/Await

- Use async/await for asynchronous operations
- Mark functions with async when they perform async work
- Use Task for concurrent operations
- Handle cancellation appropriately

## Navigation Patterns

### When to Use Each Navigation Model

#### NavigationStack
- Use for single-column navigation (primary pattern for iPhone)
- Ideal for hierarchical content that stacks views
- Use when users navigate through a series of related screens
- Supports programmatic navigation with NavigationPath
- Example use cases: Settings flows, detail views, linear workflows

```swift
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {
            ItemRow(item: item)
        }
    }
    .navigationDestination(for: Item.self) { item in
        ItemDetailView(item: item)
    }
}
```

#### NavigationSplitView
- Use for multi-column navigation (iPad and Mac)
- Ideal for master-detail or sidebar-content layouts
- Use when displaying hierarchical information side-by-side
- Automatically adapts to device size
- Example use cases: Mail apps, file browsers, content-detail views

```swift
NavigationSplitView {
    List(categories, selection: $selectedCategory) { category in
        Text(category.name)
    }
} detail: {
    if let category = selectedCategory {
        CategoryDetailView(category: category)
    } else {
        Text("Select a category")
    }
}
```

#### Sheets and Modals
- Use sheets for temporary, focused tasks
- Use fullScreenCover for immersive experiences
- Use .sheet() for forms, creation flows, or secondary content
- Always provide a clear dismiss action
- Example use cases: Creating new items, editing forms, secondary workflows

#### Tab Navigation
- Use TabView for top-level navigation with 3-5 distinct sections
- Each tab should represent a primary app function
- Keep tab labels short and clear
- Use SF Symbols for tab icons

### Navigation Best Practices

- Centralize routing logic with a Router/Coordinator pattern for complex apps
- Use type-safe navigation with NavigationPath
- Avoid deep navigation stacks (max 3-4 levels)
- Always provide a clear back button or dismiss action
- Use navigation titles appropriately (.navigationTitle())
- Consider NavigationStack over deprecated NavigationView (iOS 16+)

## Typography & Fonts

### Text Styles

ALWAYS use Dynamic Type text styles - never use fixed font sizes. This ensures accessibility and respects user preferences.

#### Standard Text Styles

Use Apple's semantic text styles in this order of hierarchy:

1. **Large Title** (.largeTitle) - Main screen headers
2. **Title** (.title, .title2, .title3) - Section headers, important content
3. **Headline** (.headline) - Emphasized content, list items
4. **Body** (.body) - Default body text, primary content
5. **Callout** (.callout) - Secondary content
6. **Subheadline** (.subheadline) - Less prominent text
7. **Footnote** (.footnote) - Tertiary content
8. **Caption** (.caption, .caption2) - Supporting text, metadata

```swift
Text("Main Header")
    .font(.largeTitle)

Text("Section Title")
    .font(.title2)

Text("Body content goes here")
    .font(.body)

Text("Supporting information")
    .font(.caption)
```

### Font Usage Guidelines

- **Use SF Pro** (default system font) - optimized for iOS
- **Never use fixed sizes** - breaks Dynamic Type accessibility
- Use `.fontWeight()` for emphasis: .regular, .medium, .semibold, .bold
- Use `.fontDesign()` for specific contexts: .default, .serif, .rounded, .monospaced
- For custom fonts, use @ScaledMetric to support Dynamic Type

```swift
// Good - supports Dynamic Type
Text("Title")
    .font(.headline)
    .fontWeight(.semibold)

// Bad - fixed size, breaks accessibility
Text("Title")
    .font(.system(size: 24))
```

### Typography Hierarchy Per View Type

#### List Views
- Row title: `.headline` or `.body`
- Row subtitle: `.subheadline` or `.caption`
- Section headers: `.headline` or `.subheadline`

#### Detail Views
- Main title: `.largeTitle` or `.title`
- Section headers: `.title2` or `.title3`
- Body content: `.body`
- Metadata: `.caption` or `.footnote`

#### Forms
- Field labels: `.headline` or `.body`
- Input text: `.body`
- Helper text: `.caption` or `.footnote`
- Error messages: `.caption` in red

## Forms Design

### Form Structure

Use SwiftUI's `Form` container for settings, data entry, and configuration screens.

```swift
Form {
    Section("Personal Information") {
        TextField("Name", text: $name)
        TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
    }

    Section("Preferences") {
        Toggle("Enable Notifications", isOn: $notificationsEnabled)
        Picker("Theme", selection: $selectedTheme) {
            ForEach(Theme.allCases) { theme in
                Text(theme.rawValue).tag(theme)
            }
        }
    }
}
.formStyle(.grouped)
```

### Form Styles

- **Grouped style** (.grouped) - DEFAULT for all forms
  - White background rows on gray background
  - Standard iOS settings appearance
  - Use for most forms and settings

- **Columns style** (.columns) - Use sparingly
  - Two-column layout (labels left, controls right)
  - Only for iPad/Mac when appropriate

### Form Best Practices

- Group related fields with `Section`
- Provide clear section headers
- Use appropriate keyboard types (.emailAddress, .numberPad, etc.)
- Use text content types for autofill (.emailAddress, .name, etc.)
- Add placeholder text for text fields
- Use validation and show errors inline
- Keep forms focused - one purpose per form
- Place primary action button at bottom

### Form Field Types

```swift
// Text Input
TextField("Placeholder", text: $value)

// Secure Input
SecureField("Password", text: $password)

// Toggle
Toggle("Label", isOn: $isEnabled)

// Picker
Picker("Options", selection: $selected) {
    ForEach(options) { option in
        Text(option.name).tag(option)
    }
}

// Date Picker
DatePicker("Date", selection: $date, displayedComponents: .date)

// Stepper
Stepper("Count: \(count)", value: $count, in: 0...10)
```

### Form Validation

- Validate input as user types or on field exit
- Show error states with red accent and caption text
- Disable submit button until form is valid
- Provide clear error messages

```swift
TextField("Email", text: $email)
    .textContentType(.emailAddress)
    .foregroundColor(isValidEmail ? .primary : .red)

if !isValidEmail && !email.isEmpty {
    Text("Please enter a valid email")
        .font(.caption)
        .foregroundColor(.red)
}
```

## Background Colors & Color System

### Semantic Background Colors

ALWAYS use semantic colors - never hardcode colors. This ensures proper dark mode support.

#### Background Color Hierarchy

iOS provides two background stacks:

**Stack 1: systemBackground** (white primary in light mode)
```swift
Color(.systemBackground)        // Main background
Color(.secondarySystemBackground)   // Elevated content
Color(.tertiarySystemBackground)    // Grouped content
```

**Stack 2: systemGroupedBackground** (gray primary in light mode)
```swift
Color(.systemGroupedBackground)        // Main grouped background
Color(.secondarySystemGroupedBackground)   // Elevated grouped content
Color(.tertiarySystemGroupedBackground)    // Grouped content within groups
```

### When to Use Each Background

#### Use systemBackground for:
- Main app views
- Standard lists and table views
- Content-focused screens
- Detail views

```swift
VStack {
    // Content
}
.background(Color(.systemBackground))
```

#### Use systemGroupedBackground for:
- Forms and settings
- Grouped lists
- Card-based layouts
- Sections with visual grouping

```swift
Form {
    // Form content
}
.scrollContentBackground(.hidden)
.background(Color(.systemGroupedBackground))
```

### Background Guidelines Per View Type

#### List Views
- Background: `.systemBackground`
- Row background: Default (white/black)
- Alternating rows: Use `.listRowBackground()` if needed

#### Forms
- Background: `.systemGroupedBackground`
- Section background: `.secondarySystemGroupedBackground`
- Use `.formStyle(.grouped)`

#### Detail Views
- Background: `.systemBackground`
- Cards/sections: `.secondarySystemBackground`

#### Sheets/Modals
- Background: `.systemGroupedBackground`
- Content cards: `.secondarySystemGroupedBackground`

### Foreground Colors

Use semantic foreground colors for text and icons:

```swift
Color(.label)              // Primary text
Color(.secondaryLabel)     // Secondary text
Color(.tertiaryLabel)      // Tertiary text
Color(.quaternaryLabel)    // Watermark text

Color(.separator)          // Separator lines
Color(.link)              // Links
```

### Accent Colors

- Use `.tint()` for primary accent color
- Use semantic colors: `.blue`, `.green`, `.red`, etc.
- Never use pure black (#000000) or pure white (#FFFFFF)

### Dark Mode Considerations

- All colors must work in both light and dark mode
- Test every view in both modes
- Use dark gray (not black) for dark mode backgrounds
- Maintain proper contrast ratios
- Use Asset Catalog for custom colors with appearance variants

## UI/UX Guidelines

### Design Principles

- Follow Apple's Human Interface Guidelines
- Design for accessibility (VoiceOver, Dynamic Type, color contrast)
- Use native iOS patterns and components
- Support both light and dark mode
- Design for all device sizes (iPhone, iPad)

### Visual Design

- Use SF Symbols for icons
- Follow iOS spacing conventions (8pt grid)
- Use semantic colors (see Background Colors section)
- Maintain consistent spacing and alignment
- Use native iOS animations and transitions

### Interaction

- Provide immediate feedback for user actions
- Use standard iOS gestures
- Display loading states for async operations
- Show error states with clear messaging
- Use navigation patterns described in Navigation section

## Testing

- Write unit tests for ViewModels and business logic
- Test edge cases and error conditions
- Use preview providers for SwiftUI view development
- Keep tests simple and focused on one behavior
- Use descriptive test names that explain intent

## Comments and Documentation

- Use inline comments sparingly; prefer self-documenting code
- Add comments for complex algorithms or non-obvious logic
- Use MARK: comments to organize code sections
- Document public APIs with proper documentation comments (///)
- Avoid obvious comments that just repeat the code

## Performance and Optimization

- Profile before optimizing
- Use Instruments to identify bottlenecks
- Optimize images and assets
- Use lazy loading for expensive operations
- Cache when appropriate, but avoid premature optimization

## Indentation

- Use 4-space indents
- Use spaces, not tabs

## Short Circuit Pattern

Use short-circuit pattern for cleaner code:

Bad:
```swift
if condition1 {
    if condition2 {
        if condition3 {
            doSomething()
        }
    }
}
```

Good:
```swift
guard condition1 else { return }
guard condition2 else { return }
guard condition3 else { return }
doSomething()
```
