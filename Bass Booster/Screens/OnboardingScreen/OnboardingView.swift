//
//  ContentView.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI

struct OnboardingView: View {
    @State var state: OnboardingState
    @State private var isHomeLinkActive: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    VStack {
                        PageIndicatorView(currentPage: state.rawValue)
                            .padding(.vertical, 10)
                        VStack(spacing: 10) {
                            Text(state.title)
                                .font(.sfProText(type: .semiBold600, size: 32))
                                .foregroundColor(.white)
                            Text(state.description)
                                .font(.sfProText(type: .regular400, size: 16))
                                .foregroundColor(.gray)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        Spacer()
                    }
                    
                    VStack {
                        switch state {
                        case .welcome, .effects, .presets, .potential:
                            Spacer()
                            state.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .offset(y: state == .presets ? 60 : 0 )
                            
                        case .initial, .rating:
                            Spacer()
                            state.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(state == .initial ? 0.6 : 1.0)
                            Spacer()
                            
                        }
                    }
                    .ignoresSafeArea(edges: [.bottom, .horizontal])
                    
                    VStack {
                        Spacer()
                        SelectionButton(type: .confirmation, title: "Next") {
                            if state == .potential {
                                isHomeLinkActive = true
                            } else {
                                state.next()
                            }
                        }
                        .padding(.bottom, 10)
                        SubscriptionFunctionsView()
                            .padding(.bottom, 10)
                    }
                    .navigationDestination(isPresented: $isHomeLinkActive) {
                        HomeView(viewModel: HomeViewModel())
                    }
                    .padding(.horizontal, 16)
                }
            }
            .appGradientBackground()
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

#Preview {
    OnboardingView(state: .initial)
}
