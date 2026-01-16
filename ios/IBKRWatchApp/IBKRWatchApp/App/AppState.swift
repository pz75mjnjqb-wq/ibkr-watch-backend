import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var baseURLString: String
    @Published var apiToken: String
    @Published var pollInterval: TimeInterval

    private let defaults = UserDefaults.standard
    private let baseURLKey = "BackendBaseURL"
    private let pollKey = "PollInterval"

    init() {
        let storedBaseURL = defaults.string(forKey: baseURLKey) ?? "http://127.0.0.1:8000"
        baseURLString = storedBaseURL
        apiToken = KeychainService.shared.loadToken() ?? ""
        pollInterval = defaults.double(forKey: pollKey)
        if pollInterval <= 0 {
            pollInterval = 30
        }
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
}
