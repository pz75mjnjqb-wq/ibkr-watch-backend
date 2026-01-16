import Foundation

struct PriceRow: Identifiable {
    let id = UUID()
    let symbol: String
    let price: Double?
}

@MainActor
final class PricesViewModel: ObservableObject {
    @Published var rows: [PriceRow] = []
    @Published var lastUpdated: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let symbols = ["AAPL", "MSFT", "SPY"]
    private let appState: AppState
    private var timer: Timer?

    init(appState: AppState) {
        self.appState = appState
        rows = symbols.map { PriceRow(symbol: $0, price: nil) }
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
            var updatedRows: [PriceRow] = []
            for symbol in symbols {
                let response = try await client.fetchPrice(symbol: symbol)
                updatedRows.append(PriceRow(symbol: response.symbol, price: response.price))
            }
            rows = updatedRows
            lastUpdated = Date()
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
