import Foundation
import SwiftUI
import Combine

@MainActor
class AIPlaylistViewModel: ObservableObject {
    @Published var playlistSuggestions: [PlaylistSuggestion] = []
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var selectedSuggestion: PlaylistSuggestion?
    @Published var resolvedSongs: [ResolvedSong] = []
    @Published var isResolvingSongs = false
    @Published var isSavingPlaylist = false
    @Published var savedPlaylistUrl: String?

    private let geminiService = GeminiService.shared
    private let spotifyService = SpotifyService.shared
    private let itunesService = iTunesService.shared

    var canGenerate: Bool {
        geminiService.isConfigured && spotifyService.isAuthenticated && geminiService.canMakeRequest()
    }

    var remainingRequests: Int {
        geminiService.remainingRequests()
    }

    func generatePlaylists() async {
        guard canGenerate else {
            if !geminiService.isConfigured {
                errorMessage = "Configure your Gemini API key in Settings to use AI features."
            } else if !spotifyService.isAuthenticated {
                errorMessage = "Connect Spotify to generate personalized playlists."
            } else {
                errorMessage = "Daily AI generation limit reached. Try again tomorrow."
            }
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            // Build music profile from Spotify data
            async let topArtistsTask = spotifyService.getTopArtists(timeRange: "medium_term", limit: 10)
            async let topTracksTask = spotifyService.getTopTracks(timeRange: "medium_term", limit: 20)
            async let recentTracksTask = spotifyService.getRecentlyPlayed(limit: 20)

            let (topArtists, topTracks, recentTracks) = try await (topArtistsTask, topTracksTask, recentTracksTask)

            let profile = MusicProfile.from(
                artists: topArtists,
                tracks: topTracks,
                recentTracks: recentTracks.map { $0.track }
            )

            // Generate playlists from AI
            let suggestions = try await geminiService.generateThemedPlaylists(profile: profile)
            playlistSuggestions = suggestions

            // Auto-select first suggestion
            if let first = suggestions.first {
                await selectSuggestion(first)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isGenerating = false
    }

    func selectSuggestion(_ suggestion: PlaylistSuggestion) async {
        selectedSuggestion = suggestion
        await resolveSongs(for: suggestion)
    }

    private func resolveSongs(for suggestion: PlaylistSuggestion) async {
        isResolvingSongs = true
        resolvedSongs = []

        // Resolve each song by searching Spotify
        var resolved: [ResolvedSong] = []

        for songSuggestion in suggestion.suggestedSongs {
            do {
                let tracks = try await spotifyService.searchTracks(query: songSuggestion.searchQuery, limit: 1)

                if let track = tracks.first {
                    // Try to get iTunes preview if Spotify doesn't have one
                    var previewUrl = track.previewUrl
                    if previewUrl == nil {
                        previewUrl = await itunesService.searchPreview(
                            trackName: track.name,
                            artistName: track.artists.first?.name ?? ""
                        )
                    }

                    resolved.append(ResolvedSong(
                        id: songSuggestion.id,
                        suggestion: songSuggestion,
                        track: track,
                        previewUrl: previewUrl
                    ))
                } else {
                    resolved.append(ResolvedSong(
                        id: songSuggestion.id,
                        suggestion: songSuggestion,
                        track: nil,
                        previewUrl: nil
                    ))
                }
            } catch {
                resolved.append(ResolvedSong(
                    id: songSuggestion.id,
                    suggestion: songSuggestion,
                    track: nil,
                    previewUrl: nil
                ))
            }
        }

        resolvedSongs = resolved
        isResolvingSongs = false
    }

    func saveAsSpotifyPlaylist(name: String) async {
        guard let userId = spotifyService.userProfile?.id else {
            errorMessage = "Could not get Spotify user ID"
            return
        }

        let trackUris = resolvedSongs.compactMap { $0.track?.uri }
        guard !trackUris.isEmpty else {
            errorMessage = "No tracks to add to playlist"
            return
        }

        isSavingPlaylist = true
        errorMessage = nil

        do {
            // Create playlist
            let playlistId = try await spotifyService.createPlaylist(
                userId: userId,
                name: name,
                description: "Created by vibes AI"
            )

            // Add tracks
            try await spotifyService.addTracksToPlaylist(playlistId: playlistId, trackUris: trackUris)

            savedPlaylistUrl = "https://open.spotify.com/playlist/\(playlistId)"
        } catch {
            errorMessage = "Failed to create playlist: \(error.localizedDescription)"
        }

        isSavingPlaylist = false
    }
}
