//
//  FeatureViewModel.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 02.09.2024.
//

import SwiftUI

final class FeaturesViewModel: ObservableObject {
    
    @AppStorage("isQuietSoundSelected") var isQuietSoundSelected: Bool = false
    @AppStorage("isSuppressionSelected") var isSuppressionSelected: Bool = false
}

extension FeaturesViewModel {
    enum Features: String {
        case quietSounds = "Amplifying quiet sounds"
        case noiseSuppression = "Noise suppression"
    }
}
