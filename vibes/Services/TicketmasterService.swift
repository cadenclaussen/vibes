//
//  TicketmasterService.swift
//  vibes
//
//  Concert discovery using Ticketmaster API.
//

import Foundation
import Combine

// MARK: - Concert Models

struct Concert: Identifiable, Codable {
    let id: String
    let name: String
    let artistName: String
    let date: Date
    let venueName: String
    let city: String
    let ticketUrl: String?
    let imageUrl: String?
    let priceRange: String?
}

// MARK: - Ticketmaster API Response Models

private struct TMSearchResponse: Codable {
    let _embedded: TMEmbedded?
}

private struct TMEmbedded: Codable {
    let events: [TMEvent]?
}

private struct TMEvent: Codable {
    let id: String
    let name: String
    let dates: TMDates
    let _embedded: TMEventEmbedded?
    let images: [TMImage]?
    let url: String?
    let priceRanges: [TMPriceRange]?
}

private struct TMDates: Codable {
    let start: TMStart
}

private struct TMStart: Codable {
    let localDate: String?
    let localTime: String?
}

private struct TMEventEmbedded: Codable {
    let venues: [TMVenue]?
    let attractions: [TMAttraction]?
}

private struct TMVenue: Codable {
    let name: String?
    let city: TMCity?
}

private struct TMCity: Codable {
    let name: String?
}

private struct TMAttraction: Codable {
    let name: String?
}

private struct TMImage: Codable {
    let url: String?
    let ratio: String?
    let width: Int?
    let height: Int?
}

private struct TMPriceRange: Codable {
    let min: Double?
    let max: Double?
    let currency: String?
}

// MARK: - TicketmasterService

class TicketmasterService: ObservableObject {
    static let shared = TicketmasterService()

    @Published var userCity: String = ""

    // Embedded API key - user just needs to set their city
    private let apiKey = "YOUR_TICKETMASTER_API_KEY"
    private let baseURL = "https://app.ticketmaster.com/discovery/v2/events.json"

    var isConfigured: Bool {
        return apiKey != "YOUR_TICKETMASTER_API_KEY" && !apiKey.isEmpty
    }

    private init() {
        loadUserCity()
    }

    // MARK: - City Configuration

    func setUserCity(_ city: String) {
        userCity = city
        UserDefaults.standard.set(city, forKey: "ticketmasterUserCity")
    }

    private func loadUserCity() {
        userCity = UserDefaults.standard.string(forKey: "ticketmasterUserCity") ?? ""
    }

    // MARK: - Search Concerts

    func searchConcerts(artistNames: [String], daysAhead: Int = 60) async throws -> [Concert] {
        guard isConfigured else { return [] }
        guard !userCity.isEmpty else { return [] }

        var allConcerts: [Concert] = []
        var seenEventIds = Set<String>()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let now = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: daysAhead, to: now) ?? now

        let startDateStr = dateFormatter.string(from: now)
        let endDateStr = dateFormatter.string(from: endDate)

        // Search for each artist (limit to avoid rate limits)
        for artistName in artistNames.prefix(10) {
            do {
                let concerts = try await searchArtistConcerts(
                    artistName: artistName,
                    city: userCity,
                    startDate: startDateStr,
                    endDate: endDateStr
                )

                for concert in concerts {
                    if !seenEventIds.contains(concert.id) {
                        seenEventIds.insert(concert.id)
                        allConcerts.append(concert)
                    }
                }

                // Small delay to avoid rate limiting
                try await Task.sleep(nanoseconds: 100_000_000)
            } catch {
                continue
            }
        }

        allConcerts.sort { $0.date < $1.date }
        return Array(allConcerts.prefix(20))
    }

    private func searchArtistConcerts(
        artistName: String,
        city: String,
        startDate: String,
        endDate: String
    ) async throws -> [Concert] {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "keyword", value: artistName),
            URLQueryItem(name: "city", value: city),
            URLQueryItem(name: "classificationName", value: "music"),
            URLQueryItem(name: "startDateTime", value: startDate),
            URLQueryItem(name: "endDateTime", value: endDate),
            URLQueryItem(name: "size", value: "20"),
            URLQueryItem(name: "sort", value: "date,asc")
        ]

        guard let url = components.url else { return [] }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return []
        }

        let searchResponse = try JSONDecoder().decode(TMSearchResponse.self, from: data)
        guard let events = searchResponse._embedded?.events else { return [] }

        return events.compactMap { event -> Concert? in
            guard let dateStr = event.dates.start.localDate else { return nil }

            let eventDateFormatter = DateFormatter()
            eventDateFormatter.dateFormat = "yyyy-MM-dd"

            var eventDate = eventDateFormatter.date(from: dateStr) ?? Date()

            if let timeStr = event.dates.start.localTime {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"
                if let time = timeFormatter.date(from: timeStr) {
                    let calendar = Calendar.current
                    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
                    eventDate = calendar.date(
                        bySettingHour: timeComponents.hour ?? 0,
                        minute: timeComponents.minute ?? 0,
                        second: timeComponents.second ?? 0,
                        of: eventDate
                    ) ?? eventDate
                }
            }

            let venueName = event._embedded?.venues?.first?.name ?? "Unknown Venue"
            let eventCity = event._embedded?.venues?.first?.city?.name ?? city
            let attractionName = event._embedded?.attractions?.first?.name ?? artistName

            let bestImage = event.images?
                .filter { $0.ratio == "16_9" && ($0.width ?? 0) >= 200 }
                .first?.url ?? event.images?.first?.url

            var priceRange: String? = nil
            if let range = event.priceRanges?.first,
               let minPrice = range.min,
               let maxPrice = range.max {
                if minPrice == maxPrice {
                    priceRange = "$\(Int(minPrice))"
                } else {
                    priceRange = "$\(Int(minPrice)) - $\(Int(maxPrice))"
                }
            }

            return Concert(
                id: event.id,
                name: event.name,
                artistName: attractionName,
                date: eventDate,
                venueName: venueName,
                city: eventCity,
                ticketUrl: event.url,
                imageUrl: bestImage,
                priceRange: priceRange
            )
        }
    }

    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "ticketmasterUserCity")
        userCity = ""
    }
}
