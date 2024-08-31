//
//  SelectionButton.swift
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

struct SelectionButton: View {
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
                .frame(height: 64)
                .frame(maxWidth: .infinity)
                .background(backgroundView)
                .cornerRadius(50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.selectionButtonBaseColor, lineWidth: type == .cancel ? 2 : 0)
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
    SelectionButton(type: .cancel, title: "Next", action: {})
}
