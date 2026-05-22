import SwiftUI

@main
struct Heart_RateApp: App {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @StateObject private var historyStore = HistoryStore()
    
    var body: some Scene {
        WindowGroup {
            LaunchScaffold {
                if hasCompletedOnboarding {
                    MainView()
                        .environmentObject(historyStore)
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
        }
    }
}
