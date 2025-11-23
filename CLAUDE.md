# Task Tracking - MANDATORY

**Every user request MUST be tracked in `docs/task.md` FIRST.**

## Workflow
1. User requests task → EITHER IMMEDIATELY add to `docs/task.md` OR if the user asks for the task to be done in the future, IMMEDIATELY add to `docs/backlog.md`
2. Check archiving: `wc -l docs/task.md` and `wc -l docs/backlog.md` - if > 300 lines, archive old
   completed tasks to docs/.archive/tasks.md
3. Set status: TASK → IN_PROGRESS → COMPLETED
4. On failure: Increment failure count, document what went wrong

## Task Format
```markdown
### N. Brief task description
- **Status**: TASK | IN_PROGRESS | COMPLETED
- **Type**: Bug | Feature
- **Location**: File:line
- **Requested**: Full detailed user request
- **Context**: Why it matters, related features
- **Acceptance Criteria**: Checkboxes for verification
- **Failure Count**: N
- **Failures**: Attempt N: What went wrong and why
- **Solution**: Exact changes made and verification
```

**Type Field**:
- **Bug**: Fixes for broken functionality (incorrect behavior, crashes,
  performance issues)
- **Feature**: New functionality, improvements, or refactoring (requires
  documentation updates)

## Critical Requirements
1. **No exceptions** - User request = immediate task.md entry
2. **Be verbose in Requested** - Capture full context for verification
3. **Document acceptance criteria** - Specific checks to verify completion
4. **Update status in real-time** - Move through states as you work
5. **Always verify** - Re-read request and check criteria before COMPLETED

## Xcode Project Configuration

- Project file: `vibes.xcodeproj`
- Scheme: `vibes`
- Target simulator: iPhone 16e (latest iOS version)
- Xcode installation: `/Applications/Xcode.app`
- Developer tools path must be set to Xcode (not Command Line Tools)
- If `xcodebuild` fails with "requires Xcode" error, run:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  ```

## iOS App Development

REQUIRED: All iOS app development MUST follow the style guide in `docs/style.md`

When writing Swift/SwiftUI code:
1. Read and follow `docs/style.md` for all architecture, code style, and UI/UX decisions
2. Use MVVM pattern
3. Follow Apple Human Interface Guidelines
4. Maintain consistency with existing code patterns

## iOS App Style Guide (Reference)

### Architecture

- Use MVVM (Model-View-ViewModel) pattern for SwiftUI apps
- Separate concerns: Views for UI, ViewModels for business logic, Models for data
- Keep views simple and focused on presentation
- Use dependency injection for testability
- Follow Apple's Human Interface Guidelines

### SwiftUI Code Style

#### View Structure

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

#### Naming Conventions

- Use clear, descriptive names that reveal intent
- Views: Noun + "View" suffix (e.g., `ProfileView`, `SettingsView`)
- ViewModels: Noun + "ViewModel" suffix (e.g., `ProfileViewModel`)
- Models: Singular nouns (e.g., `User`, `Item`)
- Functions: Verb phrases (e.g., `fetchData()`, `handleSubmit()`)
- Boolean properties: Use "is", "has", "should" prefix (e.g., `isLoading`, `hasError`)

#### State Management

- Use @State for simple, local view state
- Use @Binding to share state between parent and child views
- Use @ObservedObject or @StateObject for complex state with ObservableObject
- Use @EnvironmentObject for app-wide shared state
- Keep state as local as possible; only lift state when necessary

#### Code Organization

- One view per file unless views are tightly coupled
- Group files by feature, not by type
- Structure: Models, ViewModels, Views, Services, Utilities
- Use extensions to organize code by functionality

#### Performance

- Use lazy stacks (LazyVStack, LazyHStack) for long lists
- Avoid expensive computations in view body; use computed properties or methods
- Use @ViewBuilder for conditional view logic
- Prefer lightweight views; extract heavy components

### Swift Language Style

#### General

- Follow Swift API Design Guidelines
- Use Swift's type inference; avoid redundant type annotations
- Prefer structs over classes unless reference semantics needed
- Use optionals appropriately; avoid force unwrapping (!)
- Use guard for early returns
- Prefer immutability (let) over mutability (var)

#### Error Handling

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

#### Async/Await

- Use async/await for asynchronous operations
- Mark functions with async when they perform async work
- Use Task for concurrent operations
- Handle cancellation appropriately

### UI/UX Guidelines

#### Design Principles

- Follow Apple's Human Interface Guidelines
- Design for accessibility (VoiceOver, Dynamic Type, color contrast)
- Use native iOS patterns and components
- Support both light and dark mode
- Design for all device sizes (iPhone, iPad)

#### Visual Design

- Use SF Symbols for icons
- Follow iOS spacing conventions (8pt grid)
- Use semantic colors (Color.primary, Color.secondary)
- Maintain consistent spacing and alignment
- Use native iOS animations and transitions

#### Interaction

- Provide immediate feedback for user actions
- Use standard iOS gestures
- Display loading states for async operations
- Show error states with clear messaging
- Use native navigation patterns (NavigationView, sheets, alerts)

### Testing

- Write unit tests for ViewModels and business logic
- Test edge cases and error conditions
- Use preview providers for SwiftUI view development
- Keep tests simple and focused on one behavior
- Use descriptive test names that explain intent

### Comments and Documentation

- Use inline comments sparingly; prefer self-documenting code
- Add comments for complex algorithms or non-obvious logic
- Use MARK: comments to organize code sections
- Document public APIs with proper documentation comments (///)
- Avoid obvious comments that just repeat the code

### Performance and Optimization

- Profile before optimizing
- Use Instruments to identify bottlenecks
- Optimize images and assets
- Use lazy loading for expensive operations
- Cache when appropriate, but avoid premature optimization

## Coding Style

### General Guidelines

- KISS: Keep code simple and readable
- Use procedural programming style rather than object-oriented when writing scripts
- Prefer Node.js for new scripts unless specified otherwise
- No emojis in code or documentation unless explicitly requested
- Use descriptive variable and function names
- Prefer explicit over clever
- Prefer readability over brevity
- One responsibility per function
- Keep functions small and focused
- Aggressively refactor code when possible
- Aggressively remove dead code immediately
- Scripts should be self-contained and easily portable
- Include clear comments for complex logic
- Use standard Unix conventions for CLI tools
- Test scripts before considering them complete

### Top Down

- Do not do this:
```
def function2() { ... }
def function1() { ... }
def main() {
    function1()
    function2()
}
```

- Do this instead:
```
def main() {
    function1()
    function2()
}
def function1() { ... }
def function2() { ... }
```

### Indentation

- Use 4-space indents
- Use spaces, not tabs

### Short Circuit

Use short-circuit pattern for cleaner code:

- Bad:
```python
if condition1:
    if condition2:
        if condition3:
            do_something()
```

- Good:
```python
if not condition1:
    return
if not condition2:
    return
if not condition3:
    return
do_something()
```

### Comments

- Use terse, inline comments
- No block comments
- Avoid obvious comments
- Comment complex logic only

### Error Messages

- Be specific about what went wrong
- Include context when helpful
- Suggest fixes when possible
- Use consistent formatting