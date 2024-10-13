//
//  TabBarButton.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 08.09.2024.
//

import SwiftUI

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(isSelected ? .tabBarSelected : .clear)
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .tabBarSelected : .gray)
                Text(label)
                    .font(.sfProText(type: .regular400, size: 10))
                    .foregroundColor(isSelected ? .tabBarSelected : .gray)
            }
        }
    }
}
