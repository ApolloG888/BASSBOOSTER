//
//  ModesView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 02.09.2024.
//

import SwiftUI

enum Modes: String, CaseIterable {
    case normal = "Normal"
    case club = "Club"
    case inside = "Inside"
    case street = "Street"
    case movie = "Movie"
    case car = "Car"
}

struct ModesView: View {
    @State private var state: MainScreenTabState = .modes
    @State private var mode: Modes = .normal
    @StateObject var viewModel: ModesViewModel
    
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
            .padding(.bottom, 32)
            
            Spacer()
            
            ForEach(Modes.allCases, id: \.self) { mode in
                PrimaryButton(
                    type: .modeSelection,
                    title: mode.rawValue,
                    action: {
                        self.mode = mode
                    },
                    modeSelected: self.mode == mode
                )
                .padding(.bottom, 8)
            }
            Spacer()
        }
        .padding()
        .appGradientBackground()
    }
}

#Preview {
    ModesView(viewModel: ModesViewModel())
}
