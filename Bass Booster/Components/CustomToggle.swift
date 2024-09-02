//
//  CustomToggle.swift
//  Bass Booster
//
//  Created by Дмитрий Процак on 01.09.2024.
//

import SwiftUI

struct CustomToggleStyle: ToggleStyle {
    var gradient: LinearGradient
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(.white)
                .font(.sfProText(size: 30))
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black)
                    .frame(width: 80, height: 40)
                    
                
                Circle()
                    .fill(gradient)
                    .frame(width: 29, height: 29)
                    .offset(x: configuration.isOn ? 20 : -20)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}
