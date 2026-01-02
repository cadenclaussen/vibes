# Concert Discovery - Requirements

## Functional Requirements

### FR-1: Entry Point Navigation
- **Type**: Event-Driven
- **Statement**: When the user taps the "Discover Concerts" button on the Feed page, the system shall navigate to the Artist List screen.
- **Acceptance Criteria**:
  - [ ] Button labeled "Discover Concerts" visible on Feed page
  - [ ] Button uses SF Symbol icon (e.g., `ticket.fill` or `music.mic`)
  - [ ] Tapping button pushes Artist List screen onto navigation stack
  - [ ] Back navigation returns to Feed
- **Priority**: Must
- **Notes**: Button should be prominently placed, possibly as a card or in quick actions area

### FR-2: Load Top Artists from Spotify
- **Type**: Event-Driven
- **Statement**: When the Artist List screen loads, the system shall fetch and display the user's top 10 artists from Spotify for the last 3 months.
- **Acceptance Criteria**:
  - [ ] Calls Spotify API `/me/top/artists` with `time_range=short_term` and `limit=10`
  - [ ] Displays loading state while fetching
  - [ ] Shows artist name and image for each artist
  - [ ] Artists displayed in order of listening frequency (rank 1-10)
  - [ ] Each artist row shows rank number
- **Priority**: Must
- **Notes**: Uses existing SpotifyAuthService for token management. Requires new SpotifyDataService.

### FR-3: Remove Artist from List
- **Type**: Event-Driven
- **Statement**: When the user swipes left on an artist row or taps the remove button, the system shall remove that artist from the list.
- **Acceptance Criteria**:
  - [ ] Swipe-to-delete gesture removes artist
  - [ ] Alternative: visible delete/minus button on each row
  - [ ] Removed artist no longer appears in list
  - [ ] Remaining artists re-rank automatically (no gaps)
  - [ ] Removal is immediate (no confirmation dialog)
  - [ ] Can remove all artists (empty list allowed)
- **Priority**: Must
- **Notes**: Standard iOS swipe-to-delete pattern

### FR-4: Search and Add Artists
- **Type**: Event-Driven
- **Statement**: When the user enters text in the search bar and selects an artist from results, the system shall add that artist to the bottom of the list.
- **Acceptance Criteria**:
  - [ ] Search bar visible at top of Artist List screen
  - [ ] Search queries Spotify Search API (`/search?type=artist`)
  - [ ] Results show as autocomplete dropdown below search bar
  - [ ] Each result shows artist name, image, and plus button
  - [ ] Tapping plus button adds artist to end of list
  - [ ] Search bar clears after adding
  - [ ] Duplicate artists cannot be added (plus button disabled or hidden)
- **Priority**: Must
- **Notes**: Debounce search input (300ms) to reduce API calls

### FR-5: Enforce Maximum Artist Limit
- **Type**: Unwanted Behavior
- **Statement**: If the user attempts to add an artist when the list already contains 20 artists, the system shall prevent the addition and display a message.
- **Acceptance Criteria**:
  - [ ] Plus buttons disabled when list has 20 artists
  - [ ] Toast/alert shown: "Maximum 20 artists allowed"
  - [ ] User must remove an artist before adding another
- **Priority**: Must
- **Notes**: Visual indicator showing current count (e.g., "12/20 artists")

### FR-6: Reorder Artist List
- **Type**: Event-Driven
- **Statement**: When the user long-presses and drags an artist row, the system shall allow reordering the list.
- **Acceptance Criteria**:
  - [ ] Long-press activates drag mode
  - [ ] Dragging moves artist to new position
  - [ ] Other artists shift to accommodate
  - [ ] Rank numbers update after reorder
  - [ ] Edit mode toggle available (shows drag handles)
- **Priority**: Must
- **Notes**: Use SwiftUI's `onMove` modifier with `EditButton` or custom implementation

### FR-7: Find Concerts Button
- **Type**: Event-Driven
- **Statement**: When the user taps the "Find Concerts" button, the system shall search Ticketmaster for concerts from all artists in the list.
- **Acceptance Criteria**:
  - [ ] Button labeled "Find Concerts" visible below artist list
  - [ ] Button disabled if artist list is empty
  - [ ] Tapping initiates concert search
  - [ ] Loading indicator shown during search
  - [ ] Navigates to Concert Results screen when complete
- **Priority**: Must
- **Notes**: Button should be prominent (filled style, accent color)

