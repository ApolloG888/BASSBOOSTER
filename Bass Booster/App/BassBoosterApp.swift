//
//  BassBoosterApp.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI
import ApphudSDK
import AppTrackingTransparency
import AdSupport

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Инициализация Apphud SDK
        Apphud.start(apiKey: "app_dvCEY6wr9U7EVLjXPPdFebCrVskJq4")
        
        // Установка идентификаторов устройства (передаем только IDFV на старте)
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)
        
        // Запрос IDFA и обновление идентификаторов устройства
        fetchIDFA()
        
        fetchProduct()
    }

    var body: some Scene {
        WindowGroup {
            OnboardingAssembly().build()
        }
    }

    private func fetchIDFA() {
        if #available(iOS 14.5, *) {
            // Задержка в 2 секунды перед запросом разрешения
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    // Проверка, что пользователь разрешил отслеживание
                    guard status == .authorized else { return }
                    
                    // Получаем IDFA
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    
                    // Устанавливаем идентификаторы устройства в Apphud
                    Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
                    
                    // Дополнительно можно напечатать IDFA для проверки
                    print("Updated IDFA: \(idfa)")
                }
            }
        }
    }
    
    private func fetchProduct() {
        Apphud.fetchPlacements { placements, error in
            // if paywalls are already loaded, callback will be invoked immediately
            if let paywall = placements.first(where: { $0.identifier == "YOUR_PLACEMENT_ID" })?.paywall {
                let products = paywall.products
                // setup your UI with these products
            }
        }
    }
}
