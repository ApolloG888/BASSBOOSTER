//
//  ContentView.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .font(.sfProText(size: 33))
        }
        .appGradientBackground()
    }
}

#Preview {
    OnboardingView()
}
