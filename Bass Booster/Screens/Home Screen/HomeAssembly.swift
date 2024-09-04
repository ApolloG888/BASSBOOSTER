//
//  HomeAssembly.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 04.09.2024.
//

import Foundation
import SwiftUI

struct HomeAssembly {
    
    @MainActor
    func build() -> some View {
        let viewModel = HomeViewModel()
        return HomeView(viewModel: viewModel)
    }
}
