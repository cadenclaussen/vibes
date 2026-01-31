import Foundation

struct SyncedLyrics {
    let lines: [LyricLine]

    var isEmpty: Bool {
        lines.isEmpty
    }

    func currentLineIndex(at position: TimeInterval) -> Int? {
        // Find the line where position >= startTime and position < next line's startTime
        for (index, line) in lines.enumerated() {
            let nextStartTime = index + 1 < lines.count ? lines[index + 1].startTime : .infinity
            if position >= line.startTime && position < nextStartTime {
                return index
            }
        }
        return nil
    }
}

struct LyricLine: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let startTime: TimeInterval

    static func == (lhs: LyricLine, rhs: LyricLine) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - LRC Parser

extension SyncedLyrics {
    /// Parse LRC format lyrics
    /// Format: [mm:ss.xx] Lyric text
    static func parse(lrc: String) -> SyncedLyrics {
        var lines: [LyricLine] = []

        let pattern = #"\[(\d{2}):(\d{2})\.(\d{2,3})\]\s*(.+)"#
        let regex = try? NSRegularExpression(pattern: pattern)

        for line in lrc.components(separatedBy: .newlines) {
            guard let match = regex?.firstMatch(
                in: line,
                range: NSRange(line.startIndex..., in: line)
            ) else { continue }

            guard let minutesRange = Range(match.range(at: 1), in: line),
                  let secondsRange = Range(match.range(at: 2), in: line),
                  let millisecondsRange = Range(match.range(at: 3), in: line),
                  let textRange = Range(match.range(at: 4), in: line) else { continue }

            guard let minutes = Double(line[minutesRange]),
                  let seconds = Double(line[secondsRange]),
                  let milliseconds = Double(line[millisecondsRange]) else { continue }

            let text = String(line[textRange]).trimmingCharacters(in: .whitespaces)
            if text.isEmpty { continue }

            // Convert to seconds
            let msMultiplier = line[millisecondsRange].count == 2 ? 10.0 : 1.0
            let startTime = minutes * 60 + seconds + (milliseconds * msMultiplier / 1000)

            lines.append(LyricLine(text: text, startTime: startTime))
        }

        // Sort by start time
        lines.sort { $0.startTime < $1.startTime }

        return SyncedLyrics(lines: lines)
    }
}
