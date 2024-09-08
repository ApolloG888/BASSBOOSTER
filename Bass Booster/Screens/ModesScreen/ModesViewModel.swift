//
//  ModesViewModel.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 02.09.2024.
//

import SwiftUI

final class ModesViewModel: ObservableObject {
    
    @AppStorage("selectedMode") var selectedMode: Modes = .normal
}

extension ModesViewModel {
    enum Modes: String, CaseIterable {
        case normal = "Normal"
        case club = "Club"
        case inside = "Inside"
        case street = "Street"
        case movie = "Movie"
        case car = "Car"
    }
}
