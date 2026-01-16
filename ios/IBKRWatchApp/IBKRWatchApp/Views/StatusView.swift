import SwiftUI

struct StatusView: View {
    @StateObject private var viewModel: StatusViewModel

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: StatusViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Backend") {
                    HStack {
                        Text("Reachable")
                        Spacer()
                        if viewModel.health != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    if let status = viewModel.health?.status {
                        LabeledContent("Status", value: status)
                    }
                }

                Section("IB Gateway") {
                    if let ibConnected = viewModel.health?.ibConnected {
                        LabeledContent("Connected", value: ibConnected ? "true" : "false")
                    } else {
                        Text("No data")
                            .foregroundStyle(.secondary)
                    }

                    if let attempt = viewModel.health?.ibLastConnectAttempt {
                        LabeledContent("Last Attempt", value: attempt)
                    }

                    if let error = viewModel.health?.ibLastError, !error.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Last Error")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(error)
                                .foregroundStyle(.red)
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Status")
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
            .task {
                await viewModel.refresh()
            }
        }
    }
}
