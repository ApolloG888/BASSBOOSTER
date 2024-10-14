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
            overlayViews
        }
        .hideNavigationBar()
        .background(Color.customBlack)
        .overlay {
            if viewModel.isExpandedSheet {
                MusicView(
                    expandSheet: $viewModel.isExpandedSheet,
                    animation: animation
                )
                .environmentObject(viewModel)
            }
        }
        .overlay {
            if viewModel.isShowSubscriptionOverlay {
                SubscriptionAssembly().build(isPresented: $viewModel.isShowSubscriptionOverlay)
                    .transition(.opacity)
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
            .onDismiss {
                viewModel.isVolumeSheet = false
                viewModel.isBoosterSheet = false
            }
    }
}

// MARK: - Tab View

extension MainTabView {
    var tabView: some View {
        TabView(selection: $selectedIndex) {
            HomeView().environmentObject(viewModel)
                .tabItem {
                    TabBarButton(
                        icon: selectedIndex == 0 ? "homeSelected" : "home",
                        isSelected: selectedIndex == 0,
                        label: selectedIndex == 0 ? "" : "home"
                    ) {
                        selectedIndex = 0
                    }
                }
                .tag(0)
            
            ModesView().environmentObject(viewModel)
                .tabItem {
                    TabBarButton(
                        icon: selectedIndex == 1 ? "modesSelected" : "modes",
                        isSelected: selectedIndex == 1,
                        label: selectedIndex == 1 ? "" : "Modes"
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
            
            FeaturesView().environmentObject(viewModel)
                .tabItem {
                    TabBarButton(
                        icon: selectedIndex == 3 ? "featuresSelected" : "features",
                        isSelected: selectedIndex == 3,
                        label: selectedIndex == 3 ? "" : "Features"
                    ) {
                        selectedIndex = 3
                    }
                }
                .tag(3)
            
            SettingsView().environmentObject(viewModel)
                .tabItem {
                    TabBarButton(
                        icon: selectedIndex == 4 ? "settingsSelected" : "settings",
                        isSelected: selectedIndex == 4,
                        label: selectedIndex == 4 ? "" : "Settings"
                    ) {
                        selectedIndex = 4
                    }
                }
                .tag(4)
        }
        .accentColor(.musicProgressBar)
    }
}

// MARK: - Down View

extension MainTabView {
    var downView: some View {
        VStack {
            Spacer()
            if viewModel.currentSong != nil {
                customBottomSheet()
            }
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
        if viewModel.canAddSong() {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                let manager = DocumentPickerManager { urls in
                    viewModel.handlePickedFiles(urls: urls)
                }
                manager.showDocumentPicker()
                self.documentPickerManager = manager
            }
        }
    }
    
    @ViewBuilder
    func customBottomSheet() -> some View {
        ZStack {
            if viewModel.isExpandedSheet {
                Rectangle()
                    .fill(.musicInfoColor)
            } else {
                Rectangle()
                    .fill(Color.musicInfoColor)
                    .overlay {
                        MusicInfo(
                            expandSheet: $viewModel.isExpandedSheet,
                            animation: animation
                        )
                        .environmentObject(viewModel)
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
        if viewModel.isVolumeSheet {
            VStack {
                CircularProgressBar(type: .constant(.volume))
                    .padding(.top, 72)
                
                VStack {
                    Text("Pan")
                        .foregroundStyle(.white)
                        .font(.quicksand(type: .bold700, size: 20))
                    
                    BidirectionalSlider(value: 34)
                }
                .padding(.top, 80)
            }
            .padding(.top, 30)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        } else if viewModel.isBoosterSheet {
            VStack {
                CircularProgressBar(type: $viewModel.sheetState)
                
                CustomToggleSwitch(selectedType: $viewModel.sheetState)
                    .padding(.top, 80)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        } else if viewModel.isQualizerSheet {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            // reset хуй знает как пока
                        } label: {
                            Image(.resetPreset)
                        }
                    }
                    .padding(.trailing, 10)
                    
                    HStack {
                        Text("Presets")
                            .foregroundStyle(.white)
                            .font(.sfProDisplay(type: .regular400, size: 16))
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        ForEach(MusicPreset.allCases, id: \.self) { preset in
                            PresetButton(preset: Preset(id: ObjectIdentifier(Preset.self), name: preset.rawValue),
                                         isSelected: viewModel.selectedPreset?.name == preset.rawValue)
                            .onTapGesture {
                                viewModel.selectedPreset = Preset(id: ObjectIdentifier(Preset.self), name: preset.rawValue)
                            }
                        }
                        Spacer()
                    }
                    
                    // Custom Presets
                    HStack {
                        Text("Custom Presets")
                            .font(.sfProDisplay(type: .regular400, size: 16))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.top)
                    
                    HStack(spacing: 12) {
                        AddButton(isSelected: viewModel.customPresets.isEmpty) {
                            viewModel.isShowingCreatePresetView = true
                        }
                        ForEach(viewModel.customPresets) { customPreset in
                            PresetButton(preset: customPreset, isSelected: viewModel.selectedPreset?.id == customPreset.id)
                                .onTapGesture {
                                    viewModel.selectedPreset = customPreset
                                }
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    HStack {
                        VStack(spacing: 64) {
                            Text("12")
                            Text("0")
                            Text("-12")
                        }
                        .font(.sfProDisplay(type: .bold700, size: 12))
                        .foregroundStyle(.gray)
                        
                        VStack {
                            HStack(spacing: 0) {
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(90))
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(270))
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(90))
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(270))
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(90))
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(270))
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(90))
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(270))
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(90))
                                BidirectionalSlider(value: 0, forPresetUsage: true)
                                    .rotationEffect(.degrees(270))
                            }
                            .padding(.top, 40)
                            .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                Text("32")
                                Text("64")
                                Text("125")
                                Text("250")
                                Text("500")
                                Text("1k")
                                Text("2k")
                                Text("4k")
                                Text("8k")
                                Text("12k")
                            }
                            .font(.sfProDisplay(type: .bold700, size: 12))
                            .foregroundStyle(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                if viewModel.isShowingCreatePresetView {
                    CreatePresetView(isPresented: $viewModel.isShowingCreatePresetView, onSave: { newPresetName in
                        let newPreset = Preset(id: ObjectIdentifier(Preset.self), name: newPresetName)
                        viewModel.customPresets.append(newPreset)
                        viewModel.isShowingCreatePresetView = false
                    }, onCancel: {
                        viewModel.isShowingCreatePresetView = false
                    })
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        } else if !viewModel.isPlaylistList {
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
                            .padding(.vertical, 8)
                    }
                }
            }
            .font(.sfProText(type: .regular400, size: 16))
            .foregroundColor(.subProductPriceColor)
            .padding()
            .padding(.top, 20)
        } else if viewModel.isPlaylistList {
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
            viewModel.isExpandedSheet = false
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
            viewModel.isExpandedSheet = false
            viewModel.hideBottomSheet()
        }))
        return buttons
    }
}

