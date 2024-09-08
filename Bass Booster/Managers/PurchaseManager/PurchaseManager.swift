//
//  PurchaseManager.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 08.09.2024.
//

import SwiftUI
import ApphudSDK

final class PurchaseManager {
    
    @AppStorage("userPurchaseIsActive") var userPurchaseIsActive: Bool = false
    @AppStorage("shouldShowPromotion") var shouldShowPromotion = true
    
    static let instance = PurchaseManager()
    var products: [ApphudProduct] = []
    
    private init() {}
    
    @MainActor
    func activate() {
        Apphud.start(apiKey: "app_dvCEY6wr9U7EVLjXPPdFebCrVskJq4")
    }
    
    @MainActor
    func purchase(_ productID: String, completion: @escaping (String?, Bool) -> ()) {
        Apphud.purchase(productID) { result in
            if result.success {
                self.userPurchaseIsActive = true
                self.shouldShowPromotion = false
                completion(nil, true)
            } else if let subscription = result.subscription, subscription.isActive() {
                self.userPurchaseIsActive = Apphud.hasActiveSubscription()
                self.shouldShowPromotion = false
                completion(nil, true)
            } else {
                completion(nil, false)
            }
        }
    }
    
    @MainActor
    func getSubscriptions(completion: @escaping (Bool) -> ()) {
        // Prevent multiple fetches
            print("Subscriptions already fetched.")
            completion(true)

        checkSubscription()
        
        // Use the old paywallsDidLoadCallback method
        Apphud.paywallsDidLoadCallback { paywalls, error in
            if let error = error {
                print("Error fetching paywalls: \(error.localizedDescription)")
                completion(false)
                return
            }

            if paywalls.count == 0 {
                completion(false)
            } else {
                // Find the paywall with the identifier "insidePaywalls"
                if let paywall = paywalls.first(where: { $0.identifier == "insidePaywalls" }) {
                    self.products = paywall.products
                    self.products.forEach { product in
                        print("Product: \(product.skProduct?.localizedTitle ?? "")")
                    }
                    completion(true)
                } else {
                    print("No paywall found with the identifier insidePaywalls")
                    completion(false)
                }
            }
        }
    }
    
    @MainActor
    func restorePurchases(completion: @escaping (Bool) -> ()) {
        Apphud.restorePurchases { _, _, _ in
            if Apphud.hasActiveSubscription() {
                self.userPurchaseIsActive = Apphud.hasActiveSubscription()
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    @MainActor
    func checkSubscription() {
        userPurchaseIsActive = Apphud.hasActiveSubscription()
    }
}
