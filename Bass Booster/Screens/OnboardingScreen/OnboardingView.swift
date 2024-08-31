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
            ZStack {
                VStack {
                    Spacer()
                    Image(.potenial)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .ignoresSafeArea(edges: [.bottom, .horizontal])
                VStack {
                    CustomTextContainer(text: "Play", textSize: 30)
                    CustomTextContainer(text: "Play", textSize: 30)
                    Spacer()
                    
                    CustomTextContainer(text: "Play", textSize: 30)
                }
            }
        }
        .appGradientBackground()
    }
}
#Preview {
    OnboardingView()
}

struct CustomTextContainer: View {
    let text: String
    let textSize: CGFloat
    
    var body: some View {
        Text(text)
            .foregroundStyle(.white)
            .font(.sfProText(size: textSize))
            .padding(.vertical)
            .padding(.horizontal, 40)
            .background(
                Color.red
                    .cornerRadius(5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 5
                    )
            )
            .frame(height: 65)
    }
}
