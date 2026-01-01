import Foundation

enum APIValidationError: LocalizedError {
    case invalidKey
    case networkError(Error)
    case serverError(Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "Invalid API key. Please check and try again."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .invalidResponse:
            return "Unexpected response. Please try again."
        }
    }
}

class APIValidationService {
    static let shared = APIValidationService()

    private init() {}

    func validateGeminiKey(_ apiKey: String) async throws {
        let urlString = "\(Constants.Gemini.baseURL)/models?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw APIValidationError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIValidationError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                return // valid key
            case 400, 401, 403:
                throw APIValidationError.invalidKey
            case 500...599:
                throw APIValidationError.serverError(httpResponse.statusCode)
            default:
                throw APIValidationError.invalidResponse
            }
        } catch let error as APIValidationError {
            throw error
        } catch {
            throw APIValidationError.networkError(error)
        }
    }

    func validateTicketmasterKey(_ apiKey: String) async throws {
        let urlString = "\(Constants.Ticketmaster.baseURL)/classifications?size=1&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw APIValidationError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIValidationError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                return // valid key
            case 400, 401, 403:
                throw APIValidationError.invalidKey
            case 500...599:
                throw APIValidationError.serverError(httpResponse.statusCode)
            default:
                throw APIValidationError.invalidResponse
            }
        } catch let error as APIValidationError {
            throw error
        } catch {
            throw APIValidationError.networkError(error)
        }
    }
}
