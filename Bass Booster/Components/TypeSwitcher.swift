//
//  TypeSwitcher.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 13.10.2024.
//

import SwiftUI

struct CustomToggleSwitch: View {
    @Binding var selectedType: SliderType
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.black.opacity(0.8))
                .frame(height: 50)
            
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation {
                        selectedType = .bass
                    }
                }) {
                    Text("Bass boost")
                        .font(.sfProDisplay(type: .regular400, size: 14))
                        .foregroundColor(selectedType == .bass ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedType == .bass ? Color.musicProgressBar : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                Button(action: {
                    withAnimation {
                        selectedType = .crystalizer
                    }
                }) {
                    Text("Crystallizer")
                        .font(.sfProDisplay(type: .regular400, size: 14))
                        .foregroundColor(selectedType == .crystalizer ? .white : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.all, 10)
                        .background(
                            selectedType == .crystalizer ? Color.blue : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(6)
        }
        .frame(maxWidth: 200)
        .padding(.horizontal, 30)
    }
}
//
//struct CustomToggleSwitch_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomToggleSwitch(selectedType: .bass)
//    }
//}
