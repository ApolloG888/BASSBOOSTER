// MainTabView.swift
import SwiftUI
import BottomSheet

struct MainTabView: View {
    @State private var selectedIndex = 0
    @State private var expandSheet = false
    @Namespace private var animation
    @State private var documentPickerManager: DocumentPickerManager?
    
    // Инициализируем общий ViewModel
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            tabView
            downView
                .ignoresSafeArea(.keyboard)
            
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
            switchablePositions: [
                .dynamic
            ]) {
                if !viewModel.isPlaylistList {
                    VStack(alignment: .leading) {
                        Button {
                            guard let selectedMusicFile = viewModel.selectedMusicFile else {
                                viewModel.hideBottomSheet()
                                return
                            }
                            // Открываем окно для переименования
                            viewModel.requestRenameSong(selectedMusicFile)
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Rename")
                                Spacer()
                            }
                        }
                        .padding(.vertical, 8)
                        
                        if viewModel.isInGeneralPlaylist {
                            Button {
                                guard let selectedMusicFile = viewModel.selectedMusicFile else {
                                    viewModel.hideBottomSheet()
                                    return
                                }
                                // Запросить добавление песни в плейлист
                                viewModel.requestAddToPlaylist(selectedMusicFile)
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                    Text("Add to Playlist")
                                    Spacer()
                                }
                            }
                            .padding(.vertical, 8)
                        } else {
                            Button {
                                guard let selectedMusicFile = viewModel.selectedMusicFile else {
                                    viewModel.hideBottomSheet()
                                    return
                                }
                                // Удаляем песню из текущего плейлиста
                                if let selectedPlaylist = viewModel.selectedPlaylist {
                                    viewModel.removeSongFromPlaylist(selectedMusicFile, from: selectedPlaylist)
                                }
                                viewModel.hideBottomSheet()
                            } label: {
                                HStack {
                                    Image(systemName: "minus.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                    Text("Remove from Playlist")
                                    Spacer()
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Button {
                            guard let selectedMusicFile = viewModel.selectedMusicFile else {
                                viewModel.hideBottomSheet()
                                return
                            }
                            // Запрашиваем подтверждение удаления песни
                            viewModel.requestDeleteSong(selectedMusicFile)
                            viewModel.hideBottomSheet()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Delete")
                                Spacer()
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white)
                    .padding()
                    .padding(.top, 30)
                } else {
                    // Отображение списка плейлистов
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
                            // Отмена выбора плейлиста
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
            .enableTapToDismiss()
            .enableBackgroundBlur(true)
            .enableSwipeToDismiss(true)
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
                DataManager.shared.handlePickedFiles(urls: urls)
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

#Preview {
    MainTabView()
}
