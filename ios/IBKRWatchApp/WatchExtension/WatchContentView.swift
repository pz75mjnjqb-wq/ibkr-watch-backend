import SwiftUI

struct WatchContentView: View {
    @StateObject private var receiver = WatchSessionReceiver()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(receiver.payload.backendOk ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(receiver.payload.backendOk ? "Backend OK" : "Backend Down")
                    .font(.caption)
            }

            HStack {
                Circle()
                    .fill(receiver.payload.ibConnected ? Color.green : Color.orange)
                    .frame(width: 10, height: 10)
                Text(receiver.payload.ibConnected ? "IB Connected" : "IB Disconnected")
                    .font(.caption)
            }

            Divider()

            ForEach(receiver.payload.prices.prefix(3)) { price in
                HStack {
                    Text(price.symbol)
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(price.last.map { String(format: "%.2f", $0) } ?? "—")
                        .font(.caption)
                        .monospacedDigit()
                }
            }

            if let updatedAt = receiver.payload.updatedAt {
                Text("Updated: \(updatedAt.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("No data yet")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if receiver.isStale {
                Text("Stale data")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(8)
    }
}
