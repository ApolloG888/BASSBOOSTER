//
//  SubscriptionAssembly.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import Foundation
import SwiftUI

struct SubscriptionAssembly {
    
    @MainActor
    func build() -> some View {
        //let urlService = URLManager()
        let viewModel = SubscriptionViewModel()
        return SubscriptionView(viewModel: viewModel)
    }
}
