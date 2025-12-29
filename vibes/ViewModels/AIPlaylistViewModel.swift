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
    private let musicServiceManager = MusicServiceManager.shared
    private let itunesService = iTunesService.shared

    var canGenerate: Bool {
        geminiService.isConfigured && musicServiceManager.isAuthenticated && geminiService.canMakeRequest()
    }

    var remainingRequests: Int {
        geminiService.remainingRequests()
    }

    func generatePlaylists() async {
        guard canGenerate else {
            if !geminiService.isConfigured {
                errorMessage = "Configure your Gemini API key in Settings to use AI features."
            } else if !musicServiceManager.isAuthenticated {
                errorMessage = "Connect \(musicServiceManager.serviceName) to generate personalized playlists."
            } else {
                errorMessage = "Daily AI generation limit reached. Try again tomorrow."
            }
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            let service = musicServiceManager.currentService

            // Build music profile from music service data
            async let topArtistsTask = service.getTopArtists(timeRange: .mediumTerm, limit: 10)
            async let topTracksTask = service.getTopTracks(timeRange: .mediumTerm, limit: 20)
            async let recentTracksTask = service.getRecentlyPlayed(limit: 20)

            let (topArtists, topTracks, recentTracks) = try await (topArtistsTask, topTracksTask, recentTracksTask)

            let profile = MusicProfile.fromUnified(
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

        let service = musicServiceManager.currentService

        // Resolve each song by searching the music service
        var resolved: [ResolvedSong] = []

        for songSuggestion in suggestion.suggestedSongs {
            do {
                let tracks = try await service.searchTracks(query: songSuggestion.searchQuery, limit: 1)

                if let track = tracks.first {
                    // Try to get iTunes preview if no preview available
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
                        unifiedTrack: track,
                        previewUrl: previewUrl
                    ))
                } else {
                    resolved.append(ResolvedSong(
                        id: songSuggestion.id,
                        suggestion: songSuggestion,
                        unifiedTrack: nil,
                        previewUrl: nil
                    ))
                }
            } catch {
                resolved.append(ResolvedSong(
                    id: songSuggestion.id,
                    suggestion: songSuggestion,
                    unifiedTrack: nil,
                    previewUrl: nil
                ))
            }
        }

        resolvedSongs = resolved
        isResolvingSongs = false
    }

    func savePlaylist(name: String) async {
        let service = musicServiceManager.currentService

        let trackUris = resolvedSongs.compactMap { resolved -> String? in
            guard let track = resolved.unifiedTrack else { return nil }
            return service.getTrackUri(for: track)
        }

        guard !trackUris.isEmpty else {
            errorMessage = "No tracks to add to playlist"
            return
        }

        isSavingPlaylist = true
        errorMessage = nil

        do {
            // Create playlist
            let playlistId = try await service.createPlaylist(
                name: name,
                description: "Created by vibes AI"
            )

            // Add tracks
            try await service.addTracksToPlaylist(playlistId: playlistId, trackUris: trackUris)

            // Set the URL based on service type
            switch musicServiceManager.activeServiceType {
            case .spotify:
                savedPlaylistUrl = "https://open.spotify.com/playlist/\(playlistId)"
            case .appleMusic:
                savedPlaylistUrl = "https://music.apple.com/library/playlist/\(playlistId)"
            case .none:
                savedPlaylistUrl = nil
            }
        } catch {
            errorMessage = "Failed to create playlist: \(error.localizedDescription)"
        }

        isSavingPlaylist = false
    }
}
