//
//  OnboardingViewModel.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import Foundation

final class OnboardingViewModel: ObservableObject {
    private let urlManager: URLManagerProtocol
    
    init(urlManager: URLManagerProtocol) {
        self.urlManager = urlManager
    }
    
    func openMockURL() {
        urlManager.open(urlString: "https://www.google.com")
    }
    
}
