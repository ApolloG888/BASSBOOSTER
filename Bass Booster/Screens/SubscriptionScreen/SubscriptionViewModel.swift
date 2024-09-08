//
//  SubscriptionViewModel.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import SwiftUI
import ApphudSDK

final class SubscriptionViewModel: ObservableObject {

    @Published var products: [ApphudProduct] = []
    @Published var selectedProductIndex = 0
    @Published var isLoading = false
    @Published var isRestoreAlertPresented = false
    @Published var restoreTitle = ""
    @Published var restoreMessage: String?
    
    private let purchaseService: PurchaseManager
    private let urlManager: URLManagerProtocol
    
    init(purchaseService: PurchaseManager, urlManager: URLManagerProtocol) {
        self.purchaseService = purchaseService
        self.urlManager = urlManager
    }
    
    @MainActor
    func fetchProducts() {
        if purchaseService.products.isEmpty {
            purchaseService.getSubscriptions { succeeded in
                if succeeded {
                    self.purchaseService.products.forEach { product in
                        print("Product: \(product.skProduct?.localizedTitle ?? "")")
                    }
                    self.products = self.purchaseService.products
                }
            }
        }  else {
            products = purchaseService.products
        }
    }
    
    @MainActor
    func purchase(completion: @escaping (Bool) -> ()) {
        if !products.isEmpty {
            isLoading = true
            purchaseService.purchase(products[selectedProductIndex].productId) { [weak self] _, succeeded in
                self?.isLoading = false
                if succeeded {
                    print("Subscription succeeded!")
                } else {
                    print("Subscription failed.")
                }
                completion(succeeded)
            }
        } else {
            print("Subscription not loaded.")
        }
    }
    
    // Add restore purchases method
    @MainActor
    func restorePurchases() {
        isLoading = true
        purchaseService.restorePurchases { [weak self] success in
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

    func openMockURL() {
        urlManager.open(urlString: "https://www.google.com")
    }
}
