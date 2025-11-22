# Apple Navigation Models Overview

A guide to understanding how users move through iOS and macOS apps.

## What is Navigation?

Navigation determines how users move between different screens and sections of your app. Apple provides several standard patterns that users already know and expect.

## Core Navigation Patterns

### 1. Stack Navigation (Hierarchical)

**What it is**: Like drilling down through folders - each tap pushes you deeper into content.

**When to use**:
- Settings menus
- Mail (inbox → message → attachment)
- File browsing
- Any hierarchical content

**How it works**:
- Starts with a root screen
- Each selection pushes a new screen on top
- Back button automatically appears to go back
- Navigation bar at the top shows where you are

**Example Flow**:
```
Home → Settings → Notifications → Email Notifications
```

### 2. Tab Navigation (Flat)

**What it is**: Persistent tabs at the bottom let you switch between main sections instantly.

**When to use**:
- Apps with 3-5 distinct, equally important sections
- When users need quick access to different areas
- Examples: Phone app (Favorites, Recents, Contacts, Keypad, Voicemail)

**How it works**:
- Tabs stay visible at all times
- Tapping a tab switches the entire view
- Each tab can have its own navigation stack
- Selected tab is highlighted

**Best Practices**:
- Use 2-5 tabs (if you need more, consider different navigation)
- Label tabs clearly with icons and text
- Keep tab order consistent

### 3. Modal Presentation

**What it is**: A screen that appears on top of everything else, requiring user action.

**When to use**:
- Creating new content (compose email, new post)
- Focused tasks that need completion or cancellation
- Alerts and confirmations
- Critical information that demands attention

**How it works**:
- Slides up from bottom (or other transitions)
- Blocks interaction with content underneath
- Usually has "Cancel" and "Done" buttons
- Can be dismissed with swipe-down gesture

**Presentation Styles**:
- **Full Screen**: Takes over entire screen
- **Page Sheet**: Card-like, shows previous screen dimmed behind (default on iOS)
- **Form Sheet**: Centered, smaller card (iPad)

### 4. Split View / Sidebar (iPad & Mac)

**What it is**: Multiple columns showing different levels of information simultaneously.

**When to use**:
- iPad apps needing to show sidebar + detail
- macOS apps
- Mail, Notes, Settings on iPad

**How it works**:
- Sidebar shows navigation/categories
- Content area shows selected item
- Can collapse on smaller screens
- Adapts to available space

**Typical Layouts**:

**Two-Column Layout**: Sidebar + Detail
- Left column shows navigation options or categories
- Right column shows the content for selected item
- Entire detail view changes when you select a different sidebar item
- **Examples**:
  - **Settings (iPad)**: Sidebar lists setting categories (General, Privacy, etc.), detail shows the settings for that category
  - **Photos (Mac)**: Sidebar shows albums/folders, main area shows photos in that album
  - **Simple document apps**: Sidebar lists documents, detail shows document content

**Three-Column Layout**: Sidebar + List + Detail
- Left column shows high-level categories
- Middle column shows items within that category
- Right column shows detail for selected item
- Navigation is hierarchical: category → item → detail
- **Examples**:
  - **Mail (iPad)**: Sidebar (Mailboxes) → List (Email list) → Detail (Email content)
  - **Notes (iPad)**: Sidebar (Folders) → List (Notes in folder) → Detail (Note content)
  - **Music (Mac)**: Sidebar (Library sections) → List (Albums/Songs) → Detail (Album/Song info)
  - **Finder (Mac)**: Sidebar (Favorites/Locations) → List (Files) → Detail (Preview/Info)

### 5. Page-Based Navigation

**What it is**: Swiping horizontally between pages, like a book.

**When to use**:
- Onboarding flows
- Photo galleries
- Tutorial walkthroughs
- Content that's consumed in sequence

**How it works**:
- Swipe left/right to navigate
- Page indicators (dots) show position
- Each page is a complete screen

## Combining Navigation Patterns

Apps often combine multiple patterns:

**Example: Instagram-like App**
```
TabView (main navigation)
├── Feed Tab
│   └── NavigationStack
│       ├── Feed List
│       └── Post Detail (pushed)
├── Search Tab
│   └── NavigationStack
├── Create Tab
│   └── Modal (full screen camera)
├── Activity Tab
│   └── NavigationStack
└── Profile Tab
    └── NavigationStack
        ├── Profile View
        └── Settings (pushed)
```

## Platform Differences

### iOS
- Emphasis on full-screen experiences
- Tab bars at bottom
- Navigation bars at top
- Gestures: swipe back, pull to dismiss modals

### iPadOS
- Split views and sidebars
- Can show multiple navigation contexts simultaneously
- Larger tap targets and spacing

### macOS
- Sidebar navigation is standard
- Toolbars instead of navigation bars
- Window-based instead of screen-based
- Menus for commands

## Navigation Components

### Navigation Bar
- Shows current screen title
- Houses back button
- Can contain action buttons (Edit, Add, etc.)

### Tab Bar
- Fixed at bottom (iOS) or top (macOS)
- Shows 2-5 items
- Icons with optional labels

### Toolbar
- Bottom bar for contextual actions
- Different from tab bar (actions vs navigation)

### Search
- Can be integrated into navigation bar
- Appears/hides as user scrolls

## Best Practices

1. **Be Consistent**: Use standard patterns users already know
2. **Make Navigation Obvious**: Users should always know where they are and how to get back
3. **Minimize Depth**: Try to keep navigation 3 levels deep or less
4. **Respect Platform Conventions**: Don't use Android hamburger menus on iOS
5. **Provide Context**: Show where users are in the hierarchy
6. **Enable Gestures**: Support swipe-back and other standard gestures
7. **Adapt to Context**: Use appropriate navigation for screen size (iPhone vs iPad)

## Common Mistakes

- Using modals when push navigation would be better
- Too many tab bar items (>5)
- Inconsistent navigation patterns in the same app
- Navigation that's too deep (>4 levels)
- Custom navigation that breaks user expectations
- Not adapting navigation for different device sizes

## Decision Tree

**Choosing the Right Pattern**:

1. **Multiple top-level sections of equal importance?** → Use Tab Bar
2. **Drilling down into hierarchical content?** → Use Stack Navigation
3. **Focused task requiring completion?** → Use Modal
4. **iPad/Mac with sidebar categories?** → Use Split View
5. **Sequential content consumed in order?** → Use Page-Based

## Resources

- [Apple Human Interface Guidelines - Navigation](https://developer.apple.com/design/human-interface-guidelines/navigation)
- [SwiftUI Navigation Documentation](https://developer.apple.com/documentation/swiftui/navigation)
- [UIKit Navigation Documentation](https://developer.apple.com/documentation/uikit/view_controllers)
