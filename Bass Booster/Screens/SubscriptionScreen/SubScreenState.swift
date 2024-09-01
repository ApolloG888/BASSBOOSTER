//
//  SubScreenStatae.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import Foundation
import SwiftUI

enum SubScreenState {
    case preset
    case booster
    case playlist
    
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
}
