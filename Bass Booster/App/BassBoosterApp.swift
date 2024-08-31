//
//  BassBoosterApp.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI

@main
struct BassBoosterApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingView(state: .initial)
        }
    }
}
