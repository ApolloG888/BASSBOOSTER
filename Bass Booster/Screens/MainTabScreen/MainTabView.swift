// MainTabView.swift
import SwiftUI
import BottomSheet

struct MainTabView: View {
    @State private var selectedIndex = 0
    @State private var expandSheet = false
    @Namespace private var animation
    @State private var documentPickerManager: DocumentPickerManager?
    
    // Инициализируем общий ViewModel
    @StateObject var viewModel = MusicViewModel()
    
    var body: some View {
        ZStack {
            tabView
            downView
                .ignoresSafeArea(.keyboard)
            
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .scaleEffect(1.5)
                }
                .zIndex(2) // Устанавливаем более высокий zIndex
            }
            
            // Отображение NewPlaylistView
            if viewModel.isShowViewNewPlaylist {
                NewPlaylistView(
                    isPresented: $viewModel.isShowViewNewPlaylist,
                    onSave: { name in
                        viewModel.createNewPlaylist(name: name)
                    },
                    onCancel: {
                        viewModel.cancelNewPlaylist()
                    }
                )
                .zIndex(1) // Убедитесь, что этот вид выше других
            }
            
            // Отображение DeleteSongView
            if viewModel.isShowDeleteSongView, let song = viewModel.songToDelete {
                DeleteSongView(
                    isPresented: $viewModel.isShowDeleteSongView,
                    songName: song.name ?? "Unknown",
                    onConfirm: {
                        viewModel.confirmDeleteSong()
                    },
                    onCancel: {
                        viewModel.cancelDeleteSong()
                    }
                )
                .transition(.opacity)
                .zIndex(1) // Убедитесь, что этот вид выше других
            }
            
            if viewModel.isShowRenameSongView, let song = viewModel.selectedMusicFile {
                RenameSongView(
                    isPresented: $viewModel.isShowRenameSongView,
                    authorName: song.artist ?? "",
                    songName: song.name ?? "",
                    onSave: { newAuthor, newSongName in
                        viewModel.confirmRenameSong(newArtist: newAuthor, newSongName: newSongName)
                    },
                    onCancel: {
                        viewModel.cancelRenameSong()
                    }
                )
                .zIndex(1)
            }
        }
        .hideNavigationBar()
        .background(Color.customBlack)
        .overlay {
            if expandSheet {
                MusicView(expandSheet: $expandSheet, animation: animation)
            }
        }
        .bottomSheet(
            bottomSheetPosition: $viewModel.bottomSheetPosition,
            switchablePositions: [.dynamic]) {
                bottomSheetContent()
            }
            .enableTapToDismiss()
            .enableBackgroundBlur(true)
            .enableSwipeToDismiss(true)
            .customBackground(
                Color.bottomSheetColor
                    .cornerRadius(15)
            )
    }
}

// MARK: - Tab View

extension MainTabView {
    var tabView: some View {
        TabView(selection: $selectedIndex) {
            HomeView().environmentObject(viewModel)
                .tabItem {
                    TabBarButton(
                        icon: "Home",
                        isSelected: selectedIndex == 0,
                        label: "Home"
                    ) {
                        selectedIndex = 0
                    }
                }
                .tag(0)
            
            ModesAssembly().build()
                .tabItem {
                    TabBarButton(
                        icon: "modes",
                        isSelected: selectedIndex == 1,
                        label: "Modes"
                    ) {
                        selectedIndex = 1
                    }
                }
                .tag(1)
            
            Spacer()
                .tabItem {
                    EmptyView()
                }
                .tag(2)
            
            FeaturesAssembly().build()
                .tabItem {
                    TabBarButton(
                        icon: "features",
                        isSelected: selectedIndex == 3,
                        label: "Features"
                    ) {
                        selectedIndex = 3
                    }
                }
                .tag(3)
            
            SettingsAssembly().build()
                .tabItem {
                    TabBarButton(
                        icon: "settings",
                        isSelected: selectedIndex == 4,
                        label: "Settings"
                    ) {
                        selectedIndex = 4
                    }
                }
                .tag(4)
        }
    }
}

// MARK: - Down View

