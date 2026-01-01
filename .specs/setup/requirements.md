# Setup Feature - Requirements

## Functional Requirements

### FR-1: Setup Card Display
- **Type**: Ubiquitous
- **Statement**: The system shall display a SetupCard at the top of the Feed tab, above all feed content.
- **Acceptance Criteria**:
  - [ ] SetupCard appears at the top of FeedView
  - [ ] SetupCard is always visible (even when all steps complete)
  - [ ] SetupCard shows progress indicator (e.g., "1/3 complete" or "Setup Complete")
- **Priority**: Must

### FR-2: Setup Card Navigation
- **Type**: Event-Driven
- **Statement**: When the user taps the SetupCard, the system shall push-navigate to the SetupChecklistView.
- **Acceptance Criteria**:
  - [ ] Tapping SetupCard pushes SetupChecklistView onto feedPath
  - [ ] Back navigation returns to Feed tab
- **Priority**: Must

### FR-3: Setup Checklist Display
- **Type**: Ubiquitous
- **Statement**: The SetupChecklistView shall display three vertically stacked buttons representing Spotify, Gemini, and Ticketmaster setup steps.
- **Acceptance Criteria**:
  - [ ] Three buttons displayed vertically
  - [ ] Each button shows the setup step name
  - [ ] Buttons are large and easily tappable
- **Priority**: Must

### FR-4: Setup Button States
- **Type**: State-Driven
- **Statement**: While a setup step is incomplete, the system shall display that step's button in red; while complete, the system shall display it in green.
- **Acceptance Criteria**:
  - [ ] Incomplete steps show red button
  - [ ] Completed steps show green button
  - [ ] State updates immediately after completion
- **Priority**: Must

### FR-5: Setup Button Navigation
- **Type**: Event-Driven
- **Statement**: When the user taps any setup button (red or green), the system shall push-navigate to that step's setup view.
- **Acceptance Criteria**:
  - [ ] Tapping Spotify button navigates to SpotifySetupView
  - [ ] Tapping Gemini button navigates to GeminiSetupView
  - [ ] Tapping Ticketmaster button navigates to TicketmasterSetupView
  - [ ] Green buttons remain tappable to allow editing
- **Priority**: Must

### FR-6: Spotify Setup View
- **Type**: Ubiquitous
- **Statement**: The SpotifySetupView shall display instructions for connecting Spotify and a "Connect with Spotify" button.
- **Acceptance Criteria**:
  - [ ] Header displays "Connect Spotify"
  - [ ] Instructions explain why Spotify connection is needed
  - [ ] "Connect with Spotify" button is prominently displayed
- **Priority**: Must

### FR-7: Spotify OAuth Flow
- **Type**: Event-Driven
- **Statement**: When the user taps "Connect with Spotify", the system shall initiate the Spotify OAuth authorization flow.
- **Acceptance Criteria**:
  - [ ] OAuth flow opens in system browser or in-app web view
  - [ ] User can authorize Spotify access
  - [ ] On success, tokens are stored in Keychain
  - [ ] On success, view pops back to SetupChecklistView
- **Priority**: Must

### FR-8: Gemini Setup View
- **Type**: Ubiquitous
- **Statement**: The GeminiSetupView shall display instructions for obtaining a Gemini API key, a link to Google AI Studio, and a text field for entering the key.
- **Acceptance Criteria**:
  - [ ] Header displays "Gemini API Key"
  - [ ] Instructions explain how to get a free API key
  - [ ] Tappable link opens Google AI Studio in browser
  - [ ] Text field accepts API key input
  - [ ] Save button is displayed
- **Priority**: Must

### FR-9: Gemini API Key Validation
- **Type**: Event-Driven
- **Statement**: When the user taps Save on GeminiSetupView, the system shall validate the API key before accepting it.
- **Acceptance Criteria**:
  - [ ] System makes test API call to validate key
  - [ ] Invalid key shows error message
  - [ ] Valid key is saved to Keychain
  - [ ] On success, view pops back to SetupChecklistView
- **Priority**: Must

