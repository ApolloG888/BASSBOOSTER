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
    @State private var state: SubScreenState = .preset
    
    var body: some View {
        NavigationStack {
            VStack {
                headerView
                infoView
                state.image
                Spacer()
            }
            .appGradientBackground()
        }
    }
}

extension SubscriptionView {
    var headerView: some View {
        HStack {
            Spacer()
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(.white)
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
//presentationMode.wrappedValue.dismiss()

#Preview {
    SubscriptionView(viewModel: SubscriptionViewModel())
}
