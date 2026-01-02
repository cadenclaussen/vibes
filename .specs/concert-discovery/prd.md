# Concert Discovery - Product Requirements

## Summary

A feature that enables users to discover live concerts from their favorite artists. Users start with their top 10 Spotify artists from the last 3 months, can customize this list (add, remove, reorder up to 20 artists), and then search for upcoming concerts via the Ticketmaster API. Results are ranked by the user's artist preferences, with special highlighting for concerts in the user's home city.

## Problem Statement

Music fans often miss concerts from artists they love because:
1. They don't actively track tour announcements for all their favorite artists
2. Concert discovery is fragmented across multiple ticketing platforms
3. There's no connection between their streaming habits and live music opportunities

Users need a way to leverage their existing music taste data (Spotify listening history) to automatically surface relevant concerts without manual searching.

## Goals

- **G1**: Let users see their top artists from Spotify as a starting point for concert discovery
- **G2**: Allow full customization of the artist list (add via search, remove, reorder)
- **G3**: Search Ticketmaster for concerts from the user's selected artists
- **G4**: Rank concert results by the user's artist ranking preferences
- **G5**: Highlight concerts in the user's home city for easy identification
- **G6**: Provide direct links to purchase tickets on Ticketmaster

## Non-Goals

- **NG1**: Supporting multiple ticketing platforms (Ticketmaster only for MVP)
- **NG2**: Calendar integration or concert reminders
- **NG3**: Price comparison across ticket sellers
- **NG4**: Secondary market / resale tickets
- **NG5**: Concert notifications or alerts
- **NG6**: Social features (sharing concerts with friends)

## Target Users

- **Primary**: Spotify users who attend live music events
- **Secondary**: Music enthusiasts who want to discover concerts based on their listening habits
- **Tertiary**: Casual concert-goers looking for recommendations

## Scope

### Included Functionality

1. **Artist List Screen**
   - Display user's top 10 Spotify artists (time range: last 3 months)
   - Remove any artist from the list (swipe or button)
   - Add artists via search bar with autocomplete
   - Reorder artists via drag-and-drop
   - Enforce maximum of 20 artists

2. **Concert Search**
   - "Find Concerts" button to initiate search
   - Query Ticketmaster API for each artist in the list
   - Aggregate and deduplicate results

3. **Concert Results**
   - List of upcoming concerts sorted by artist ranking
   - Each result shows: artist name, venue, city, date, time
   - Special icon/badge for concerts in user's home city
   - Ticketmaster link button for each concert

4. **Navigation**
   - Button on Feed page to access Concert Discovery
   - Push navigation to the artist list screen
   - Transition to results after search

### Data Sources

- **Spotify API**: User's top artists (time_range: medium_term for ~6 months, or short_term for ~4 weeks)
- **Spotify Search API**: Artist search for adding new artists
- **Ticketmaster Discovery API**: Concert/event search by artist
- **User Profile**: Home city (from setup/settings)

### Key Screens

1. **Feed Page**: Entry point button "Discover Concerts"
2. **Artist List Screen**: Editable list of artists with search bar
3. **Concert Results Screen**: Ranked list of concerts with purchase links
