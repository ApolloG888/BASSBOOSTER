//
//  MusicView.swift
//  Music App
//
//  Created by Gurjot Singh on 28/10/23.
//

import SwiftUI

struct MusicImage: Identifiable {
    let id = UUID()
    let image: Image
}

struct MusicView: View {
    
    @EnvironmentObject var viewModel: MusicViewModel
    
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    
    // View Properties
    @State private var animateContent: Bool = false
    @State private var offsetY: CGFloat = 0
    @State var musicProgress = 0.1
    @State var state: SongState
    
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let safeArea = geometry.safeAreaInsets
            
            ZStack {
                RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous)
                    .fill(.black)
                    .overlay {
                        Rectangle()
                            .opacity(animateContent ? 1 : 0)
                    }
                    .overlay(alignment: .top) {
                        MusicInfo(expandSheet: $expandSheet, state: .play, animation: animation)
                            .allowsHitTesting(false)
                            .opacity(animateContent ? 0 : 1)
                    }
                    .matchedGeometryEffect(id: "BACKGROUNDVIEW", in: animation)
                
                VStack {
                    HStack {
                        Image(.downElipse)
                            .imageScale(.large)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.36)) {
                                    viewModel.isExpandedSheet = false
                                    animateContent = false
                                }
                            }
                        
                        Spacer()
                        
                        Image(.more)
                            .imageScale(.large)
                    }
                    .padding(.horizontal)
                    .padding(.top, 80)
                    
                    Text(viewModel.currentSong?.name ?? "Unknown")
                    
                 VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.currentSong?.name ?? "Unknown")
                        .font(.quicksand(size: 20))
                        .foregroundStyle(.white)
                    Text(viewModel.currentSong?.artist ?? "Unknown Artist")
                        .font(.quicksand(size: 14))
                        .foregroundStyle(.musicPlayerAuthor)
                }

                    Spacer()
                    
                    HStack {
                        CustomButton(state: .equalizer, action: {})
                        CustomButton(state: .booster, action: {})
                        CustomButton(state: .volume, action: {})
                    }
                    .padding(.bottom, 24)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(viewModel.currentSong?.name ?? "Unknown")")
                                .font(.quicksand(size: 20))
                                .foregroundStyle(.white)
                            Text("\(viewModel.currentSong?.artist ?? "Unknown Artist")")
                                .font(.quicksand(size: 14))
                                .foregroundStyle(.musicPlayerAuthor)
                        }
                        .padding(.bottom, 24)
                        Spacer()
                    }
                    
                    FanSlider(progress: viewModel.playbackProgress, width: UIScreen.main.bounds.width - 40)
                        .frame(height: 10)
                        .padding(.bottom, 16)
                    
                    PlayerView(size)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, safeArea.bottom + 20)
                        .offset(y: animateContent ? 0 : size.height)
                }
                .padding(.horizontal, 25)
                .appGradientBackground()
            }
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let tranlationY = value.translation.height
                        offsetY = (tranlationY > 0 ? tranlationY : 0)
                    }).onEnded({ value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if offsetY > size.height * 0.4 {
                                expandSheet = false
                                animateContent = false
                            } else {
                                offsetY = .zero
                            }
                        }
                    })
            )
            .ignoresSafeArea(.container, edges: .all)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.35)) {
                    animateContent = true
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    @ViewBuilder
    func PlayerView(_ mainSize: CGSize) -> some View {
        HStack(alignment: .center) {
            Button(action: {
               // $viewModel.shuffleToggle
            }) {
                Image(.shuffle)
                    .imageScale(.medium)
            }
            
            Spacer()

            Button(action: {
                viewModel.previousSong()
            }) {
                Image(.previous)
                    .imageScale(.medium)
            }
            
            Spacer()

            Button(action: {
                viewModel.playPauseMusic()
            }) {
                (viewModel.isPlaying ? Image(.pausee) : Image(.play))
                    .imageScale(.large)
                    .padding()
                    .background(.musicProgressBar)
                    .clipShape(Circle())
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.black)
                    .shadow(color: Color.white.opacity(0.8), radius: 10, x: 0, y: 0)
            }
            
            Spacer()

            Button(action: {
                viewModel.nextSong()
            }) {
                Image(.next)
                    .imageScale(.medium)
            }
            
            Spacer()

            Button(action: {
               // viewModel.repeatToggle()
            }) {
                Image(.repeate)
                    .imageScale(.medium)
            }
        }
        .padding()
    }
}

#Preview {
    MainTabView()
}

extension View {
    var deviceCornerRadius: CGFloat {
        let key = "_displayCornerRadius"
        if let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen {
            if let cornerRadius = screen.value(forKey: key) as? CGFloat {
                return cornerRadius
            }
            
            return 0
        }
        return 0
    }
}
