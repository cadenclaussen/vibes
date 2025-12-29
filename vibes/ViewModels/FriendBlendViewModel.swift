import Foundation
import SwiftUI
import Combine
import FirebaseAuth

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
    private let musicServiceManager = MusicServiceManager.shared
    private let itunesService = iTunesService.shared
    private let firestoreService = FirestoreService.shared
    private let authManager = AuthManager.shared

    init(friend: FriendProfile) {
        self.friend = friend
    }

    var canGenerate: Bool {
        geminiService.isConfigured && musicServiceManager.isAuthenticated && geminiService.canMakeRequest()
    }

    var remainingRequests: Int {
        geminiService.remainingRequests()
    }

    func generateBlend() async {
        guard canGenerate else {
            if !geminiService.isConfigured {
                errorMessage = "Configure your Gemini API key in Settings to use AI features."
            } else if !musicServiceManager.isAuthenticated {
                errorMessage = "Connect \(musicServiceManager.serviceName) to generate personalized blends."
            } else {
                errorMessage = "Daily AI generation limit reached. Try again tomorrow."
            }
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            // Get current user's profile for their musicTasteTags
            guard let userId = authManager.user?.uid else {
                errorMessage = "Not authenticated"
                isGenerating = false
                return
            }
            let currentUserProfile = try await firestoreService.getUserProfile(userId: userId)

            // Build current user's profile from music service + their musicTasteTags
            let service = musicServiceManager.currentService
            async let topArtistsTask = service.getTopArtists(timeRange: .mediumTerm, limit: 10)
            async let topTracksTask = service.getTopTracks(timeRange: .mediumTerm, limit: 20)

            let (topArtists, topTracks) = try await (topArtistsTask, topTracksTask)

            let userProfile = MusicProfile.fromUnified(
                artists: topArtists,
                tracks: topTracks,
                recentTracks: [],
                tags: currentUserProfile.musicTasteTags
            )

            // Build friend's profile from their favorite artists and music taste tags
            let friendProfile = MusicProfile(
                topArtists: friend.favoriteArtists,
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

            // Track blend achievement
            LocalAchievementStats.shared.blendsCreated += 1

            // Check for soulmate secret achievement (90%+ average blend score)
            if !blend.recommendations.isEmpty {
                let averageScore = blend.recommendations.reduce(0.0) { $0 + $1.blendScore } / Double(blend.recommendations.count)
                if averageScore >= 0.9 {
                    LocalAchievementStats.shared.hasSoulmate = true
                }
            }

            LocalAchievementStats.shared.checkLocalAchievements()

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

        let service = musicServiceManager.currentService
        var resolved: [ResolvedBlendSong] = []

        for recommendation in recommendations {
            do {
                let tracks = try await service.searchTracks(query: recommendation.searchQuery, limit: 1)

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
                        unifiedTrack: track,
                        previewUrl: previewUrl
                    ))
                } else {
                    resolved.append(ResolvedBlendSong(
                        id: recommendation.id,
                        recommendation: recommendation,
                        unifiedTrack: nil,
                        previewUrl: nil
                    ))
                }
            } catch {
                resolved.append(ResolvedBlendSong(
                    id: recommendation.id,
                    recommendation: recommendation,
                    unifiedTrack: nil,
                    previewUrl: nil
                ))
            }
        }

        resolvedSongs = resolved
        isResolvingSongs = false
    }

    func savePlaylist() async {
        guard let blendResult = blendResult else {
            errorMessage = "No blend result to save"
            return
        }

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
            let playlistId = try await service.createPlaylist(
                name: blendResult.blendName,
                description: "A musical blend with \(friend.displayName) - Created by vibes AI"
            )

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
