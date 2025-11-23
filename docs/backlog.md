# Future Tasks Backlog

This file tracks tasks and features to be implemented in the future.

---

## Profile Enhancements

### 1. Add profile picture upload capability
- **Type**: Feature
- **Description**: Add the ability to change the profile picture in the profile section
- **Context**: Currently shows placeholder person icon, need ability to upload/change photo
- **Requirements**:
  - Photo picker integration
  - Image upload to Firebase Storage
  - Update profile picture URL in Firestore
  - Display uploaded image in ProfileView
  - Handle image compression/sizing

### 2. Inline editing mode for profile
- **Type**: Feature
- **Description**: Change the edit option to not pop up a new screen, just change the current screen into editing mode
- **Context**: Current implementation uses sheet modal for editing, prefer inline editing
- **Requirements**:
  - Remove sheet modal approach
  - Add edit/save toggle to toolbar
  - Show/hide edit controls inline
  - Preserve current editing functionality (display name, genres)
  - Smooth transition between view/edit modes

### 3. Predefined genre selection
- **Type**: Feature
- **Description**: Instead of adding favorite genres with free text input, have a set list of music genres that you can pick from
- **Context**: Free text input allows typos and inconsistencies, predefined list ensures data quality
- **Requirements**:
  - Define comprehensive list of music genres
  - Replace text input with selection UI (checkboxes, chips, or multi-select)
  - Allow multiple genre selection
  - Update ProfileEditView to use genre picker
  - Consider genre categorization (Rock, Pop, Hip-Hop, Electronic, etc.)

---

## Backlog Statistics
- Total Future Tasks: 3
- Profile Enhancements: 3
