import SwiftUI

struct PricesView: View {
    @StateObject private var viewModel: PricesViewModel

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: PricesViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(viewModel.rows) { row in
                        HStack {
                            Text(row.symbol)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(row.price.map { String(format: "%.2f", $0) } ?? "—")
                                .monospacedDigit()
                        }
                    }
                } header: {
                    Text("Prices")
                }

                Section {
                    if let lastUpdated = viewModel.lastUpdated {
                        Text("Last updated: \(lastUpdated.formatted(date: .abbreviated, time: .standard))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Prices")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh") {
                        Task { await viewModel.refresh() }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .onAppear {
                viewModel.startAutoRefresh()
            }
            .onDisappear {
                viewModel.stopAutoRefresh()
            }
            .task {
                await viewModel.refresh()
            }
        }
    }
}
