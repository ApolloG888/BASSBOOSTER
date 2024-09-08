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
        VStack {
            headerView
            infoView
            state.image
            PageIndicator(
                currentPage: state.rawValue,
                totalPages: 3
            )
            Spacer()
            if !viewModel.products.isEmpty {
                productView
            }
            Spacer()
            bottomView
        }
        .padding(.horizontal)
        .hideNavigationBar()
        .appGradientBackground()
        .onAppear {
            print("onAppear called")
            viewModel.fetchProducts()
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.6)))
                    .scaleEffect(2)
            }
        }
        .alert(viewModel.restoreTitle, isPresented: $viewModel.isRestoreAlertPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.restoreMessage ?? .empty)
        }
    }
}

// MARK: - Header View

extension SubscriptionView {
    var headerView: some View {
        HStack {
            Spacer()
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(size: Size.m)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, Space.xs)
    }
}

// MARK: - Info View

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
    }
}

// MARK: - Product View

extension SubscriptionView {
    var productView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<viewModel.products.count, id: \.self) { index in
                    if let product = viewModel.products[index].skProduct {
                        ProductView(
                            productDuration: product.getProductDuration(),
                            weekPrice: "\(product.getProductWeeklyPrice())/week",
                            fullPrice: "\(product.getProductPrice())/\(product.getProductDurationTypeAndUnit())",
                            selected: viewModel.selectedProductIndex == index
                        )
                        .frame(width: 171, height: 98)
                        .padding(.vertical)
                        .onTapGesture {
                            print("Tapped block")
                            viewModel.selectedProductIndex = index
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Bottom View

extension SubscriptionView {
    var bottomView: some View {
        VStack(spacing: Space.xs) {
            benefitsView
            PrimaryButton(
                type: .confirmation,
                title: state == .playlist ? "Start free trial" : "Next"
            ) {
                state == .playlist ?
                viewModel.purchase { succeeded in
                    if succeeded {
                        print("Красава")
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Не получилось")
                    }
                } :
                state.next()
            }
            OptionsView {
                viewModel.restorePurchases()
            } browserAction: {
                viewModel.openMockURL()
            }
        }
    }
}

// MARK: - Benefits View

extension SubscriptionView {
    var benefitsView: some View {
        Text("3-day free trial • Recurring Bill • Cancel anytime")
            .font(.sfProText(type: .regular400, size: 14))
            .foregroundColor(.white)
            .fixedSize()
            .padding(.bottom, Space.xs)
            .padding(.horizontal, Space.l)
            .cornerRadius(CornerRadius.s)
    }
}

#Preview {
    SubscriptionView(viewModel: SubscriptionViewModel(purchaseService: PurchaseManager.instance, urlManager: URLManager()))
}
