# Album Detail & Artist Profile Requirements

## Functional Requirements (EARS Format)

### Album Detail View

**REQ-ALB-1**: When the user taps an album, the system shall display the Album Detail View with album artwork, name, artist name, release year, and track count.

**REQ-ALB-2**: When the Album Detail View loads, the system shall fetch and display all tracks from the album using SpotifyDataService.getAlbumTracks().

**REQ-ALB-3**: For each track in the album, the system shall display: track number, track name, duration, and explicit badge (if applicable).

**REQ-ALB-4**: When the user taps a track, the system shall play that track using SpotifyRemoteService.

**REQ-ALB-5**: When the user taps "Play All", the system shall play the first track of the album.

**REQ-ALB-6**: When the user taps "Shuffle", the system shall play a random track from the album.

**REQ-ALB-7**: When the user taps the artist name, the system shall navigate to the Artist Profile View.

**REQ-ALB-8**: When the user long-presses a track, the system shall display a context menu with: "Send to Friend", "Add to Playlist", "Open in Spotify".

### Artist Profile View

**REQ-ART-1**: When the user navigates to an artist, the system shall display the Artist Profile View with artist image, name, and genres.

**REQ-ART-2**: When the Artist Profile View loads, the system shall fetch the artist's top tracks and albums using SpotifyDataService.

**REQ-ART-3**: The system shall display up to 5 top songs in a vertical list with play functionality.

**REQ-ART-4**: The system shall display the artist's albums in a horizontal scrolling section.

**REQ-ART-5**: When the user taps a song, the system shall play that song using SpotifyRemoteService.

**REQ-ART-6**: When the user taps an album, the system shall navigate to the Album Detail View.

**REQ-ART-7**: When the user long-presses a song, the system shall display a context menu with: "Send to Friend", "Add to Playlist", "Open in Spotify".

## Non-Functional Requirements

**REQ-NFR-1**: The system shall display a loading indicator while fetching album/artist data.

**REQ-NFR-2**: The system shall display the MiniPlayer at the bottom when a track is playing.

**REQ-NFR-3**: Album tracks shall load within 2 seconds on a typical network connection.

**REQ-NFR-4**: Artist data (top tracks + albums) shall load within 3 seconds on a typical network connection.
