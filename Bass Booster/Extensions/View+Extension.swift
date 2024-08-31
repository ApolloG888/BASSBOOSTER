//
//  View+Extension.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

//
//  View+Extension.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI

extension View {
    
    func appGradientBackground(ignoreSafeAreaEdges edges: Edge.Set = .all) -> some View {
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
            .ignoresSafeArea(edges: edges)
    }
    
    func hideNavigationBar() -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarHidden(true)
    }
}
