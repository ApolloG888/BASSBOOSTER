//
//  OnboardingViewModel.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import Foundation

final class OnboardingViewModel: ObservableObject {
    private let urlManager: URLManagerProtocol
    private let purchaseManager: PurchaseManager
    
    init(urlManager: URLManagerProtocol, purchaseManager: PurchaseManager) {
        self.urlManager = urlManager
        self.purchaseManager = purchaseManager
    }
    
    func openMockURL() {
        urlManager.open(urlString: "https://www.google.com")
    }
    
    @MainActor 
    func restore() {
        
    }
}
