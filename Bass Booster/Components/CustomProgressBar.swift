import SwiftUI

struct FanSlider: View {
    @Binding var progress: Double
    let sliderConfig = FanSliderConfig()
    
    @State private var draggingProgress: Double? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height: CGFloat = 30 // Fixed height for the slider
            
            ZStack(alignment: .leading) {
                // Background Slider Track
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.musicPlayerSlider)
                    .frame(height: 7.5)
                
                // Progress Fill
                RoundedRectangle(cornerRadius: 5)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.placeholderYellow,
                            Color.placeholderPlayerYellow2
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: CGFloat(currentProgress()) * width, height: 6)
                
                // Knob
                KnobView(type: .constant(.bass), radius: sliderConfig.knobRadius)
                    .offset(x: CGFloat(currentProgress()) * width - sliderConfig.knobRadius)
                    .gesture(DragGesture(minimumDistance: 0)
                                .onChanged({ value in
                                    let newProgress = calculateProgressWidth(xLocation: value.location.x, width: width)
                                    draggingProgress = newProgress
                                })
                                .onEnded({ value in
                                    let finalProgress = calculateProgressWidth(xLocation: value.location.x, width: width)
                                    draggingProgress = nil
                                    progress = finalProgress // Update binding only on drag end
                                })
                    )
            }
            .frame(height: height)
        }
        .frame(height: 30) // Ensure the slider has a fixed height
    }
    
    // Calculate progress based on drag location, clamped between 0.0 and 1.0
    private func calculateProgressWidth(xLocation: CGFloat, width: CGFloat) -> Double {
        let tempProgress = min(max(Double(xLocation / width), 0.0), 1.0)
        return tempProgress
    }
    
    // Determine current progress (draggingProgress takes precedence if dragging)
    private func currentProgress() -> Double {
        return draggingProgress ?? progress
    }
}

struct FanSliderConfig {
    let knobRadius: CGFloat = 14
}

struct KnobView: View {
    @Binding var type: SliderType
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
                .fill(type == .bass || type == .volume ? Color.musicProgressBar : Color.blueIndicaor)
                .frame(width: 4, height: 4)
        }
    }
}

//struct FanSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        FanSlider(progress: .constant(0.5))
//            .frame(width: 300, height: 30)
//            .padding()
//    }
//}
