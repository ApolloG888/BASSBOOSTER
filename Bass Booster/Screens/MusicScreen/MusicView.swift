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
    @State var value = 11.0
    @State var state: SongState
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous)
                    .fill(.black)
                    .overlay {
                        Rectangle()
                        // I forget to start recording ;) so please check and change gray to black
                            .fill(.gray)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .overlay(alignment: .top) {
                        MusicInfo(expandSheet: $expandSheet, state: .play, animation: animation)
                            .allowsHitTesting(false)
                        // Here first when animateContent is true then musicInfo is hide and if animatecontent is false the musicInfo is visible
                            .opacity(animateContent ? 0 : 1)
                    }
                    .matchedGeometryEffect(id: "BACKGROUNDVIEW", in: animation)
                    

                VStack(spacing: 10) {
                    HStack(alignment: .top) {
                        Image(systemName: "chevron.down")
                            .imageScale(.large)
                            .onTapGesture {
                                expandSheet = false
                                animateContent = false
                            }
                                            
                        Spacer()
                        
                        VStack(alignment: .center, content: {
                            Text("Playlist from album")
                                .opacity(0.5)
                                .font(.caption)
                            Text("Top Hits")
                                .font(.title2)
                        })
                        
                        Spacer()
                        
                        Image(systemName: "ellipsis")
                            .imageScale(.large)

                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 80)
                    
                    GeometryReader {
                        let size = $0.size
                        Image("music 1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: animateContent ? 30 : 60, style: .continuous))
                    }
                    .matchedGeometryEffect(id: "SONGCOVER", in: animation)
                    .frame(height: size.width - 50)
                    .padding(.vertical, size.height < 700 ? 30 : 40)
                    
                
                PlayerView(size)
                    .offset(y: animateContent ? 0 : size.height)
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .top)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.36)) {
                        expandSheet = false
                        animateContent = false
                    }
                }
            }
            .contentShape(Rectangle())
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
            ).ignoresSafeArea(.container, edges: .all)
                        
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear() {
            withAnimation(.easeInOut(duration: 0.35)) {
                animateContent = true
            }
        }
        
    }
    
    @ViewBuilder
    func PlayerView(_ mainSize: CGSize) -> some View {
        GeometryReader {
            let size = $0.size
            
            HStack(alignment: .center) {
                Button(action: {
                    // Действие при нажатии на shuffle
                }) {
                    Image(.shuffle)
                        .imageScale(.medium)
                }
                
                Spacer()
                
                Button(action: {
                    // Действие при нажатии на previous
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
                        .frame(width: 30,height: 30)
                        .foregroundStyle(Color.black)
                        .shadow(color: Color.white.opacity(0.8), radius: 10, x: 0, y: 0)
                }
                
                Spacer()
                
                Button(action: {
                    // Действие при нажатии на next
                }) {
                    Image(.next)
                        .imageScale(.medium)
                }
                
                Spacer()
                
                Button(action: {
                    // Действие при нажатии на repeat
                }) {
                    Image(.repeate)
                        .imageScale(.medium)
                }
            }

        }
    }
}

#Preview {
    MainTabView()
}


// Extension For Corner Radius
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
