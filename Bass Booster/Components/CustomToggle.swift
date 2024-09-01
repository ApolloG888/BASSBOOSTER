//
//  CustomToggle.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 01.09.2024.
//

import SwiftUI

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(.white)
                .font(.sfProText(size: 30))
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.orange)
                    .frame(width: 51, height: 31)
                
                Circle()
                    .fill(configuration.isOn ? Color.red : Color.green)
                    .frame(width: 27, height: 27)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}
