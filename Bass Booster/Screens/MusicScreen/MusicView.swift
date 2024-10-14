import SwiftUI

struct MusicView: View {
    
    @EnvironmentObject var viewModel: MusicViewModel
    
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    
    // View Properties
    @State private var animateContent: Bool = false
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let safeArea = geometry.safeAreaInsets
            
            ZStack {
                RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous)
                    .fill(Color.black)
                    .overlay {
                        Rectangle()
                            .opacity(animateContent ? 1 : 0)
                    }
                    .overlay(alignment: .top) {
                        MusicInfo(expandSheet: $expandSheet, animation: animation)
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
                            .onTapGesture {
                                guard let currentSong = viewModel.currentSong else { return }
                                viewModel.showBottomSheet(for: currentSong)
                            }
                    }
                    .padding(.horizontal)
                    .padding(.top, 80)
                    
                    Spacer()
                    
                    if let albumArt = viewModel.currentSong?.albumArt, let image = UIImage(data: albumArt) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 336, height: 336)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        Image(.musicNote)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.playlistGrey)
                            .frame(width: 336, height: 336)
                            .background(
                                RoundedRectangle(cornerRadius: 19)
                                    .fill(Color.customBlack)
                            )
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
                    
                    FanSlider(progress: Binding(
                        get: { viewModel.playbackProgress },
                        set: { newValue in
                            viewModel.seek(to: newValue)
                        }
                    ))
                    .frame(height: 30)
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
                        let translationY = value.translation.height
                        offsetY = (translationY > 0 ? translationY : 0)
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
                viewModel.shuffleToggle()
            }) {
                Image(viewModel.shuffleMode ? .shuffleSelected : .shuffle)
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
                    .background(Color.musicProgressBar)
                    .clipShape(Circle())
                    .frame(width: 60, height: 60) // Increased size for better touch area
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
                viewModel.repeatToggle()
            }) {
                Image(viewModel.isRepeatOn ? .repeateSelected : .repeate)
                    .imageScale(.medium)
            }
        }
        .padding()
    }
}

struct MusicView_Previews: PreviewProvider {
    @Namespace static var animation
    static var previews: some View {
        MusicView(expandSheet: .constant(true), animation: animation)
            .environmentObject(MusicViewModel())
    }
}
