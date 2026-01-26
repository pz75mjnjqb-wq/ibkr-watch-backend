import SwiftUI

struct WatchSimulationView: View {
    @ObservedObject var watchManager = WatchSessionManager.shared
    
    var body: some View {
        List {
            if let payload = watchManager.lastSentPayload {
                Section("Status") {
                    LabeledContent("Backend OK", value: (payload["backendOk"] as? Bool ?? false) ? "Yes" : "No")
                    LabeledContent("IB Connected", value: (payload["ibConnected"] as? Bool ?? false) ? "Yes" : "No")
                    if let updated = payload["updatedAt"] as? String {
                        LabeledContent("Updated", value: updated)
                    }
                }
                
                Section("Prices Payload") {
                    let prices = payload["prices"] as? [[String: Any]] ?? []
                    if prices.isEmpty {
                        Text("No prices in payload")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(prices.indices, id: \.self) { index in
                            let p = prices[index]
                            HStack {
                                Text(p["symbol"] as? String ?? "?")
                                Spacer()
                                if let price = p["last"] as? Double {
                                    Text(String(format: "%.2f", price))
                                        .monospacedDigit()
                                } else {
                                    Text("—")
                                }
                            }
                        }
                    }
                }
            } else {
                Text("No data sent to Watch yet.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Watch Sim")
    }
}