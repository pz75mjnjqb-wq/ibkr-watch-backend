import Foundation

struct HealthResponse: Codable {
    let status: String
    let ibConnected: Bool
    let ibLastConnectAttempt: String?
    let ibLastError: String?

    enum CodingKeys: String, CodingKey {
        case status
        case ibConnected = "ib_connected"
        case ibLastConnectAttempt = "ib_last_connect_attempt"
        case ibLastError = "ib_last_error"
    }
}

struct PriceResponse: Codable {
    let symbol: String
    let price: Double?
}

struct PriceSnapshot: Identifiable {
    let id = UUID()
    let symbol: String
    let price: Double?
}
