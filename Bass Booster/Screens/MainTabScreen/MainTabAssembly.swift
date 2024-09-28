//
//  MainAssembly.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 08.09.2024.
//

import Foundation
import SwiftUI

struct MainTabAssembly {
    
    @MainActor
    func build() -> some View {
        let viewModel = MainTabViewModel()
        return MainTabView(viewModel: viewModel)
    }
}
