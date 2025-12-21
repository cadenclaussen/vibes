import Foundation
import SwiftUI
import Combine

@MainActor
class FriendBlendViewModel: ObservableObject {
    @Published var blendResult: BlendResult?
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var resolvedSongs: [ResolvedBlendSong] = []
    @Published var isResolvingSongs = false
    @Published var isSavingPlaylist = false
    @Published var savedPlaylistUrl: String?

    let friend: FriendProfile

    private let geminiService = GeminiService.shared
    private let spotifyService = SpotifyService.shared
    private let itunesService = iTunesService.shared

    init(friend: FriendProfile) {
        self.friend = friend
    }

    var canGenerate: Bool {
        geminiService.isConfigured && spotifyService.isAuthenticated && geminiService.canMakeRequest()
    }

    var remainingRequests: Int {
        geminiService.remainingRequests()
    }

    func generateBlend() async {
        guard canGenerate else {
            if !geminiService.isConfigured {
                errorMessage = "Configure your Gemini API key in Settings to use AI features."
            } else if !spotifyService.isAuthenticated {
                errorMessage = "Connect Spotify to generate personalized blends."
            } else {
                errorMessage = "Daily AI generation limit reached. Try again tomorrow."
            }
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            // Build current user's profile from Spotify
            async let topArtistsTask = spotifyService.getTopArtists(timeRange: "medium_term", limit: 10)
            async let topTracksTask = spotifyService.getTopTracks(timeRange: "medium_term", limit: 20)

            let (topArtists, topTracks) = try await (topArtistsTask, topTracksTask)

            let userProfile = MusicProfile.from(
                artists: topArtists,
                tracks: topTracks,
                recentTracks: []
            )

            // Build friend's profile from their music taste tags
            // Since we don't have direct access to friend's Spotify, we use their music taste tags
            let friendProfile = MusicProfile(
                topArtists: [],
                topTracks: [],
                genres: friend.musicTasteTags,
                recentTracks: [],
                musicTasteTags: friend.musicTasteTags
            )

            // Generate blend
            let blend = try await geminiService.generateFriendBlend(
                user1Profile: userProfile,
                user2Profile: friendProfile,
                user2Name: friend.displayName
            )

            blendResult = blend

            // Resolve songs
            await resolveSongs(from: blend.recommendations)
        } catch {
            errorMessage = error.localizedDescription
        }

        isGenerating = false
    }

    private func resolveSongs(from recommendations: [BlendRecommendation]) async {
        isResolvingSongs = true
        resolvedSongs = []

        var resolved: [ResolvedBlendSong] = []

        for recommendation in recommendations {
            do {
                let tracks = try await spotifyService.searchTracks(query: recommendation.searchQuery, limit: 1)

                if let track = tracks.first {
                    var previewUrl = track.previewUrl
                    if previewUrl == nil {
                        previewUrl = await itunesService.searchPreview(
                            trackName: track.name,
                            artistName: track.artists.first?.name ?? ""
                        )
                    }

                    resolved.append(ResolvedBlendSong(
                        id: recommendation.id,
                        recommendation: recommendation,
                        track: track,
                        previewUrl: previewUrl
                    ))
                } else {
                    resolved.append(ResolvedBlendSong(
                        id: recommendation.id,
                        recommendation: recommendation,
                        track: nil,
                        previewUrl: nil
                    ))
                }
            } catch {
                resolved.append(ResolvedBlendSong(
                    id: recommendation.id,
                    recommendation: recommendation,
                    track: nil,
                    previewUrl: nil
                ))
            }
        }

        resolvedSongs = resolved
        isResolvingSongs = false
    }

    func saveAsSpotifyPlaylist() async {
        guard let userId = spotifyService.userProfile?.id,
              let blendResult = blendResult else {
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
            let playlistId = try await spotifyService.createPlaylist(
                userId: userId,
                name: blendResult.blendName,
                description: "A musical blend with \(friend.displayName) - Created by vibes AI"
            )

            try await spotifyService.addTracksToPlaylist(playlistId: playlistId, trackUris: trackUris)

            savedPlaylistUrl = "https://open.spotify.com/playlist/\(playlistId)"
        } catch {
            errorMessage = "Failed to create playlist: \(error.localizedDescription)"
        }

        isSavingPlaylist = false
    }
}
