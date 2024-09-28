//
//  MusicInfo.swift
//  Music App
//
//  Created by Gurjot Singh on 28/10/23.
//

import SwiftUI

enum SongState {
    case play
    case pause
    
    var image: Image {
        switch self {
        case .play:
            Image(.play)
        case .pause:
            Image(.pausee)
        }
    }
    
    mutating func toggle() {
        if self == .pause {
            self = .play
        } else {
            self = .pause
        }
    }
}

struct MusicInfo: View {
    
    @Binding var expandSheet: Bool
    @State var state: SongState
    var animation: Namespace.ID
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ZStack {
                    if !expandSheet {
                        GeometryReader {
                            let size = $0.size
                            Image(.mockMusic)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                            }
                        .matchedGeometryEffect(id: "SONGCOVER", in: animation)
                    }
                }
                .frame(width: 55, height: 55)
                
                VStack {
                    Text("The Chain - 2004 Remaster")
                    Text("The Chain - 2004 Remaster")
                       
                }
                .font(.sfProText(size: 14))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .lineLimit(1)
                
                Spacer()
                
                Button {
                    state.toggle()
                } label: {
                    state.image
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(height: 20)
                }
            }
            .foregroundStyle(.blue)
            .padding(.horizontal,20)
            .padding(.bottom)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    expandSheet = true
                }
        }
            MusicProgressView(progress: 0.5)
        }
    }
}

#Preview {
    MainTabView()
}


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
