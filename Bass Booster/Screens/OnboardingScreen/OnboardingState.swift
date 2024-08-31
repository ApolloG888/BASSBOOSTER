//
//  OnboardingState.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 31.08.2024.
//

import Foundation
import SwiftUI

enum OnboardingState: Int {
    case initial = 0
    case welcome, rating, effects, presets, potential
    
    var title: String {
        switch self {
        case .initial:
            .empty
        case .welcome:
            "Welcome"
        case .rating:
            "Your rating help us get better"
        case .effects:
            "Add effects"
        case .presets:
            "Set up your preset"
        case .potential:
            "Unlock your potential"
        }
    }
    
    var description: String {
        switch self {
        case .initial:
            .empty
        case .welcome:
            "Enjoy your music as never before with the audio editing tools Bass Booster brings directly to your device"
        case .rating:
            "We always glad to see your feedback! It help us in adding your ideas into the app"
        case .effects:
            "An easy-to-use interface to boost the bass of each song in your device"
        case .presets:
            "Set up your custom preset using the equalizer"
        case .potential:
            "Unlock more possibilities with a premium subscription"
        }
    }
    
    var image: Image {
        switch self {
        case .initial:
            Image(.initial)
        case .welcome:
            Image(.welcome)
        case .rating:
            Image(.rating)
        case .effects:
            Image(.effects)
        case .presets:
            Image(.preset)
        case .potential:
            Image(.potential)
        }
    }
    
    mutating func next() {
        switch self {
        case .initial:
            self = .welcome
        case .welcome:
            self = .rating
        case .rating:
            self = .effects
        case .effects:
            self = .presets
        case .presets:
            self = .potential
        case .potential:
            self = .potential
        }
    }
}
