//
//  View+Extension.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI

extension View {
    
    func appGradientBackground() -> some View {
        let gradient = LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.gradientBackground1,
                    Color.gradientBackground2
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        
        return self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(gradient)
            .edgesIgnoringSafeArea(.all)
    }
    
    func hideNavigationBar() -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarHidden(true)
    }
}
