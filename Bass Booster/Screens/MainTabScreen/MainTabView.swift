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
                viewModel.bottomSheetPosition
            ]) {
                VStack {
                    Button {
                        guard let selectedMusicFile = viewModel.selectedMusicFile else {
                            viewModel.bottomSheetPosition = .hidden
                            return
                        }
                        viewModel.deleteMusicFileEntity(selectedMusicFile)
                        viewModel.bottomSheetPosition = .hidden
                    } label: {
                        Text("Delete")
                    }
                }
            }
            .enableTapToDismiss()
            .showDragIndicator(false)
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
