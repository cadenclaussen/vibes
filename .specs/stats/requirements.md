# Stats Feature Requirements

## Functional Requirements

### Profile Preview Card

#### STAT-1: Stats Preview on Profile
When the user views their Profile and has Spotify connected, the system shall display a "Your Stats" preview card showing their top 3 artists with images and names.

#### STAT-2: Preview Card Navigation
When the user taps the Stats preview card, the system shall navigate to the full Stats view.

#### STAT-3: Preview Card No-Spotify State
When the user views their Profile without Spotify connected, the Stats preview card shall display "Connect Spotify to see your stats" with a button to navigate to Settings.

### Full Stats View

#### STAT-4: Top Artists Display
When the user views the full Stats screen, the system shall display their top 10 artists from Spotify with artist name and image in a horizontal scrollable list.

#### STAT-5: Top Songs Display
When the user views the full Stats screen, the system shall display their top 10 songs from Spotify with song title, artist name, and album art in a vertical list.

#### STAT-6: Top Genres Display
When the user views the full Stats screen, the system shall display their top 5 genres derived from their top artists as chips.

#### STAT-7: Recently Played Display
When the user views the full Stats screen, the system shall display their last 20 recently played tracks with song title, artist, and relative play time.

#### STAT-8: Time Range Selection
The Stats view shall allow users to select a time range for top artists and songs:
- Short term (last 4 weeks) - default
- Medium term (last 6 months)
- Long term (all time)

#### STAT-9: Open in Spotify
When the user taps an artist or song, the system shall open that item in the Spotify app (or web if app not installed).

### States

#### STAT-10: Loading State
While fetching data from Spotify, the system shall display a loading indicator.

#### STAT-11: Error Handling
If the Spotify API fails, the system shall display an error message with a retry option.

#### STAT-12: Pull to Refresh
The Stats view shall support pull-to-refresh to reload all data.

## Non-Functional Requirements

### STAT-NFR-1: Preview Performance
The Stats preview card shall load within 1 second (fetches only 3 artists).

### STAT-NFR-2: Full Stats Performance
The full Stats view shall load within 3 seconds on a typical network connection.

### STAT-NFR-3: Spotify Rate Limits
The system shall respect Spotify API rate limits and handle 429 responses gracefully.
