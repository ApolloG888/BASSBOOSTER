import SwiftUI

struct OnboardingAssembly {
    
    @MainActor
    func build() -> some View {
        let urlService = URLManager()
        let purchaseManager = PurchaseManager.instance
        let viewModel = OnboardingViewModel(urlManager: urlService, purchaseManager: purchaseManager)
        return OnboardingView(viewModel: viewModel)
    }
}
