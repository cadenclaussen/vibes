import Foundation

enum TicketmasterError: LocalizedError {
    case apiKeyMissing
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case noResults

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "Ticketmaster API key not configured. Add it in Settings."
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Ticketmaster"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .noResults:
            return "No concerts found"
        }
    }
}

class TicketmasterService {
    static let shared = TicketmasterService()
    private let baseURL = "https://app.ticketmaster.com/discovery/v2"

    private init() {}

    func searchConcerts(artistName: String) async throws -> [Concert] {
        guard let apiKey = KeychainManager.shared.getTicketmasterApiKey() else {
            throw TicketmasterError.apiKeyMissing
        }

        guard var components = URLComponents(string: "\(baseURL)/events") else {
            throw TicketmasterError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "keyword", value: artistName),
            URLQueryItem(name: "classificationName", value: "Music"),
            URLQueryItem(name: "countryCode", value: "US"),
            URLQueryItem(name: "size", value: "50"),
            URLQueryItem(name: "sort", value: "date,asc")
        ]

        guard let url = components.url else {
            throw TicketmasterError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TicketmasterError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                throw TicketmasterError.invalidResponse
            }

            let decoded = try JSONDecoder().decode(TicketmasterResponse.self, from: data)

            guard let events = decoded._embedded?.events else {
                return []
            }

            // Filter to only events where the searched artist is actually performing
            return events.compactMap { event -> Concert? in
                let concert = event.toConcert(searchedArtist: artistName)
                let searchedLower = artistName.lowercased()
                let concertArtistLower = concert.artistName.lowercased()
                let eventNameLower = event.name.lowercased()

                if concertArtistLower.contains(searchedLower) ||
                   searchedLower.contains(concertArtistLower) ||
                   eventNameLower.contains(searchedLower) {
                    return concert
                }
                return nil
            }
        } catch let error as TicketmasterError {
            throw error
        } catch {
            throw TicketmasterError.networkError(error)
        }
    }

    func searchConcertsForArtists(
        artists: [RankedArtist],
        homeCity: String?
    ) async throws -> [RankedConcert] {
        var allConcerts: [RankedConcert] = []
        var seenIds = Set<String>()

        for rankedArtist in artists {
            do {
                let concerts = try await searchConcerts(artistName: rankedArtist.artist.name)

                for concert in concerts {
                    if !seenIds.contains(concert.id) {
                        seenIds.insert(concert.id)
                        let isHome = isHomeCity(concertCity: concert.city, homeCity: homeCity)
                        let rankedConcert = RankedConcert(
                            concert: concert,
                            artistRank: rankedArtist.rank,
                            isHomeCity: isHome
                        )
                        allConcerts.append(rankedConcert)
                    }
                }
            } catch {
                // Skip artists that fail, continue with others
                continue
            }
        }

        // Sort by artist rank (ascending), then by date (ascending)
        allConcerts.sort { lhs, rhs in
            if lhs.artistRank != rhs.artistRank {
                return lhs.artistRank < rhs.artistRank
            }
            return lhs.concert.date < rhs.concert.date
        }

        return allConcerts
    }

    private func isHomeCity(concertCity: String, homeCity: String?) -> Bool {
        guard let home = homeCity, !home.isEmpty else {
            return false
        }

        let normalizedConcert = concertCity.lowercased()
        let normalizedHome = home.lowercased()

        return normalizedConcert.contains(normalizedHome) ||
               normalizedHome.contains(normalizedConcert)
    }
}

// MARK: - Ticketmaster API Response Models

private struct TicketmasterResponse: Decodable {
    let _embedded: TicketmasterEmbedded?
}

private struct TicketmasterEmbedded: Decodable {
    let events: [TicketmasterEvent]
}

private struct TicketmasterEvent: Decodable {
    let id: String
    let name: String
    let url: String
    let dates: TicketmasterDates?
    let _embedded: TicketmasterEventEmbedded?
    let priceRanges: [TicketmasterPriceRange]?
    let images: [TicketmasterImage]?

    func toConcert(searchedArtist: String) -> Concert {
        // Get venue - use placeholder if missing
        let venueName = _embedded?.venues?.first?.name ?? "TBA"
        let venueCity = _embedded?.venues?.first?.city?.name ?? "TBA"
        let venueAddress = _embedded?.venues?.first?.address?.line1 ?? ""

        // Parse date - use future date if missing
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date: Date
        if let localDate = dates?.start?.localDate,
           let parsedDate = dateFormatter.date(from: localDate) {
            date = parsedDate
        } else {
            // Use a far future date if no date available
            date = Date().addingTimeInterval(365 * 24 * 60 * 60)
        }

        // Get artist name from attractions or event name or searched artist
        let artistName = _embedded?.attractions?.first?.name ?? searchedArtist
        let artistImage = _embedded?.attractions?.first?.images?.first?.url ?? images?.first?.url

        // Get additional artists (excluding the primary)
        let additionalArtists = _embedded?.attractions?.dropFirst().map { $0.name } ?? []

        // Format price range
        var priceRange: String?
        if let prices = priceRanges?.first {
            if let min = prices.min, let max = prices.max {
                let currency = prices.currency ?? "USD"
                priceRange = "\(currency) \(Int(min)) - \(Int(max))"
            }
        }

        return Concert(
            id: id,
            artistName: artistName,
            artistImageURL: artistImage,
            venueName: venueName,
            venueAddress: venueAddress,
            city: venueCity,
            date: date,
            priceRange: priceRange,
            ticketURL: url,
            additionalArtists: additionalArtists
        )
    }
}

private struct TicketmasterDates: Decodable {
    let start: TicketmasterStartDate?
}

private struct TicketmasterStartDate: Decodable {
    let localDate: String?
    let localTime: String?
}

private struct TicketmasterEventEmbedded: Decodable {
    let venues: [TicketmasterVenue]?
    let attractions: [TicketmasterAttraction]?
}

private struct TicketmasterVenue: Decodable {
    let name: String?
    let city: TicketmasterCity?
    let address: TicketmasterAddress?
}

private struct TicketmasterCity: Decodable {
    let name: String?
}

private struct TicketmasterAddress: Decodable {
    let line1: String?
}

private struct TicketmasterAttraction: Decodable {
    let name: String
    let images: [TicketmasterImage]?
}

private struct TicketmasterImage: Decodable {
    let url: String
}

private struct TicketmasterPriceRange: Decodable {
    let min: Double?
    let max: Double?
    let currency: String?
}
