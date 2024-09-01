//
//  ProductView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 01.09.2024.
//

import SwiftUI

enum ProductType: String {
    case yearly = "Yearly"
    case monthly = "Monthly"
    
    var tag: String {
        switch self {
        case .yearly:
            return "Best deal"
        case .monthly:
            return "Popular"
        }
    }
    
    var weekPrice: String {
        switch self {
        case .yearly:
            return "$1.99/week"
        case .monthly:
            return "$4.99/month"
        }
    }
    
    var fullPrice: String {
        switch self {
        case .yearly:
            return "$48.99/year"
        case .monthly:
            return "$11.99/month"
        }
    }
}

struct ProductView: View {
    var productType: ProductType
    @State var selected: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: CornerRadius.l) {
            HStack {
                Text(productType.rawValue)
                    .font(.sfProText(type: .semiBold600, size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(productType.tag)
                    .font(.sfProText(type: .medium500, size: 10))
                    .padding(Space.xs)
                    .background(.subProductTagColor)
                    .cornerRadius(CornerRadius.xl3 * 2)
                    .foregroundColor(.white)
                
            }
            
            VStack(alignment: .leading, spacing: Space.xs3) {
                Text(productType.weekPrice)
                    .font(.sfProText(type: .medium500, size: 16))
                    .foregroundColor(.subProductPriceColor)
                Text(productType.fullPrice)
                    .font(.sfProText(type: .regular400, size: 12))
                    .foregroundColor(.subProductFullPrice)

            }
        }
        .padding()
        .background(.subProductColor)
        .cornerRadius(CornerRadius.l)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.l)
                .stroke(Color.yellow, lineWidth: selected ? 2 : .zero)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        ProductView(productType: .yearly)
    }
    .background(Color.gray.edgesIgnoringSafeArea(.all))
}