### FR-8: Query Ticketmaster API
- **Type**: Event-Driven
- **Statement**: When concert search is initiated, the system shall query the Ticketmaster Discovery API for each artist and aggregate results.
- **Acceptance Criteria**:
  - [ ] Calls Ticketmaster `/discovery/v2/events` for each artist
  - [ ] Uses stored API key from Keychain
  - [ ] Queries by artist keyword/name
  - [ ] Filters to music events only (`classificationName=Music`)
  - [ ] Fetches events within reasonable future window (e.g., 6 months)
  - [ ] Deduplicates events appearing for multiple artists
- **Priority**: Must
- **Notes**: Consider batch requests or parallel fetching for performance

### FR-9: Rank Concerts by Artist Priority
- **Type**: Ubiquitous
- **Statement**: The system shall sort concert results primarily by the user's artist ranking, then by date.
- **Acceptance Criteria**:
  - [ ] Concerts for rank #1 artist appear first
  - [ ] Within same artist, sort by date (soonest first)
  - [ ] Multi-artist concerts ranked by highest-ranked artist
  - [ ] Clear visual grouping or ranking indicator
- **Priority**: Must
- **Notes**: If Drake is #1 and has 3 concerts, all 3 appear before #2 artist's concerts

### FR-10: Display Concert Results
- **Type**: Ubiquitous
- **Statement**: The system shall display each concert with artist name, venue, city, date, and time.
- **Acceptance Criteria**:
  - [ ] Concert row shows: artist name, venue name, city, date, time
  - [ ] Date formatted as readable string (e.g., "Sat, Mar 15")
  - [ ] Time formatted in local time (e.g., "8:00 PM")
  - [ ] Artist image shown if available
  - [ ] Scrollable list for many results
- **Priority**: Must
- **Notes**: Consider card-style layout for visual appeal

### FR-11: Highlight Home City Concerts
- **Type**: State-Driven
- **Statement**: While displaying concert results, the system shall show a special icon/badge for concerts in the user's home city.
- **Acceptance Criteria**:
  - [ ] Compares concert city to user's `concertCity` setting
  - [ ] Matching concerts show home icon (e.g., `house.fill`)
  - [ ] Badge/icon clearly visible on concert row
  - [ ] Case-insensitive city comparison
  - [ ] Works for partial matches (e.g., "Los Angeles" matches "Los Angeles, CA")
- **Priority**: Must
- **Notes**: Home city from UserDefaults key "concertCity"

### FR-12: Ticketmaster Purchase Link
- **Type**: Event-Driven
- **Statement**: When the user taps the ticket/buy button on a concert row, the system shall open the Ticketmaster purchase URL in Safari.
- **Acceptance Criteria**:
  - [ ] Each concert row has "Get Tickets" button or tap action
  - [ ] Opens Ticketmaster URL in default browser
  - [ ] Uses `ticketURL` from Concert model
  - [ ] Button shows ticket icon (e.g., `ticket.fill`)
- **Priority**: Must
- **Notes**: Use `UIApplication.shared.open(url)`

### FR-13: Empty State - No Artists
- **Type**: State-Driven
- **Statement**: While the artist list is empty, the system shall display an empty state prompting the user to add artists.
- **Acceptance Criteria**:
  - [ ] Shows ContentUnavailableView or custom empty state
  - [ ] Message: "No artists selected"
  - [ ] Subtext: "Search to add artists or connect Spotify"
  - [ ] Search bar remains accessible
- **Priority**: Should
- **Notes**: Should not show if Spotify returns 0 top artists (show different message)

### FR-14: Empty State - No Concerts Found
- **Type**: State-Driven
- **Statement**: While concert search returns no results, the system shall display an empty state.
- **Acceptance Criteria**:
  - [ ] Shows after search completes with 0 results
  - [ ] Message: "No upcoming concerts found"
  - [ ] Subtext: "Try adding more artists or check back later"
  - [ ] Button to go back to artist list
- **Priority**: Should
- **Notes**: Common scenario - many artists may not be touring

### FR-15: Persist Artist List
- **Type**: Ubiquitous
- **Statement**: The system shall persist the user's customized artist list between sessions.
- **Acceptance Criteria**:
  - [ ] Artist list saved to local storage (UserDefaults or file)
  - [ ] List restored when returning to screen
  - [ ] Includes custom order and any added artists
  - [ ] "Reset to Spotify Top Artists" option available
- **Priority**: Should
- **Notes**: Avoids re-fetching and losing customizations

---

## Non-Functional Requirements

### NFR-1: API Response Time
- **Category**: Performance
- **Statement**: The system shall complete Spotify top artists fetch within 3 seconds under normal network conditions.
- **Acceptance Criteria**:
  - [ ] 95th percentile response time < 3 seconds
  - [ ] Timeout after 10 seconds with error message
- **Priority**: Must

