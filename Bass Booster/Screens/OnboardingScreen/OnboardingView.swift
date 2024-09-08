//
//  OnboardingView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import SwiftUI

struct OnboardingView: View {
    @State var state: OnboardingState = .initial
    @State private var isHomeLinkActive: Bool = false
    @StateObject var viewModel: OnboardingViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    imageView
                    mainView
                }
            }
            .navigationDestination(isPresented: $isHomeLinkActive) {
                MainTabAssembly().build()
            }
            .appGradientBackground()
            .alert(viewModel.restoreTitle, isPresented: $viewModel.isRestoreAlertPresented) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.restoreMessage ?? .empty)
            }
        }
    }
}

// MARK: - Main View

extension OnboardingView {
    var mainView: some View {
        VStack {
            PageIndicator(currentPage: state.rawValue, totalPages: 6)
                .padding(.vertical, Space.m)
            VStack(spacing: Space.s) {
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
        .padding(.horizontal, Space.m)
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
                        y: state == .presets || state == .potential ? Space.xl5 : .zero
                    )
                    .padding(.leading, state == .potential ? Space.s : .zero)
                
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
        VStack(spacing: Space.s) {
            if state == .potential {
                Text(
                    "Get the unlimited access to all features and templates just for 4.99 USD/week"
                )
                .foregroundStyle(.white.opacity(0.4))
                .font(.sfProText(type: .regular400, size: 16))
                .multilineTextAlignment(.center)
            }
            PrimaryButton(
                type: .confirmation,
                title: state.buttonTitle
            ) {
                state == .potential 
                ? routeToMainScreen()
                : state.next()
            }
            OptionsView {
                viewModel.restore()
            } browserAction: {
                viewModel.openMockURL()
            }
        }
    }
}

private extension OnboardingView {
    func routeToMainScreen() {
        isHomeLinkActive = true
        viewModel.isFirstLaunch = false
    }
}

#Preview {
    OnboardingView(state: .initial, viewModel: OnboardingViewModel(urlManager: URLManager(), purchaseManager: PurchaseManager.instance))
}