// MARK: - Playlist Selection Content

extension MainTabView {
    @ViewBuilder
    func playlistSelectionContent() -> some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.playlists.indices, id: \.self) { index in
                        let playlist = viewModel.playlists[index]
                        Button(action: {
                            viewModel.addSongToSelectedPlaylist(playlist)
                        }) {
                            HStack {
                                Image(.musicNoteYellow)
                                Text("\(playlist.name ?? "Unknown playlist")")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                        }
                        
                        if index != viewModel.playlists.count - 1 {
                            RoundedRectangle(cornerRadius: 0)
                                .frame(height: 0.5)
                                .foregroundColor(Color.gray.opacity(0.4))
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding()
            }
            
            Button(action: {
                viewModel.isShowViewNewPlaylist = true
                viewModel.bottomSheetPosition = .hidden
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("New Playlist")
                }
                .font(.sfProDisplay(type: .bold700, size: 17))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.selectionButtonBaseColor)
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
    }
}

// MARK: - BottomSheet Button

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

// MARK: - OverlayViews

extension MainTabView {
    @ViewBuilder
    var overlayViews: some View {
        if viewModel.isLoading {
            loadingView
        }
        
        if viewModel.isShowViewNewPlaylist {
            newPlaylistOverlay
        }
        
        if viewModel.isShowDeleteSongView, let song = viewModel.songToDelete {
            deleteSongOverlay(song: song)
        }
        
        if viewModel.isShowRenameSongView, let song = viewModel.selectedMusicFile {
            renameSongOverlay(song: song)
        }
    }
    
    var loadingView: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .foregroundColor(.white)
                .scaleEffect(1.5)
        }
        .zIndex(2)
    }
    
    var newPlaylistOverlay: some View {
        NewPlaylistView(
            isPresented: $viewModel.isShowViewNewPlaylist,
            onSave: { name in
                viewModel.createNewPlaylist(name: name)
            },
            onCancel: {
                viewModel.cancelNewPlaylist()
            }
        )
        .zIndex(1)
    }
    
    func deleteSongOverlay(song: MusicFileEntity) -> some View {
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
        .zIndex(1)
    }
    
    func renameSongOverlay(song: MusicFileEntity) -> some View {
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

#Preview {
    MainTabView()
}
