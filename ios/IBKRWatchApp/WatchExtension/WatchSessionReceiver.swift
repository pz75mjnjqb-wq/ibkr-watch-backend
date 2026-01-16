import Foundation
import WatchConnectivity

@MainActor
final class WatchSessionReceiver: NSObject, ObservableObject, WCSessionDelegate {
    @Published var payload = WatchPayload(backendOk: false, ibConnected: false, prices: [], updatedAt: nil)
    @Published var isStale = true

    private let formatter = ISO8601DateFormatter()

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            let backendOk = applicationContext["backendOk"] as? Bool ?? false
            let ibConnected = applicationContext["ibConnected"] as? Bool ?? false
            let updatedAtString = applicationContext["updatedAt"] as? String
            let updatedAt = updatedAtString.flatMap { formatter.date(from: $0) }

            let priceList = (applicationContext["prices"] as? [[String: Any]] ?? []).compactMap { entry in
                guard let symbol = entry["symbol"] as? String else { return nil }
                let last = entry["last"] as? Double
                return WatchPrice(symbol: symbol, last: last)
            }

            payload = WatchPayload(
                backendOk: backendOk,
                ibConnected: ibConnected,
                prices: priceList,
                updatedAt: updatedAt
            )

            isStale = false
        }
    }
}
