//
//  ContentView.swift
//  Cybertruck
//
//  Created by Anik on 19/8/20.
//

import SwiftUI

enum SliderType: String {
    case bass = "Bass"
    case crystalizer = "Crystalizer"
    case volume = "Volume"
}

struct CircularProgressConfig {
    let minimumValue: CGFloat
    let maximumValue: CGFloat
    let totalValue: CGFloat
}

struct CircularProgressBar: View {
    @Binding var type: SliderType
    let radius: CGFloat = 110
    let knobRadius: CGFloat = 20
    let strokeWidth: CGFloat = 40
    
    @State var progress: CGFloat = 0.0
    @State var angleValue: CGFloat = 0.0
    let config = CircularProgressConfig(minimumValue: 0, maximumValue: 100, totalValue: 100)
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    ProgressBackgroundView(radius: radius)
                    Circle()
                        .trim(from: 0.0, to: progress / config.totalValue)
                        .stroke(
                            type == .crystalizer
                                ? AnyShapeStyle(Color.blueIndicaor)
                                : AnyShapeStyle(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.placeholderYellow,
                                        Color.placeholderPlayerYellow2
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )),
                            style: StrokeStyle(lineWidth: strokeWidth + 5, lineCap: .round)
                        )
                        .frame(width: radius * 2, height: radius * 2)
                        .rotationEffect(.degrees(90))

                    
                    KnobView(type: $type, radius: knobRadius)
                        .offset(y: -radius)
                        .rotationEffect(.degrees(Double(angleValue)))
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: -4)
                        .gesture(DragGesture(minimumDistance: 10)
                            .onChanged({ value in
                                self.changeProgress(locaton: value.location)
                            })
                        )
                        .rotationEffect(.degrees(180))
                    
                    ProgressIndicatorsView(progress: $progress, type: $type, totalValue: config.totalValue)
                        .rotationEffect(.degrees(90))
                    
                    VStack {
                        Text("\(String.init(format: "%.0f", progress))%")
                            .font(.sfProDisplay(type: .regular400, size: 32))
                            .foregroundColor(.textPrimary)
                            .padding(.bottom, 6)
                        
                        Text(type.rawValue)
                            .font(.sfProDisplay(type: .medium500, size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            updateInitialValue()
        }
    }
    
    private func updateInitialValue() {
        angleValue = CGFloat(progress/config.totalValue) * 360
    }
    
    private func changeProgress(locaton: CGPoint) {
        let vector = CGVector(dx: locaton.x, dy: locaton.y)
        let angle = atan2(vector.dy - knobRadius, vector.dx - knobRadius) + .pi/2.0
        
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        let value = fixedAngle / (2.0 * .pi) * config.totalValue
        
        if value > config.minimumValue && value < config.maximumValue {
            progress = value
            angleValue = fixedAngle * 180 / .pi
        }
    }
}

struct ProgressIndicatorsView: View {
    @Binding var progress: CGFloat
    @Binding var type: SliderType
    let totalValue: CGFloat
    let indicatorCount = 8
    var body: some View {
        ZStack {
            ForEach(Array(stride(from: 0, to: indicatorCount, by: 1)), id: \.self) { i in
                IndicatorView(
                    type: type, isOn: progress >= CGFloat(i) * totalValue/CGFloat(indicatorCount),
                    offsetValue: 160)
                .rotationEffect(.degrees(Double(i * 360/indicatorCount)))
            }
        }
    }
}

struct IndicatorView: View {
    var type: SliderType
    let isOn: Bool
    let offsetValue: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isOn ? (type == .bass || type == .volume ? AnyShapeStyle(LinearGradient(
                gradient: Gradient(colors: [
                    Color.placeholderYellow,
                    Color.placeholderPlayerYellow2
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )) : AnyShapeStyle(Color.blueIndicaor)) : AnyShapeStyle(Color.sliderIndicator))
            .frame(width: 15, height: 3)
            .offset(x: offsetValue)
    }
}

struct ProgressBackgroundView: View {
    let radius: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.sliderBackgroundEnd)
                .frame(width: radius * 2, height: radius * 2)
                .scaleEffect(1.3)
                .shadow(color: .sliderTopShadow, radius: 30, x: -20, y: -20)
                .shadow(color: .sliderBottomShadow, radius: 30, x: 20, y: 20)
            
            Circle()
                .stroke(Color.sliderInnerBackground, lineWidth: 52)
                .frame(width: radius * 2, height: radius * 2)
        }
    }
}

//#Preview {
//    CircularProgressBar()
//}

extension Color {
    static let buttonTintColor          = Color.init(red: 127/255, green: 132/255, blue: 137/255)
    static let textPrimary              = Color.init(red: 253/255, green: 253/255, blue: 253/255)
    
    static let darkStart                = Color.init(red: 47/255, green: 53/255, blue: 58/255)
    static let darkEnd                  = Color.init(red: 28/255, green: 31/255, blue: 34/255)
    
    
    static let buttonSelectedStart      = Color.init(red: 29/255, green: 35/255, blue: 40/255)
    static let buttonSelectedEnd        = Color.init(red: 19/255, green: 19/255, blue: 20/255)
    
    static let blueButtonBorderStart    = Color.init(red: 17/255, green: 168/255, blue: 253/255)
    static let blueButtonBorderEnd      = Color.init(red: 0/255, green: 94/255, blue: 163/255)
    
    static let backgroundStart          = Color.init(red: 53/255, green: 58/255, blue: 64/255)
    static let backgroundEnd            = Color.init(red: 22/255, green: 23/255, blue: 27/255)
    
    static let backgroundBorderStart    = Color.init(red: 66/255, green: 71/255, blue: 80/255)
    static let backgroundBorderEnd      = Color.init(red: 32/255, green: 35/255, blue: 38/255)
    
    static let blueButtonStart          = Color.init(red: 0/255, green: 94/255, blue: 163/255)
    static let blueButtonEnd            = Color.init(red: 17/255, green: 168/255, blue: 253/255)
    
    static let sliderIndicator          = Color.init(red: 23/255, green: 24/255, blue: 28/255)
    static let sliderBackgroundEnd      = Color.init(red: 19/255, green: 19/255, blue: 20/255)
    static let sliderInnerBackground    = Color.init(red: 31/255, green: 33/255, blue: 36/255)
    
    static let sliderTopShadow          = Color.init(red: 72/255, green: 80/255, blue: 87/255)
    static let sliderBottomShadow       = Color.init(red: 20/255, green: 20/255, blue: 21/255)
    
    static let blueIndicaor             = Color.init(red: 14/255, green: 155/255, blue: 239/255)
    
    static let knobStart                = Color.init(red: 20/255, green: 21/255, blue: 21/255)
    static let knobEnd                  = Color.init(red: 46/255, green: 50/255, blue: 54/255)
    
    static let backgroundColor = LinearGradient(
        gradient: Gradient(
            colors: [backgroundStart, backgroundEnd]),
        startPoint: .top,
        endPoint: .bottom)
    
    static let backgroundBorderColor = LinearGradient(
        gradient: Gradient(
            colors: [backgroundBorderStart, backgroundBorderEnd]),
        startPoint: .top,
        endPoint: .bottom)
}
