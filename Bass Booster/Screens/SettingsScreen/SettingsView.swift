//
//  SettingsView.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 08.09.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: MusicViewModel
    @State private var isSubscriptionLinkActive = false {
        didSet {
            viewModel.isShowSubscriptionOverlay = true
        }
    }
    @State var allSettings = Settings.allCases
    
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
        Button {
            viewModel.isShowSubscriptionOverlay = true
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
        List(allSettings, id: \.self) { setting in
            VStack(spacing: 16) {
                HStack {
                    Image(setting.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text(setting.title)
                        .font(.sfProText(size: 16))
                        .foregroundStyle(.subProductPriceColor)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .contentShape(Rectangle())
            .listRowBackground(Color.white.opacity(0.07))
            .onTapGesture {
                handleTap(for: setting)
            }
        }
        .scrollContentBackground(.hidden)
    }

    func handleTap(for setting: Settings) {
        switch setting {
        case .subscription:
            isSubscriptionLinkActive = true
        default:
            viewModel.openMockURL()
        }
    }
}
