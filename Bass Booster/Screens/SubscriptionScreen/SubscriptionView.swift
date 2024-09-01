//
//  SubscriptionView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import SwiftUI

struct SubscriptionView: View {
    @StateObject var viewModel: SubscriptionViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var state: SubScreenState = .preset
    
    var body: some View {
        NavigationStack {
            VStack {
                headerView
                infoView
                state.image
                PageIndicator(currentPage: state.rawValue, totalPages: 3)
                HStack(spacing: 4) {
                    ProductView(productType: .yearly)
                    ProductView(productType: .monthly)
                }
                titleView
                PrimaryButton(type: .confirmation, title: "Next") {
                    state == .playlist ?
                    presentationMode.wrappedValue.dismiss() :
                    state.next()
                }
                .padding(.horizontal)
                OptionsView()
            }
            .ignoresSafeArea(ed)
            .appGradientBackground()
        }
    }
}

extension SubscriptionView {
    var headerView: some View {
        HStack {
            Spacer()
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

extension SubscriptionView {
    var infoView: some View {
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
    }
}

extension SubscriptionView {
    var titleView: some View {
        Text("3-day free trial • Recurring Bill • Cancel anytime")
            .font(.sfProText(type: .regular400, size: 14))
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.vertical, 4)
            .cornerRadius(8)
    }
}

#Preview {
    SubscriptionView(viewModel: SubscriptionViewModel())
}
