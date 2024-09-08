//
//  SettingsAssembly.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 08.09.2024.
//

import SwiftUI

struct SettingsAssembly {
    
    @MainActor
    func build() -> some View {
        let urlManager = URLManager()
        let viewModel = SettingsViewModel(urlManager: urlManager)
        return SettingsView(viewModel: viewModel)
    }
}
