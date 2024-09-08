//
//  MainTabScreenTabState.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 02.09.2024.
//

import SwiftUI

enum MainTabScreenState: Int, CaseIterable {
    case home, modes, features, settings
    
    var icon: String {
        switch self {
        case .home:
            return "home"
        case .modes:
            return "modes"
        case .features:
            return "features"
        case .settings:
            return "settings"
        }
    }
    
    var name: String {
        switch self {
        case .home:
            return "Home"
        case .modes:
            return "Modes"
        case .features:
            return "Features"
        case .settings:
            return "Settings"
        }
    }
    
    var possibilities: String {
        switch self {
        case .modes, .features:
            "Customize the sound yourself"
        default: .empty
        }
    }
    
    @MainActor
    @ViewBuilder
    var viewBuilder: some View {
        switch self {
        case .home:
            HomeAssembly().build()
        case .modes:
            ModesAssembly().build()
        case .features:
            FeaturesAssembly().build()
        case .settings:
            SettingsAssembly().build()
        }
    }
}
