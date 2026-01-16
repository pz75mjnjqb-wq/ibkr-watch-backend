import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var baseURLString: String
    @Published var apiToken: String
    @Published var pollInterval: TimeInterval
    @Published var lastHealth: HealthResponse?
    @Published var lastPrices: [PriceSnapshot] = []
    @Published var lastUpdated: Date?

    private let defaults = UserDefaults.standard
    private let baseURLKey = "BackendBaseURL"
    private let pollKey = "PollInterval"
    private let watchSession = WatchSessionManager.shared

    init() {
        let storedBaseURL = defaults.string(forKey: baseURLKey) ?? "http://127.0.0.1:8000"
        baseURLString = storedBaseURL
        apiToken = KeychainService.shared.loadToken() ?? ""
        pollInterval = defaults.double(forKey: pollKey)
        if pollInterval <= 0 {
            pollInterval = 30
        }
        watchSession.start()
    }

    var baseURL: URL? {
        URL(string: baseURLString)
    }

    func saveBaseURL() {
        defaults.set(baseURLString, forKey: baseURLKey)
    }

    func saveToken() -> Bool {
        KeychainService.shared.saveToken(apiToken)
    }

    func clearToken() {
        apiToken = ""
        _ = KeychainService.shared.deleteToken()
    }

    func savePollInterval() {
        defaults.set(pollInterval, forKey: pollKey)
    }

    func updateHealth(_ health: HealthResponse) {
        lastHealth = health
        pushWatchUpdate()
    }

    func updatePrices(_ prices: [PriceSnapshot]) {
        lastPrices = prices
        lastUpdated = Date()
        pushWatchUpdate()
    }

    private func pushWatchUpdate() {
        let timestamp = lastUpdated ?? Date()
        watchSession.update(health: lastHealth, prices: lastPrices, updatedAt: timestamp)
    }
}
