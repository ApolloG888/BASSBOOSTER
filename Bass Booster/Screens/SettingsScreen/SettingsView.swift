//
//  SettingsView.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 08.09.2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var state: MainTabScreenState = .settings
    @StateObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            header
            settingsList
            Spacer()
        }
        .padding(.vertical)
        .appGradientBackground()
    }
}

// MARK: - Header

extension SettingsView {
    var header: some View {
        HStack {
            Text(state.name)
                .font(.sfProDisplay(type: .medium500, size: 32))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.bottom, Space.xs)
        .padding(.horizontal)
    }
}

// MARK: - Settings List

extension SettingsView {
    var settingsList: some View {
        List(viewModel.allSettings, id: \.self) { setting in
            VStack {
                HStack {
                    Image(setting.image)
                        .resizable()
                        .scaledToFit()
                        .frame(size: Size.xl)
                    Text(setting.title)
                        .font(.sfProText(size: 14))
                        .foregroundStyle(.subProductPriceColor)
                    Spacer()
                    Image(.arrowRight)
                        .resizable()
                        .scaledToFit()
                        .frame(size: Size.xl)
                }
            }
            .listRowBackground(Color.white.opacity(0.07))
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
