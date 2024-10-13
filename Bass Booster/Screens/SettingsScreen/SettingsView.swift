//
//  SettingsView.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 08.09.2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @State private var isSubscriptionLinkActive = false
    
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
//            .navigationDestination(isPresented: $isSubscriptionLinkActive) {
//                SubscriptionAssembly().build()
//            }
        }
    }
}

// MARK: - Header

extension SettingsView {
    var header: some View {
        HStack {
            Text("Settings")
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
//            SubscriptionAssembly().build()
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
            }
            .padding(.vertical, 5)
            .listRowBackground(Color.white.opacity(0.07))
            .onTapGesture {
                handleTap(for: setting)
            }
        }
        .scrollContentBackground(.hidden)
    }

    func handleTap(for setting: SettingsViewModel.Settings) {
        switch setting {
        case .subscription:
            isSubscriptionLinkActive = true
        default:
            viewModel.openMockURL()
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(urlManager: URLManager()))
}
