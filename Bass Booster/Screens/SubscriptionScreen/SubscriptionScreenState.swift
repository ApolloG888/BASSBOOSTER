//
//  SubScreenStatae.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import Foundation
import SwiftUI

enum SubScreenState: Int {
    case preset, booster, playlist
    
    var title: String {
        "Unlock your potential"
    }
    
    var description: String {
        "Unlock more possibilities with a premium subscription"
    }
    
    var image: Image {
        switch self {
        case .preset:
            Image(.presets)
        case .booster:
            Image(.booster)
        case .playlist:
            Image(.playlist)
        }
    }
    
    mutating func next() {
        switch self {
        case .preset:
            self = .booster
        case .booster:
            self = .playlist
        case .playlist:
            self = .playlist
        }
    }
}
