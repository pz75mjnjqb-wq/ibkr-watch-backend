import Foundation
import Combine
import WatchConnectivity

@MainActor
final class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()

    @Published var lastSentPayload: [String: Any]?
    private var lastPayloadHash: Int?
    private var lastSentAt: Date?
    private let formatter = ISO8601DateFormatter()

    func start() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func update(health: HealthResponse?, prices: [PriceSnapshot], updatedAt: Date) {
        guard WCSession.isSupported() else { return }
        let payload: [String: Any] = [
            "backendOk": health?.status == "ok",
            "ibConnected": health?.ibConnected ?? false,
            "prices": prices.map { ["symbol": $0.symbol, "last": $0.price as Any] },
            "updatedAt": formatter.string(from: updatedAt)
        ]

        let payloadHash = payload.description.hashValue
        let now = Date()
        if let lastHash = lastPayloadHash, lastHash == payloadHash,
           let lastSentAt, now.timeIntervalSince(lastSentAt) < 30 {
            return
        }

        do {
            try WCSession.default.updateApplicationContext(payload)
            lastPayloadHash = payloadHash
            lastSentPayload = payload
            lastSentAt = now
        } catch {
            // Best-effort only; no retry required.
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
