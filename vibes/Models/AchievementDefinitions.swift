//
//  AchievementDefinitions.swift
//  vibes
//
//  All achievement definitions for the app.
//

import Foundation

extension AchievementDefinition {
    static let all: [AchievementDefinition] = [
        // MARK: - Sharing achievements (8 total)
        AchievementDefinition(
            id: "first_share",
            name: "First Vibe",
            description: "Share your first song",
            icon: "music.note",
            category: .sharing,
            requirement: 1
        ),
        AchievementDefinition(
            id: "share_10",
            name: "Vibe Spreader",
            description: "Share 10 songs",
            icon: "music.note.list",
            category: .sharing,
            requirement: 10
        ),
        AchievementDefinition(
            id: "share_50",
            name: "DJ Mode",
            description: "Share 50 songs",
            icon: "waveform",
            category: .sharing,
            requirement: 50
        ),
        AchievementDefinition(
            id: "share_100",
            name: "Curator",
            description: "Share 100 songs",
            icon: "star.fill",
            category: .sharing,
            requirement: 100
        ),
        AchievementDefinition(
            id: "share_250",
            name: "Vibesetter",
            description: "Share 250 songs",
            icon: "music.quarternote.3",
            category: .sharing,
            requirement: 250
        ),
        AchievementDefinition(
            id: "share_500",
            name: "Music Maven",
            description: "Share 500 songs",
            icon: "guitars.fill",
            category: .sharing,
            requirement: 500
        ),
        AchievementDefinition(
            id: "share_1000",
            name: "Vibe Legend",
            description: "Share 1000 songs",
            icon: "trophy.fill",
            category: .sharing,
            requirement: 1000,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "unique_artists_25",
            name: "Diverse Taste",
            description: "Share songs from 25 different artists",
            icon: "person.wave.2.fill",
            category: .sharing,
            requirement: 25,
            showsProgressCount: true
        ),

        // MARK: - Social achievements (10 total)
        AchievementDefinition(
            id: "first_friend",
            name: "Connected",
            description: "Add your first friend",
            icon: "person.fill.badge.plus",
            category: .social,
            requirement: 1
        ),
        AchievementDefinition(
            id: "friends_5",
            name: "Circle",
            description: "Have 5 friends",
            icon: "person.2.fill",
            category: .social,
            requirement: 5
        ),
        AchievementDefinition(
            id: "friends_10",
            name: "Crew",
            description: "Have 10 friends",
            icon: "person.3.fill",
            category: .social,
            requirement: 10
        ),
        AchievementDefinition(
            id: "friends_25",
            name: "Squad",
            description: "Have 25 friends",
            icon: "person.3.sequence.fill",
            category: .social,
            requirement: 25
        ),
        AchievementDefinition(
            id: "friends_50",
            name: "Popular",
            description: "Have 50 friends",
            icon: "figure.socialdance",
            category: .social,
            requirement: 50
        ),
        AchievementDefinition(
            id: "friends_100",
            name: "Influencer",
            description: "Have 100 friends",
            icon: "star.circle.fill",
            category: .social,
            requirement: 100,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "friend_requests_sent_5",
            name: "Outgoing",
            description: "Send 5 friend requests",
            icon: "paperplane.fill",
            category: .social,
            requirement: 5
        ),
        AchievementDefinition(
            id: "friend_requests_sent_25",
            name: "Networker",
            description: "Send 25 friend requests",
            icon: "network",
            category: .social,
            requirement: 25,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "first_blend",
            name: "Blend Beginner",
            description: "Create your first Friend Blend",
            icon: "arrow.triangle.merge",
            category: .social,
            requirement: 1
        ),
        AchievementDefinition(
            id: "blends_10",
            name: "Blend Master",
            description: "Create 10 Friend Blends",
            icon: "arrow.triangle.branch",
            category: .social,
            requirement: 10,
            showsProgressCount: true
        ),

        // MARK: - Streak achievements (8 total)
        AchievementDefinition(
            id: "streak_3",
            name: "Getting Started",
            description: "Maintain a 3-day vibestreak",
            icon: "flame",
            category: .streak,
            requirement: 3
        ),
        AchievementDefinition(
            id: "streak_7",
            name: "Week Warrior",
            description: "Maintain a 7-day vibestreak",
            icon: "flame",
            category: .streak,
            requirement: 7
        ),
        AchievementDefinition(
            id: "streak_14",
            name: "Fortnight Focus",
            description: "Maintain a 14-day vibestreak",
            icon: "flame.fill",
            category: .streak,
            requirement: 14
        ),
        AchievementDefinition(
            id: "streak_30",
            name: "Monthly Maven",
            description: "Maintain a 30-day vibestreak",
            icon: "flame.fill",
            category: .streak,
            requirement: 30
        ),
        AchievementDefinition(
            id: "streak_60",
            name: "Two Month Titan",
            description: "Maintain a 60-day vibestreak",
            icon: "flame.circle",
            category: .streak,
            requirement: 60
        ),
        AchievementDefinition(
            id: "streak_100",
            name: "Centurion",
            description: "Maintain a 100-day vibestreak",
            icon: "flame.circle.fill",
            category: .streak,
            requirement: 100
        ),
        AchievementDefinition(
            id: "streak_180",
            name: "Half Year Hero",
            description: "Maintain a 180-day vibestreak",
            icon: "sun.max.fill",
            category: .streak,
            requirement: 180
        ),
        AchievementDefinition(
            id: "streak_365",
            name: "Legendary",
            description: "Maintain a 365-day vibestreak",
            icon: "crown.fill",
            category: .streak,
            requirement: 365,
            showsProgressCount: true
        ),

        // MARK: - Discovery achievements (10 total)
        AchievementDefinition(
            id: "spotify_connect",
            name: "Tuned In",
            description: "Connect Spotify",
            icon: "antenna.radiowaves.left.and.right",
            category: .discovery,
            requirement: 1
        ),
        AchievementDefinition(
            id: "playlist_share",
            name: "Playlist Pro",
            description: "Share a playlist",
            icon: "list.bullet.rectangle",
            category: .discovery,
            requirement: 1
        ),
        AchievementDefinition(
            id: "playlist_share_5",
            name: "Playlist Pusher",
            description: "Share 5 playlists",
            icon: "list.bullet.rectangle.fill",
            category: .discovery,
            requirement: 5
        ),
        AchievementDefinition(
            id: "playlist_share_25",
            name: "Playlist Legend",
            description: "Share 25 playlists",
            icon: "rectangle.stack.fill",
            category: .discovery,
            requirement: 25,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "genres_3",
            name: "Explorer",
            description: "Have 3 favorite genres",
            icon: "music.mic",
            category: .discovery,
            requirement: 3
        ),
        AchievementDefinition(
            id: "genres_5",
            name: "Eclectic",
            description: "Have 5 favorite genres",
            icon: "music.mic",
            category: .discovery,
            requirement: 5
        ),
        AchievementDefinition(
            id: "genres_10",
            name: "Music Encyclopedia",
            description: "Have 10 favorite genres",
            icon: "books.vertical.fill",
            category: .discovery,
            requirement: 10,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "songs_added_10",
            name: "Playlist Builder",
            description: "Add 10 songs to playlists",
            icon: "plus.circle",
            category: .discovery,
            requirement: 10
        ),
        AchievementDefinition(
            id: "songs_added_50",
            name: "Playlist Architect",
            description: "Add 50 songs to playlists",
            icon: "plus.circle.fill",
            category: .discovery,
            requirement: 50
        ),
        AchievementDefinition(
            id: "songs_added_100",
            name: "Playlist Engineer",
            description: "Add 100 songs to playlists",
            icon: "rectangle.stack.badge.plus",
            category: .discovery,
            requirement: 100,
            showsProgressCount: true
        ),

        // MARK: - Messaging achievements (10 total)
        AchievementDefinition(
            id: "first_message",
            name: "Ice Breaker",
            description: "Send your first message",
            icon: "bubble.left.fill",
            category: .messaging,
            requirement: 1
        ),
        AchievementDefinition(
            id: "messages_10",
            name: "Chatterbox",
            description: "Send 10 messages",
            icon: "bubble.left.and.bubble.right",
            category: .messaging,
            requirement: 10
        ),
        AchievementDefinition(
            id: "messages_50",
            name: "Conversationalist",
            description: "Send 50 messages",
            icon: "bubble.left.and.bubble.right.fill",
            category: .messaging,
            requirement: 50
        ),
        AchievementDefinition(
            id: "messages_100",
            name: "Social Butterfly",
            description: "Send 100 messages",
            icon: "message.fill",
            category: .messaging,
            requirement: 100
        ),
        AchievementDefinition(
            id: "messages_500",
            name: "Talk Show Host",
            description: "Send 500 messages",
            icon: "mic.fill",
            category: .messaging,
            requirement: 500
        ),
        AchievementDefinition(
            id: "messages_1000",
            name: "Chatter Champion",
            description: "Send 1000 messages",
            icon: "megaphone.fill",
            category: .messaging,
            requirement: 1000,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "conversations_3",
            name: "Social Starter",
            description: "Chat with 3 different friends",
            icon: "person.2.wave.2",
            category: .messaging,
            requirement: 3
        ),
        AchievementDefinition(
            id: "conversations_10",
            name: "Connector",
            description: "Chat with 10 different friends",
            icon: "person.2.wave.2.fill",
            category: .messaging,
            requirement: 10,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "song_messages_25",
            name: "Track Dealer",
            description: "Send 25 song messages",
            icon: "music.note.tv",
            category: .messaging,
            requirement: 25
        ),
        AchievementDefinition(
            id: "song_messages_100",
            name: "Music Dealer",
            description: "Send 100 song messages",
            icon: "music.note.tv.fill",
            category: .messaging,
            requirement: 100,
            showsProgressCount: true
        ),

        // MARK: - Reactions achievements (8 total)
        AchievementDefinition(
            id: "first_reaction",
            name: "Expressive",
            description: "Give your first reaction",
            icon: "hand.thumbsup",
            category: .reactions,
            requirement: 1
        ),
        AchievementDefinition(
            id: "reactions_10",
            name: "Reactor",
            description: "Give 10 reactions",
            icon: "hand.thumbsup.fill",
            category: .reactions,
            requirement: 10
        ),
        AchievementDefinition(
            id: "reactions_50",
            name: "Reaction King",
            description: "Give 50 reactions",
            icon: "hands.clap.fill",
            category: .reactions,
            requirement: 50
        ),
        AchievementDefinition(
            id: "reactions_100",
            name: "Emoji Master",
            description: "Give 100 reactions",
            icon: "face.smiling.inverse",
            category: .reactions,
            requirement: 100
        ),
        AchievementDefinition(
            id: "reactions_500",
            name: "Reaction Legend",
            description: "Give 500 reactions",
            icon: "sparkles",
            category: .reactions,
            requirement: 500,
            showsProgressCount: true
        ),

        // MARK: - AI achievements (5 total)
        AchievementDefinition(
            id: "first_ai_playlist",
            name: "AI Curious",
            description: "Create your first AI playlist",
            icon: "wand.and.stars",
            category: .ai,
            requirement: 1
        ),
        AchievementDefinition(
            id: "ai_playlists_5",
            name: "AI Enthusiast",
            description: "Create 5 AI playlists",
            icon: "wand.and.stars.inverse",
            category: .ai,
            requirement: 5
        ),
        AchievementDefinition(
            id: "ai_playlists_10",
            name: "AI Power User",
            description: "Create 10 AI playlists",
            icon: "brain.head.profile",
            category: .ai,
            requirement: 10
        ),
        AchievementDefinition(
            id: "ai_playlists_25",
            name: "AI Maestro",
            description: "Create 25 AI playlists",
            icon: "brain",
            category: .ai,
            requirement: 25
        ),
        AchievementDefinition(
            id: "ai_playlists_50",
            name: "AI Overlord",
            description: "Create 50 AI playlists",
            icon: "brain.fill",
            category: .ai,
            requirement: 50,
            showsProgressCount: true
        ),

        // MARK: - Listening achievements (10 total)
        AchievementDefinition(
            id: "preview_plays_10",
            name: "Sampler",
            description: "Play 10 song previews",
            icon: "play.circle",
            category: .listening,
            requirement: 10
        ),
        AchievementDefinition(
            id: "preview_plays_50",
            name: "Music Taster",
            description: "Play 50 song previews",
            icon: "play.circle.fill",
            category: .listening,
            requirement: 50
        ),
        AchievementDefinition(
            id: "preview_plays_100",
            name: "Preview Master",
            description: "Play 100 song previews",
            icon: "play.square.fill",
            category: .listening,
            requirement: 100
        ),
        AchievementDefinition(
            id: "preview_plays_500",
            name: "Audio Addict",
            description: "Play 500 song previews",
            icon: "headphones.circle.fill",
            category: .listening,
            requirement: 500,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "artists_viewed_10",
            name: "Artist Explorer",
            description: "View 10 artist profiles",
            icon: "music.mic.circle",
            category: .listening,
            requirement: 10
        ),
        AchievementDefinition(
            id: "artists_viewed_50",
            name: "Artist Stalker",
            description: "View 50 artist profiles",
            icon: "music.mic.circle.fill",
            category: .listening,
            requirement: 50,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "albums_viewed_10",
            name: "Album Browser",
            description: "View 10 albums",
            icon: "square.stack",
            category: .listening,
            requirement: 10
        ),
        AchievementDefinition(
            id: "albums_viewed_50",
            name: "Album Collector",
            description: "View 50 albums",
            icon: "square.stack.fill",
            category: .listening,
            requirement: 50,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "search_queries_25",
            name: "Searcher",
            description: "Search 25 times",
            icon: "magnifyingglass",
            category: .listening,
            requirement: 25
        ),
        AchievementDefinition(
            id: "search_queries_100",
            name: "Music Detective",
            description: "Search 100 times",
            icon: "magnifyingglass.circle.fill",
            category: .listening,
            requirement: 100,
            showsProgressCount: true
        ),

        // MARK: - Secret achievements (16 total)
        AchievementDefinition(
            id: "secret_collector",
            name: "The Collector",
            description: "Unlock 50 other achievements",
            icon: "medal.fill",
            category: .discovery,
            requirement: 50,
            isSecret: true,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "secret_social_royalty",
            name: "Social Royalty",
            description: "Have 250 friends",
            icon: "crown.fill",
            category: .social,
            requirement: 250,
            isSecret: true,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "secret_night_owl",
            name: "Night Owl",
            description: "Play 1000 song previews",
            icon: "moon.stars.fill",
            category: .listening,
            requirement: 1000,
            isSecret: true,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "secret_reaction_machine",
            name: "Reaction Machine",
            description: "Give 1000 reactions",
            icon: "bolt.heart.fill",
            category: .reactions,
            requirement: 1000,
            isSecret: true,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "secret_eternal_vibe",
            name: "Eternal Vibe",
            description: "Maintain a 500-day vibestreak",
            icon: "infinity",
            category: .streak,
            requirement: 500,
            isSecret: true,
            showsProgressCount: true
        ),

        // Time-based secrets
        AchievementDefinition(
            id: "secret_midnight_drop",
            name: "Midnight Drop",
            description: "Share a song at exactly midnight",
            icon: "clock.fill",
            category: .sharing,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_early_bird",
            name: "Early Bird",
            description: "Use the app before 5 AM",
            icon: "sunrise.fill",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_friday_feeling",
            name: "Friday Feeling",
            description: "Share 10 songs on a single Friday",
            icon: "party.popper.fill",
            category: .sharing,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_new_years_vibe",
            name: "New Year's Vibe",
            description: "Share a song on January 1st",
            icon: "sparkles",
            category: .sharing,
            requirement: 1,
            isSecret: true
        ),

        // Social secrets
        AchievementDefinition(
            id: "secret_boomerang",
            name: "Boomerang",
            description: "Receive back a song you originally shared",
            icon: "arrow.uturn.backward.circle.fill",
            category: .social,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_same_wavelength",
            name: "Same Wavelength",
            description: "Send the same song as a friend within 24 hours",
            icon: "waveform.path",
            category: .social,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_soulmate",
            name: "Soulmate",
            description: "Create a Friend Blend with 90%+ compatibility",
            icon: "heart.text.square.fill",
            category: .social,
            requirement: 1,
            isSecret: true
        ),

        // Discovery secrets
        AchievementDefinition(
            id: "secret_genre_hopper",
            name: "Genre Hopper",
            description: "Share songs from 8 different genres in one day",
            icon: "shuffle",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_deep_cut",
            name: "Deep Cut",
            description: "Share an obscure song with under 100K plays",
            icon: "diamond.fill",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),

        // Meta secrets
        AchievementDefinition(
            id: "secret_completionist",
            name: "Completionist",
            description: "Unlock every non-secret achievement",
            icon: "checkmark.seal.fill",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),
        AchievementDefinition(
            id: "secret_secret_keeper",
            name: "Secret Keeper",
            description: "Unlock all other secret achievements",
            icon: "lock.open.fill",
            category: .discovery,
            requirement: 1,
            isSecret: true
        ),

        // Super secret achievements
        AchievementDefinition(
            id: "secret_butterfly_effect",
            name: "Butterfly Effect",
            description: "Pass along 5 songs you received from friends",
            icon: "arrow.triangle.branch",
            category: .sharing,
            requirement: 5,
            isSecret: true,
            isSuperSecret: true,
            showsProgressCount: true
        ),
        AchievementDefinition(
            id: "secret_contrarian",
            name: "The Contrarian",
            description: "Have an obscure song be your most-played of the month",
            icon: "hand.thumbsdown.fill",
            category: .listening,
            requirement: 1,
            isSecret: true,
            isSuperSecret: true
        ),
        AchievementDefinition(
            id: "secret_resurrection",
            name: "The Resurrection",
            description: "Re-add a song you removed over 6 months ago",
            icon: "arrow.counterclockwise.circle.fill",
            category: .discovery,
            requirement: 1,
            isSecret: true,
            isSuperSecret: true
        ),
    ]
}
