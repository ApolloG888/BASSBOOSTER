import Sliders
import SwiftUI

struct FanSliderView: View {
    var body: some View {
        VStack {
            GeometryReader { geometry in
                FanSlider(width: geometry.size.width)
                    .padding(.top, 6)
            }
            .frame(height: 50)
        }
    }
}

struct FanSlider: View {
    @State var progress: CGFloat = 0.0
    @State var knobPosition: CGFloat = 0.0
    let sliderConfig = FanSliderConfig()
    let width: CGFloat
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.secondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black.opacity(0.95))
                            .mask(RoundedRectangle(cornerRadius: 5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.musicPlayerSlider)
                            .blur(radius: 3)
                            .offset(y: 6)
                            .mask(RoundedRectangle(cornerRadius: 5))
                    )
                    .frame(height: 7.5)
                RoundedRectangle(cornerRadius: 5)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.placeholderYellow,
                            Color.placeholderPlayerYellow2
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: knobPosition, height: 6)
                
                KnobView(radius: sliderConfig.knobRadius)
                    .offset(x: knobPosition - 5)
                    .gesture(DragGesture(minimumDistance: 0)
                                .onChanged({ value in
                                    calculateProgressWidth(xLocation: value.location.x)
                                })
                                .onEnded({ value in
                                    calculateStep(xLocation: value.location.x)
                                })
                    )
            }
        }
    }
    
    func calculateInitialKnobPosition() {
        progress = sliderConfig.minimumValue
        knobPosition = (progress * width) - knobPosition
    }
    
    func calculateProgressWidth(xLocation: CGFloat) {
        let tempProgress = xLocation/width
        if tempProgress > 0 && tempProgress <= 1 {
            progress = (tempProgress * (sliderConfig.maximumValue - sliderConfig.minimumValue)) + sliderConfig.minimumValue
            let tempPosition = (tempProgress * width) - sliderConfig.knobRadius
            knobPosition = tempPosition > 0 ? tempPosition : 0
        }
    }
    
    func calculateStep(xLocation: CGFloat) {
        let tempProgress = xLocation/width
        if tempProgress >= 0 && tempProgress <= 1 {
            var roundedProgress = (tempProgress * (sliderConfig.maximumValue - sliderConfig.minimumValue)) + sliderConfig.minimumValue
            roundedProgress = roundedProgress.rounded()
            progress = roundedProgress
            
            let updatedTempProgress = (roundedProgress - sliderConfig.minimumValue) / (sliderConfig.maximumValue - sliderConfig.minimumValue)
            knobPosition = updatedTempProgress == 0 ? 0 : (updatedTempProgress * width) - sliderConfig.knobRadius
        }
    }
}

struct FanSliderConfig {
    let minimumValue: CGFloat = 1.0
    let maximumValue: CGFloat = 100.0
    let knobRadius: CGFloat = 14
}

struct KnobView: View {
    let radius: CGFloat
    var body: some View {
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
                .frame(width: radius * 2, height: radius * 2)
            
            Circle()
                .fill(.musicProgressBar)
                .frame(width: 4, height: 4)
        }
    }
}

#Preview {
    ZStack {
        Color.white.opacity(0.1)
        FanSliderView()
            .padding()
    }
}
