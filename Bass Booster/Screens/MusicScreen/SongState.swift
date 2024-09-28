//
//  SongState.swift
//  Bass Booster
//
//  Created by Protsak Dmytro on 29.09.2024.
//

import SwiftUI

enum SongState {
    case play
    case pause
    
    var image: Image {
        switch self {
        case .play:
            Image(.play)
        case .pause:
            Image(.pause)
        }
    }
    
    mutating func toggle() {
        if self == .pause {
            self = .play
        } else {
            self = .pause
        }
    }
}
