import Sliders
import SwiftUI

struct CustomProgressBar: View {
    @Binding var value: Double
    
    var body: some View {
        ValueSlider(value: $value)
            .valueSliderStyle(
                HorizontalValueSliderStyle(
                    track:
                        HorizontalRangeTrack(
                            view: Capsule().foregroundColor(.musicPlayerSlider)
                            
                        )
                        .frame(height: 8), thumb: Image(.holder).offset(y: 4)))
    }
}

#Preview {
    ZStack {
        Color.white.opacity(0.1)
        //CustomProgressBar()
    }
}
