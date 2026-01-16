import Foundation

@MainActor
final class PricesViewModel: ObservableObject {
    @Published var rows: [PriceSnapshot] = []
    @Published var lastUpdated: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let symbols = ["AAPL", "MSFT", "SPY"]
    private let appState: AppState
    private var timer: Timer?

    init(appState: AppState) {
        self.appState = appState
        rows = symbols.map { PriceSnapshot(symbol: $0, price: nil) }
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        timer = Timer.scheduledTimer(withTimeInterval: appState.pollInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.refresh()
            }
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
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
            var updatedRows: [PriceSnapshot] = []
            for symbol in symbols {
                let response = try await client.fetchPrice(symbol: symbol)
                updatedRows.append(PriceSnapshot(symbol: response.symbol, price: response.price))
            }
            rows = updatedRows
            lastUpdated = Date()
            appState.updatePrices(updatedRows)
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
