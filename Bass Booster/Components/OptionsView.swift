//
//  OptionsView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 31.08.2024.
//

import SwiftUI

struct OptionsView: View {
    var restoreAction: (() -> Void)?
    var browserAction: (() -> Void)?
    
    var body: some View {
            HStack {
                Button {
                    browserAction?()
                } label: {
                    Text("Privacy Policy")
                        .font(.sfProText(type: .light300, size: 11))
                }
                
                Spacer()
                Rectangle()
                    .frame(width: 1, height: Space.l)
                    .foregroundColor(.white.opacity(0.3))
                
                Spacer()
                
                Button(action: {
                    restoreAction?()
                }) {
                    Text("Restore")
                        .font(.sfProText(type: .light300, size: 11))
                }
                
                Spacer()
                
                Rectangle()
                    .frame(width: 1, height: Space.l)
                    .foregroundColor(.white.opacity(0.3))
                
                Spacer()
                
                Button(action: {
                    browserAction?()
                }) {
                    Text("Terms of use")
                        .font(.sfProText(type: .light300, size: 11))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, Space.xl4)
    }
}

#Preview {
    OptionsView()
        .background(Color.black)
}
