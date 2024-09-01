//
//  PrimaryButton.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 31.08.2024.
//

import SwiftUI

enum ButtonType {
    case confirmation
    case modeSelection
    case playlist
    case cancel
}

struct PrimaryButton: View {
    var type: ButtonType
    var title: String
    var action: () -> Void
    var modeSelected: Bool?
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .font(.sfProText(type: .medium500, size: 16))
                .foregroundColor(type == .cancel ? .white : .black)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(backgroundView)
                .cornerRadius(CornerRadius.xl2 * 2)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl2 * 2)
                        .stroke(Color.selectionButtonBaseColor, lineWidth: type == .cancel ? 2 : .zero)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var baseColor: Color {
        if type == .confirmation {
            return .selectionButtonBaseColor
        } else {
            return .black
        }
    }
    
    private var backgroundView: some View {
        Group {
            if shouldApplyGradient {
                selectionButtonGradient()
            } else {
                baseColor
            }
        }
    }
    
    private var shouldApplyGradient: Bool {
        return type == .modeSelection && modeSelected ?? false
    }
}

#Preview {
    PrimaryButton(type: .cancel, title: "Next", action: {})
}
