//
//  PageIndicatorView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 31.08.2024.
//

import SwiftUI

struct PageIndicatorView: View {
    var currentPage: Int
    var totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                if index == currentPage {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 16, height: 8)
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
