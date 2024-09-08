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
        NavigationStack {
            VStack {
                header
                if viewModel.shouldShowPromotion {
                    premiumRow
                }
                settingsList
                Spacer()
            }
            .hideNavigationBar()
            .padding(.vertical)
            .appGradientBackground()
        }
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

// MARK: - Premium Row

extension SettingsView {
    var premiumRow: some View {
        NavigationLink {
            SubscriptionAssembly().build()
        } label: {
            Image(.premiumRow)
                .resizable()
                .scaledToFill()
                .frame(height: 138)
                .padding(.horizontal)
        }
    }
}

// MARK: - Settings List

extension SettingsView {
    var settingsList: some View {
        List(viewModel.allSettings, id: \.self) { setting in
            VStack(spacing: 16) {
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
                Divider()
                    .background(Color.settingCellBG)
            }
            .padding(.vertical, 5)
            .listRowBackground(Color.white.opacity(0.07))
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
