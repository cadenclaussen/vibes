import SwiftUI

struct GenreChipsView: View {
    let genres: [String]
    let isLoading: Bool

    var body: some View {
        if isLoading {
            loadingView
        } else if !genres.isEmpty {
            genreChips
        }
    }

    private var loadingView: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 70, height: 28)
                    .shimmer()
            }
        }
    }

    private var genreChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(genres, id: \.self) { genre in
                    ProfileGenreChip(genre: genre)
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct ProfileGenreChip: View {
    let genre: String

    var body: some View {
        Text(genre.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor)
            .clipShape(Capsule())
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.3),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + phase * geometry.size.width * 2)
                    .animation(
                        .linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: phase
                    )
                }
                .mask(content)
            }
            .onAppear {
                phase = 1
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

#Preview("Loading") {
    GenreChipsView(genres: [], isLoading: true)
}

#Preview("Loaded") {
    GenreChipsView(
        genres: ["hip hop", "r&b", "pop", "trap", "rap"],
        isLoading: false
    )
}
