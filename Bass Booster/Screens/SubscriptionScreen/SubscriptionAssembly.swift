//
//  SubscriptionAssembly.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import Foundation
import SwiftUI

struct SubscriptionAssembly {
    
    @MainActor
    func build() -> some View {
        let purchaseService = PurchaseManager.instance
        let urlManager = URLManager()
        let viewModel = SubscriptionViewModel(purchaseService: purchaseService, urlManager: urlManager)
        return SubscriptionView(viewModel: viewModel)
    }
}
