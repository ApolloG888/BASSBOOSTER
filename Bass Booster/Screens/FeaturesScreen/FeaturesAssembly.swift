//
//  FeaturesAssembly.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 02.09.2024.
//


import Foundation
import SwiftUI

struct FeaturesAssembly {
    
    @MainActor
    func build() -> some View {
        let viewModel = FeaturesViewModel()
        return FeaturesView(viewModel: viewModel)
    }
}
