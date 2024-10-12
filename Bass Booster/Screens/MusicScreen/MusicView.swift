//
//  MusicView.swift
//  Music App
//
//  Created by Gurjot Singh on 28/10/23.
//

import SwiftUI

struct MusicView: View {
    
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    
    // View Properties
    @State private var animateContent: Bool = false
    @State private var offsetY: CGFloat = 0
    @State var musicProgress = 0.1
    @State var state: SongState
    @State var songName: String
    @State var songAuthor: String
    @State var music: [MusicFileEntity] = []
    
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
                                    expandSheet = false
                                    animateContent = false
                                }
                            }
                        
                        Spacer()
                        
                        Image(.more)
                            .imageScale(.large)
                    }
                    .padding(.horizontal)
                    .padding(.top, 80)
                    
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 20) {
//                            ForEach(1..4) { album in
//                                Image(.home)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 200, height: 200)
//                                    .cornerRadius(15)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 15)
//                                            .stroke(Color.purple, lineWidth: 2) // Обводка фиолетового цвета
//                                    )
//                                    .shadow(radius: 5)
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                    }
//                    
                    
                    // нечем проверить эту шляпу ебаную на картинки музыки
                    
                    
                    HStack {
                        CustomButton(state: .equalizer, action: {})
                        CustomButton(state: .booster, action: {})
                        CustomButton(state: .volume, action: {})
                    }
                    .padding(.bottom, 32)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(songName)")
                                .font(.sfProDisplay(type: .bold700, size: 20))
                                .foregroundStyle(.white)
                            Text("\(songAuthor)")
                                .font(.helvetica(type: .medium500, size: 14))
                                .foregroundStyle(.musicPlayerAuthor)
                        }
                        .padding(.bottom, 32)
                        Spacer()
                    }
                    
                    CustomProgressBar(value: $musicProgress)
                        .frame(height: 20)
                        .shadow(radius: 6)

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
            }) {
                Image(.shuffle)
                    .imageScale(.medium)
            }
            
            Spacer()
            
            Button(action: {
            }) {
                Image(.previous)
                    .imageScale(.medium)
            }
            
            Spacer()
            
            Button(action: {
                state.toggle()
            }) {
                state.image
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
                
            }) {
                Image(.next)
                    .imageScale(.medium)
            }
            
            Spacer()
            
            Button(action: {
                
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
