import SwiftUI

struct LyricsView: View {
    let lyrics: SyncedLyrics?
    let currentLineIndex: Int?
    let isLoading: Bool
    let error: Error?
    let hasSyncedLyrics: Bool

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if error != nil {
                notAvailableView
            } else if let lyrics = lyrics, !lyrics.isEmpty {
                lyricsScrollView(lyrics)
            } else {
                notAvailableView
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(.white)
            Text("Loading lyrics...")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notAvailableView: some View {
        VStack(spacing: 8) {
            Image(systemName: "text.quote")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.3))
            Text("Lyrics not available")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func lyricsScrollView(_ lyrics: SyncedLyrics) -> some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    ForEach(Array(lyrics.lines.enumerated()), id: \.element.id) { index, line in
                        LyricLineView(
                            text: line.text,
                            isCurrentLine: index == currentLineIndex,
                            isPastLine: hasSyncedLyrics && currentLineIndex != nil && index < (currentLineIndex ?? 0)
                        )
                        .id(index)
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20)
            }
            .onChange(of: currentLineIndex) { _, newIndex in
                guard let index = newIndex, hasSyncedLyrics else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(index, anchor: .center)
                }
            }
        }
    }
}

struct LyricLineView: View {
    let text: String
    let isCurrentLine: Bool
    let isPastLine: Bool

    var body: some View {
        Text(text)
            .font(isCurrentLine ? .title2 : .title3)
            .fontWeight(isCurrentLine ? .bold : .medium)
            .foregroundStyle(foregroundColor)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isCurrentLine ? Color.white.opacity(0.15) : Color.clear)
            )
            .scaleEffect(isCurrentLine ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: isCurrentLine)
    }

    private var foregroundColor: Color {
        if isCurrentLine {
            return .white
        } else if isPastLine {
            return .white.opacity(0.35)
        } else {
            return .white.opacity(0.55)
        }
    }
}

#Preview("Loading") {
    ZStack {
        Color.black.ignoresSafeArea()
        LyricsView(
            lyrics: nil,
            currentLineIndex: nil,
            isLoading: true,
            error: nil,
            hasSyncedLyrics: false
        )
    }
}

#Preview("With Lyrics") {
    ZStack {
        Color.black.ignoresSafeArea()
        LyricsView(
            lyrics: SyncedLyrics(lines: [
                LyricLine(text: "First line of the song", startTime: 5),
                LyricLine(text: "Second line here", startTime: 10),
                LyricLine(text: "This is the current line playing right now", startTime: 15),
                LyricLine(text: "Next line coming up", startTime: 20),
                LyricLine(text: "And another one after that", startTime: 25),
            ]),
            currentLineIndex: 2,
            isLoading: false,
            error: nil,
            hasSyncedLyrics: true
        )
    }
}
