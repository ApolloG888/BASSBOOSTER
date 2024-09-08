//
//  SettingsViewModel.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 08.09.2024.
//

import SwiftUI

final class SettingsViewModel: ObservableObject {
    
    @Published var allSettings = Settings.allCases
    @AppStorage("shouldShowPromotion") var shouldShowPromotion = true
    
    private let urlManager: URLManagerProtocol
    
    init(urlManager: URLManagerProtocol) {
        self.urlManager = urlManager
    }
    
    func openMockURL() {
        urlManager.open(urlString: "https://www.google.com")
    }
}

extension SettingsViewModel {
    enum Settings: CaseIterable {
        case subscription
        case shareApp
        case support
        case terms
        case privacyPolicy
        
        var title: String {
            switch self {
            case .subscription:
                "Subscription"
            case .shareApp:
                "Share APP"
            case .support:
                "Support"
            case .terms:
                "Terms of use"
            case .privacyPolicy:
                "Privacy policy"
            }
        }
        
        var image: String {
            switch self {
            case .subscription:
                "subscription"
            case .shareApp:
                "share"
            case .support:
                "support"
            case .terms:
                "terms"
            case .privacyPolicy:
                "privacy"
            }
        }
    }
}
