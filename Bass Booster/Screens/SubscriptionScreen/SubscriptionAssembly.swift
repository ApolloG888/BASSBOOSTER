import SwiftUI

struct SubscriptionAssembly {
    
    @MainActor
    func build(isPresented: Binding<Bool>) -> some View {
        let purchaseService = PurchaseManager.instance
        let urlManager = URLManager()
        let viewModel = SubscriptionViewModel(purchaseService: purchaseService, urlManager: urlManager)
        return SubscriptionView(viewModel: viewModel, isPresented: isPresented)
    }
}
