import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case networkError(String)
    case httpError(Int)
    case unauthorized
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let message):
            return message
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .unauthorized:
            return "Unauthorized (invalid API token)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

struct APIClient {
    let baseURL: URL
    let tokenProvider: () -> String?

    func fetchHealth() async throws -> HealthResponse {
        let url = baseURL.appendingPathComponent("health")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await perform(request, requiresAuth: false)
    }

    func fetchPrice(symbol: String) async throws -> PriceResponse {
        let url = baseURL.appendingPathComponent("price/\(symbol)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await perform(request, requiresAuth: true)
    }

    private func perform<T: Decodable>(_ request: URLRequest, requiresAuth: Bool) async throws -> T {
        var request = request
        if requiresAuth {
            guard let token = tokenProvider(), !token.isEmpty else {
                throw APIError.unauthorized
            }
            request.setValue(token, forHTTPHeaderField: "X-API-Token")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError("Invalid response")
            }

            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(httpResponse.statusCode)
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }
}
