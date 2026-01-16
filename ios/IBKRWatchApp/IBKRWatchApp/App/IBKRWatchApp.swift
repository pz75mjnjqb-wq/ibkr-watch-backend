import SwiftUI

@main
struct IBKRWatchApp: App {
    @StateObject private var appState = AppState()
    @State private var showTokenPrompt = false

    var body: some Scene {
        WindowGroup {
            TabView {
                StatusView(appState: appState)
                    .tabItem {
                        Label("Status", systemImage: "waveform.path.ecg")
                    }

                PricesView(appState: appState)
                    .tabItem {
                        Label("Prices", systemImage: "chart.line.uptrend.xyaxis")
                    }

                SettingsView(appState: appState)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .onAppear {
                showTokenPrompt = appState.apiToken.isEmpty
            }
            .sheet(isPresented: $showTokenPrompt) {
                TokenPromptView(appState: appState)
            }
        }
    }
}
