//
//  MusicPersonalityCard.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI

struct MusicPersonality {
    let title: String
    let subtitle: String
    let emoji: String
    let primaryGenre: String
    let secondaryGenre: String?
    let traits: [String]
    let gradient: [Color]

    static func analyze(genres: [String]) -> MusicPersonality {
        let genreCounts = Dictionary(grouping: genres, by: { $0 }).mapValues { $0.count }
        let sortedGenres = genreCounts.sorted { $0.value > $1.value }

        let primaryGenre = sortedGenres.first?.key ?? "eclectic"
        let secondaryGenre = sortedGenres.count > 1 ? sortedGenres[1].key : nil

        // Calculate genre diversity
        let uniqueGenreCount = Set(genres).count
        let isGenreFluid = uniqueGenreCount > 8

        // Determine personality based on genres
        return determinePersonality(
            primaryGenre: primaryGenre.lowercased(),
            secondaryGenre: secondaryGenre?.lowercased(),
            isGenreFluid: isGenreFluid,
            genreCount: uniqueGenreCount
        )
    }

    private static func determinePersonality(
        primaryGenre: String,
        secondaryGenre: String?,
        isGenreFluid: Bool,
        genreCount: Int
    ) -> MusicPersonality {

        // Genre fluid - no dominant genre
        if isGenreFluid {
            return MusicPersonality(
                title: "Genre Fluid",
                subtitle: "Your taste knows no boundaries",
                emoji: "🌈",
                primaryGenre: "Various",
                secondaryGenre: nil,
                traits: ["Adventurous", "Open-minded", "Eclectic"],
                gradient: [.purple, .pink, .orange]
            )
        }

        // Check for specific genre patterns
        if primaryGenre.contains("hip") || primaryGenre.contains("rap") {
            return MusicPersonality(
                title: "Hip-Hop Head",
                subtitle: "Bars and beats run through your veins",
                emoji: "🎤",
                primaryGenre: "Hip-Hop/Rap",
                secondaryGenre: secondaryGenre,
                traits: ["Lyrical", "Rhythmic", "Culture-driven"],
                gradient: [.black, .purple]
            )
        }

        if primaryGenre.contains("indie") {
            return MusicPersonality(
                title: "Indie Explorer",
                subtitle: "You find gems before they shine",
                emoji: "🔮",
                primaryGenre: "Indie",
                secondaryGenre: secondaryGenre,
                traits: ["Curious", "Authentic", "Trendsetter"],
                gradient: [.teal, .mint]
            )
        }

        if primaryGenre.contains("pop") {
            return MusicPersonality(
                title: "Pop Enthusiast",
                subtitle: "You know what the world loves",
                emoji: "⭐",
                primaryGenre: "Pop",
                secondaryGenre: secondaryGenre,
                traits: ["Social", "Upbeat", "Connected"],
                gradient: [.pink, .purple]
            )
        }

        if primaryGenre.contains("rock") || primaryGenre.contains("metal") {
            return MusicPersonality(
                title: "Rock Soul",
                subtitle: "Guitar riffs fuel your spirit",
                emoji: "🎸",
                primaryGenre: "Rock",
                secondaryGenre: secondaryGenre,
                traits: ["Passionate", "Intense", "Authentic"],
                gradient: [.red, .black]
            )
        }

        if primaryGenre.contains("electronic") || primaryGenre.contains("edm") || primaryGenre.contains("house") {
            return MusicPersonality(
                title: "Electronic Soul",
                subtitle: "You live for the drop",
                emoji: "🎧",
                primaryGenre: "Electronic",
                secondaryGenre: secondaryGenre,
                traits: ["Energetic", "Futuristic", "Night owl"],
                gradient: [.cyan, .blue]
            )
        }

        if primaryGenre.contains("r&b") || primaryGenre.contains("soul") {
            return MusicPersonality(
                title: "R&B Romantic",
                subtitle: "Smooth vibes, deep feelings",
                emoji: "💜",
                primaryGenre: "R&B/Soul",
                secondaryGenre: secondaryGenre,
                traits: ["Emotional", "Smooth", "Romantic"],
                gradient: [.purple, .indigo]
            )
        }

        if primaryGenre.contains("jazz") || primaryGenre.contains("blues") {
            return MusicPersonality(
                title: "Jazz Aficionado",
                subtitle: "You appreciate the classics",
                emoji: "🎷",
                primaryGenre: "Jazz/Blues",
                secondaryGenre: secondaryGenre,
                traits: ["Sophisticated", "Timeless", "Cultured"],
                gradient: [.brown, .orange]
            )
        }

        if primaryGenre.contains("country") || primaryGenre.contains("folk") {
            return MusicPersonality(
                title: "Country Soul",
                subtitle: "Stories and strings speak to you",
                emoji: "🤠",
                primaryGenre: "Country/Folk",
                secondaryGenre: secondaryGenre,
                traits: ["Storyteller", "Grounded", "Nostalgic"],
                gradient: [.brown, .yellow]
            )
        }

        if primaryGenre.contains("classical") || primaryGenre.contains("orchestra") {
            return MusicPersonality(
                title: "Classical Connoisseur",
                subtitle: "Timeless compositions move you",
                emoji: "🎻",
                primaryGenre: "Classical",
                secondaryGenre: secondaryGenre,
                traits: ["Refined", "Patient", "Deep thinker"],
                gradient: [.black, .gray]
            )
        }

        if primaryGenre.contains("latin") || primaryGenre.contains("reggaeton") {
            return MusicPersonality(
                title: "Latin Vibes",
                subtitle: "Rhythm is in your blood",
                emoji: "💃",
                primaryGenre: "Latin",
                secondaryGenre: secondaryGenre,
                traits: ["Passionate", "Vibrant", "Celebratory"],
                gradient: [.red, .orange]
            )
        }

        // Default fallback
        return MusicPersonality(
            title: "Music Lover",
            subtitle: "Your taste is uniquely you",
            emoji: "🎵",
            primaryGenre: primaryGenre.capitalized,
            secondaryGenre: secondaryGenre,
            traits: ["Diverse", "Curious", "Authentic"],
            gradient: [.blue, .purple]
        )
    }
}

