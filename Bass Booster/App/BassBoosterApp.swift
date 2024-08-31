//
//  BassBoosterApp.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI
import ApphudSDK

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        Apphud.start(apiKey: "app_2ojGaR5zyQUUJn1htob9ei2uFhZFxv")
    }

    var body: some Scene {
        WindowGroup {
            OnboardingView()
        }
    }
}
