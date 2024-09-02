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
                    Color.appGradientBackground1,
                    Color.appGradientBackground2
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        
        return self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(gradient)
    }
    
    func selectionButtonGradient() -> LinearGradient {
        let gradient = LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.selectionButtonGradientBackground1,
                    Color.selectionButtonGradientBackground2
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return gradient
    }
    
    func plusButtonGradient() -> LinearGradient {
            let gradient = LinearGradient(
                gradient: Gradient(colors: [.plusButtonTabBarGradient1, .plusButtonTabBarGradient2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            return gradient
        }
    
    func plusButtonBorderGradient() -> LinearGradient {
            let gradient = LinearGradient(
                gradient: Gradient(colors: [.plusButtonTabBarGradient2, .plusButtonTabBarGradient1]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            return gradient
        }
    
    func hideNavigationBar() -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarHidden(true)
    }
    
    func frame(size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
}
