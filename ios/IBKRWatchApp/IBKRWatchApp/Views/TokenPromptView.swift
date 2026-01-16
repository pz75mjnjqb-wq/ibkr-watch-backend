import SwiftUI

struct TokenPromptView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var token: String = ""
    @State private var baseURL: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Backend") {
                    TextField("Base URL", text: $baseURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }

                Section("API Token") {
                    SecureField("Token", text: $token)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Setup")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
            .onAppear {
                token = appState.apiToken
                baseURL = appState.baseURLString
            }
        }
    }

    private func save() {
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedToken.isEmpty else {
            errorMessage = "Token required"
            return
        }

        guard URL(string: trimmedBaseURL) != nil else {
            errorMessage = "Invalid base URL"
            return
        }

        appState.apiToken = trimmedToken
        appState.baseURLString = trimmedBaseURL
        appState.saveBaseURL()
        _ = appState.saveToken()

        dismiss()
    }
}
