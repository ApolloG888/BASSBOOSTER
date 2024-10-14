import SwiftUI

struct MusicProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ProgressView(value: progress)
                    .tint(.musicProgressBar)
            }
        }
    }
}

#Preview {
    MusicProgressView(progress: 0.3)
}
