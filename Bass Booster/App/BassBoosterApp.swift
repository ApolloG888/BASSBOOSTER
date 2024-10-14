import SwiftUI
import ApphudSDK
import AppTrackingTransparency
import AdSupport

@main
struct BassBoosterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                OnboardingAssembly().build()
                    .preferredColorScheme(.dark)
            } else {
                MainTabAssembly().build()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
