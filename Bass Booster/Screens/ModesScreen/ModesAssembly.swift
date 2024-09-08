//
//  ModesAssembly.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 02.09.2024.
//

import SwiftUI

struct ModesAssembly {
    
    @MainActor
    func build() -> some View {
        let viewModel = ModesViewModel()
        return ModesView(viewModel: viewModel)
    }
}
