//
//  ContentView.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 31.08.2024.
//

import SwiftUI

enum OnboardingState: Int {
    case initial = 0
    case welcome, rating, effects, presets, potential
    
    var title: String {
        switch self {
        case .initial:
            .empty
        case .welcome:
            "Welcome"
        case .rating:
            "Your rating help us get better"
        case .effects:
            "Add effects"
        case .presets:
            "Set up your preset"
        case .potential:
            "Unlock your potential"
        }
    }
    
    var description: String {
        switch self {
        case .initial:
            .empty
        case .welcome:
            "Enjoy your music as never before with the audio editing tools Bass Booster brings directly to your device"
        case .rating:
            "We always glad to see your feedback! It help us in adding your ideas into the app"
        case .effects:
            "An easy-to-use interface to boost the bass of each song in your device"
        case .presets:
            "Set up your custom preset using the equalizer"
        case .potential:
            "Unlock more possibilities with a premium subscription"
        }
    }
    
    var image: Image {
        switch self {
        case .initial:
            Image(.initial)
        case .welcome:
            Image(.welcome)
        case .rating:
            Image(.rating)
        case .effects:
            Image(.effects)
        case .presets:
            Image(.preset)
        case .potential:
            Image(.potential)
        }
    }
    
    mutating func next() {
        switch self {
        case .initial:
            self = .welcome
        case .welcome:
            self = .rating
        case .rating:
            self = .effects
        case .effects:
            self = .presets
        case .presets:
            self = .potential
        case .potential:
            self = .potential
        }
    }
}

struct OnboardingView: View {
    @State var state: OnboardingState
    
    var body: some View {
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
                        state.next()
                    }
                    .padding(.bottom, 10)
                    SubscriptionFunctionsView()
                        .padding(.bottom, 10)
                }
                .padding(.horizontal, 16)
            }
        }
        .appGradientBackground()
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    OnboardingView(state: .initial)
}
