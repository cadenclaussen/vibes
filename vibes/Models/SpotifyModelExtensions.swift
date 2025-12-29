import Foundation

// MARK: - Spotify to Unified Model Conversions

extension Track {
    func toUnified() -> UnifiedTrack {
        UnifiedTrack(
            id: "spotify_\(id)",
            originalId: id,
            serviceType: .spotify,
            name: name,
            artists: artists.map { $0.toUnified() },
            album: album.toUnified(),
            durationMs: durationMs,
            isExplicit: explicit,
            previewUrl: previewUrl,
            externalUrl: externalUrls.spotify,
            uri: uri
        )
    }
}

extension Artist {
    func toUnified() -> UnifiedArtist {
        UnifiedArtist(
            id: "spotify_\(id)",
            originalId: id,
            serviceType: .spotify,
            name: name,
            imageUrl: images?.first?.url,
            genres: genres,
            followerCount: followers?.total,
            externalUrl: externalUrls?.spotify,
            uri: uri
        )
    }
}

extension Album {
    func toUnified() -> UnifiedAlbum {
        UnifiedAlbum(
            id: "spotify_\(id)",
            originalId: id,
            serviceType: .spotify,
            name: name,
            imageUrl: images.first?.url,
            releaseDate: releaseDate,
            trackCount: totalTracks,
            externalUrl: nil,
            uri: uri
        )
    }
}

extension Playlist {
    func toUnified() -> UnifiedPlaylist {
        UnifiedPlaylist(
            id: "spotify_\(id)",
            originalId: id,
            serviceType: .spotify,
            name: name,
            description: description,
            imageUrl: images?.first?.url,
            ownerName: owner.displayName ?? owner.id,
            trackCount: tracks.total,
            isPublic: isPublic,
            isCollaborative: collaborative,
            externalUrl: externalUrls?.spotify,
            uri: uri
        )
    }
}

extension SimplifiedTrack {
    func toUnified() -> UnifiedSimplifiedTrack {
        UnifiedSimplifiedTrack(
            id: "spotify_\(id)",
            originalId: id,
            serviceType: .spotify,
            name: name,
            artists: artists.map { $0.toUnified() },
            durationMs: durationMs,
            isExplicit: explicit,
            previewUrl: previewUrl,
            trackNumber: trackNumber,
            uri: uri
        )
    }
}

extension CurrentlyPlaying {
    func toUnified() -> UnifiedCurrentlyPlaying {
        UnifiedCurrentlyPlaying(
            track: item?.toUnified(),
            isPlaying: isPlaying,
            progressMs: progressMs,
            timestamp: timestamp
        )
    }
}

extension PlayHistory {
    func toUnified() -> UnifiedPlayHistory {
        UnifiedPlayHistory(
            track: track.toUnified(),
            playedAt: playedAt
        )
    }
}

extension SpotifyUserProfile {
    func toUnified() -> UnifiedUserProfile {
        UnifiedUserProfile(
            id: id,
            displayName: displayName,
            email: email,
            imageUrl: images?.first?.url,
            serviceType: .spotify,
            followerCount: followers?.total,
            country: country
        )
    }
}
