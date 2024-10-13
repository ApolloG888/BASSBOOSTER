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
    @EnvironmentObject var viewModel: MusicViewModel
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
                .frame(width: 43, height: 43)
                .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.currentSong?.name ?? "Unknown")
                        .foregroundStyle(.white)
                        .font(.helvetica(type: .regular400, size: 14))
                    Text(viewModel.currentSong?.artist ?? "Unknown Artist")
                        .foregroundStyle(.musicInfoSubColor)
                        .font(.helvetica(type: .medium500, size: 14))
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .lineLimit(1)
                
                Spacer()
                
                Button {
                    viewModel.playPauseMusic()
                } label: {
                    (viewModel.isPlaying ? Image(.pausee) : Image(.play))
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(height: 20)
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal,20)
            .padding(.bottom, 12)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.isExpandedSheet = true
                }
            }
            MusicProgressView(progress: viewModel.playbackProgress)
        }
    }
}

#Preview {
    MainTabView()
}



