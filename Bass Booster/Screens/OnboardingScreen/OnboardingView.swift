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
            Spacer()
            ZStack {
                Image(.welcome) // Замените на ваш ресурс
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea(.all, edges: .bottom) // Игнорируем SafeArea снизу
                
//                VStack {
//                    VStack {
//                        Text("Welcome")
//                        Text("Welcome")
//                        Text("Welcome")
//                    }
//                    .foregroundStyle(.white)
//                    
//                    Spacer()
//                    
//                    CustomTextContainer(text: "Next", textSize: 30)
//                        .padding(.bottom, 20)
//                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .appGradientBackground(ignoreSafeAreaEdges: .bottom) // Применяем градиент с игнорированием SafeArea
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
