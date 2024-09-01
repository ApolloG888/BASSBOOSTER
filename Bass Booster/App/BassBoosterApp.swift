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
        Apphud.start(apiKey: "app_dvCEY6wr9U7EVLjXPPdFebCrVskJq4")
    }

    var body: some Scene {
        WindowGroup {
            OnboardingAssembly().build()
        }
    }
}
