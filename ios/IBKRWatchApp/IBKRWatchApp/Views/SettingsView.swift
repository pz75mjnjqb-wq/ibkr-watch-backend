import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @State private var tokenDraft: String = ""
    @State private var baseURLDraft: String = ""
    @State private var pollDraft: String = ""
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Backend") {
                    TextField("Base URL", text: $baseURLDraft)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }

                Section("API Token") {
                    SecureField("Token", text: $tokenDraft)
                    if let statusMessage {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Polling") {
                    TextField("Interval (seconds)", text: $pollDraft)
                        .keyboardType(.numberPad)
                }

                Button("Save") {
                    saveSettings()
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                tokenDraft = appState.apiToken
                baseURLDraft = appState.baseURLString
                pollDraft = String(Int(appState.pollInterval))
            }
        }
    }

    private func saveSettings() {
        appState.baseURLString = baseURLDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        appState.saveBaseURL()

        appState.apiToken = tokenDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        _ = appState.saveToken()

        if let value = Double(pollDraft), value >= 5 {
            appState.pollInterval = value
            appState.savePollInterval()
        }

        statusMessage = "Saved"
    }
}