### FR-10: Ticketmaster Setup View
- **Type**: Ubiquitous
- **Statement**: The TicketmasterSetupView shall display instructions for obtaining a Ticketmaster API key, a link to the Developer Portal, and text fields for API key and city name.
- **Acceptance Criteria**:
  - [ ] Header displays "Ticketmaster"
  - [ ] Instructions explain how to get API key
  - [ ] Tappable link opens Ticketmaster Developer Portal in browser
  - [ ] Text field for API key
  - [ ] Text field for city name
  - [ ] Save button is displayed
- **Priority**: Must

### FR-11: Ticketmaster Validation
- **Type**: Event-Driven
- **Statement**: When the user taps Save on TicketmasterSetupView, the system shall validate the API key before accepting it.
- **Acceptance Criteria**:
  - [ ] System makes test API call to validate key
  - [ ] Invalid key shows error message
  - [ ] Valid key is saved to Keychain
  - [ ] City name is saved to UserDefaults
  - [ ] On success, view pops back to SetupChecklistView
- **Priority**: Must

### FR-12: Edit Existing Values
- **Type**: Event-Driven
- **Statement**: When the user taps a completed (green) setup button, the system shall display the setup view with current values pre-filled.
- **Acceptance Criteria**:
  - [ ] GeminiSetupView shows masked/partial current API key
  - [ ] TicketmasterSetupView shows masked/partial API key and current city
  - [ ] SpotifySetupView shows "Connected" status with disconnect option
  - [ ] User can update values and save
- **Priority**: Must

### FR-13: Setup Completion Status
- **Type**: Ubiquitous
- **Statement**: The system shall persist setup completion status in UserDefaults for local access.
- **Acceptance Criteria**:
  - [ ] Completion status survives app restart
  - [ ] Status updates immediately when step is completed
  - [ ] SetupCard reflects current completion count
- **Priority**: Must

---

## Non-Functional Requirements

### NFR-1: Secure Credential Storage
- **Category**: Security
- **Statement**: The system shall store all API keys and tokens in iOS Keychain, never in UserDefaults or plain files.
- **Acceptance Criteria**:
  - [ ] Spotify tokens stored in Keychain
  - [ ] Gemini API key stored in Keychain
  - [ ] Ticketmaster API key stored in Keychain
  - [ ] Only city name stored in UserDefaults
- **Priority**: Must

### NFR-2: Responsive Navigation
- **Category**: Performance
- **Statement**: The system shall complete all setup navigation transitions within 300ms.
- **Acceptance Criteria**:
  - [ ] Push navigation is immediate
  - [ ] No visible lag when tapping buttons
- **Priority**: Should

### NFR-3: Accessibility
- **Category**: Accessibility
- **Statement**: The system shall make all setup UI elements accessible via VoiceOver.
- **Acceptance Criteria**:
  - [ ] All buttons have accessibility labels
  - [ ] Setup status is announced (e.g., "Spotify, not configured")
  - [ ] Links are properly labeled
- **Priority**: Should

### NFR-4: Visual Clarity
- **Category**: Usability
- **Statement**: The system shall use distinct, high-contrast colors for complete (green) and incomplete (red) states.
- **Acceptance Criteria**:
  - [ ] Red and green colors meet WCAG contrast requirements
  - [ ] State is visually obvious at a glance
- **Priority**: Should

---

## Constraints

- **Spotify OAuth**: Must use PKCE flow (no client secret in app)
- **Keychain Access**: Keys use `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`
- **External Links**: Must use `UIApplication.shared.open()` or `Link` view
- **iOS Version**: Requires iOS 17.0+ (uses @Observable)

---

## Assumptions

- User has already signed in via Google Sign-In before reaching setup
- User has internet connectivity during setup
- External services (Spotify, Google AI Studio, Ticketmaster) are available
- User can obtain free API keys from Google and Ticketmaster

---

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| OAuth cancelled by user | Return to SpotifySetupView, show no error |
| Invalid Gemini API key | Show error message, keep text field populated for editing |
| Invalid Ticketmaster API key | Show error message, keep fields populated for editing |
| Network failure during validation | Show error message with retry option |
| Keychain save fails | Show error message, do not mark step complete |
| User clears app data | Setup status resets, user must reconfigure |
| Spotify token expires | Not a setup concern; handled by SpotifyService refresh logic |
