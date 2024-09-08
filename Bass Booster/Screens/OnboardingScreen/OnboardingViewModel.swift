//
//  OnboardingViewModel.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import SwiftUI

final class OnboardingViewModel: ObservableObject {
    private let urlManager: URLManagerProtocol
    private let purchaseManager: PurchaseManager
    
    @Published var isLoading = false
    @Published var isRestoreAlertPresented = false
    @Published var restoreTitle = ""
    @Published var restoreMessage: String?
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    init(urlManager: URLManagerProtocol, purchaseManager: PurchaseManager) {
        self.urlManager = urlManager
        self.purchaseManager = purchaseManager
    }
    
    func openMockURL() {
        urlManager.open(urlString: "https://www.google.com")
    }
    
    @MainActor
    func restore() {
        isLoading = true
        purchaseManager.restorePurchases { [weak self] success in
            self?.isLoading = false
            if success {
                self?.restoreTitle = "Restore Successful"
                self?.restoreMessage = "Your purchases have been successfully restored."
            } else {
                self?.restoreTitle = "Restore Failed"
                self?.restoreMessage = "There was an issue restoring your purchases."
            }
            self?.isRestoreAlertPresented = true
        }
    }
}