extension MainTabView {
    var downView: some View {
        VStack {
            Spacer()
            customBottomSheet()
            Button {
                presentDocumentPicker()
            } label: {
                addButtonGradient
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

// MARK: - AddButtonGradient

extension MainTabView {
    var addButtonGradient: some View {
        ZStack {
            Circle()
                .fill(plusButtonGradient())
                .frame(width: 56, height: 56)
                .overlay(
                    Circle()
                        .stroke(
                            plusButtonBorderGradient(),
                            lineWidth: 0.66
                        )
                )
            Image(systemName: "plus")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
        }
        .frame(width: 55, height: 55)
    }
}

// MARK: - Private Methods

extension MainTabView {
    func presentDocumentPicker() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            let manager = DocumentPickerManager { urls in
                viewModel.handlePickedFiles(urls: urls)
            }
            manager.showDocumentPicker()
            self.documentPickerManager = manager
        }
    }
    
    @ViewBuilder
    func customBottomSheet() -> some View {
        ZStack {
            if expandSheet {
                Rectangle()
                    .fill(Color.red)
            } else {
                Rectangle()
                    .fill(Color.musicInfoColor)
                    .overlay {
                        MusicInfo(expandSheet: $expandSheet, state: .pause, animation: animation)
                    }
                    .matchedGeometryEffect(id: "BACKGROUNDVIEW", in: animation)
            }
        }
        .appGradientBackground()
        .frame(height: 70)
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - BottomSheetContent

extension MainTabView {
    @ViewBuilder
    func bottomSheetContent() -> some View {
        if !viewModel.isPlaylistList {
            VStack(alignment: .leading) {
                let buttons = getBottomSheetButtons()
                let lastIndex = buttons.indices.last
                ForEach(buttons.indices, id: \.self) { index in
                    bottomSheetButton(
                        imageName: buttons[index].imageName,
                        text: buttons[index].text,
                        action: buttons[index].action
                    )
                    
                    if index != lastIndex {
                        RoundedRectangle(cornerRadius: 0)
                            .frame(maxWidth: .infinity, maxHeight: 0.5)
                            .foregroundStyle(.subProductPriceColor.opacity(0.4))
                    }
                }
            }
            .font(.sfProText(type: .regular400, size: 16))
            .foregroundColor(.subProductPriceColor)
            .padding()
            .padding(.top, 20)
        } else {
            playlistSelectionContent()
        }
    }
}

// MARK: - BottomSheetButtons

extension MainTabView {
    private func getBottomSheetButtons() -> [(imageName: String, text: String, action: () -> Void)] {
        var buttons: [(imageName: String, text: String, action: () -> Void)] = []
        
        buttons.append((imageName: "rename", text: "Rename", action: {
            guard let selectedMusicFile = viewModel.selectedMusicFile else {
                viewModel.hideBottomSheet()
                return
            }
            viewModel.requestRenameSong(selectedMusicFile)
        }))
        
        if viewModel.isInGeneralPlaylist {
            buttons.append((imageName: "addToPlaylist", text: "Add to Playlist", action: {
                guard let selectedMusicFile = viewModel.selectedMusicFile else {
                    viewModel.hideBottomSheet()
                    return
                }
                viewModel.requestAddToPlaylist(selectedMusicFile)
            }))
        } else {
            buttons.append((imageName: "Forward", text: "Remove from Playlist", action: {
                guard let selectedMusicFile = viewModel.selectedMusicFile else {
                    viewModel.hideBottomSheet()
                    return
                }
                if let selectedPlaylist = viewModel.selectedPlaylist {
                    viewModel.removeSongFromPlaylist(selectedMusicFile, from: selectedPlaylist)
                }
                viewModel.hideBottomSheet()
            }))
        }
        
        buttons.append((imageName: "delete", text: "Delete", action: {
            guard let selectedMusicFile = viewModel.selectedMusicFile else {
                viewModel.hideBottomSheet()
                return
            }
            viewModel.requestDeleteSong(selectedMusicFile)
            viewModel.hideBottomSheet()
        }))
        return buttons
    }
}

extension MainTabView {
    @ViewBuilder
    func playlistSelectionContent() -> some View {
        VStack(alignment: .leading) {
            Text("Select Playlist")
                .font(.headline)
                .padding(.top, 20)
                .padding(.horizontal, 20)
            
            List(viewModel.playlists) { playlist in
                Button(action: {
                    // Добавить песню в выбранный плейлист
                    viewModel.addSongToSelectedPlaylist(playlist)
                }) {
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundColor(.blue)
                        Text("\(playlist.name ?? "Unknown playlist")")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Button(action: {
                viewModel.isShowViewNewPlaylist = true
                viewModel.bottomSheetPosition = .hidden
            }) {
                Text("New Playlist")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .padding(.top, 10)
        }
    }
}

extension MainTabView {
    private func bottomSheetButton(
        imageName: String,
        text: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(text)
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MainTabView()
}
