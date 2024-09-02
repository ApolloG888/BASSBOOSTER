//
//  FeaturesView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 02.09.2024.
//

import SwiftUI

enum Features: String {
    case quietSounds = "Amplifying quiet sounds"
    case noiseSuppression = "Noise suppression"
}

struct FeaturesView: View {
    @State private var state: MainScreenTabState = .features
    @StateObject var viewModel: FeaturesViewModel
    @State var isQuietSoundSelected: Bool = false
    @State var isSuppressionSelected: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text(state.name)
                    .font(.sfProDisplay(type: .medium500, size: 32))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 8)
            
            HStack {
                Text(state.possibilities)
                    .font(.sfProText(type: .regular400, size: 14))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
            }
            .padding(.bottom, 24)
            
            VStack {
                Toggle(isOn: $isQuietSoundSelected, label: {
                    Text(Features.quietSounds.rawValue)
                        .font(.sfProText(type: .medium500, size: 15))
                })
               
                Toggle(isOn: $isSuppressionSelected, label: {
                    Text(Features.noiseSuppression.rawValue)
                        .font(.sfProText(type: .medium500, size: 15))
                })
            }
            .toggleStyle(CustomToggleStyle(gradient: selectionButtonGradient()))
           
            Spacer()
        }
        .padding()
        .appGradientBackground()
    }
}

#Preview {
    FeaturesView(viewModel: FeaturesViewModel())
        .appGradientBackground()
}
