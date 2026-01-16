import Foundation

struct WatchPrice: Identifiable {
    let id = UUID()
    let symbol: String
    let last: Double?
}

struct WatchPayload {
    let backendOk: Bool
    let ibConnected: Bool
    let prices: [WatchPrice]
    let updatedAt: Date?
}
