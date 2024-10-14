//
//  BidirectionalSlider.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 14.10.2024.
//

import SwiftUI

import SwiftUI

struct BidirectionalSlider: View {
    
    @State var value: Double
    
    private let minValue: Double = -50
    private let maxValue: Double = 50
    private let thumbRadius: CGFloat = 12
    var forPresetUsage: Bool = false
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack(alignment: .leading){
                //--Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(forPresetUsage ? .musicPlayerSlider : .customBlack)
                    .frame(width: geometry.size.width, height: 8)

                if forPresetUsage {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.placeholderYellow)
                        .frame(width: 5, height: 20,alignment: .center)
                        .offset(x: geometry.size.width / 2 - 1)
                }
                
                ZStack{
                    let valueChangeFraction = CGFloat(value/(maxValue - minValue))
                    let tintedTrackWidth = geometry.size.width * valueChangeFraction
                    let tintedTrackOffset = min((geometry.size.width / 2) + tintedTrackWidth, geometry.size.width / 2)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color.placeholderYellow,
                                Color.placeholderPlayerYellow2
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: abs(tintedTrackWidth), height: 7.5)
                        .offset(x: tintedTrackOffset)
                }
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.firstGradientViewColor,
                                    Color.secondGradientViewColor
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .fill(Color.musicProgressBar)
                        .frame(width: 4, height: 4)
                }
                    .offset(x: CGFloat((maxValue + value)/(maxValue - minValue)) * geometry.size.width - thumbRadius)
                
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ gesture in
                                updateValue(with: gesture, in: geometry)
                            })
                    )
                    
            }

        }
        .frame(height: 100)
        .padding()
        
    }
    
    private func updateValue(with gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let dragPortion = gesture.location.x / geometry.size.width
        let newValue = Double((maxValue - minValue) * dragPortion) - maxValue
        value = min(max(newValue,minValue),maxValue)
    }
}

#Preview {
    BidirectionalSlider(value: 0)
}
