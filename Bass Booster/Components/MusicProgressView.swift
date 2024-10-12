//
//  MusicProgressView.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 29.09.2024.
//

import SwiftUI

struct MusicProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ProgressView(value: 0.5)
                    .tint(.musicProgressBar)
            }
        }
    }
}

#Preview {
    MusicProgressView(progress: 0.3)
}
