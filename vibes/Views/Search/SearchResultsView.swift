import SwiftUI

struct SearchResultsView: View {
    let artists: [UnifiedArtist]
    let albums: [UnifiedAlbum]
    let tracks: [UnifiedTrack]
    let onArtistTap: (UnifiedArtist) -> Void
    let onAlbumTap: (UnifiedAlbum) -> Void
    let onTrackPlay: (UnifiedTrack) -> Void
    let onTrackOpenInSpotify: (UnifiedTrack) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !tracks.isEmpty {
                    tracksSection
                }

                if !artists.isEmpty {
                    artistsSection
                }

                if !albums.isEmpty {
                    albumsSection
                }

                if artists.isEmpty && albums.isEmpty && tracks.isEmpty {
                    emptyState
                }

                // Space for mini player
                Color.clear.frame(height: 80)
            }
            .padding(.top)
        }
    }

    private var artistsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Artists")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(artists) { artist in
                    ArtistSearchRow(artist: artist) {
                        onArtistTap(artist)
                    }

                    if artist.id != artists.last?.id {
                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    private var albumsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Albums")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(albums) { album in
                    AlbumSearchRow(album: album) {
                        onAlbumTap(album)
                    }

                    if album.id != albums.last?.id {
                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    private var tracksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Songs")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(tracks) { track in
                    SongSearchRow(
                        track: track,
                        onPlay: { onTrackPlay(track) },
                        onOpenInSpotify: { onTrackOpenInSpotify(track) }
                    )

                    if track.id != tracks.last?.id {
                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Results",
            systemImage: "magnifyingglass",
            description: Text("Try a different search term")
        )
        .padding(.top, 40)
    }
}

#Preview {
    SearchResultsView(
        artists: [
            UnifiedArtist(id: "1", name: "Drake", genres: ["hip-hop", "rap"])
        ],
        albums: [
            UnifiedAlbum(id: "1", name: "Views", artistName: "Drake", releaseDate: "2016")
        ],
        tracks: [
            UnifiedTrack(id: "1", name: "One Dance", artistName: "Drake", albumName: "Views", durationMs: 177000)
        ],
        onArtistTap: { _ in },
        onAlbumTap: { _ in },
        onTrackPlay: { _ in },
        onTrackOpenInSpotify: { _ in }
    )
    .environment(SpotifyRemoteService.shared)
}
