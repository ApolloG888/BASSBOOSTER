//
//  SettingsViewModel.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 08.09.2024.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    
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
    
    @Published var allSettings = Settings.allCases
}
