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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(productType.rawValue)
                    .font(.sfProText(type: .semiBold600, size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(productType.tag)
                    .font(.sfProText(type: .medium500, size: 10))
                    .padding(8)
                    .background(.subProductTagColor)
                    .cornerRadius(40)
                    .foregroundColor(.white)
                
            }
            
            VStack(alignment: .leading,spacing: 4, content: {
                Text(productType.weekPrice)
                    .font(.sfProText(type: .medium500, size: 16))
                    .foregroundColor(.subProductPriceColor)
                Text(productType.fullPrice)
                    .font(.sfProText(type: .regular400, size: 12))
                    .foregroundColor(.subProductFullPrice)

            })
        }
        .padding()
        .background(.subProductColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow, lineWidth: selected ? 2 : 0)
        )
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProductView(productType: .yearly)
    }
    .background(Color.gray.edgesIgnoringSafeArea(.all))
}
