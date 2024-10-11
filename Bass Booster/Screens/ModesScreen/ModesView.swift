//
//  ModesView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 02.09.2024.
//

import SwiftUI

struct ModesView: View {

    @StateObject var viewModel: ModesViewModel
    
    var body: some View {
        VStack {
            header
            Spacer()
            modes
            Spacer()
        }
        .padding()
        .appGradientBackground()
        .hideNavigationBar()
    }
}

// MARK: - Header

extension ModesView {
    var header: some View {
        VStack {
            HStack {
                Text("Modes")
                    .font(.sfProDisplay(type: .medium500, size: 32))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, Space.xs)
            
            HStack {
                Text("Customize the sound yourself")
                    .font(.sfProText(type: .regular400, size: 14))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
            }
            .padding(.bottom, Space.xs)
        }
    }
}

// MARK: - Modes

extension ModesView {
    var modes: some View {
        ForEach(ModesViewModel.Modes.allCases, id: \.self) { mode in
            PrimaryButton(
                type: .modeSelection,
                title: mode.rawValue,
                action: {
                    viewModel.selectedMode = mode
                },
                modeSelected: viewModel.selectedMode == mode
            )
            .padding(.bottom, Space.xs)
        }
    }
}

#Preview {
    ModesView(viewModel: ModesViewModel())
}
