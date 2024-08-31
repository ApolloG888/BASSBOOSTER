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
                    imageView
                    mainView
                }
            }
            .navigationDestination(isPresented: $isHomeLinkActive) {
                HomeView(viewModel: HomeViewModel())
            }
            .appGradientBackground()
        }
    }
}

// MARK: - Main View

extension OnboardingView {
    var mainView: some View {
        VStack {
            PageIndicatorView(currentPage: state.rawValue)
                .padding(.vertical, 16)
            VStack(spacing: 10) {
                Text(state.title)
                    .font(.sfProText(type: .semiBold600, size: 32))
                    .foregroundColor(.white)
                Text(state.description)
                    .font(.sfProText(type: .regular400, size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            Spacer()
            bottomView
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Image View

extension OnboardingView {
    var imageView: some View {
        VStack {
            Spacer()
            switch state {
            case .welcome, .effects, .presets, .potential:
                state.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(
                        y: state == .presets || state == .potential ? 50 : 0
                    )
                    .padding(.leading, state == .potential ? 10 : 0)
                
            case .initial, .rating:
                state.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(state == .initial ? 0.6 : 1.0)
                Spacer()
            }
        }
        .ignoresSafeArea(edges: [.bottom, .horizontal])
    }
}

// MARK: - Bottom View

extension OnboardingView {
    var bottomView: some View {
        VStack(spacing: 10) {
            if state == .potential {
                Text(
                    "Get the unlimited access to all features and templates just for 4.99 USD/week"
                )
                .foregroundStyle(.white.opacity(0.4))
                .font(.sfProText(type: .regular400, size: 16))
                .multilineTextAlignment(.center)
            }
            SelectionButton(
                type: .confirmation,
                title: state == .initial ? "Get Started" : "Next"
            ) {
                state == .potential ? isHomeLinkActive = true :  state.next()
            }
            SubscriptionFunctionsView()
        }
    }
}


#Preview {
    OnboardingView(state: .initial)
}
