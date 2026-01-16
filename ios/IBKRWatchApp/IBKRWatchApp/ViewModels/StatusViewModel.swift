import Foundation

@MainActor
final class StatusViewModel: ObservableObject {
    @Published var health: HealthResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func refresh() async {
        guard let baseURL = appState.baseURL else {
            errorMessage = APIError.invalidURL.localizedDescription
            return
        }

        isLoading = true
        errorMessage = nil
        let client = APIClient(baseURL: baseURL, tokenProvider: { self.appState.apiToken })

        do {
            let response = try await client.fetchHealth()
            health = response
            appState.updateHealth(response)
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