struct MusicPersonalityCard: View {
    let personality: MusicPersonality
    let username: String

    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            ZStack {
                LinearGradient(
                    colors: personality.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 8) {
                    Text(personality.emoji)
                        .font(.system(size: 48))

                    Text(personality.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(personality.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 24)
            }
            .frame(height: 180)

            // Details section
            VStack(spacing: 16) {
                // Username
                HStack {
                    Text("@\(username)")
                        .font(.headline)
                    Spacer()
                    Text("vibes")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Primary genre
                HStack {
                    Text("Primary Genre")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(personality.primaryGenre)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                if let secondary = personality.secondaryGenre {
                    HStack {
                        Text("Secondary")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(secondary.capitalized)
                            .font(.subheadline)
                    }
                }

                Divider()

                // Traits
                HStack(spacing: 8) {
                    ForEach(personality.traits, id: \.self) { trait in
                        Text(trait)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

struct MusicPersonalityCardView: View {
    @StateObject private var spotifyService = SpotifyService.shared
    @State private var personality: MusicPersonality?
    @State private var isLoading = true
    @State private var username: String = ""

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(height: 300)
            } else if let personality = personality {
                MusicPersonalityCard(personality: personality, username: username)
            } else {
                Text("Connect Spotify to see your music personality")
                    .foregroundColor(.secondary)
                    .frame(height: 300)
            }
        }
        .task {
            await loadPersonality()
        }
    }

    private func loadPersonality() async {
        isLoading = true

        do {
            let artists = try await spotifyService.getTopArtists(timeRange: "medium_term", limit: 50)
            let allGenres = artists.flatMap { $0.genres ?? [] }

            if !allGenres.isEmpty {
                personality = MusicPersonality.analyze(genres: allGenres)
            }

            if let profile = spotifyService.userProfile {
                username = profile.displayName ?? profile.id
            }
        } catch {
            print("Failed to load personality: \(error)")
        }

        isLoading = false
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            MusicPersonalityCard(
                personality: MusicPersonality(
                    title: "Indie Explorer",
                    subtitle: "You find gems before they shine",
                    emoji: "🔮",
                    primaryGenre: "Indie",
                    secondaryGenre: "Alternative",
                    traits: ["Curious", "Authentic", "Trendsetter"],
                    gradient: [.teal, .mint]
                ),
                username: "musicfan"
            )
            .padding()

            MusicPersonalityCard(
                personality: MusicPersonality(
                    title: "Hip-Hop Head",
                    subtitle: "Bars and beats run through your veins",
                    emoji: "🎤",
                    primaryGenre: "Hip-Hop",
                    secondaryGenre: "R&B",
                    traits: ["Lyrical", "Rhythmic", "Culture-driven"],
                    gradient: [.black, .purple]
                ),
                username: "hiphoplover"
            )
            .padding()
        }
    }
}
