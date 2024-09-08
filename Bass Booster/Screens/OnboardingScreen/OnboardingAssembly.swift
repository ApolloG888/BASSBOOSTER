//
//  OnboardingAssembly.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import Foundation
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
