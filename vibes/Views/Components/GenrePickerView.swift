//
//  GenrePickerView.swift
//  vibes
//
//  Created by Claude Code on 12/20/25.
//

import SwiftUI

struct MusicGenre: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color

    static let all: [MusicGenre] = [
        // Popular
        MusicGenre(name: "Pop", icon: "star.fill", color: .pink),
        MusicGenre(name: "Hip-Hop", icon: "mic.fill", color: .purple),
        MusicGenre(name: "R&B", icon: "heart.fill", color: .red),
        MusicGenre(name: "Rock", icon: "guitars.fill", color: .orange),
        MusicGenre(name: "Electronic", icon: "waveform", color: .cyan),
        MusicGenre(name: "Indie", icon: "leaf.fill", color: .green),

        // Dance & Electronic
        MusicGenre(name: "House", icon: "speaker.wave.3.fill", color: .blue),
        MusicGenre(name: "Techno", icon: "bolt.fill", color: .indigo),
        MusicGenre(name: "EDM", icon: "party.popper.fill", color: .yellow),
        MusicGenre(name: "Dubstep", icon: "waveform.path", color: .purple),

        // Alternative
        MusicGenre(name: "Alternative", icon: "sparkles", color: .teal),
        MusicGenre(name: "Punk", icon: "flame.fill", color: .red),
        MusicGenre(name: "Metal", icon: "bolt.circle.fill", color: .gray),
        MusicGenre(name: "Grunge", icon: "cloud.fill", color: .brown),

        // Soul & Jazz
        MusicGenre(name: "Soul", icon: "heart.circle.fill", color: .orange),
        MusicGenre(name: "Jazz", icon: "music.quarternote.3", color: .brown),
        MusicGenre(name: "Blues", icon: "drop.fill", color: .blue),
        MusicGenre(name: "Funk", icon: "figure.dance", color: .purple),

        // Latin & World
        MusicGenre(name: "Latin", icon: "sun.max.fill", color: .orange),
        MusicGenre(name: "Reggaeton", icon: "flame.fill", color: .yellow),
        MusicGenre(name: "Afrobeats", icon: "globe.americas.fill", color: .green),
        MusicGenre(name: "K-Pop", icon: "star.circle.fill", color: .pink),

        // Country & Folk
        MusicGenre(name: "Country", icon: "leaf.fill", color: .brown),
        MusicGenre(name: "Folk", icon: "guitars", color: .green),
        MusicGenre(name: "Americana", icon: "flag.fill", color: .red),

        // Classical & Instrumental
        MusicGenre(name: "Classical", icon: "music.note.list", color: .indigo),
        MusicGenre(name: "Acoustic", icon: "guitars", color: .orange),
        MusicGenre(name: "Lo-Fi", icon: "headphones", color: .purple),
        MusicGenre(name: "Ambient", icon: "cloud.sun.fill", color: .cyan),

        // Other
        MusicGenre(name: "Trap", icon: "speaker.wave.2.fill", color: .red),
        MusicGenre(name: "Drill", icon: "bolt.fill", color: .gray),
        MusicGenre(name: "Gospel", icon: "hands.sparkles.fill", color: .yellow),
        MusicGenre(name: "Reggae", icon: "sun.max.fill", color: .green),
    ]
}

struct GenrePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedGenres: [String]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(MusicGenre.all) { genre in
                        GenreChip(
                            genre: genre,
                            isSelected: selectedGenres.contains(genre.name),
                            onTap: {
                                toggleGenre(genre.name)
                            }
                        )
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedGenres)
                .padding()
            }
            .navigationTitle("Select Genres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggleGenre(_ name: String) {
        HapticService.selectionChanged()
        if selectedGenres.contains(name) {
            selectedGenres.removeAll { $0 == name }
        } else {
            selectedGenres.append(name)
        }
    }
}

struct GenreChip: View {
    let genre: MusicGenre
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? genre.color : Color(.tertiarySystemFill))
                        .frame(width: 50, height: 50)

                    Image(systemName: genre.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .secondary)
                }

                Text(genre.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? genre.color.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? genre.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GenrePickerView(selectedGenres: .constant(["Pop", "Hip-Hop", "R&B"]))
}