### NFR-2: Concert Search Performance
- **Category**: Performance
- **Statement**: The system shall complete Ticketmaster search for 20 artists within 10 seconds.
- **Acceptance Criteria**:
  - [ ] Parallel API calls to Ticketmaster
  - [ ] Progress indicator during search
  - [ ] Graceful handling if some artists timeout
- **Priority**: Should

### NFR-3: Accessibility - VoiceOver
- **Category**: Accessibility
- **Statement**: The system shall support VoiceOver for all interactive elements.
- **Acceptance Criteria**:
  - [ ] Artist rows have accessibility labels (name, rank)
  - [ ] Buttons have descriptive labels
  - [ ] Reorder actions accessible via rotor
  - [ ] Concert results fully navigable
- **Priority**: Must

### NFR-4: Accessibility - Dynamic Type
- **Category**: Accessibility
- **Statement**: The system shall support Dynamic Type for all text.
- **Acceptance Criteria**:
  - [ ] Text scales with system font size
  - [ ] Layout adjusts for larger text
  - [ ] No text truncation at accessibility sizes
- **Priority**: Should

### NFR-5: Error Recovery
- **Category**: Reliability
- **Statement**: The system shall gracefully handle API failures and allow retry.
- **Acceptance Criteria**:
  - [ ] Network errors show user-friendly message
  - [ ] "Retry" button available on error screens
  - [ ] Partial results shown if some requests succeed
- **Priority**: Must

### NFR-6: Offline Handling
- **Category**: Reliability
- **Statement**: If no network connection, the system shall inform the user and show cached data if available.
- **Acceptance Criteria**:
  - [ ] Detect network unavailability
  - [ ] Show cached artist list if previously loaded
  - [ ] Disable "Find Concerts" when offline
  - [ ] Clear message: "No internet connection"
- **Priority**: Should

---

## Constraints

### Technical Constraints
- **TC-1**: Must use existing SpotifyAuthService for Spotify authentication
- **TC-2**: Ticketmaster API key stored in Keychain (existing pattern)
- **TC-3**: Must follow MVVM architecture pattern per style guide
- **TC-4**: Navigation must integrate with existing AppRouter
- **TC-5**: Concert model already defined - extend if needed, don't replace

### Business Constraints
- **BC-1**: Ticketmaster API rate limits (5 requests/second, 5000/day)
- **BC-2**: Spotify API requires user authorization (already implemented)
- **BC-3**: Only MVP scope - no notifications, calendar, or social features

---

## Assumptions

- **A-1**: User has already connected Spotify in setup (or will be prompted)
- **A-2**: User has configured Ticketmaster API key in setup
- **A-3**: User has set home city in setup (concertCity in UserDefaults)
- **A-4**: Ticketmaster API returns consistent event data structure
- **A-5**: Artist names from Spotify will match Ticketmaster search reasonably well
- **A-6**: Network connection available for initial load

---

## Edge Cases

### EC-1: Spotify Not Connected
- **Scenario**: User opens Concert Discovery but hasn't connected Spotify
- **Handling**: Show prompt to connect Spotify with button to Settings/Setup

### EC-2: No Top Artists from Spotify
- **Scenario**: New Spotify user with no listening history
- **Handling**: Show empty state with message "Listen to more music on Spotify to see recommendations" and allow manual search

### EC-3: Ticketmaster API Key Invalid
- **Scenario**: API key expired or invalid
- **Handling**: Show error with link to Settings to update API key

### EC-4: Artist Name Mismatch
- **Scenario**: Spotify artist name doesn't match Ticketmaster exactly
- **Handling**: Search by artist name as keyword; accept that some may not match

### EC-5: Home City Not Set
- **Scenario**: User hasn't configured concert city
- **Handling**: Don't show home icon on any concerts; optionally prompt to set city

### EC-6: Duplicate Concert (Multiple Artists)
- **Scenario**: Festival or tour with multiple artists from user's list
- **Handling**: Show once, ranked by highest-ranked artist; show all matching artists

### EC-7: Token Expiration During Search
- **Scenario**: Spotify token expires mid-operation
- **Handling**: Refresh token automatically using existing SpotifyAuthService

### EC-8: Very Long Artist List Search
- **Scenario**: User adds 20 artists, each with many tour dates
- **Handling**: Paginate results or limit to 50-100 concerts initially with "Load More"

### EC-9: Concert in Multiple Cities
- **Scenario**: Tour with multiple dates, some in home city
- **Handling**: Each date is a separate concert; home city ones get icon

### EC-10: International Artists
- **Scenario**: Artist with concerts only in other countries
- **Handling**: Show all concerts; home city matching still works; consider country in comparison
