//
//  PlayerSelectionButton.swift
//  Bass Booster
//
//  Created by Mac Book Air M1 on 13.10.2024.
//

import SwiftUI

enum ButtonState {
    case equalizer
    case booster
    case volume
    
    var title: String {
        switch self {
        case .equalizer:
            return "Equalizer"
        case .booster:
            return "Booster"
        case .volume:
            return "Volume"
        }
    }
    
    var icon: Image {
        switch self {
        case .equalizer:
            return Image(.equalixer)
        case .booster:
            return Image(.music)
        case .volume:
            return Image(.volume)
        }
    }
}

struct CustomButton: View {
    var state: ButtonState
    var action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                action()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.musicInfoColor)
                        .frame(height: 54)
                    VStack(spacing: 6) {
                        state.icon
                            .foregroundColor(.tabBarSelected)
                            .padding(.top, 8)
                            .padding(.horizontal, 30)
                            
                        Text(state.title)
                            .foregroundColor(.white)
                            .font(.quicksand(size: 12))
                            .fontWeight(.semibold)
                            .padding(.bottom,4)
                    }
                    .frame(maxWidth: .infinity)
                    
                }
            }
        }
    }
}

struct ContentsView: View {
    var body: some View {
        HStack {
            CustomButton(state: .equalizer, action: {})
            CustomButton(state: .booster, action: {})
            CustomButton(state: .volume, action: {})
        }
    }
}

struct ContentsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentsView()
    }
}
