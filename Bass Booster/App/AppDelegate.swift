import SwiftUI
import ApphudSDK
import AppTrackingTransparency
import AdSupport

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        PurchaseManager.instance.activate()
        
        // Request tracking transparency
        requestTrackingPermission()
        
        return true
    }
    
    private func requestTrackingPermission() {
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        print("Tracking authorized.")
                        let idfa = ASIdentifierManager.shared().advertisingIdentifier
                        print("IDFA: \(idfa)")
                    case .denied, .restricted, .notDetermined:
                        print("Tracking not authorized.")
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
}
